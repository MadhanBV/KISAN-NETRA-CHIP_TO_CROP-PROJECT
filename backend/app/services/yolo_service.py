import io
import os
import threading
import logging
from typing import List, Dict, Any, Tuple, Optional
from PIL import Image
import numpy as np

from app.config import settings
from app.models.crop_models import BoundingBox, DetectionItem

logger = logging.getLogger("chiptocrop.yolo")

class YOLOService:
    _instance: Optional["YOLOService"] = None
    _init_lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._init_lock:
                if cls._instance is None:
                    cls._instance = super(YOLOService, cls).__new__(cls)
                    cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if getattr(self, "_initialized", False):
            return
        self.model_path = settings.yolo_model_path
        self.conf_threshold = settings.yolo_conf_threshold
        self.iou_threshold = settings.yolo_iou_threshold
        self._model = None
        self._model_lock = threading.Lock()
        self._class_names: Dict[int, str] = {}
        self._initialized = True
        logger.info(f"YOLOService initialized (model will be lazy-loaded from {self.model_path}).")

    def is_model_file_present(self) -> bool:
        return os.path.isfile(self.model_path)

    def is_model_loaded(self) -> bool:
        return self._model is not None

    def get_class_names(self) -> Dict[int, str]:
        if not self._class_names and self.is_model_file_present():
            # Quick check from model if loaded or return expected 11 classes
            if self._model is not None:
                return dict(self._model.names)
            return {
                0: "MANGO_ANTHRACNOSE",
                1: "MANGO_BACTERIAL_CANKER",
                2: "MANGO_DIE_BACK",
                3: "MANGO_GALL_MIDGE",
                4: "MANGO_HEALTHY",
                5: "MANGO_POWDERY_MILDEW",
                6: "MANGO_SOOTY_MOULD",
                7: "TOMATO_BACTERIAL_SPOT",
                8: "TOMATO_EARLY_BLIGHT",
                9: "TOMATO_HEALTHY",
                10: "TOMATO_LEAF_MOLD"
            }
        return self._class_names

    def _load_model_if_needed(self):
        """Thread-safe lazy loader for YOLO26s."""
        if self._model is not None:
            return

        with self._model_lock:
            if self._model is not None:
                return

            if not os.path.isfile(self.model_path):
                raise FileNotFoundError(
                    f"Trained YOLO model not found at expected path: {self.model_path}. "
                    "Ensure best.pt is copied to backend/models/yolo26s/best.pt."
                )

            logger.info(f"Lazy-loading YOLO model from: {self.model_path} onto CPU...")
            try:
                from ultralytics import YOLO
                model = YOLO(self.model_path)
                self._model = model
                self._class_names = dict(model.names)
                logger.info(
                    f"YOLO26s model loaded successfully on CPU. "
                    f"Number of classes: {len(self._class_names)}"
                )
            except Exception as e:
                logger.error(f"Failed to load YOLO model: {e}", exc_info=True)
                raise RuntimeError(f"YOLO model load failed: {str(e)}")

    @staticmethod
    def normalize_class_name(raw_name: str) -> Tuple[str, str, bool]:
        """
        Normalizes dataset class names into clean Crop and Condition strings.
        Example:
          'TOMATO_EARLY_BLIGHT' -> ('Tomato', 'Early Blight', False)
          'MANGO_HEALTHY' -> ('Mango', 'Healthy', True)
        """
        upper = raw_name.strip().upper()
        if upper.startswith("TOMATO_"):
            crop = "Tomato"
            cond_raw = upper[len("TOMATO_"):]
        elif upper.startswith("MANGO_"):
            crop = "Mango"
            cond_raw = upper[len("MANGO_"):]
        else:
            parts = upper.split("_", 1)
            crop = parts[0].title()
            cond_raw = parts[1] if len(parts) > 1 else upper

        is_healthy = "HEALTHY" in cond_raw
        condition = cond_raw.replace("_", " ").title()
        return crop, condition, is_healthy

    def validate_image_bytes(self, image_bytes: bytes, max_bytes: int = 15 * 1024 * 1024) -> Image.Image:
        """Validates image size and decodes to RGB PIL Image."""
        if not image_bytes or len(image_bytes) == 0:
            raise ValueError("Uploaded image file is empty.")

        if len(image_bytes) > max_bytes:
            raise ValueError(f"Image file exceeds maximum allowable size of {max_bytes // (1024*1024)}MB.")

        try:
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()  # Verify integrity
            # Reopen after verify() closes the stream
            image = Image.open(io.BytesIO(image_bytes))
            if image.mode != "RGB":
                image = image.convert("RGB")
            return image
        except Exception as e:
            raise ValueError(f"Invalid or corrupted image format. Supported formats: JPEG, PNG, WEBP. Error: {str(e)}")

    def predict(
        self,
        image_bytes: bytes,
        conf_threshold: Optional[float] = None,
        iou_threshold: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Runs CPU inference on an input image.
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

        # Run inference on CPU
        with self._model_lock:
            results = self._model.predict(
                source=image,
                conf=conf,
                iou=iou,
                device="cpu",
                verbose=False
            )

        detections: List[DetectionItem] = []
        if results and len(results) > 0:
            result = results[0]
            boxes = result.boxes
            if boxes is not None and len(boxes) > 0:
                for box in boxes:
                    cls_id = int(box.cls[0].item())
                    conf_val = float(box.conf[0].item())
                    raw_cls_name = self._class_names.get(cls_id, f"CLASS_{cls_id}")
                    crop, condition, is_healthy = self.normalize_class_name(raw_cls_name)

                    # xyxy coordinates
                    coords = box.xyxy[0].tolist()
                    x1, y1, x2, y2 = coords[0], coords[1], coords[2], coords[3]

                    norm_box = BoundingBox(
                        x1=max(0.0, min(1.0, x1 / img_width)),
                        y1=max(0.0, min(1.0, y1 / img_height)),
                        x2=max(0.0, min(1.0, x2 / img_width)),
                        y2=max(0.0, min(1.0, y2 / img_height))
                    )

                    abs_box = BoundingBox(x1=x1, y1=y1, x2=x2, y2=y2)

                    detections.append(DetectionItem(
                        class_name=raw_cls_name,
                        class_id=cls_id,
                        confidence=round(conf_val, 4),
                        crop=crop,
                        condition=condition,
                        is_healthy=is_healthy,
                        box=abs_box,
                        box_normalized=norm_box
                    ))

        # Sort detections by confidence descending
        detections.sort(key=lambda d: d.confidence, reverse=True)

        top_detection = detections[0] if detections else None

        return {
            "image_width": img_width,
            "image_height": img_height,
            "detections": detections,
            "top_detection": top_detection
        }

