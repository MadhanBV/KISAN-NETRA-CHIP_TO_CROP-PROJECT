import logging
from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.models.auth_models import HealthCheckResponse
from app.routes.auth import router as auth_router
from app.routes.language import router as language_router
from app.routes.mandi import router as mandi_router
from app.routes.crop import router as crop_router
from app.routes.voice import router as voice_router
from app.routes.community import router as community_router
from app.services.face_service import FaceService
from app.services.mandi_service import MandiService
from app.services.sarvam_service import SarvamService
from app.services.supabase_service import SupabaseService

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("chiptocrop.main")

app = FastAPI(
    title="CHIP TO CROP - Farmer Authentication Service",
    description="Phone + Face Biometric Authentication API with Supabase & Face++ for Indian Farmers",
    version="1.0.0",
)

# Enable CORS for Flutter mobile client
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(language_router)
app.include_router(mandi_router)
app.include_router(crop_router)
app.include_router(voice_router)
app.include_router(community_router)


@app.on_event("startup")
async def startup_event():
    logger.info("Starting CHIP TO CROP Backend Services (Supabase + Face++ + Sarvam AI + Mandi API)...")
    SupabaseService.initialize()
    if SupabaseService.is_configured():
        logger.info("Supabase client is configured and ready.")
    else:
        logger.warning(
            "Supabase credentials not configured in backend/.env. "
            "Please provide SUPABASE_URL and SUPABASE_SECRET_KEY to enable database & storage operations."
        )

    if FaceService.is_configured():
        logger.info("Face++ Compare API is configured.")
    else:
        logger.warning(
            "Face++ Compare API endpoint is pending configuration in .env. "
            "Please provide FACEPP_COMPARE_URL to enable live facial comparisons."
        )

    if SarvamService.is_configured():
        logger.info("Sarvam AI Translation Service is configured and ready.")
    else:
        logger.warning(
            "Sarvam AI credentials not configured in backend/.env. "
            "Please provide SARVAM_API_KEY to enable Indian language translations."
        )

    if MandiService.is_configured():
        logger.info("Government of India Mandi API (data.gov.in) is configured and ready.")
    else:
        logger.warning(
            "DATA_GOV_IN_API_KEY not configured in backend/.env. "
            "Please provide DATA_GOV_IN_API_KEY to enable live mandi price feeds."
        )


@app.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """Health check endpoint confirming service status and backend readiness."""
    return HealthCheckResponse(
        status="healthy",
        app_name="CHIP TO CROP Backend Service",
        version="1.0.0",
        supabase_configured=SupabaseService.is_configured(),
        facepp_configured=FaceService.is_configured(),
        sarvam_configured=SarvamService.is_configured(),
        mandi_configured=MandiService.is_configured(),
        timestamp=datetime.utcnow(),
    )
