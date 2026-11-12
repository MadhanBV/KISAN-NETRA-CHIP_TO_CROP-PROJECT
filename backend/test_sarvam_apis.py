import httpx
from app.config import settings

def test_tts():
    print("Testing Sarvam TTS...")
    key = settings.sarvam_api_key.strip()
    url = f"{settings.sarvam_api_url.rstrip('/')}/text-to-speech"
    headers = {
        "api-subscription-key": key,
        "Content-Type": "application/json"
    }
    payload = {
        "inputs": ["नमस्ते किसान भाई, आपकी फसल अच्छी है।"],
        "target_language_code": "hi-IN",
        "model": "bulbul:v3"
    }
    res = httpx.post(url, headers=headers, json=payload, timeout=20.0)
    print("TTS Status:", res.status_code)
    if res.status_code == 200:
        data = res.json()
        print("TTS Keys:", list(data.keys()))
        audios = data.get("audios", [])
        print("Audios count:", len(audios))
        if audios:
            print("First audio base64 len:", len(audios[0]))
    else:
        print("TTS Error:", res.text)

def test_stt_schema():
    print("\nTesting Sarvam STT Endpoint inspection...")
    key = settings.sarvam_api_key.strip()
    url = f"{settings.sarvam_api_url.rstrip('/')}/speech-to-text"
    headers = {"api-subscription-key": key}
    # Send empty or dummy to see what schema / parameters Sarvam STT expects
    res = httpx.post(url, headers=headers, timeout=20.0)
    print("STT Status on empty post:", res.status_code)
    print("STT Response:", res.text[:300])

if __name__ == "__main__":
    test_tts()
    test_stt_schema()
