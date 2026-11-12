import unittest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

from app.main import app
from app.config import settings
from app.routes.auth import validate_indian_phone, create_access_token, verify_token
from app.services.supabase_service import SupabaseService
from app.services.face_service import FaceService, FaceCompareResult


class TestSupabaseAuth(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_phone_normalization(self):
        """Test Indian mobile number validation and E.164 normalization."""
        self.assertEqual(validate_indian_phone("9876543210"), "+919876543210")
        self.assertEqual(validate_indian_phone("+919876543210"), "+919876543210")
        self.assertEqual(validate_indian_phone("919876543210"), "+919876543210")
        self.assertEqual(validate_indian_phone("09876543210"), "+919876543210")
        self.assertEqual(validate_indian_phone(" 98765-43210 "), "+919876543210")

        # Invalid starting digit or length
        with self.assertRaises(Exception):
            validate_indian_phone("1234567890")
        with self.assertRaises(Exception):
            validate_indian_phone("98765")

    def test_jwt_token_creation_and_verification(self):
        """Test JWT token encoding and identity verification."""
        token = create_access_token("test-farmer-uuid", "+919876543210")
        self.assertIsInstance(token, str)
        self.assertTrue(len(token) > 20)

        farmer_id, phone = verify_token(f"Bearer {token}")
        self.assertEqual(farmer_id, "test-farmer-uuid")
        self.assertEqual(phone, "+919876543210")

    def test_health_check_endpoint(self):
        """Verify health check reports accurate service configuration status."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "healthy")
        self.assertIn("supabase_configured", data)
        self.assertIn("facepp_configured", data)

    def test_unconfigured_endpoints_return_503(self):
        """Verify that when Supabase credentials are not set, endpoints reject access cleanly."""
        with patch.object(SupabaseService, "is_configured", return_value=False):
            # 1. check-phone
            res = self.client.get("/api/auth/check-phone?phone_number=%2B919876543210")
            self.assertEqual(res.status_code, 503)

            # 2. register
            res = self.client.post(
                "/api/auth/register",
                data={"phone_number": "+919876543210", "consent": "true"},
                files={"face_image": ("face.jpg", b"fake_content", "image/jpeg")},
            )
            self.assertEqual(res.status_code, 503)

            # 3. login
            res = self.client.post(
                "/api/auth/login",
                data={"phone_number": "+919876543210"},
                files={"face_image": ("face.jpg", b"fake_content", "image/jpeg")},
            )
            self.assertEqual(res.status_code, 503)

    @patch.object(SupabaseService, "is_configured", return_value=True)
    @patch.object(SupabaseService, "farmer_exists", return_value=False)
    @patch.object(SupabaseService, "upload_face_image", return_value="uuid-123/reference.jpg")
    @patch.object(SupabaseService, "create_farmer_record")
    def test_successful_registration_flow(
        self, mock_create, mock_upload, mock_exists, mock_is_conf
    ):
        """Test full successful registration with Supabase storage and table insertion."""
        mock_create.return_value = {
            "id": "uuid-123",
            "phone_number": "+919876543210",
            "face_image_path": "uuid-123/reference.jpg",
            "account_status": "active",
        }

        res = self.client.post(
            "/api/auth/register",
            data={"phone_number": "+919876543210", "consent": "true"},
            files={"face_image": ("face.jpg", b"valid_image_bytes", "image/jpeg")},
        )
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertIn("access_token", data)
        self.assertEqual(data["phone_number"], "+919876543210")
        self.assertFalse(data["is_demo"])
        self.assertTrue(mock_upload.called)
        self.assertTrue(mock_create.called)

    @patch.object(SupabaseService, "is_configured", return_value=True)
    @patch.object(SupabaseService, "farmer_exists", return_value=False)
    @patch.object(SupabaseService, "upload_face_image", return_value="uuid-123/reference.jpg")
    @patch.object(SupabaseService, "delete_face_image")
    @patch.object(SupabaseService, "create_farmer_record")
    def test_registration_storage_cleanup_on_db_failure(
        self, mock_create, mock_delete_image, mock_upload, mock_exists, mock_is_conf
    ):
        """Verify transactional rollback: deletes uploaded face image if DB insertion fails."""
        mock_create.side_effect = Exception("Database duplicate key or constraint error")

        res = self.client.post(
            "/api/auth/register",
            data={"phone_number": "+919876543210", "consent": "true"},
            files={"face_image": ("face.jpg", b"valid_image_bytes", "image/jpeg")},
        )
        self.assertEqual(res.status_code, 500)
        # Verify cleanup of the uploaded image was triggered
        mock_delete_image.assert_called_once_with("uuid-123/reference.jpg")

    @patch.object(SupabaseService, "is_configured", return_value=True)
    @patch.object(FaceService, "is_configured", return_value=True)
    @patch.object(SupabaseService, "get_farmer_by_phone")
    @patch.object(SupabaseService, "get_reference_face_image")
    @patch.object(FaceService, "compare_faces")
    def test_successful_login_flow(
        self, mock_compare, mock_get_ref, mock_get_farmer, mock_face_conf, mock_supa_conf
    ):
        """Test login with private Supabase image download and Face++ comparison."""
        mock_get_farmer.return_value = {
            "id": "uuid-123",
            "phone_number": "+919876543210",
            "face_image_path": "uuid-123/reference.jpg",
            "account_status": "active",
        }
        mock_get_ref.return_value = b"stored_reference_bytes"
        mock_compare.return_value = FaceCompareResult(
            success=True,
            confidence=95.2,
            threshold=80.0,
            message="Face verified successfully (confidence: 95.2%).",
        )

        res = self.client.post(
            "/api/auth/login",
            data={"phone_number": "+919876543210"},
            files={"face_image": ("login.jpg", b"login_face_bytes", "image/jpeg")},
        )
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertTrue(data["success"])
        self.assertEqual(data["confidence"], 95.2)
        self.assertIsNotNone(data["token"])
        self.assertEqual(data["token"]["farmer_id"], "uuid-123")

    @patch.object(SupabaseService, "is_configured", return_value=True)
    @patch.object(SupabaseService, "get_farmer_by_id")
    @patch.object(SupabaseService, "delete_farmer_account", return_value=True)
    def test_account_deletion_with_jwt_token(
        self, mock_delete, mock_get_id, mock_is_conf
    ):
        """Test account deletion using JWT authentication token."""
        mock_get_id.return_value = {
            "id": "uuid-123",
            "phone_number": "+919876543210",
            "face_image_path": "uuid-123/reference.jpg",
        }

        token = create_access_token("uuid-123", "+919876543210")
        res = self.client.delete(
            "/api/auth/account",
            headers={"Authorization": f"Bearer {token}"},
        )
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertTrue(data["success"])
        mock_delete.assert_called_once_with("uuid-123", "uuid-123/reference.jpg")


if __name__ == "__main__":
    unittest.main()
