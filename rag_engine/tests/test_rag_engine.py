import sys
import pytest
from pathlib import Path
from fastapi.testclient import TestClient

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.config import settings
from app.services.document_loader import DocumentLoader
from app.services.chunking_service import ChunkingService
from app.services.ollama_service import OllamaService
from app.services.vector_store import VectorStore
from app.services.retrieval_service import RetrievalService
from app.services.generation_service import GenerationService
from app.main import app

client = TestClient(app)

# 1. Document Discovery
def test_document_discovery():
    loader = DocumentLoader()
    docs = loader.discover_documents()
    assert len(docs) == 5, f"Expected 5 documents, found {len(docs)}"
    names = [p.name for p in docs]
    assert "KISAN NETRA BANANA RAG REPO.txt" in names
    assert "KISAN NETRA MANGO RAG REPO.txt" in names
    assert "KISAN NETRA POTATO RAG REPO.txt" in names
    assert "KISAN NETRA TOMATO RAG REPO.txt" in names
    assert "training model.txt" in names

# 2 & 3. Document Readability & UTF-8 BOM Handling
def test_document_readability_and_bom():
    loader = DocumentLoader()
    docs = loader.load_all()
    assert len(docs) == 5
    for doc in docs:
        assert doc["char_count"] > 1000
        assert not doc["content"].startswith("\ufeff"), f"BOM was not stripped in {doc['file_name']}"

# 4 & 5. Chunking & Metadata Preservation
def test_chunking_and_metadata():
    loader = DocumentLoader()
    docs = loader.load_all()
    chunker = ChunkingService()
    
    for doc in docs:
        chunks = chunker.chunk_document(doc)
        assert len(chunks) > 0
        for c in chunks:
            assert c.source_file == doc["file_name"]
            assert c.crop == doc["crop"]
            assert c.source_type == doc["source_type"]
            assert len(c.section) > 0
            assert len(c.text) > 20
            assert c.chunk_id.startswith(f"{c.crop}_")

# 6 & 7. ChromaDB Persistence & No Duplicate Chunks
def test_chroma_persistence_and_no_duplicates():
    store = VectorStore()
    stats = store.get_stats()
    assert stats["total_chunks"] == 412, f"Expected 412 chunks in ChromaDB, found {stats['total_chunks']}"
    assert stats["crop_distribution"]["banana"] == 23
    assert stats["crop_distribution"]["mango"] == 86
    assert stats["crop_distribution"]["potato"] == 36
    assert stats["crop_distribution"]["tomato"] == 67
    assert stats["crop_distribution"]["general"] == 200

# 8. Tomato Retrieval
def test_tomato_retrieval():
    retrieval = RetrievalService()
    passages = retrieval.retrieve(
        query="What are the symptoms and causes of tomato leaf mold?",
        crop="tomato",
        top_k=3
    )
    assert len(passages) > 0
    crops = [p.crop for p in passages]
    assert "tomato" in crops
    assert any("mold" in p.text.lower() or "leaf" in p.text.lower() for p in passages)

# 9. Banana Retrieval
def test_banana_retrieval():
    retrieval = RetrievalService()
    passages = retrieval.retrieve(
        query="How does banana anthracnose develop on fruit peel?",
        crop="banana",
        top_k=3
    )
    assert len(passages) > 0
    crops = [p.crop for p in passages]
    assert "banana" in crops
    assert any("anthracnose" in p.text.lower() or "peel" in p.text.lower() for p in passages)

# 10. Mango Retrieval
def test_mango_retrieval():
    retrieval = RetrievalService()
    passages = retrieval.retrieve(
        query="What causes sooty mould in mango and how to treat it?",
        crop="mango",
        top_k=3
    )
    assert len(passages) > 0
    crops = [p.crop for p in passages]
    assert "mango" in crops
    assert any("sooty" in p.text.lower() or "mould" in p.text.lower() for p in passages)

# 11. Potato Retrieval
def test_potato_retrieval():
    retrieval = RetrievalService()
    passages = retrieval.retrieve(
        query="Difference between potato dry rot and blackspot bruising?",
        crop="potato",
        top_k=3
    )
    assert len(passages) > 0
    crops = [p.crop for p in passages]
    assert "potato" in crops
    assert any("dry rot" in p.text.lower() or "bruising" in p.text.lower() for p in passages)

# 12. General Agriculture Retrieval from training model.txt
def test_general_agriculture_retrieval():
    retrieval = RetrievalService()
    passages = retrieval.retrieve(
        query="Why is soil testing important before applying fertilizer?",
        crop=None,
        top_k=3
    )
    assert len(passages) > 0
    sources = [p.source_file for p in passages]
    assert any("training model.txt" in s for s in sources)

# 13. Ollama Embeddings
def test_ollama_embeddings():
    ollama = OllamaService()
    emb = ollama.get_embedding("Testing agricultural soil moisture")
    assert len(emb) == 768
    ollama.close()

# 14. Qwen3 Generation
def test_qwen3_generation():
    ollama = OllamaService(timeout=180.0)
    res = ollama.generate("Say 'Vegetables' in one word.", temperature=0.1)
    assert len(res) > 0
    ollama.close()

# 15. FastAPI Endpoints & Error Handling
def test_api_health_endpoint():
    res = client.get("/health")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "healthy"
    assert data["ollama_connected"] is True
    assert data["chroma_total_chunks"] == 412

def test_api_query_validation():
    # Test valid query
    res = client.post("/api/rag/query", json={
        "question": "How to manage early blight in tomato?",
        "crop": "tomato",
        "top_k": 3
    })
    assert res.status_code == 200
    data = res.json()
    assert "answer" in data
    assert len(data["retrieved_passages"]) > 0

    # Test input validation (empty question)
    bad_res = client.post("/api/rag/query", json={
        "question": "",
        "crop": "tomato"
    })
    assert bad_res.status_code == 422

def test_api_disease_advisory():
    res = client.post("/api/rag/disease-advisory", json={
        "crop": "tomato",
        "predicted_disease": "Tomato Leaf Mold",
        "confidence": 0.94,
        "question": "What are the symptoms and how can I treat it?",
        "top_k": 3
    })
    assert res.status_code == 200
    data = res.json()
    assert data["crop"] == "tomato"
    assert data["predicted_disease"] == "Tomato Leaf Mold"
    assert len(data["explanation"]) > 0
    assert len(data["retrieved_passages"]) > 0
