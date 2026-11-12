import logging
import uuid
from datetime import datetime
from typing import Optional, Dict, Any, List

from supabase import create_client, Client
from app.config import settings

logger = logging.getLogger("chiptocrop.supabase_service")


class SupabaseService:
    _client: Optional[Client] = None

    @classmethod
    def initialize(cls) -> None:
        """Initializes the official Supabase client using server-side credentials."""
        if settings.supabase_url and settings.supabase_secret_key:
            try:
                # Normalize URL: strip PostgREST/Storage endpoints and trailing slashes if present
                clean_url = (
                    settings.supabase_url.split("/rest/v1")[0]
                    .split("/storage/v1")[0]
                    .rstrip("/")
                )
                cls._client = create_client(
                    supabase_url=clean_url,
                    supabase_key=settings.supabase_secret_key,
                )
                logger.info("Supabase client initialized successfully with server credentials.")
            except Exception as e:
                logger.error(f"Failed to initialize Supabase client: {str(e)}")
                cls._client = None
        else:
            cls._client = None
            logger.warning(
                "Supabase URL or Secret Key not configured in .env. "
                "Backend will report service unconfigured and require valid credentials."
            )

    @classmethod
    def get_client(cls) -> Client:
        """Returns the active Supabase client or raises an error if not configured."""
        if cls._client is None:
            cls.initialize()
        if cls._client is None:
            raise RuntimeError(
                "Supabase service is not configured. "
                "Please configure SUPABASE_URL and SUPABASE_SECRET_KEY in backend/.env."
            )
        return cls._client

    @classmethod
    def is_configured(cls) -> bool:
        """Checks whether Supabase credentials have been provided and the client is ready."""
        if cls._client is None:
            cls.initialize()
        return cls._client is not None

    @classmethod
    def check_connection(cls) -> bool:
        """Verifies database connectivity against public.farmers table."""
        if not cls.is_configured():
            return False
        try:
            client = cls.get_client()
            # Perform a lightweight metadata probe
            res = client.table(settings.supabase_table_name).select("id").limit(1).execute()
            return res is not None
        except Exception as e:
            logger.error(f"Database connectivity check failed: {str(e)}")
            return False

    @classmethod
    def farmer_exists(cls, phone_number: str) -> bool:
        """Checks if a normalized mobile number is already registered in public.farmers."""
        farmer = cls.get_farmer_by_phone(phone_number)
        return farmer is not None

    @classmethod
    def get_farmer_by_phone(cls, phone_number: str) -> Optional[Dict[str, Any]]:
        """Queries public.farmers by normalized E.164 phone number."""
        client = cls.get_client()
        try:
            res = (
                client.table(settings.supabase_table_name)
                .select("*")
                .eq("phone_number", phone_number)
                .limit(1)
                .execute()
            )
            if res.data and len(res.data) > 0:
                return res.data[0]
            return None
        except Exception as e:
            logger.error(f"Error querying farmer by phone: {str(e)}")
            raise

    @classmethod
    def get_farmer_by_id(cls, farmer_id: str) -> Optional[Dict[str, Any]]:
        """Queries public.farmers by primary key UUID."""
        client = cls.get_client()
        try:
            res = (
                client.table(settings.supabase_table_name)
                .select("*")
                .eq("id", farmer_id)
                .limit(1)
                .execute()
            )
            if res.data and len(res.data) > 0:
                return res.data[0]
            return None
        except Exception as e:
            logger.error(f"Error querying farmer by ID: {str(e)}")
            raise

    @classmethod
    def upload_face_image(
        cls,
        farmer_id: str,
        image_bytes: bytes,
        filename: str = "reference.jpg",
    ) -> str:
        """
        Uploads reference face photograph to private Supabase Storage bucket.
        Returns the internal private storage path: '{farmer_id}/{filename}'.
        Never stores or returns public image URLs.
        """
        client = cls.get_client()
        storage_path = f"{farmer_id}/{filename}"
        try:
            client.storage.from_(settings.supabase_storage_bucket).upload(
                path=storage_path,
                file=image_bytes,
                file_options={"content-type": "image/jpeg", "upsert": "true"},
            )
            logger.info(f"Biometric face image uploaded successfully to private storage: {storage_path}")
            return storage_path
        except Exception as e:
            logger.error(f"Failed to upload face image to Supabase Storage: {str(e)}")
            raise

    @classmethod
    def get_reference_face_image(
        cls,
        farmer_id: str,
        face_image_path: Optional[str] = None,
    ) -> Optional[bytes]:
        """
        Downloads the farmer's registered reference face photograph
        directly from the private Supabase Storage bucket.
        """
        client = cls.get_client()
        path = face_image_path or f"{farmer_id}/reference.jpg"
        try:
            data = client.storage.from_(settings.supabase_storage_bucket).download(path)
            return data
        except Exception as e:
            logger.error(f"Failed to download reference image for farmer {farmer_id}: {str(e)}")
            return None

    @classmethod
    def create_farmer_record(
        cls,
        farmer_id: str,
        phone_number: str,
        face_image_path: str,
        biometric_consent: bool,
    ) -> Dict[str, Any]:
        """Inserts a new farmer profile row into public.farmers."""
        client = cls.get_client()
        now_iso = datetime.utcnow().isoformat()
        payload = {
            "id": farmer_id,
            "phone_number": phone_number,
            "face_image_path": face_image_path,
            "biometric_consent": biometric_consent,
            "consent_timestamp": now_iso,
            "account_status": "active",
            "created_at": now_iso,
            "updated_at": now_iso,
        }
        try:
            res = client.table(settings.supabase_table_name).insert(payload).execute()
            if res.data and len(res.data) > 0:
                return res.data[0]
            return payload
        except Exception as e:
            logger.error(f"Database insertion failed for farmer {farmer_id}: {str(e)}")
            raise

    @classmethod
    def delete_face_image(cls, face_image_path: str) -> bool:
        """Removes a biometric image from private Supabase Storage."""
        client = cls.get_client()
        try:
            client.storage.from_(settings.supabase_storage_bucket).remove([face_image_path])
            logger.info(f"Deleted private face image: {face_image_path}")
            return True
        except Exception as e:
            logger.error(f"Failed to delete face image {face_image_path}: {str(e)}")
            return False

    @classmethod
    def delete_farmer_account(
        cls,
        farmer_id: str,
        face_image_path: Optional[str] = None,
    ) -> bool:
        """
        Permanently deletes the farmer record from public.farmers
        and removes the private reference photograph from Supabase Storage.
        """
        client = cls.get_client()
        # 1. Delete private biometric photo from Storage
        path = face_image_path or f"{farmer_id}/reference.jpg"
        cls.delete_face_image(path)

        # 2. Delete row from public.farmers
        try:
            res = (
                client.table(settings.supabase_table_name)
                .delete()
                .eq("id", farmer_id)
                .execute()
            )
            logger.info(f"Deleted farmer record from database: {farmer_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to delete farmer record {farmer_id}: {str(e)}")
            return False

