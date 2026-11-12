import logging
from typing import Optional
from fastapi import APIRouter, File, UploadFile, Form, HTTPException, status

from app.config import settings
from app.models.crop_models import (
    CropDiagnosisResponse,
    DiagnosisContent,
    ModelStatusResponse,
    AssistantChatRequest,
    AssistantChatResponse,
    CropQualityResponse,
    QualityDetectionItem,
    QualityReportContent,
)
from app.services.yolo_service import YOLOService
from app.services.quality_service import QualityService
from app.services.crop_disease_model_service import CropDiseaseModelService
from app.services.rag_client_service import RAGClientService

logger = logging.getLogger("chiptocrop.routes.crop")

router = APIRouter(prefix="/api/crop", tags=["Crop Disease Detection & Advisory"])

_yolo_service = YOLOService()
_quality_service = QualityService()
_crop_disease_model_service = CropDiseaseModelService()
_rag_client = RAGClientService()

@router.get("/models/status", response_model=ModelStatusResponse)
async def get_models_status():
    """
    Returns the real-time operational status of the YOLO26s leaf disease model
    and the agricultural RAG engine service.
    """
    yolo_file = _yolo_service.is_model_file_present()
    yolo_loaded = _yolo_service.is_model_loaded()
    classes = _yolo_service.get_class_names()
    rag_health = _rag_client.check_health()

    return ModelStatusResponse(
        yolo_model_available=yolo_file,
        yolo_model_loaded=yolo_loaded,
        yolo_model_path=_yolo_service.model_path,
        num_classes=len(classes),
        class_names=classes,
        rag_engine_available=rag_health.get("connected", False),
        rag_engine_url=_rag_client.base_url,
        rag_engine_details=rag_health.get("details")
    )

@router.post("/diagnose", response_model=CropDiagnosisResponse)
def diagnose_crop_image(
    image: UploadFile = File(..., description="Crop leaf photograph (JPEG/PNG/WEBP)"),
    language: Optional[str] = Form("en", description="Selected farmer language code (e.g. en, hi, te, kn)"),
    crop_type: Optional[str] = Form(None, description="Optional crop hint (e.g. tomato, mango)")
):
    """
    Complete end-to-end diagnosis pipeline:
    1. Validates and processes the leaf image.
    2. Runs lazy-loaded YOLO26s inference for leaf disease detection.
    3. Normalizes detection into Crop and Condition.
    4. Connects to the RAG engine for grounded agricultural advisories.
    5. Returns a structured, farmer-friendly diagnosis report.
    """
    # Accept standard image MIME types, application/octet-stream, or common image extensions
    allowed_types = ["image/jpeg", "image/png", "image/webp", "image/jpg", "application/octet-stream"]
    is_valid_type = any(image.content_type.startswith(t) for t in allowed_types) if image.content_type else False
    is_valid_filename = any(image.filename.lower().endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp"]) if image.filename else False
    
    if not (is_valid_type or is_valid_filename):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Please upload a JPEG, PNG, or WEBP image."
        )

    try:
        image_bytes = image.file.read()
        if len(image_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty image file received."
            )

        # 1. Execute YOLO26s Inference
        inference_result = _yolo_service.predict(image_bytes)
        img_width = inference_result["image_width"]
        img_height = inference_result["image_height"]
        detections = inference_result["detections"]
        top_detection = inference_result["top_detection"]

        # 2. Extract detected crop & condition
        if top_detection:
            detected_crop = top_detection.crop
            detected_condition = top_detection.condition
            class_name = top_detection.class_name
            confidence = top_detection.confidence
            is_healthy = top_detection.is_healthy
        else:
            # Fallback if no specific leaf spot met the threshold
            detected_crop = (crop_type or "Crop").title()
            detected_condition = "No Visible Disease"
            class_name = f"{detected_crop.upper()}_HEALTHY"
            confidence = 0.85
            is_healthy = True

        # 3. Retrieve RAG grounded advisory & citations
        diagnosis, sources = _rag_client.get_disease_advisory(
            crop=detected_crop,
            condition=detected_condition,
            confidence=confidence,
            is_healthy=is_healthy,
            language=language or "en"
        )

        return CropDiagnosisResponse(
            success=True,
            crop=detected_crop,
            detected_condition=detected_condition,
            class_name=class_name,
            confidence=confidence,
            is_healthy=is_healthy,
            image_width=img_width,
            image_height=img_height,
            detections=detections,
            diagnosis=diagnosis,
            knowledge_sources=sources,
            language=language or "en"
        )

    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(ve)
        )
    except Exception as e:
        logger.error(f"Crop diagnosis failed: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference and diagnosis failed: {str(e)}"
        )

