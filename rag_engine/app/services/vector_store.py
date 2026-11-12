from pathlib import Path
from typing import List, Dict, Any, Optional
import chromadb
from chromadb.config import Settings as ChromaSettings
from ..config import settings
from ..models import Chunk, RetrievedPassage

class VectorStore:
    def __init__(
        self,
        persist_dir: Path = settings.CHROMA_PERSIST_DIR,
        collection_name: str = settings.COLLECTION_NAME
    ):
        self.persist_dir = Path(persist_dir)
        self.persist_dir.mkdir(parents=True, exist_ok=True)
        self.collection_name = collection_name
        
        # Initialize persistent ChromaDB client
        self.client = chromadb.PersistentClient(
            path=str(self.persist_dir),
            settings=ChromaSettings(anonymized_telemetry=False)
        )
        self.collection = self.client.get_or_create_collection(
            name=self.collection_name,
            metadata={"hnsw:space": "cosine"}
        )

    def upsert_chunks(self, chunks: List[Chunk], embeddings: List[List[float]], batch_size: int = 50) -> int:
        """Upserts chunks and their embeddings into ChromaDB in batches."""
        if not chunks:
            return 0
        if len(chunks) != len(embeddings):
            raise ValueError(f"Mismatch: {len(chunks)} chunks vs {len(embeddings)} embeddings")

        total_inserted = 0
        for i in range(0, len(chunks), batch_size):
            b_chunks = chunks[i:i + batch_size]
            b_embeddings = embeddings[i:i + batch_size]
            
            ids = [c.chunk_id for c in b_chunks]
            documents = [c.text for c in b_chunks]
            metadatas = [c.to_metadata() for c in b_chunks]
            
            self.collection.upsert(
                ids=ids,
                documents=documents,
                embeddings=b_embeddings,
                metadatas=metadatas
            )
            total_inserted += len(b_chunks)
            
        return total_inserted

    def query(
        self,
        query_embedding: List[float],
        top_k: int = 5,
        where_filter: Optional[Dict[str, Any]] = None
    ) -> List[RetrievedPassage]:
        """Queries ChromaDB with an embedding vector and optional metadata filter."""
        total_in_db = self.collection.count()
        if total_in_db == 0:
            return []

        actual_k = min(top_k, total_in_db)
        kwargs: Dict[str, Any] = {
            "query_embeddings": [query_embedding],
            "n_results": actual_k,
            "include": ["documents", "metadatas", "distances"]
        }
        if where_filter:
            kwargs["where"] = where_filter

        results = self.collection.query(**kwargs)
        
        passages: List[RetrievedPassage] = []
        if not results or not results.get("ids") or not results["ids"][0]:
            return passages

        ids = results["ids"][0]
        docs = results["documents"][0] if results.get("documents") else []
        metas = results["metadatas"][0] if results.get("metadatas") else []
        distances = results["distances"][0] if results.get("distances") else []

        for idx, chunk_id in enumerate(ids):
            meta = metas[idx] if idx < len(metas) else {}
            doc_text = docs[idx] if idx < len(docs) else ""
            dist = distances[idx] if idx < len(distances) else 1.0
            
            # Cosine similarity score (1 - distance for cosine space)
            score = max(0.0, min(1.0, 1.0 - dist))

            passages.append(RetrievedPassage(
                chunk_id=chunk_id,
                source_file=meta.get("source_file", "unknown"),
                crop=meta.get("crop", "general"),
                source_type=meta.get("source_type", "unknown"),
                section=meta.get("section", "unknown"),
                text=doc_text,
                score=round(score, 4)
            ))

        return passages

    def get_stats(self) -> Dict[str, Any]:
        """Returns collection stats including total chunks and breakdown by crop."""
        count = self.collection.count()
        crop_counts: Dict[str, int] = {}
        file_counts: Dict[str, int] = {}

        if count > 0:
            # Sample or get metadatas to compute distribution
            all_data = self.collection.get(include=["metadatas"])
            for meta in all_data.get("metadatas", []):
                c = meta.get("crop", "unknown")
                f = meta.get("source_file", "unknown")
                crop_counts[c] = crop_counts.get(c, 0) + 1
                file_counts[f] = file_counts.get(f, 0) + 1

        return {
            "collection_name": self.collection_name,
            "total_chunks": count,
            "crop_distribution": crop_counts,
            "file_distribution": file_counts
        }

    def reset(self):
        """Explicitly resets and clears the collection."""
        self.client.delete_collection(self.collection_name)
        self.collection = self.client.get_or_create_collection(
            name=self.collection_name,
            metadata={"hnsw:space": "cosine"}
        )

