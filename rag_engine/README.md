# KISAN NETRA — Shared Agricultural RAG Engine (Phase 2)

A lightweight, high-performance, locally running Retrieval-Augmented Generation (RAG) engine designed for agricultural decision support, crop leaf disease advisories, and farmer assistance.

---

## 1. Architecture Overview

- **Runtime Environment:** Isolated Python 3.12.10 virtual environment (`rag_engine/venv`).
- **Embedding Model:** `nomic-embed-text:latest` (768-dimensional embeddings) running via local Ollama.
- **Large Language Model (LLM):** `qwen3:1.7b` (1.4 GB parameter model) running via local Ollama.
- **Vector Database:** Persistent ChromaDB (`rag_engine/data/chroma_db`) with cosine similarity space.
- **API Framework:** FastAPI with Pydantic v2 schemas and Uvicorn ASGI server.
- **Default Port:** `8001` (avoids any collision with main backend on port `8000`).

---

## 2. Directory Structure

```text
rag_engine/
│
├── app/
│   ├── __init__.py
│   ├── config.py                 # Central settings & env config (host, port, timeouts)
│   ├── main.py                   # FastAPI application & REST route definitions
│   ├── models.py                 # Pydantic request/response & passage models
│   ├── prompts/
│   │   ├── disease_advisory.txt  # Few-shot grounded prompt for disease queries
│   │   └── farmer_assistance.txt # Grounded conversational prompt for general Q&A
│   └── services/
│       ├── __init__.py
│       ├── chunking_service.py   # Context-preserving section chunker
│       ├── document_loader.py    # Multi-encoding (BOM safe) document loader
│       ├── generation_service.py # Prompt synthesis and section parsing
│       ├── ollama_service.py     # Connection-pooled Ollama HTTP client
│       ├── retrieval_service.py  # Semantic retrieval with crop & general filtering
│       └── vector_store.py       # Persistent ChromaDB wrapper with batch upserts
│
├── data/
│   ├── chroma_db/                # Persistent vector database store
│   └── documents/                # 5 Ingested agricultural text corpora
│       ├── KISAN NETRA BANANA RAG REPO.txt
│       ├── KISAN NETRA MANGO RAG REPO.txt
│       ├── KISAN NETRA POTATO RAG REPO.txt
│       ├── KISAN NETRA TOMATO RAG REPO.txt
│       └── training model.txt
│
├── scripts/
│   ├── ingest_documents.py       # Automated ingestion CLI tool
│   └── inspect_database.py       # Vector DB audit and statistics utility
│
├── tests/
│   └── test_rag_engine.py        # Comprehensive 14-test verification suite
│
├── requirements.txt              # Pinned Python dependencies
└── README.md                     # Documentation and runbook
```

---

## 3. Knowledge Corpus & Ingestion Stats

The knowledge base indexes 5 structured agricultural documents without inventing or modifying original facts:

| Document | Crop Category | Chunks Indexed | Key Content |
| :--- | :--- | :---: | :--- |
| `KISAN NETRA BANANA RAG REPO.txt` | Banana | 23 | Anthracnose, Sigatoka, Panama Wilt, Cordana Leaf Spot |
| `KISAN NETRA MANGO RAG REPO.txt` | Mango | 86 | Anthracnose, Powdery Mildew, Sooty Mould, Dieback |
| `KISAN NETRA POTATO RAG REPO.txt` | Potato | 36 | Early Blight, Late Blight, Dry Rot, Black Scurf |
| `KISAN NETRA TOMATO RAG REPO.txt` | Tomato | 67 | Early Blight, Late Blight, Leaf Mold, Bacterial Spot |
| `training model.txt` | General Agriculture | 200 | Soil testing, irrigation, organic fertilizers, crop rotations |
| **Total** | | **412 chunks** | **100% Vectorized & Persisted** |

To re-index or verify the database:
```powershell
# Inspect database status
.\rag_engine\venv\Scripts\python.exe .\rag_engine\scripts\inspect_database.py

# Re-run full ingestion
.\rag_engine\venv\Scripts\python.exe .\rag_engine\scripts\ingest_documents.py --reset
```

---

## 4. Running the RAG Server

Ensure Ollama is running (`ollama serve` or Windows system tray icon).

Start the RAG API service on port `8001`:
```powershell
.\rag_engine\venv\Scripts\uvicorn.exe app.main:app --app-dir rag_engine --host 127.0.0.1 --port 8001 --reload
```

---

## 5. API Reference & Endpoints

### 1. Health Check
- **Endpoint:** `GET /health`
- **Description:** Verifies service health, Ollama connectivity, and ChromaDB chunk count.
- **Example Response:**
```json
{
  "status": "healthy",
  "ollama_connected": true,
  "chroma_collection": "kisan_netra_agriculture",
  "chroma_total_chunks": 412,
  "available_models": {
    "embedding": "nomic-embed-text:latest",
    "llm": "qwen3:1.7b"
  }
}
```

### 2. General Agricultural Query
- **Endpoint:** `POST /api/rag/query`
- **Request Body:**
```json
{
  "question": "Why is soil testing important before applying fertilizer?",
  "crop": null,
  "top_k": 3
}
```

### 3. Structured Disease Advisory
- **Endpoint:** `POST /api/rag/disease-advisory`
- **Request Body:**
```json
{
  "crop": "tomato",
  "predicted_disease": "Tomato Early Blight",
  "confidence": 0.94,
  "question": "What are the early symptoms and recommended fungicides?",
  "top_k": 3
}
```
- **Response Structure:**
  - `crop`: string
  - `predicted_disease`: string
  - `confidence`: float
  - `explanation`: string
  - `symptoms`: array of strings
  - `causes_or_conditions`: array of strings
  - `management_and_prevention`: array of strings
  - `missing_or_uncertain_info`: string / null
  - `raw_answer`: full model response
  - `retrieved_passages`: array of grounded context passages with similarity scores and source files

---

## 6. Running Tests

Run the full automated verification suite:
```powershell
$env:PYTHONIOENCODING="utf-8"
.\rag_engine\venv\Scripts\pytest.exe .\rag_engine\tests\test_rag_engine.py -v
```

