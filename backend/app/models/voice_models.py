from typing import Optional
from pydantic import BaseModel, Field

class TTSRequest(BaseModel):
    text: str = Field(..., description="Text content to synthesize into regional speech")
    language_code: Optional[str] = Field("hi-IN", description="Target language code (e.g. hi-IN, te-IN, kn-IN, ta-IN)")
    speaker: Optional[str] = Field("meera", description="Sarvam speaker persona")

class TTSResponse(BaseModel):
    success: bool
    audio_base64: Optional[str] = None
    language_code: str
    error: Optional[str] = None

class STTResponse(BaseModel):
    success: bool
    transcript: str = ""
    language_code: Optional[str] = None
    error: Optional[str] = None

