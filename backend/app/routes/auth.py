import re
import time
import uuid
import logging
from datetime import datetime, timedelta
from typing import Dict, Tuple, Optional

from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Header, Query, status
from jose import jwt, JWTError

from app.config import settings
from app.models.auth_models import (
    CheckPhoneResponse,
    TokenResponse,
    FaceVerifyResponse,
)
from app.services.face_service import FaceService
from app.services.supabase_service import SupabaseService

logger = logging.getLogger("chiptocrop.auth_routes")

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

# Failed attempt tracking per phone number: {clean_phone: (failed_count, lockout_until_timestamp)}
_FAILED_ATTEMPTS: Dict[str, Tuple[int, float]] = {}

MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024  # 5 MB
ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp", "image/jpg", "application/octet-stream"}


def validate_indian_phone(phone: str) -> str:
    """Validates and normalizes a 10-digit Indian phone number to E.164 (+91...)."""
    clean = re.sub(r"[^\d+]", "", phone)
    if clean.startswith("+91"):
        digits = clean[3:]
    elif clean.startswith("91") and len(clean) == 12:
        digits = clean[2:]
    elif clean.startswith("0") and len(clean) == 11:
        digits = clean[1:]
    else:
        digits = clean

    if not re.match(r"^[6-9]\d{9}$", digits):
        raise HTTPException(
            status_code=422,
            detail="Invalid Indian mobile number. Must be a 10-digit number starting with 6, 7, 8, or 9.",
        )
    return f"+91{digits}"


