import logging
from fastapi import APIRouter, status

from app.models.language_models import (
    SupportedLanguagesResponse,
    TranslationRequest,
    TranslationResponse,
)
from app.services.sarvam_service import SarvamService

logger = logging.getLogger("chiptocrop.language_routes")

router = APIRouter(prefix="/api/language", tags=["Language & Translation"])


@router.post(
    "/translate",
    response_model=TranslationResponse,
    status_code=status.HTTP_200_OK,
    summary="Translate text across 23 Indian languages using Sarvam AI",
)
async def translate_text(request: TranslationRequest):
    """
    Translates input text from source_language_code to target_language_code.
    Supports all 23 official Indian languages via Sarvam-Translate v1.
    """
    logger.info(
        f"Translating text ({len(request.input)} chars) from "
        f"{request.source_language_code} to {request.target_language_code}"
    )
    return await SarvamService.translate(request)


@router.get(
    "/supported",
    response_model=SupportedLanguagesResponse,
    status_code=status.HTTP_200_OK,
    summary="List all 23 languages supported by Sarvam AI",
)
async def get_supported_languages():
    """Returns the complete list of 23 languages supported by Sarvam-Translate v1."""
    languages = SarvamService.get_supported_languages()
    return SupportedLanguagesResponse(
        total=len(languages),
        languages=languages,
    )


@router.get(
    "/status",
    status_code=status.HTTP_200_OK,
    summary="Check Sarvam AI service configuration status",
)
async def get_sarvam_status():
    """Confirms if Sarvam AI translation is configured without revealing secrets."""
    return {
        "status": "ready" if SarvamService.is_configured() else "unconfigured",
        "configured": SarvamService.is_configured(),
        "model": "sarvam-translate:v1",
        "supported_languages_count": 23,
    }

