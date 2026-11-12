import os
from pathlib import Path
from pydantic_settings import BaseSettings
from pydantic import ConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent

class RAGSettings(BaseSettings):
    model_config = ConfigDict(
        env_file=str(BASE_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore"
    )

    # Service Network Settings
    RAG_HOST: str = "127.0.0.1"
    RAG_PORT: int = 8001
    
    # Ollama Local Configuration
    OLLAMA_BASE_URL: str = "http://127.0.0.1:11434"
    EMBEDDING_MODEL: str = "nomic-embed-text:latest"
    LLM_MODEL: str = "qwen3:1.7b"
    OLLAMA_TIMEOUT_SECONDS: float = 300.0
    
    # Storage & Document Paths
    DOCUMENTS_DIR: Path = BASE_DIR / "data" / "documents"
    CHROMA_PERSIST_DIR: Path = BASE_DIR / "data" / "chroma_db"
    COLLECTION_NAME: str = "kisan_netra_agriculture"
    
    # Chunking Configuration
    CHUNK_SIZE: int = 1200
    CHUNK_OVERLAP: int = 180
    
    # Prompt Directory
    PROMPTS_DIR: Path = Path(__file__).resolve().parent / "prompts"

settings = RAGSettings()
