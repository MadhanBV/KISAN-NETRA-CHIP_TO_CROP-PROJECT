from typing import List, Optional
from pydantic import BaseModel, Field, constr


class TranslationRequest(BaseModel):
    """Request model for Sarvam text translation."""
    input: str = Field(
        ...,
        min_length=1,
        max_length=2000,
        description="Text to translate (maximum 2,000 characters for sarvam-translate:v1)",
        example="Welcome to CHIP TO CROP",
    )
    source_language_code: str = Field(
        ...,
        description="Source language code (e.g., 'en-IN', 'hi-IN', 'kn-IN')",
        example="en-IN",
    )
    target_language_code: str = Field(
        ...,
        description="Target language code (e.g., 'kn-IN', 'hi-IN', 'ta-IN')",
        example="kn-IN",
    )
    model: str = Field(
        default="sarvam-translate:v1",
        description="Sarvam model identifier",
        example="sarvam-translate:v1",
    )
    mode: Optional[str] = Field(
        default="formal",
        description="Translation formality/mode (e.g., 'formal', 'colloquial', 'code-mixed')",
        example="formal",
    )


class TranslationResponse(BaseModel):
    """Response model for Sarvam text translation."""
    translated_text: str = Field(
        ...,
        description="Translated text in target language script",
        example="ಚಿಪ್ ಟು ಕ್ರಾಪ್‌ಗೆ ಸ್ವಾಗತ",
    )
    source_language_code: str = Field(
        ...,
        description="Source language code used for translation",
        example="en-IN",
    )
    target_language_code: str = Field(
        ...,
        description="Target language code of the result",
        example="kn-IN",
    )
    request_id: Optional[str] = Field(
        default=None,
        description="Sarvam upstream transaction request ID",
    )


class SupportedLanguageItem(BaseModel):
    """Language item metadata."""
    code: str = Field(..., description="Sarvam ISO language-country code", example="kn-IN")
    name: str = Field(..., description="Language name in English", example="Kannada")
    native_name: str = Field(..., description="Language name in native script", example="ಕನ್ನಡ")


class SupportedLanguagesResponse(BaseModel):
    """Response model listing all 23 supported languages."""
    total: int = Field(..., description="Total number of supported languages")
    languages: List[SupportedLanguageItem] = Field(..., description="List of supported languages")


# Future Service Model Interfaces (Modular boundaries for Phase 2 speech capabilities)
class SpeechToTextRequestStub(BaseModel):
    """Reserved interface for future Sarvam Speech-to-Text."""
    language_code: str = "kn-IN"
    model: str = "saarika:v2"


class TextToSpeechRequestStub(BaseModel):
    """Reserved interface for future Sarvam Text-to-Speech."""
    inputs: List[str]
    target_language_code: str = "kn-IN"
    speaker: str = "meera"

