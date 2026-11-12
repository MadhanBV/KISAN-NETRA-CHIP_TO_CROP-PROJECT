import sys
from pathlib import Path
from typing import List, Dict, Any
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware

# Ensure app package is in path
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

from app.config import settings
from app.models import (
    HealthResponse,
    QueryRequest,
    QueryResponse,
    DiseaseAdvisoryRequest,
    DiseaseAdvisoryResponse,
    IngestResponse,
    RetrievedPassage
)
from app.services.ollama_service import OllamaService
from app.services.vector_store import VectorStore
from app.services.document_loader import DocumentLoader
from app.services.chunking_service import ChunkingService
from app.services.retrieval_service import RetrievalService
from app.services.generation_service import GenerationService

# Instantiate FastAPI application
app = FastAPI(
    title="Kisan Netra Agricultural RAG Engine",
    description="Standalone local agricultural RAG engine powered by Ollama, Nomic embeddings, ChromaDB, and Qwen3.",
    version="1.0.0"
)

# Enable CORS for local client connections
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Shared singletons for performance and connection pooling
_ollama_service = OllamaService()
_vector_store = VectorStore()
_retrieval_service = RetrievalService(vector_store=_vector_store, ollama_service=_ollama_service)
_generation_service = GenerationService(ollama_service=_ollama_service)

@app.get("/health", response_model=HealthResponse)
@app.get("/api/rag/health", response_model=HealthResponse)
def health_check():
    """Health endpoint verifying Ollama connectivity and ChromaDB collection status."""
    ollama_health = _ollama_service.check_health()
    stats = _vector_store.get_stats()
    
    is_healthy = (
        ollama_health.get("connected", False) and
        ollama_health.get("embedding_model_available", False) and
        ollama_health.get("llm_model_available", False)
    )
    
    return HealthResponse(
        status="healthy" if is_healthy else "degraded",
        ollama_connected=ollama_health.get("connected", False),
        ollama_models_available=ollama_health.get("models", []),
        chroma_initialized=True,
        chroma_total_chunks=stats.get("total_chunks", 0),
        details={
            "embedding_model": settings.EMBEDDING_MODEL,
            "llm_model": settings.LLM_MODEL,
            "collection_name": settings.COLLECTION_NAME,
            "crop_distribution": stats.get("crop_distribution", {})
        }
    )

@app.post("/api/rag/ingest", response_model=IngestResponse)
def ingest_documents(reset: bool = False):
    """
    Ingests all 5 source documents into the shared ChromaDB collection.
    Idempotent: uses deterministic chunk IDs to avoid duplicate records.
    """
    try:
        if reset:
            _vector_store.reset()

        loader = DocumentLoader()
        documents = loader.load_all()
        chunker = ChunkingService()
        
        all_chunks = []
        chunks_per_doc = {}
        for doc in documents:
            doc_chunks = chunker.chunk_document(doc)
            all_chunks.extend(doc_chunks)
            chunks_per_doc[doc["file_name"]] = len(doc_chunks)

        # Generate embeddings
        embeddings = []
        for c in all_chunks:
            emb = _ollama_service.get_embedding(c.text)
            embeddings.append(emb)

        # Upsert
        inserted = _vector_store.upsert_chunks(all_chunks, embeddings, batch_size=50)
        stats = _vector_store.get_stats()

        return IngestResponse(
            status="success",
            documents_processed=len(documents),
            sections_created=len(all_chunks),
            chunks_inserted=inserted,
            chunks_per_document=chunks_per_doc,
            total_records_in_db=stats.get("total_chunks", 0),
            errors=[]
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Ingestion failed: {str(e)}"
        )

@app.post("/api/rag/query", response_model=QueryResponse)
def query_rag(request: QueryRequest):
    """
    Farmer assistance query endpoint. Retrieves relevant agricultural chunks
    and generates grounded answers using Qwen3.
    """
    try:
        passages = _retrieval_service.retrieve(
            query=request.question,
            crop=request.crop,
            top_k=request.top_k
        )
        
        if request.mode == "disease_advisory" and request.crop:
            advisory = _generation_service.generate_disease_advisory(
                crop=request.crop,
                predicted_disease=request.crop,
                confidence=None,
                question=request.question,
                passages=passages
            )
            answer = advisory["raw_answer"]
        else:
            answer = _generation_service.generate_farmer_assistance(
                question=request.question,
                crop=request.crop,
                passages=passages,
                language=request.language
            )

        return QueryResponse(
            question=request.question,
            crop=request.crop,
            mode=request.mode,
            answer=answer,
            retrieved_passages=passages,
            retrieval_metadata={
                "top_k": request.top_k,
                "passages_returned": len(passages),
                "top_similarity": passages[0].score if passages else 0.0
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Query failed: {str(e)}"
        )

@app.post("/api/rag/disease-advisory", response_model=DiseaseAdvisoryResponse)
def disease_advisory(request: DiseaseAdvisoryRequest):
    """
    Structured disease advisory endpoint for computer vision integration.
    Retrieves grounded evidence for the predicted disease and formats symptoms,
    causes, remedies, and uncertainties.
    """
    try:
        # Retrieve passages combining crop, predicted disease, and farmer question
        passages = _retrieval_service.retrieve(
            query=request.question or "What are the symptoms, causes, and management?",
            crop=request.crop,
            predicted_disease=request.predicted_disease,
            top_k=request.top_k
        )

        # Generate structured advisory
        advisory = _generation_service.generate_disease_advisory(
            crop=request.crop,
            predicted_disease=request.predicted_disease,
            confidence=request.confidence,
            question=request.question or "What are the symptoms and remedies for this disease?",
            passages=passages
        )

        return DiseaseAdvisoryResponse(
            crop=request.crop,
            predicted_disease=request.predicted_disease,
            confidence=request.confidence,
            explanation=advisory["explanation"],
            symptoms=advisory["symptoms"],
            causes_or_conditions=advisory["causes_or_conditions"],
            management_and_prevention=advisory["management_and_prevention"],
            missing_or_uncertain_info=advisory["missing_or_uncertain_info"],
            raw_answer=advisory["raw_answer"],
            retrieved_passages=passages
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Disease advisory failed: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host=settings.RAG_HOST, port=settings.RAG_PORT, reload=False)

