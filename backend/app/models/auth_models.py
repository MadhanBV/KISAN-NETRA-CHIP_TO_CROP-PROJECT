from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class CheckPhoneResponse(BaseModel):
    phone_number: str
    exists: bool
    message: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    farmer_id: str
    phone_number: str
    is_demo: bool = False
    message: str


class FaceVerifyResponse(BaseModel):
    success: bool
    confidence: Optional[float] = None
    threshold: float
    message: str
    remaining_attempts: Optional[int] = None
    token: Optional[TokenResponse] = None


class FarmerProfile(BaseModel):
    id: str
    phone_number: str
    face_image_path: str
    biometric_consent: bool = True
    consent_timestamp: Optional[datetime] = None
    account_status: str = "active"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class HealthCheckResponse(BaseModel):
    status: str = "healthy"
    app_name: str = "CHIP TO CROP Auth Service"
    version: str = "1.0.0"
    supabase_configured: bool
    facepp_configured: bool
    sarvam_configured: bool = False
    mandi_configured: bool = False
    timestamp: datetime = Field(default_factory=datetime.utcnow)
