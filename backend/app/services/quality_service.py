import io
import os
import threading
import logging
from typing import List, Dict, Any, Tuple, Optional
from PIL import Image

from app.config import settings
from app.models.crop_models import BoundingBox, QualityDetectionItem

logger = logging.getLogger("chiptocrop.quality")


class QualityService:
    """Singleton service for running CPU inference on the Crop Quality YOLO model

    (Fresh vs Rotten detection for Mango, Potato, Tomato, Banana).
    """

    _instance: Optional["QualityService"] = None
    _init_lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._init_lock:
                if cls._instance is None:
                    cls._instance = super(QualityService, cls).__new__(cls)
                    cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if getattr(self, "_initialized", False):
            return
        self.model_path = settings.quality_model_path
        self.conf_threshold = getattr(settings, "quality_conf_threshold", 0.25)
        self.iou_threshold = getattr(settings, "quality_iou_threshold", 0.45)
        self._model = None
        self._model_lock = threading.Lock()
        self._class_names: Dict[int, str] = {
            0: "fresh_mango",
            1: "fresh_potato",
            2: "fresh_red_tomato",
            3: "fresh_yellow_banana",
            4: "rotten_banana",
            5: "rotten_mango",
            6: "rotten_potato",
            7: "rotten_tomato",
        }
        self._initialized = True
        logger.info(f"QualityService initialized (model lazy-loaded from {self.model_path}).")

    def is_model_file_present(self) -> bool:
        return os.path.isfile(self.model_path)

    def is_model_loaded(self) -> bool:
        return self._model is not None

    def get_class_names(self) -> Dict[int, str]:
        if self._model is not None:
            return dict(self._model.names)
        return self._class_names

    def _load_model_if_needed(self):
        """Thread-safe lazy loader for Quality YOLO model."""
        if self._model is not None:
            return

        with self._model_lock:
            if self._model is not None:
                return

            if not os.path.isfile(self.model_path):
                raise FileNotFoundError(
                    f"Quality model not found at expected path: {self.model_path}. "
                    "Ensure best.pt is present in models/best.pt."
                )

            logger.info(f"Lazy-loading Quality YOLO model from: {self.model_path} onto CPU...")
            try:
                from ultralytics import YOLO

                model = YOLO(self.model_path)
                self._model = model
                if hasattr(model, "names") and model.names:
                    self._class_names = dict(model.names)
                logger.info(
                    f"Quality YOLO model loaded successfully on CPU. "
                    f"Number of classes: {len(self._class_names)}"
                )
            except Exception as e:
                logger.error(f"Failed to load Quality YOLO model: {e}", exc_info=True)
                raise RuntimeError(f"Quality YOLO model load failed: {str(e)}")

    @staticmethod
    def normalize_quality_class(raw_name: str) -> Tuple[str, str, bool, str]:
        """Maps dataset class names to Crop, QualityStatus, IsFresh, and GradeLabel.

        Examples:
          'fresh_mango'        -> ('Mango', 'Fresh', True, 'Grade A (Prime Quality)')
          'fresh_red_tomato'   -> ('Tomato', 'Fresh', True, 'Grade A (Prime Quality)')
          'fresh_yellow_banana'-> ('Banana', 'Fresh', True, 'Grade A (Prime Quality)')
          'fresh_potato'       -> ('Potato', 'Fresh', True, 'Grade A (Prime Quality)')
          'rotten_mango'       -> ('Mango', 'Rotten', False, 'Damaged / Spoilage Detected')
          'rotten_tomato'      -> ('Tomato', 'Rotten', False, 'Damaged / Spoilage Detected')
          'rotten_potato'      -> ('Potato', 'Rotten', False, 'Damaged / Spoilage Detected')
          'rotten_banana'      -> ('Banana', 'Rotten', False, 'Damaged / Spoilage Detected')
        """
        clean = raw_name.strip().lower()
        is_fresh = "fresh" in clean
        quality_status = "Fresh" if is_fresh else "Rotten"
        grade_label = "Grade A (Prime Quality)" if is_fresh else "Damaged / Spoilage Detected"

        if "mango" in clean:
            crop = "Mango"
        elif "potato" in clean:
            crop = "Potato"
        elif "tomato" in clean:
            crop = "Tomato"
        elif "banana" in clean:
            crop = "Banana"
        else:
            crop = clean.replace("fresh_", "").replace("rotten_", "").replace("_", " ").title()

        return crop, quality_status, is_fresh, grade_label

    def validate_image_bytes(self, image_bytes: bytes, max_bytes: int = 15 * 1024 * 1024) -> Image.Image:
        """Validates image size and decodes to RGB PIL Image."""
        if not image_bytes or len(image_bytes) == 0:
            raise ValueError("Uploaded image file is empty.")

        if len(image_bytes) > max_bytes:
            raise ValueError(f"Image file exceeds maximum allowable size of {max_bytes // (1024*1024)}MB.")

        try:
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()
            image = Image.open(io.BytesIO(image_bytes))
            if image.mode != "RGB":
                image = image.convert("RGB")
            return image
        except Exception as e:
            raise ValueError(f"Invalid or corrupted image format. Error: {str(e)}")

    def predict(
        self,
        image_bytes: bytes,
        conf_threshold: Optional[float] = None,
        iou_threshold: Optional[float] = None,
    ) -> Dict[str, Any]:
        """Runs CPU inference on an input crop image using the Quality YOLO model.

        Returns image dimensions, list of QualityDetectionItem, and the top detection.
        """
        self._load_model_if_needed()

        image = self.validate_image_bytes(image_bytes)
        img_width, img_height = image.size

        conf = conf_threshold if conf_threshold is not None else self.conf_threshold
        iou = iou_threshold if iou_threshold is not None else self.iou_threshold

        with self._model_lock:
            results = self._model.predict(
                source=image,
                conf=conf,
                iou=iou,
                device="cpu",
                verbose=False,
            )

        detections: List[QualityDetectionItem] = []
        if results and len(results) > 0:
            result = results[0]
            boxes = result.boxes
            if boxes is not None and len(boxes) > 0:
                for box in boxes:
                    cls_id = int(box.cls[0].item())
                    conf_val = float(box.conf[0].item())
                    raw_cls_name = self._class_names.get(cls_id, f"class_{cls_id}")
                    crop, quality_status, is_fresh, grade_label = self.normalize_quality_class(raw_cls_name)

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
                        QualityDetectionItem(
                            class_name=raw_cls_name,
                            class_id=cls_id,
                            confidence=round(conf_val, 4),
                            crop=crop,
                            quality_status=quality_status,
                            is_fresh=is_fresh,
                            grade_label=grade_label,
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

