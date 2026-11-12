import io
import os
import threading
import logging
from typing import List, Dict, Any, Tuple, Optional
from PIL import Image

from app.config import settings
from app.models.crop_models import BoundingBox, DetectionItem

logger = logging.getLogger("chiptocrop.crop_disease_model")


class CropDiseaseModelService:
    """Singleton service for running CPU inference on Model 3 (Crop & Fruit Disease Detection).

    Classes:
      0: BANANA_ANTHRACNOSE
      1: MANGO_ANTHRACNOSE
      2: MANGO_STEM_END_ROT
      3: POTATO_BLACKSPOT_BRUISING
      4: POTATO_DRY_ROT_DISEASE
    """

    _instance: Optional["CropDiseaseModelService"] = None
    _init_lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._init_lock:
                if cls._instance is None:
                    cls._instance = super(CropDiseaseModelService, cls).__new__(cls)
                    cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if getattr(self, "_initialized", False):
            return
        self.model_path = settings.crop_disease_model_path
        self.conf_threshold = getattr(settings, "crop_disease_conf_threshold", 0.25)
        self.iou_threshold = getattr(settings, "crop_disease_iou_threshold", 0.45)
        self._model = None
        self._model_lock = threading.Lock()
        self._class_names: Dict[int, str] = {
            0: "BANANA_ANTHRACNOSE",
            1: "MANGO_ANTHRACNOSE",
            2: "MANGO_STEM_END_ROT",
            3: "POTATO_BLACKSPOT_BRUISING",
            4: "POTATO_DRY_ROT_DISEASE",
        }
        self._initialized = True
        logger.info(
            f"CropDiseaseModelService initialized (model lazy-loaded from {self.model_path})."
        )

    def is_model_file_present(self) -> bool:
        return os.path.isfile(self.model_path)

    def is_model_loaded(self) -> bool:
        return self._model is not None

    def get_class_names(self) -> Dict[int, str]:
        if self._model is not None:
            return dict(self._model.names)
        return self._class_names

    def _load_model_if_needed(self):
        """Thread-safe lazy loader for Crop Disease YOLO Model 3."""
        if self._model is not None:
            return

        with self._model_lock:
            if self._model is not None:
                return

            if not os.path.isfile(self.model_path):
                raise FileNotFoundError(
                    f"Crop Disease Model 3 file not found at: {self.model_path}."
                )

            logger.info(
                f"Lazy-loading Crop Disease Model 3 from {self.model_path} onto CPU..."
            )
            try:
                from ultralytics import YOLO

                model = YOLO(self.model_path)
                self._model = model
                self._class_names = dict(model.names)
                logger.info(
                    f"Crop Disease Model 3 loaded successfully on CPU. "
                    f"Number of classes: {len(self._class_names)}"
                )
            except Exception as e:
                logger.error(
                    f"Failed to load Crop Disease Model 3: {e}", exc_info=True
                )
                raise RuntimeError(f"Crop Disease Model 3 load failed: {str(e)}")

    @staticmethod
    def normalize_class_name(raw_name: str) -> Tuple[str, str, bool]:
        """Normalizes Model 3 class names into clean Crop and Condition strings.

        0: BANANA_ANTHRACNOSE        -> ('Banana', 'Anthracnose', False)
        1: MANGO_ANTHRACNOSE         -> ('Mango', 'Anthracnose', False)
        2: MANGO_STEM_END_ROT        -> ('Mango', 'Stem End Rot', False)
        3: POTATO_BLACKSPOT_BRUISING -> ('Potato', 'Blackspot Bruising', False)
        4: POTATO_DRY_ROT_DISEASE    -> ('Potato', 'Dry Rot', False)
        """
        upper = raw_name.strip().upper()
        if upper.startswith("BANANA_"):
            crop = "Banana"
            cond_raw = upper[len("BANANA_") :]
        elif upper.startswith("MANGO_"):
            crop = "Mango"
            cond_raw = upper[len("MANGO_") :]
        elif upper.startswith("POTATO_"):
            crop = "Potato"
            cond_raw = upper[len("POTATO_") :]
        else:
            parts = upper.split("_", 1)
            crop = parts[0].title()
            cond_raw = parts[1] if len(parts) > 1 else upper

        # Clean up specific condition names
        if "DRY_ROT" in cond_raw:
            condition = "Dry Rot"
        elif "BLACKSPOT" in cond_raw:
            condition = "Blackspot Bruising"
        elif "STEM_END_ROT" in cond_raw:
            condition = "Stem End Rot"
        elif "ANTHRACNOSE" in cond_raw:
            condition = "Anthracnose"
        else:
            condition = cond_raw.replace("_", " ").title()

        is_healthy = "HEALTHY" in cond_raw
        return crop, condition, is_healthy

    def validate_image_bytes(
        self, image_bytes: bytes, max_bytes: int = 15 * 1024 * 1024
    ) -> Image.Image:
        """Validates image size and decodes to RGB PIL Image."""
        if not image_bytes or len(image_bytes) == 0:
            raise ValueError("Uploaded image file is empty.")

        if len(image_bytes) > max_bytes:
            raise ValueError(
                f"Image file exceeds maximum allowable size of {max_bytes // (1024*1024)}MB."
            )

        try:
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()
            image = Image.open(io.BytesIO(image_bytes))
            if image.mode != "RGB":
                image = image.convert("RGB")
            return image
        except Exception as e:
            raise ValueError(
                f"Invalid or corrupted image format. Supported formats: JPEG, PNG, WEBP. Error: {str(e)}"
            )

    def predict(
        self,
        image_bytes: bytes,
        conf_threshold: Optional[float] = None,
        iou_threshold: Optional[float] = None,
    ) -> Dict[str, Any]:
        """Runs CPU inference on an input image using Model 3.

        Returns:
          - image_width, image_height
          - list of DetectionItem
          - top_detection (highest confidence detection)
        """
        self._load_model_if_needed()

        image = self.validate_image_bytes(image_bytes)
        img_width, img_height = image.size

        conf = conf_threshold if conf_threshold is not None else self.conf_threshold
        iou = iou_threshold if iou_threshold is not None else self.iou_threshold

        with self._model_lock:
            results = self._model.predict(
                source=image, conf=conf, iou=iou, device="cpu", verbose=False
            )

        detections: List[DetectionItem] = []
        if results and len(results) > 0:
            result = results[0]
            boxes = result.boxes
            if boxes is not None and len(boxes) > 0:
                for box in boxes:
                    cls_id = int(box.cls[0].item())
                    conf_val = float(box.conf[0].item())
                    raw_cls_name = self._class_names.get(
                        cls_id, f"CLASS_{cls_id}"
                    )
                    crop, condition, is_healthy = self.normalize_class_name(
                        raw_cls_name
                    )

                    coords = box.xyxy[0].tolist()
                    x1, y1, x2, y2 = coords[0], coords[1], coords[2], coords[3]

                    norm_box = BoundingBox(
                        x1=max(0.0, min(1.0, x1 / img_width)),
                        y1=max(0.0, min(1.0, y1 / img_height)),
                        x2=max(0.0, min(1.0, x2 / img_width)),
                        y2=max(0.0, min(1.0, y2 / img_height)),
                    )

                    abs_box = BoundingBox(x1=x1, y1=y1, x2=x2, y2=y2)

                    detections.append(
                        DetectionItem(
                            class_name=raw_cls_name,
                            class_id=cls_id,
                            confidence=round(conf_val, 4),
                            crop=crop,
                            condition=condition,
                            is_healthy=is_healthy,
                            box=abs_box,
                            box_normalized=norm_box,
                        )
                    )

        detections.sort(key=lambda d: d.confidence, reverse=True)
        top_detection = detections[0] if detections else None

        return {
            "image_width": img_width,
            "image_height": img_height,
            "detections": detections,
            "top_detection": top_detection,
        }

