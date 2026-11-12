import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.services.sarvam_service import SarvamService


class TestSarvamTranslation(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_health_check_includes_sarvam(self):
        """Verify /health reports Sarvam configuration status."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "healthy")
        self.assertIn("sarvam_configured", data)
        self.assertTrue(data["sarvam_configured"])

    def test_get_supported_languages(self):
        """Verify /api/language/supported returns all 23 official languages."""
        response = self.client.get("/api/language/supported")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["total"], 23)
        self.assertEqual(len(data["languages"]), 23)

        codes = [l["code"] for l in data["languages"]]
        self.assertIn("en-IN", codes)
        self.assertIn("kn-IN", codes)
        self.assertIn("hi-IN", codes)
        self.assertIn("ta-IN", codes)
        self.assertIn("te-IN", codes)
        self.assertIn("mr-IN", codes)
        self.assertIn("bn-IN", codes)

    def test_get_language_status(self):
        """Verify /api/language/status endpoint returns readiness."""
        response = self.client.get("/api/language/status")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "ready")
        self.assertTrue(data["configured"])
        self.assertEqual(data["supported_languages_count"], 23)

    def test_translate_english_to_kannada_live(self):
        """Verify real live translation of English to Kannada via Sarvam AI."""
        payload = {
            "input": "Welcome to Kisan Netra",
            "source_language_code": "en-IN",
            "target_language_code": "kn-IN",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["source_language_code"], "en-IN")
        self.assertEqual(data["target_language_code"], "kn-IN")
        self.assertTrue(len(data["translated_text"]) > 0)
        self.assertIsInstance(data["translated_text"], str)

    def test_translate_english_to_hindi_live(self):
        """Verify real live translation of English to Hindi via Sarvam AI."""
        payload = {
            "input": "Your digital farming companion",
            "source_language_code": "en-IN",
            "target_language_code": "hi-IN",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["source_language_code"], "en-IN")
        self.assertEqual(data["target_language_code"], "hi-IN")
        self.assertTrue(len(data["translated_text"]) > 0)

    def test_translate_english_to_tamil_live(self):
        """Verify second language pair (English to Tamil) via Sarvam AI."""
        payload = {
            "input": "Today's Weather",
            "source_language_code": "en-IN",
            "target_language_code": "ta-IN",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["target_language_code"], "ta-IN")
        self.assertTrue(len(data["translated_text"]) > 0)

    def test_translate_same_language_passthrough(self):
        """Verify translating to same language returns original text immediately."""
        payload = {
            "input": "Hello Farmer",
            "source_language_code": "en-IN",
            "target_language_code": "en-IN",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["translated_text"], "Hello Farmer")
        self.assertEqual(data["request_id"], "identity_passthrough")

    def test_translate_cached_hit(self):
        """Verify repeated request hits cache without external API call."""
        payload = {
            "input": "Cache Test Text",
            "source_language_code": "en-IN",
            "target_language_code": "hi-IN",
        }
        res1 = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(res1.status_code, 200)

        res2 = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(res2.status_code, 200)
        self.assertEqual(res2.json()["request_id"], "cache_hit")

    def test_translate_invalid_source_code(self):
        """Verify invalid source language code is rejected with 400 Bad Request."""
        payload = {
            "input": "Hello",
            "source_language_code": "invalid-code",
            "target_language_code": "kn-IN",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(response.status_code, 400)
        self.assertIn("Unsupported source language code", response.json()["detail"])

    def test_translate_invalid_target_code(self):
        """Verify invalid target language code is rejected with 400 Bad Request."""
        payload = {
            "input": "Hello",
            "source_language_code": "en-IN",
            "target_language_code": "xyz-123",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertEqual(response.status_code, 400)
        self.assertIn("Unsupported target language code", response.json()["detail"])

    def test_translate_oversized_text(self):
        """Verify input text exceeding 2000 chars is rejected."""
        payload = {
            "input": "a" * 2005,
            "source_language_code": "en-IN",
            "target_language_code": "kn-IN",
        }
        response = self.client.post("/api/language/translate", json=payload)
        self.assertIn(response.status_code, [400, 422])


if __name__ == "__main__":
    unittest.main()