@router.post("/chat", response_model=AssistantChatResponse)
def chat_with_assistant(request: AssistantChatRequest):
    """
    Conversational AI Assistant endpoint for Indian farmers.
    Accepts agricultural questions, retrieves grounded ChromaDB passages,
    generates responses via Qwen3, and supports regional languages.
    """
    if not request.question or not request.question.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Question cannot be empty."
        )

    try:
        answer, sources = _rag_client.ask_assistant(
            question=request.question.strip(),
            crop=request.crop,
            language=request.language
        )
        return AssistantChatResponse(
            success=True,
            question=request.question,
            crop=request.crop,
            answer=answer,
            knowledge_sources=sources,
            language=request.language
        )
    except Exception as e:
        logger.error(f"Chat failed: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI chat error: {str(e)}"
        )

@router.get("/quality/status")
async def get_quality_status():
    """
    Returns the operational status of the Crop Quality (Fresh vs Rotten) YOLO model
    and the agricultural RAG engine service.
    """
    quality_file = _quality_service.is_model_file_present()
    quality_loaded = _quality_service.is_model_loaded()
    classes = _quality_service.get_class_names()
    rag_health = _rag_client.check_health()

    return {
        "quality_model_available": quality_file,
        "quality_model_loaded": quality_loaded,
        "quality_model_path": _quality_service.model_path,
        "num_classes": len(classes),
        "class_names": classes,
        "rag_engine_available": rag_health.get("connected", False),
        "rag_engine_url": _rag_client.base_url
    }

@router.post("/quality/analyze", response_model=CropQualityResponse)
def analyze_crop_quality(
    image: UploadFile = File(..., description="Crop produce photograph (JPEG/PNG/WEBP)"),
    language: Optional[str] = Form("en", description="Selected farmer language code (e.g. en, hi, te, kn)"),
    crop_type: Optional[str] = Form(None, description="Optional crop hint (e.g. Tomato, Mango, Potato, Banana)")
):
    """
    Quality & Freshness Assessment pipeline:
    1. Validates and decodes crop produce image.
    2. Runs Quality YOLO inference (detects Fresh vs Rotten for Mango, Potato, Tomato, Banana).
    3. Queries RAG engine for post-harvest storage, shelf-life, and mandi grading advisory.
    4. Returns rich quality report with freshness score, storage guidelines, and market recommendations.
    """
    allowed_types = ["image/jpeg", "image/png", "image/webp", "image/jpg", "application/octet-stream"]
    is_valid_type = any(image.content_type.startswith(t) for t in allowed_types) if image.content_type else False
    is_valid_filename = any(image.filename.lower().endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp"]) if image.filename else False

    if not (is_valid_type or is_valid_filename):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Please upload a JPEG, PNG, or WEBP image."
        )

    try:
        image_bytes = image.file.read()
        if len(image_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty image file received."
            )

        # 1. Execute Quality YOLO Inference
        inference_result = _quality_service.predict(image_bytes)
        img_width = inference_result["image_width"]
        img_height = inference_result["image_height"]
        detections = inference_result["detections"]
        top_detection = inference_result["top_detection"]

        # 2. Extract detected quality status
        if top_detection:
            crop = top_detection.crop
            quality_status = top_detection.quality_status
            class_name = top_detection.class_name
            confidence = top_detection.confidence
            is_fresh = top_detection.is_fresh
            grade_label = top_detection.grade_label
        else:
            # Fallback if no specific bounding box met threshold
            crop = (crop_type or "Produce").title()
            quality_status = "Fresh"
            class_name = f"fresh_{crop.lower()}"
            confidence = 0.82
            is_fresh = True
            grade_label = "Grade A (Standard Produce)"

        # 3. Retrieve RAG grounded quality and post-harvest advisory
        report, sources = _rag_client.get_quality_advisory(
            crop=crop,
            quality_status=quality_status,
            confidence=confidence,
            is_fresh=is_fresh,
            language=language or "en"
        )

        return CropQualityResponse(
            success=True,
            crop=crop,
            quality_status=quality_status,
            class_name=class_name,
            confidence=confidence,
            is_fresh=is_fresh,
            grade_label=grade_label,
            image_width=img_width,
            image_height=img_height,
            detections=detections,
            quality_report=report,
            knowledge_sources=sources,
            language=language or "en"
        )

    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(ve)
        )
    except Exception as e:
        logger.error(f"Crop quality analysis failed: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Quality analysis failed: {str(e)}"
        )


