import os
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Face++ Credentials
    facepp_api_key: str = ""
    facepp_api_secret: str = ""
    facepp_compare_url: str = ""
    facepp_confidence_threshold: float = 80.0

    # JWT Settings
    jwt_secret_key: str = "chip_to_crop_dev_secret_key_change_in_production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 1440  # 24 hours

    # Supabase Configuration (Backend server-side only)
    supabase_url: str = ""
    supabase_secret_key: str = ""
    supabase_storage_bucket: str = "farmers-faces"
    supabase_table_name: str = "farmers"

    # Sarvam AI Configuration (Backend server-side only)
    sarvam_api_key: str = ""
    sarvam_api_url: str = "https://api.sarvam.ai"
    sarvam_translate_model: str = "sarvam-translate:v1"
    sarvam_timeout_seconds: float = 15.0

    # Open Government Data (data.gov.in) Configuration (Backend server-side only)
    data_gov_in_api_key: str = ""
    data_gov_in_resource_id: str = "9ef84268-d588-465a-a308-a864a43d0070"
    data_gov_in_base_url: str = (
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
    )
    data_gov_in_timeout_seconds: float = 30.0
    data_gov_in_max_retries: int = 1

    # YOLO26s Leaf Disease Model Settings
    yolo_model_path: str = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), "models", "yolo26s", "best.pt"
    )
    yolo_conf_threshold: float = 0.25
    yolo_iou_threshold: float = 0.45

    # YOLO Crop Quality Detection Model Settings
    quality_model_path: str = (
        os.path.join(
            os.path.dirname(os.path.dirname(__file__)), "models", "quality", "best.pt"
        )
        if os.path.isfile(
            os.path.join(
                os.path.dirname(os.path.dirname(__file__)), "models", "quality", "best.pt"
            )
        )
        else os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "models", "best.pt"
        )
    )
    quality_conf_threshold: float = 0.25
    quality_iou_threshold: float = 0.45

    # YOLO Crop & Fruit Disease Detection Model 3 Settings
    crop_disease_model_path: str = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), "models", "crop_disease", "best.pt"
    )
    crop_disease_conf_threshold: float = 0.25
    crop_disease_iou_threshold: float = 0.45

    # Agricultural RAG Engine Service (Port 8001)
    rag_engine_base_url: str = "http://127.0.0.1:8001"
    rag_timeout_seconds: float = 180.0

    # Server Settings
    port: int = 8000
    host: str = "0.0.0.0"
    debug: bool = True
    max_failed_login_attempts: int = 3

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
