import sys
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.config import settings
from app.services.vector_store import VectorStore

def inspect_db():
    print("=" * 60)
    print("CHIP TO CROP - ChromaDB Inspector")
    print("=" * 60)
    store = VectorStore()
    stats = store.get_stats()
    
    print(f"Collection: {stats['collection_name']}")
    print(f"Total Chunks: {stats['total_chunks']}")
    print("\nCrop Breakdown:")
    for crop, count in stats.get("crop_distribution", {}).items():
        print(f"  - {crop}: {count} chunks")
        
    print("\nSource File Breakdown:")
    for f, count in stats.get("file_distribution", {}).items():
        print(f"  - {f}: {count} chunks")
        
    # Sample 3 chunks
    if stats["total_chunks"] > 0:
        sample = store.collection.peek(limit=3)
        print("\nSample Chunks:")
        for idx, cid in enumerate(sample["ids"]):
            meta = sample["metadatas"][idx]
            doc = sample["documents"][idx]
            print(f"\n[{idx + 1}] ID: {cid}")
            print(f"    Crop: {meta.get('crop')} | Section: {meta.get('section')}")
            print(f"    Text Preview: {doc[:150]}...")
            
    print("=" * 60)

if __name__ == "__main__":
    inspect_db()

