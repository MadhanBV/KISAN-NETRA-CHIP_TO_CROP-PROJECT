# ==============================================================================
# KISAN NETRA — Standalone Agricultural RAG Engine & ChromaDB Container
# ==============================================================================
FROM python:3.12-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Install curl for container health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency definition
COPY requirements.txt .

# Install dependencies including ChromaDB, FastAPI, and HTTPX
RUN pip install --no-cache-dir -r requirements.txt

# Copy RAG engine source code, prompts, documents, and pre-indexed ChromaDB vector store
COPY app/ ./app/
COPY data/ ./data/
COPY scripts/ ./scripts/

# Default environment configuration
ENV RAG_HOST=0.0.0.0 \
    RAG_PORT=8001 \
    OLLAMA_BASE_URL=http://ollama:11434 \
    EMBEDDING_MODEL=nomic-embed-text:latest \
    LLM_MODEL=qwen3:1.7b

EXPOSE 8001

# Health check to ensure RAG service is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# Start RAG FastAPI application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
