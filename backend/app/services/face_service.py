import logging
from typing import Tuple, Optional
import requests
from app.config import settings

logger = logging.getLogger("chiptocrop.face_service")


class FaceCompareResult:
    def __init__(
        self,
        success: bool,
        confidence: Optional[float] = None,
        threshold: float = 80.0,
        error_code: Optional[str] = None,
        message: str = "",
    ):
        self.success = success
        self.confidence = confidence
        self.threshold = threshold
        self.error_code = error_code
        self.message = message


class FaceService:
    @staticmethod
    def is_configured() -> bool:
        """Check if Face++ API credentials and endpoint are fully provided."""
        return bool(
            settings.facepp_api_key
            and settings.facepp_api_secret
            and settings.facepp_compare_url
        )

    @classmethod
    def compare_faces(
        cls,
        image_bytes1: bytes,
        image_bytes2: bytes,
    ) -> FaceCompareResult:
        """
        Compare two face images using the Face++ Compare API (1:1 verification).

        Image 1: Registered reference face image.
        Image 2: Freshly captured login face image.
        """
        threshold = settings.facepp_confidence_threshold

        if not cls.is_configured():
            return FaceCompareResult(
                success=False,
                threshold=threshold,
                error_code="SERVICE_NOT_CONFIGURED",
                message=(
                    "Face++ Compare API credentials or endpoint URL are not yet fully configured. "
                    "Please set FACEPP_COMPARE_URL in backend/.env."
                ),
            )

        try:
            files = {
                "image_file1": ("reference.jpg", image_bytes1, "image/jpeg"),
                "image_file2": ("login.jpg", image_bytes2, "image/jpeg"),
            }
            data = {
                "api_key": settings.facepp_api_key,
                "api_secret": settings.facepp_api_secret,
            }

            response = requests.post(
                settings.facepp_compare_url,
                data=data,
                files=files,
                timeout=15,
            )

            res_json = response.json()

            if response.status_code != 200 or "error_message" in res_json:
                error_msg = res_json.get("error_message", "Unknown Face++ error")
                logger.error(f"Face++ API error response: {error_msg}")

                if "NO_FACE_FOUND" in error_msg.upper():
                    return FaceCompareResult(
                        success=False,
                        threshold=threshold,
                        error_code="NO_FACE_DETECTED",
                        message="No face was detected in one of the images. Please ensure good lighting and face the camera directly.",
                    )
                elif "MULTIPLE_FACES" in error_msg.upper():
                    return FaceCompareResult(
                        success=False,
                        threshold=threshold,
                        error_code="MULTIPLE_FACES_DETECTED",
                        message="Multiple faces were detected. Only the registered farmer should be in the frame.",
                    )

                return FaceCompareResult(
                    success=False,
                    threshold=threshold,
                    error_code="API_ERROR",
                    message=f"Face verification service returned: {error_msg}",
                )

            confidence = float(res_json.get("confidence", 0.0))
            is_match = confidence >= threshold

            if is_match:
                return FaceCompareResult(
                    success=True,
                    confidence=confidence,
                    threshold=threshold,
                    message=f"Face verified successfully (confidence: {confidence:.1f}%).",
                )
            else:
                return FaceCompareResult(
                    success=False,
                    confidence=confidence,
                    threshold=threshold,
                    error_code="CONFIDENCE_TOO_LOW",
                    message=(
                        f"Face verification failed. Match confidence ({confidence:.1f}%) "
                        f"was below the security threshold of {threshold:.1f}%."
                    ),
                )

        except requests.exceptions.Timeout:
            logger.error("Face++ request timed out")
            return FaceCompareResult(
                success=False,
                threshold=threshold,
                error_code="TIMEOUT",
                message="Face verification service timed out. Please try again.",
            )
        except requests.exceptions.RequestException as e:
            logger.error(f"Network error while calling Face++: {str(e)}")
            return FaceCompareResult(
                success=False,
                threshold=threshold,
                error_code="NETWORK_ERROR",
                message="Network error while connecting to Face++ API.",
            )

