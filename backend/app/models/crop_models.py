from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class BoundingBox(BaseModel):
    x1: float
    y1: float
    x2: float
    y2: float

class DetectionItem(BaseModel):
    class_name: str
    class_id: int
    confidence: float
    crop: str
    condition: str
    is_healthy: bool
    box: BoundingBox
    box_normalized: BoundingBox

class DiagnosisContent(BaseModel):
    overview: str = ""
    symptoms: List[str] = Field(default_factory=list)
    causes: List[str] = Field(default_factory=list)
    favorable_conditions: List[str] = Field(default_factory=list)
    severity: str = "Standard"
    organic_management: List[str] = Field(default_factory=list)
    chemical_management: List[str] = Field(default_factory=list)
    prevention: List[str] = Field(default_factory=list)
    farmer_recommendations: List[str] = Field(default_factory=list)

class KnowledgeSource(BaseModel):
    source_file: str
    crop: str
    section: str
    similarity: float

class CropDiagnosisResponse(BaseModel):
    success: bool = True
    crop: str
    detected_condition: str
    class_name: str
    confidence: float
    is_healthy: bool
    image_width: int
    image_height: int
    detections: List[DetectionItem] = Field(default_factory=list)
    diagnosis: DiagnosisContent
    knowledge_sources: List[KnowledgeSource] = Field(default_factory=list)
    disclaimer: str = (
        "This is an AI-assisted preliminary diagnosis powered by YOLO26s and "
        "agricultural RAG documentation. It does not replace laboratory culture analysis. "
        "Consult your local Krishi Vigyan Kendra (KVK) officer before applying chemical sprays."
    )
    language: str = "en"

class ModelStatusResponse(BaseModel):
    yolo_model_available: bool
    yolo_model_loaded: bool
    yolo_model_path: str
    num_classes: int
    class_names: Dict[int, str]
    rag_engine_available: bool
    rag_engine_url: str
    rag_engine_details: Optional[Dict[str, Any]] = None

class AssistantChatRequest(BaseModel):
    question: str
    crop: Optional[str] = None
    language: str = "en"

class AssistantChatResponse(BaseModel):
    success: bool = True
    question: str
    crop: Optional[str] = None
    answer: str
    knowledge_sources: List[KnowledgeSource] = Field(default_factory=list)
    language: str = "en"


# =========================================================================
# CROP QUALITY DETECTION MODELS
# =========================================================================

class QualityDetectionItem(BaseModel):
    class_name: str
    class_id: int
    confidence: float
    crop: str
    quality_status: str  # "Fresh" or "Rotten"
    is_fresh: bool
    grade_label: str  # e.g. "Grade A (Prime Quality)" or "Damaged / Spoilage Detected"
    box: BoundingBox
    box_normalized: BoundingBox


class QualityReportContent(BaseModel):
    overview: str = ""
    freshness_score: str = ""
    market_grade: str = "Grade A"
    shelf_life_estimate: str = ""
    storage_guidelines: List[str] = Field(default_factory=list)
    packaging_and_handling: List[str] = Field(default_factory=list)
    segregation_and_sanitation: List[str] = Field(default_factory=list)
    mandi_advisory: List[str] = Field(default_factory=list)
    prevention_of_spoilage: List[str] = Field(default_factory=list)


class CropQualityResponse(BaseModel):
    success: bool = True
    crop: str
    quality_status: str
    class_name: str
    confidence: float
    is_fresh: bool
    grade_label: str
    image_width: int
    image_height: int
    detections: List[QualityDetectionItem] = Field(default_factory=list)
    quality_report: QualityReportContent
    knowledge_sources: List[KnowledgeSource] = Field(default_factory=list)
    disclaimer: str = (
        "This is an AI-assisted crop quality and freshness assessment powered by YOLO "
        "and agricultural RAG documentation. Inspect physical lots thoroughly before mandi auction."
    )
    language: str = "en"


