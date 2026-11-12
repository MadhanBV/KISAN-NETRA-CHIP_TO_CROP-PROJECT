import httpx
from app.config import settings

key = settings.sarvam_api_key.strip()
print("Using key:", key[:8] + "...")

# 1. Test translation
res_trans = httpx.post(
    "https://api.sarvam.ai/translate",
    headers={"api-subscription-key": key, "Content-Type": "application/json"},
    json={
        "input": "Hello farmer",
        "source_language_code": "en-IN",
        "target_language_code": "hi-IN",
        "model": "sarvam-translate:v1"
    }
)
print("Translate status:", res_trans.status_code, res_trans.text[:150])

# 2. Test TTS with bulbul:v4-flash
res_tts_flash = httpx.post(
    "https://api.sarvam.ai/text-to-speech",
    headers={"api-subscription-key": key, "Content-Type": "application/json"},
    json={
        "inputs": ["नमस्ते किसान"],
        "target_language_code": "hi-IN",
        "model": "bulbul:v4-flash"
    }
)
print("TTS v4-flash status:", res_tts_flash.status_code, res_tts_flash.text[:150])

# 3. Test STT model options
res_stt = httpx.post(
    "https://api.sarvam.ai/speech-to-text",
    headers={"api-subscription-key": key},
    files={"file": ("test.wav", b"RIFF....WAVEfmt ....data....", "audio/wav")}
)
print("STT status:", res_stt.status_code, res_stt.text[:150])

