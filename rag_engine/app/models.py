from typing import List, Optional, Literal, Dict, Any
from pydantic import BaseModel, Field

class Chunk(BaseModel):
    chunk_id: str
    source_file: str
    crop: str
    source_type: str
    section: str
    chunk_index: int
    text: str

    def to_metadata(self) -> Dict[str, Any]:
        return {
            "source_file": self.source_file,
            "crop": self.crop,
            "source_type": self.source_type,
            "section": self.section,
            "chunk_index": self.chunk_index,
        }

class RetrievedPassage(BaseModel):
    chunk_id: str
    source_file: str
    crop: str
    source_type: str
    section: str
    text: str
    score: float = Field(..., description="Cosine similarity or distance score")

class QueryRequest(BaseModel):
    question: str = Field(..., min_length=2, description="Farmer's question")
    crop: Optional[str] = Field(None, description="Optional crop filter, e.g. tomato, banana, mango, potato")
    mode: Literal["farmer_assistance", "disease_advisory"] = "farmer_assistance"
    top_k: int = Field(5, ge=1, le=15, description="Number of passages to retrieve")
    language: Optional[str] = Field("en", description="Target language code, e.g. kn, hi, te, ta, en")

class QueryResponse(BaseModel):
    question: str
    crop: Optional[str] = None
    mode: str
    answer: str
    retrieved_passages: List[RetrievedPassage]
    retrieval_metadata: Dict[str, Any]

class DiseaseAdvisoryRequest(BaseModel):
    crop: str = Field(..., description="Target crop, e.g. tomato, banana, mango, potato")
    predicted_disease: str = Field(..., description="Predicted disease name from vision model")
    confidence: Optional[float] = Field(None, ge=0.0, le=1.0, description="Model confidence score")
    question: Optional[str] = Field("What are the symptoms and how can I manage this disease?", description="Specific farmer query")
    top_k: int = Field(5, ge=1, le=15, description="Number of passages to retrieve")

class DiseaseAdvisoryResponse(BaseModel):
    crop: str
    predicted_disease: str
    confidence: Optional[float] = None
    explanation: str
    symptoms: List[str]
    causes_or_conditions: List[str]
    management_and_prevention: List[str]
    missing_or_uncertain_info: Optional[str] = None
    raw_answer: str
    retrieved_passages: List[RetrievedPassage]

class IngestResponse(BaseModel):
    status: str
    documents_processed: int
    sections_created: int
    chunks_inserted: int
    chunks_per_document: Dict[str, int]
    total_records_in_db: int
    errors: List[str] = []

class HealthResponse(BaseModel):
    status: str
    ollama_connected: bool
    ollama_models_available: List[str]
    chroma_initialized: bool
    chroma_total_chunks: int
    details: Dict[str, Any] = {}

