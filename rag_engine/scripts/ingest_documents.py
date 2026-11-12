import sys
import time
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.config import settings
from app.services.document_loader import DocumentLoader
from app.services.chunking_service import ChunkingService
from app.services.ollama_service import OllamaService
from app.services.vector_store import VectorStore

def run_ingestion(reset_first: bool = False):
    print("=" * 60, flush=True)
    print("CHIP TO CROP - Agricultural RAG Engine Ingestion", flush=True)
    print("=" * 60, flush=True)
    start_time = time.time()
    
    # 1. Check Ollama
    ollama = OllamaService()
    try:
        health = ollama.check_health()
        if not health.get("connected"):
            print(f"ERROR: Ollama is not accessible at {ollama.base_url} ({health.get('error')})", flush=True)
            sys.exit(1)
            
        print(f"Ollama connected. Embedding model: {settings.EMBEDDING_MODEL}", flush=True)
        if not health.get("embedding_model_available"):
            print(f"WARNING: Model {settings.EMBEDDING_MODEL} might not be listed in Ollama tags", flush=True)

        # 2. Vector Store
        vector_store = VectorStore()
        if reset_first:
            print("Resetting ChromaDB collection...", flush=True)
            vector_store.reset()

        # 3. Load Documents
        loader = DocumentLoader()
        documents = loader.load_all()
        print(f"Discovered and loaded {len(documents)} documents:", flush=True)
        for doc in documents:
            print(f"  - {doc['file_name']}: {doc['char_count']} chars (crop={doc['crop']}, type={doc['source_type']})", flush=True)

        # 4. Chunk Documents
        chunker = ChunkingService()
        all_chunks = []
        chunks_per_doc = {}
        
        for doc in documents:
            doc_chunks = chunker.chunk_document(doc)
            all_chunks.extend(doc_chunks)
            chunks_per_doc[doc['file_name']] = len(doc_chunks)
            print(f"  -> {doc['file_name']}: generated {len(doc_chunks)} chunks", flush=True)

        print(f"\nTotal chunks to index: {len(all_chunks)}", flush=True)

        # Verify ID uniqueness upfront
        all_ids = [c.chunk_id for c in all_chunks]
        if len(all_ids) != len(set(all_ids)):
            print(f"ERROR: Found {len(all_ids) - len(set(all_ids))} duplicate chunk IDs!", flush=True)
            sys.exit(1)
        print("Verified all chunk IDs are strictly unique.", flush=True)

        # 5. Embed Chunks
        print("\nGenerating embeddings via Ollama nomic-embed-text (pooled connection)...", flush=True)
        embeddings = []
        for idx, c in enumerate(all_chunks):
            if (idx + 1) % 25 == 0 or idx == len(all_chunks) - 1:
                print(f"  Embedding progress: {idx + 1}/{len(all_chunks)} ({int((idx+1)/len(all_chunks)*100)}%)", flush=True)
            emb = ollama.get_embedding(c.text)
            embeddings.append(emb)

        # 6. Upsert to ChromaDB
        print("\nUpserting records into ChromaDB in batches...", flush=True)
        inserted = vector_store.upsert_chunks(all_chunks, embeddings, batch_size=50)
        print(f"Successfully upserted {inserted} chunks into collection '{settings.COLLECTION_NAME}'", flush=True)

        # 7. Verification Stats
        stats = vector_store.get_stats()
        elapsed = time.time() - start_time
        print("\n" + "=" * 60, flush=True)
        print("INGESTION COMPLETE SUMMARY", flush=True)
        print("=" * 60, flush=True)
        print(f"Elapsed Time: {elapsed:.2f} seconds", flush=True)
        print(f"Total Chunks in ChromaDB: {stats['total_chunks']}", flush=True)
        print("\nChunks by Crop:", flush=True)
        for crop, count in stats["crop_distribution"].items():
            print(f"  {crop}: {count} chunks", flush=True)
        print("\nChunks by Document:", flush=True)
        for f, count in stats["file_distribution"].items():
            print(f"  {f}: {count} chunks", flush=True)
        print("=" * 60, flush=True)
    finally:
        ollama.close()

if __name__ == "__main__":
    reset = "--reset" in sys.argv
    run_ingestion(reset_first=reset)
