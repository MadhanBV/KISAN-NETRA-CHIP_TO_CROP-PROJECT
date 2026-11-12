import logging
from typing import Dict, List, Optional, Tuple
import httpx
from fastapi import HTTPException, status

from app.config import settings
from app.models.language_models import (
    SupportedLanguageItem,
    TranslationRequest,
    TranslationResponse,
)

logger = logging.getLogger("chiptocrop.sarvam")

# Official 23 languages supported by Sarvam-Translate v1
SARVAM_SUPPORTED_LANGUAGES: Dict[str, Dict[str, str]] = {
    "en-IN": {"name": "English", "native_name": "English"},
    "hi-IN": {"name": "Hindi", "native_name": "हिन्दी"},
    "kn-IN": {"name": "Kannada", "native_name": "ಕನ್ನಡ"},
    "ta-IN": {"name": "Tamil", "native_name": "தமிழ்"},
    "te-IN": {"name": "Telugu", "native_name": "తెలుగు"},
    "ml-IN": {"name": "Malayalam", "native_name": "മലയാളം"},
    "bn-IN": {"name": "Bengali", "native_name": "বাংলা"},
    "mr-IN": {"name": "Marathi", "native_name": "मराठी"},
    "gu-IN": {"name": "Gujarati", "native_name": "ગુજરાતી"},
    "pa-IN": {"name": "Punjabi", "native_name": "ਪੰਜਾਬੀ"},
    "or-IN": {"name": "Odia", "native_name": "ଓଡ଼ିଆ"},
    "as-IN": {"name": "Assamese", "native_name": "অসমীয়া"},
    "brx-IN": {"name": "Bodo", "native_name": "बर'"},
    "doi-IN": {"name": "Dogri", "native_name": "डोगरी"},
    "ks-IN": {"name": "Kashmiri", "native_name": "کٲشُر"},
    "kok-IN": {"name": "Konkani", "native_name": "कोंकणी"},
    "mai-IN": {"name": "Maithili", "native_name": "मैथिली"},
    "mni-IN": {"name": "Manipuri", "native_name": "মৈতৈলোন্"},
    "ne-IN": {"name": "Nepali", "native_name": "नेपाली"},
    "sa-IN": {"name": "Sanskrit", "native_name": "संस्कृतम्"},
    "sat-IN": {"name": "Santali", "native_name": "ᱥᱟᱱᱛᱟᱲᱤ"},
    "sd-IN": {"name": "Sindhi", "native_name": "سنڌي"},
    "ur-IN": {"name": "Urdu", "native_name": "اردو"},
}


