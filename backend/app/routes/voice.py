import logging
from typing import Optional
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, status

from app.models.voice_models import TTSRequest, TTSResponse, STTResponse
from app.services.sarvam_service import SarvamService

logger = logging.getLogger("chiptocrop.voice")

router = APIRouter(prefix="/api/voice", tags=["Voice & Speech"])

@router.post("/tts", response_model=TTSResponse)
def text_to_speech(request: TTSRequest):
    """
    Synthesizes regional speech from text using Sarvam Bulbul TTS.
    Returns base64 encoded audio string for mobile playback.
    """
    if not request.text or not request.text.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Text cannot be empty."
        )

    try:
        audio_b64 = SarvamService.text_to_speech(
            text=request.text.strip(),
            target_language_code=request.language_code or "hi-IN",
            speaker=request.speaker or "ritu"
        )

        if audio_b64:
            return TTSResponse(
                success=True,
                audio_base64=audio_b64,
                language_code=request.language_code or "hi-IN"
            )
        else:
            return TTSResponse(
                success=False,
                audio_base64=None,
                language_code=request.language_code or "hi-IN",
                error="Sarvam TTS synthesis unavailable or quota reached. Client fallback recommended."
            )
    except Exception as e:
        logger.error(f"Error in TTS endpoint: {e}", exc_info=True)
        return TTSResponse(
            success=False,
            audio_base64=None,
            language_code=request.language_code or "hi-IN",
            error=str(e)
        )

@router.post("/stt", response_model=STTResponse)
def speech_to_text(
    file: UploadFile = File(..., description="Audio file (WAV/MP3/M4A)"),
    language_code: Optional[str] = Form(None, description="Optional spoken language code")
):
    """
    Transcribes farmer speech audio into text using Sarvam Saarika STT.
    """
    try:
        audio_bytes = file.file.read()
        if len(audio_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty audio file."
            )

        transcript = SarvamService.speech_to_text(
            audio_bytes=audio_bytes,
            filename=file.filename or "recording.wav",
            language_code=language_code
        )

        if transcript is not None:
            return STTResponse(
                success=True,
                transcript=transcript,
                language_code=language_code
            )
        else:
            return STTResponse(
                success=False,
                transcript="",
                language_code=language_code,
                error="Sarvam STT transcription failed or quota unavailable."
            )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in STT endpoint: {e}", exc_info=True)
        return STTResponse(
            success=False,
            transcript="",
            language_code=language_code,
            error=str(e)
        )

