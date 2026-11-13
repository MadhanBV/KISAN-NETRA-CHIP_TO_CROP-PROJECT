# ==============================================================================
# KISAN NETRA — Main FastAPI Application & YOLO Model Inference Container
# ==============================================================================
FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies required for OpenCV, image processing, and health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Optimize build layer caching: copy requirements first
COPY requirements.txt .

# Pre-install lightweight CPU-only PyTorch to prevent pip from downloading 3GB+ CUDA wheels
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install application dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code and YOLO model weights
COPY app/ ./app/
COPY models/ ./models/
COPY .env.example ./.env.example

# Default environment configuration
ENV HOST=0.0.0.0 \
    PORT=8000 \
    RAG_ENGINE_BASE_URL=http://rag-engine:8001

EXPOSE 8000

# Health check to monitor FastAPI readiness
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start FastAPI application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