class SarvamService:
    """Service layer for integrating Sarvam AI Text Translation and future Speech services."""

    # Simple LRU-style translation cache: (source, target, text) -> translated_text
    _translation_cache: Dict[Tuple[str, str, str], str] = {}
    _MAX_CACHE_ENTRIES: int = 500

    @classmethod
    def is_configured(cls) -> bool:
        """Check if Sarvam API key is configured."""
        return bool(settings.sarvam_api_key and settings.sarvam_api_key.strip())

    @classmethod
    def get_supported_languages(cls) -> List[SupportedLanguageItem]:
        """Return the list of 23 supported languages with metadata."""
        return [
            SupportedLanguageItem(
                code=code,
                name=info["name"],
                native_name=info["native_name"],
            )
            for code, info in SARVAM_SUPPORTED_LANGUAGES.items()
        ]

    @classmethod
    def validate_language_code(cls, code: str) -> bool:
        """Verify whether a language code is among Sarvam's supported set."""
        return code in SARVAM_SUPPORTED_LANGUAGES

    @classmethod
    async def translate(cls, request: TranslationRequest) -> TranslationResponse:
        """Translate text from source to target language using Sarvam AI."""
        if not cls.is_configured():
            logger.error("Sarvam translation requested but SARVAM_API_KEY is not configured.")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Sarvam AI translation service is not configured on the server.",
            )

        # Validate language codes
        if not cls.validate_language_code(request.source_language_code):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported source language code: '{request.source_language_code}'. "
                       f"Must be one of the 23 supported Sarvam language codes.",
            )

        if not cls.validate_language_code(request.target_language_code):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported target language code: '{request.target_language_code}'. "
                       f"Must be one of the 23 supported Sarvam language codes.",
            )

        # Validate input length
        text_to_translate = request.input.strip()
        if not text_to_translate:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Translation input text cannot be empty.",
            )

        if len(text_to_translate) > 2000:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Input text exceeds the 2,000 character limit for Sarvam-Translate v1.",
            )

        # If source and target are identical, return as-is immediately
        if request.source_language_code == request.target_language_code:
            return TranslationResponse(
                translated_text=text_to_translate,
                source_language_code=request.source_language_code,
                target_language_code=request.target_language_code,
                request_id="identity_passthrough",
            )

        # Check in-memory cache
        cache_key = (request.source_language_code, request.target_language_code, text_to_translate)
        if cache_key in cls._translation_cache:
            return TranslationResponse(
                translated_text=cls._translation_cache[cache_key],
                source_language_code=request.source_language_code,
                target_language_code=request.target_language_code,
                request_id="cache_hit",
            )

        # Map language codes where Sarvam uses alternate ISO variants (e.g. od-IN for Odia)
        sarvam_source = "od-IN" if request.source_language_code == "or-IN" else request.source_language_code
        sarvam_target = "od-IN" if request.target_language_code == "or-IN" else request.target_language_code

        # Prepare Sarvam API request
        url = f"{settings.sarvam_api_url.rstrip('/')}/translate"
        headers = {
            "api-subscription-key": settings.sarvam_api_key.strip(),
            "Content-Type": "application/json",
        }
        payload = {
            "input": text_to_translate,
            "source_language_code": sarvam_source,
            "target_language_code": sarvam_target,
            "model": request.model or settings.sarvam_translate_model,
        }
        if request.mode:
            payload["mode"] = request.mode

        try:
            async with httpx.AsyncClient(timeout=settings.sarvam_timeout_seconds) as client:
                response = await client.post(url, headers=headers, json=payload)

            if response.status_code == 200:
                data = response.json()
                translated_text = data.get("translated_text", "")
                request_id = data.get("request_id")

                # Store in cache
                if len(cls._translation_cache) >= cls._MAX_CACHE_ENTRIES:
                    cls._translation_cache.pop(next(iter(cls._translation_cache)))
                cls._translation_cache[cache_key] = translated_text

                return TranslationResponse(
                    translated_text=translated_text,
                    source_language_code=request.source_language_code,
                    target_language_code=request.target_language_code,
                    request_id=request_id,
                )

            elif response.status_code == 429:
                logger.warning("Sarvam API rate limit reached.")
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Sarvam AI translation rate limit reached. Please try again shortly.",
                )
            else:
                logger.error(
                    f"Sarvam translation API returned error {response.status_code}: {response.text}"
                )
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail=f"Sarvam API translation failed with status {response.status_code}.",
                )

        except httpx.TimeoutException:
            logger.error("Sarvam translation request timed out.")
            raise HTTPException(
                status_code=status.HTTP_504_GATEWAY_TIMEOUT,
                detail="Translation request to Sarvam AI timed out.",
            )
        except httpx.RequestError as exc:
            logger.error(f"Network error connecting to Sarvam AI: {exc}")
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Network error occurred while connecting to Sarvam AI translation service.",
            )

    # -------------------------------------------------------------------------
    # Sarvam Speech Integrations (Text-to-Speech & Speech-to-Text)
    # -------------------------------------------------------------------------

    @classmethod
    def normalize_language_code(cls, lang: Optional[str]) -> str:
        """Converts short language codes (e.g. 'hi', 'te') to Sarvam ISO format ('hi-IN', 'te-IN')."""
        if not lang:
            return "hi-IN"
        lang = lang.strip()
        if "-" in lang:
            return lang
        short_to_sarvam = {
            "en": "en-IN",
            "hi": "hi-IN",
            "kn": "kn-IN",
            "ta": "ta-IN",
            "te": "te-IN",
            "ml": "ml-IN",
            "bn": "bn-IN",
            "mr": "mr-IN",
            "gu": "gu-IN",
            "pa": "pa-IN",
            "or": "or-IN",
            "as": "as-IN",
            "ur": "ur-IN",
        }
        return short_to_sarvam.get(lang.lower(), "hi-IN")

    @classmethod
    def translate_text(
        cls,
        text: str,
        target_language: str = "hi-IN",
        source_language: str = "en-IN"
    ) -> Optional[str]:
        """Synchronous helper for Sarvam translation."""
        if not cls.is_configured() or not text or not text.strip():
            return None
        try:
            target_iso = cls.normalize_language_code(target_language)
            source_iso = cls.normalize_language_code(source_language)
            if target_iso == source_iso:
                return text

            url = f"{settings.sarvam_api_url.rstrip('/')}/translate"
            headers = {
                "api-subscription-key": settings.sarvam_api_key.strip(),
                "Content-Type": "application/json"
            }
            payload = {
                "input": text[:1800].strip(),
                "source_language_code": source_iso,
                "target_language_code": target_iso,
                "model": settings.sarvam_translate_model or "mayura:v1"
            }
            with httpx.Client(timeout=15.0) as client:
                res = client.post(url, headers=headers, json=payload)
                if res.status_code == 200:
                    data = res.json()
                    return data.get("translated_text", "")
                else:
                    logger.warning(f"Sarvam translate status {res.status_code}: {res.text}")
                    return None
        except Exception as e:
            logger.warning(f"Sarvam translate_text failed: {e}")
            return None

    @classmethod
    def clean_text_for_speech(cls, text: str) -> str:
        """Strips markdown asterisks, hashes, and symbols so TTS reads clean, natural sentences."""
        import re
        t = re.sub(r'#+\s*', '', text)
        t = re.sub(r'\*+', '', t)
        t = re.sub(r'[-•]\s*', '', t)
        t = re.sub(r'\[.*?\]\(.*?\)', '', t)
        t = re.sub(r'\s+', ' ', t).strip()
        return t

    @classmethod
    def text_to_speech(
        cls,
        text: str,
        target_language_code: str = "hi-IN",
        speaker: str = "ritu"
    ) -> Optional[str]:
        """
        Synthesizes text into speech using Sarvam Bulbul API.
        Returns base64 encoded audio string, or None if quota exhausted / unavailable.
        """
        if not cls.is_configured():
            logger.warning("Sarvam API key is not configured for TTS.")
            return None

        clean_text = cls.clean_text_for_speech(text)
        if not clean_text:
            return None

        # Truncate to first 500 chars for rapid audio generation if very long
        if len(clean_text) > 500:
            clean_text = clean_text[:500] + "."

        sarvam_lang = cls.normalize_language_code(target_language_code)
        url = f"{settings.sarvam_api_url.rstrip('/')}/text-to-speech"
        headers = {
            "api-subscription-key": settings.sarvam_api_key.strip(),
            "Content-Type": "application/json",
        }
        payload = {
            "inputs": [clean_text],
            "target_language_code": sarvam_lang,
            "speaker": speaker,
            "model": "bulbul:v3"
        }

        try:
            with httpx.Client(timeout=20.0) as client:
                res = client.post(url, headers=headers, json=payload)
                if res.status_code == 200:
                    data = res.json()
                    audios = data.get("audios", [])
                    if audios and len(audios) > 0:
                        return audios[0]
                else:
                    logger.warning(f"Sarvam TTS returned status {res.status_code}: {res.text}")
                    return None
        except Exception as e:
            logger.error(f"Sarvam TTS failed: {e}")
            return None

    @classmethod
    def speech_to_text(
        cls,
        audio_bytes: bytes,
        filename: str = "recording.wav",
        language_code: Optional[str] = None
    ) -> Optional[str]:
        """
        Transcribes speech audio into text using Sarvam Saarika API.
        Returns transcribed text string, or None on failure.
        """
        if not cls.is_configured():
            logger.warning("Sarvam API key is not configured for STT.")
            return None

        url = f"{settings.sarvam_api_url.rstrip('/')}/speech-to-text"
        headers = {
            "api-subscription-key": settings.sarvam_api_key.strip()
        }
        files = {
            "file": (filename, audio_bytes, "audio/wav")
        }
        data = {}
        if language_code:
            data["language_code"] = cls.normalize_language_code(language_code)

        try:
            with httpx.Client(timeout=30.0) as client:
                res = client.post(url, headers=headers, files=files, data=data)
                if res.status_code == 200:
                    res_data = res.json()
                    return res_data.get("transcript", "")
                else:
                    logger.warning(f"Sarvam STT returned status {res.status_code}: {res.text}")
                    return None
        except Exception as e:
            logger.error(f"Sarvam STT failed: {e}")
            return None