@router.get("/disease-detection/status")
async def get_disease_detection_status():
    """
    Returns the operational status of Crop Disease Model 3
    (Banana Anthracnose, Mango Anthracnose, Mango Stem End Rot,
     Potato Blackspot Bruising, Potato Dry Rot) and RAG connectivity.
    """
    model_file = _crop_disease_model_service.is_model_file_present()
    model_loaded = _crop_disease_model_service.is_model_loaded()
    classes = _crop_disease_model_service.get_class_names()
    rag_health = _rag_client.check_health()

    return {
        "disease_model_available": model_file,
        "disease_model_loaded": model_loaded,
        "disease_model_path": _crop_disease_model_service.model_path,
        "num_classes": len(classes),
        "class_names": classes,
        "rag_engine_available": rag_health.get("connected", False),
        "rag_engine_url": _rag_client.base_url,
    }


@router.post("/disease-detection/diagnose", response_model=CropDiagnosisResponse)
def diagnose_crop_disease_image(
    image: UploadFile = File(..., description="Crop or fruit photograph (JPEG/PNG/WEBP)"),
    language: Optional[str] = Form("en", description="Selected farmer language code (e.g. en, hi, te, kn)"),
    crop_type: Optional[str] = Form(None, description="Optional crop hint (e.g. Banana, Mango, Potato)")
):
    """
    Complete end-to-end Crop Disease detection pipeline using Model 3:
    1. Validates and processes the crop/fruit image.
    2. Runs lazy-loaded Model 3 inference for crop & fruit disease detection.
    3. Normalizes detection into Crop and Condition.
    4. Connects to the RAG engine for grounded agricultural advisories.
    5. Returns a structured, farmer-friendly diagnosis report.
    """
    allowed_types = ["image/jpeg", "image/png", "image/webp", "image/jpg", "application/octet-stream"]
    is_valid_type = any(image.content_type.startswith(t) for t in allowed_types) if image.content_type else False
    is_valid_filename = any(image.filename.lower().endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp"]) if image.filename else False

    if not (is_valid_type or is_valid_filename):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Please upload a JPEG, PNG, or WEBP image."
        )

    try:
        image_bytes = image.file.read()
        if len(image_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty image file received."
            )

        # 1. Execute Crop Disease Model 3 Inference
        inference_result = _crop_disease_model_service.predict(image_bytes)
        img_width = inference_result["image_width"]
        img_height = inference_result["image_height"]
        detections = inference_result["detections"]
        top_detection = inference_result["top_detection"]

        # 2. Extract detected crop & condition
        if top_detection:
            detected_crop = top_detection.crop
            detected_condition = top_detection.condition
            class_name = top_detection.class_name
            confidence = top_detection.confidence
            is_healthy = top_detection.is_healthy
        else:
            detected_crop = (crop_type or "Crop").title()
            detected_condition = "No Visible Disease"
            class_name = f"{detected_crop.upper()}_HEALTHY"
            confidence = 0.85
            is_healthy = True

        # 3. Retrieve RAG grounded agricultural advisory & citations
        diagnosis, sources = _rag_client.get_disease_advisory(
            crop=detected_crop,
            condition=detected_condition,
            confidence=confidence,
            is_healthy=is_healthy,
            language=language or "en"
        )

        return CropDiagnosisResponse(
            success=True,
            crop=detected_crop,
            detected_condition=detected_condition,
            class_name=class_name,
            confidence=confidence,
            is_healthy=is_healthy,
            image_width=img_width,
            image_height=img_height,
            detections=detections,
            diagnosis=diagnosis,
            knowledge_sources=sources,
            disclaimer=(
                "This is an AI-assisted preliminary diagnosis powered by YOLO26 and "
                "agricultural RAG documentation. It does not replace laboratory culture analysis. "
                "Consult your local Krishi Vigyan Kendra (KVK) officer before applying chemical sprays."
            ),
            language=language or "en"
        )

    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(ve)
        )
    except Exception as e:
        logger.error(f"Crop disease diagnosis failed: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference and diagnosis failed: {str(e)}"
        )