def create_access_token(farmer_id: str, phone_number: str) -> str:
    """Generates an expiring JWT access token."""
    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode = {
        "sub": farmer_id,
        "phone": phone_number,
        "exp": expire,
        "iat": datetime.utcnow(),
        "iss": "chiptocrop-auth",
    }
    return jwt.encode(to_encode, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def verify_token(authorization: Optional[str]) -> Tuple[str, str]:
    """Validates the Authorization: Bearer <token> header and extracts farmer identity."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or malformed Authorization header.",
        )
    token = authorization.split(" ")[1]
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
        )
        farmer_id = payload.get("sub")
        phone = payload.get("phone")
        if not farmer_id or not phone:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token payload.",
            )
        return farmer_id, phone
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token.",
        )


@router.get("/check-phone", response_model=CheckPhoneResponse)
async def check_phone(phone_number: str):
    """Check if a mobile number is already registered in public.farmers."""
    if not SupabaseService.is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase backend is not configured. Please configure SUPABASE_URL and SUPABASE_SECRET_KEY in backend/.env",
        )

    clean_phone = validate_indian_phone(phone_number)
    try:
        exists = SupabaseService.farmer_exists(clean_phone)
        return CheckPhoneResponse(
            phone_number=clean_phone,
            exists=exists,
            message="Farmer account found." if exists else "Mobile number is not registered.",
        )
    except Exception as e:
        logger.error(f"Error checking phone in Supabase: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to query farmer database.",
        )


@router.post("/register", response_model=TokenResponse)
async def register(
    phone_number: str = Form(...),
    consent: bool = Form(...),
    face_image: UploadFile = File(...),
):
    """
    Registers a new farmer with their mobile number, explicit biometric consent,
    and a reference face photograph saved securely to private Supabase Storage.
    """
    if not SupabaseService.is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase backend is not configured. Please configure SUPABASE_URL and SUPABASE_SECRET_KEY in backend/.env",
        )

    if not consent:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Biometric consent is required to register.",
        )

    clean_phone = validate_indian_phone(phone_number)

    if SupabaseService.farmer_exists(clean_phone):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This mobile number is already registered. Please proceed to Login.",
        )

    # Read and validate image
    image_bytes = await face_image.read()
    if len(image_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Face image file is empty.",
        )
    if len(image_bytes) > MAX_IMAGE_SIZE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image file size exceeds the 5 MB limit.",
        )

    # 1. Generate unique UUID for the farmer
    farmer_id = str(uuid.uuid4())

    # 2. Upload reference photograph to private Supabase Storage
    try:
        storage_path = SupabaseService.upload_face_image(
            farmer_id=farmer_id,
            image_bytes=image_bytes,
            filename="reference.jpg",
        )
    except Exception as upload_err:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload reference face image to private storage: {str(upload_err)}",
        )

    # 3. Insert record into public.farmers
    try:
        farmer_record = SupabaseService.create_farmer_record(
            farmer_id=farmer_id,
            phone_number=clean_phone,
            face_image_path=storage_path,
            biometric_consent=consent,
        )
    except Exception as db_err:
        # Transactional rollback: clean up uploaded storage image
        logger.warning(f"Database insertion failed for farmer {farmer_id}. Rolling back storage upload...")
        try:
            SupabaseService.delete_face_image(storage_path)
        except Exception as cleanup_err:
            logger.error(f"Storage rollback cleanup error: {str(cleanup_err)}")

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database record insertion failed: {str(db_err)}",
        )

    token = create_access_token(farmer_id, clean_phone)

    return TokenResponse(
        access_token=token,
        farmer_id=farmer_id,
        phone_number=clean_phone,
        is_demo=False,
        message="Registration successful! Your biometric face profile is secured.",
    )


@router.post("/login", response_model=FaceVerifyResponse)
async def login(
    phone_number: str = Form(...),
    face_image: UploadFile = File(...),
):
    """
    Authenticates a farmer:
    1. Verifies phone number exists in public.farmers.
    2. Retrieves reference face image from private Supabase Storage.
    3. Compares with newly captured face image via Face++ Compare API.
    4. Evaluates confidence against threshold.
    5. Issues JWT token upon successful match.
    """
    if not SupabaseService.is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase backend is not configured. Please configure SUPABASE_URL and SUPABASE_SECRET_KEY in backend/.env",
        )

    if not FaceService.is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Face++ Compare API is not configured. Please set FACEPP_COMPARE_URL in backend/.env",
        )

    clean_phone = validate_indian_phone(phone_number)

    # Rate limiting & lockout check
    now = time.time()
    if clean_phone in _FAILED_ATTEMPTS:
        count, lockout_until = _FAILED_ATTEMPTS[clean_phone]
        if lockout_until > now:
            wait_seconds = int(lockout_until - now)
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Too many failed verification attempts. Please wait {wait_seconds} seconds before trying again.",
            )

    farmer_data = SupabaseService.get_farmer_by_phone(clean_phone)
    if not farmer_data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Mobile number not registered. Please register first.",
        )

    if farmer_data.get("account_status") != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Farmer account is not active. Please contact support.",
        )

    farmer_id = str(farmer_data.get("id"))
    face_image_path = farmer_data.get("face_image_path") or f"{farmer_id}/reference.jpg"

    # Read login image
    login_image_bytes = await face_image.read()
    if len(login_image_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Login face image is empty.",
        )
    if len(login_image_bytes) > MAX_IMAGE_SIZE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image file size exceeds the 5 MB limit.",
        )

    # Fetch reference image from private Supabase Storage
    reference_image_bytes = SupabaseService.get_reference_face_image(farmer_id, face_image_path)
    if not reference_image_bytes:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Registered reference face image not found in private storage. Please contact support.",
        )

    # Call Face++ 1:1 comparison
    compare_result = FaceService.compare_faces(
        image_bytes1=reference_image_bytes,
        image_bytes2=login_image_bytes,
    )

    if compare_result.success:
        # Reset failed attempts on success
        _FAILED_ATTEMPTS.pop(clean_phone, None)
        token = create_access_token(farmer_id, clean_phone)

        token_obj = TokenResponse(
            access_token=token,
            farmer_id=farmer_id,
            phone_number=clean_phone,
            is_demo=False,
            message="Face verification successful.",
        )

        return FaceVerifyResponse(
            success=True,
            confidence=compare_result.confidence,
            threshold=compare_result.threshold,
            message=compare_result.message,
            token=token_obj,
        )
    else:
        # Record failure and calculate remaining attempts
        current_count, _ = _FAILED_ATTEMPTS.get(clean_phone, (0, 0))
        new_count = current_count + 1
        lockout = now + 300 if new_count >= settings.max_failed_login_attempts else 0
        _FAILED_ATTEMPTS[clean_phone] = (new_count, lockout)

        remaining = max(0, settings.max_failed_login_attempts - new_count)

        return FaceVerifyResponse(
            success=False,
            confidence=compare_result.confidence,
            threshold=compare_result.threshold,
            message=compare_result.message,
            remaining_attempts=remaining,
        )


@router.delete("/account")
async def delete_account(
    phone_number: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    """
    Deletes the farmer's account and removes their biometric face photograph from Supabase.
    Authenticates the requesting farmer using their JWT token or verified phone number.
    """
    if not SupabaseService.is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase backend is not configured.",
        )

    farmer_id: Optional[str] = None
    face_path: Optional[str] = None

    if authorization:
        auth_farmer_id, auth_phone = verify_token(authorization)
        farmer_data = SupabaseService.get_farmer_by_id(auth_farmer_id)
        if not farmer_data:
            raise HTTPException(status_code=404, detail="Account not found.")
        farmer_id = auth_farmer_id
        face_path = farmer_data.get("face_image_path")
    elif phone_number:
        clean_phone = validate_indian_phone(phone_number)
        farmer_data = SupabaseService.get_farmer_by_phone(clean_phone)
        if not farmer_data:
            raise HTTPException(status_code=404, detail="Account not found.")
        farmer_id = str(farmer_data.get("id"))
        face_path = farmer_data.get("face_image_path")
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either valid Authorization token or registered phone_number must be provided.",
        )

    success = SupabaseService.delete_farmer_account(farmer_id, face_path)
    if success:
        return {"success": True, "message": "Farmer account and biometric reference image deleted permanently."}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete farmer account.")
