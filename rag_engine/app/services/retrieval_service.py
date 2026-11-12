from typing import List, Optional, Dict, Any
from ..models import RetrievedPassage
from .vector_store import VectorStore
from .ollama_service import OllamaService

class RetrievalService:
    def __init__(self, vector_store: Optional[VectorStore] = None, ollama_service: Optional[OllamaService] = None):
        self.vector_store = vector_store or VectorStore()
        self.ollama_service = ollama_service or OllamaService()

    def retrieve(
        self,
        query: str,
        crop: Optional[str] = None,
        predicted_disease: Optional[str] = None,
        top_k: int = 5
    ) -> List[RetrievedPassage]:
        """
        Retrieves relevant agricultural chunks from ChromaDB.
        Prioritizes crop-specific documents while still allowing general agricultural knowledge.
        """
        if not query or not query.strip():
            return []

        clean_crop = crop.strip().lower() if crop else None
        
        # Build enriched semantic search query
        query_parts = []
        if clean_crop and clean_crop != "general":
            query_parts.append(clean_crop.capitalize())
        if predicted_disease:
            query_parts.append(predicted_disease)
        query_parts.append(query.strip())
        semantic_query = " - ".join(query_parts)

        # 1. Compute query vector
        query_embedding = self.ollama_service.get_embedding(semantic_query)

        # 2. Configure metadata filter
        where_filter: Optional[Dict[str, Any]] = None
        if clean_crop and clean_crop != "general":
            # ChromaDB $or operator allows matching target crop OR general agriculture
            where_filter = {
                "$or": [
                    {"crop": clean_crop},
                    {"crop": "general"}
                ]
            }

        # 3. Query ChromaDB
        passages = self.vector_store.query(
            query_embedding=query_embedding,
            top_k=top_k,
            where_filter=where_filter
        )

        # Fallback: If no results with filter (e.g. unknown crop), query globally
        if not passages and where_filter is not None:
            passages = self.vector_store.query(
                query_embedding=query_embedding,
                top_k=top_k,
                where_filter=None
            )

        return passages

