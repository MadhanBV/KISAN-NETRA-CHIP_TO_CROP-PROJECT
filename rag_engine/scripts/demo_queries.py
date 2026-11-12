import sys
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services.retrieval_service import RetrievalService
from app.services.generation_service import GenerationService

def main():
    retrieval = RetrievalService()
    generation = GenerationService()

    queries = [
        {"crop": "banana", "disease": "Banana Anthracnose", "q": "What are the early symptoms of banana anthracnose?"},
        {"crop": "mango", "disease": "Mango Sooty Mould", "q": "How can I prevent and control sooty mould in mango?"},
        {"crop": "potato", "disease": "Potato Dry Rot", "q": "What causes dry rot in potato tubers during storage?"},
        {"crop": "tomato", "disease": "Tomato Early Blight", "q": "What are the favorable weather conditions and fungicides for tomato early blight?"},
        {"crop": None, "disease": None, "q": "Why is soil testing important before applying fertilizer?"}
    ]

    print("=" * 70)
    print("CHIP TO CROP - RAG ENGINE QUERY & ADVISORY DEMO")
    print("=" * 70)

    for item in queries:
        crop = item["crop"]
        disease = item["disease"]
        q = item["q"]

        print(f"\n>>> Query: '{q}' [Crop: {crop}, Predicted Disease: {disease}]")
        passages = retrieval.retrieve(query=q, crop=crop, predicted_disease=disease, top_k=2)
        print(f"    Retrieved {len(passages)} passages:")
        for p in passages:
            print(f"      - [{p.source_file}] Section: {p.section} (Sim: {p.score:.4f})")
            print(f"        Snippet: {p.text[:120].strip()}...")

    print("\n" + "=" * 70)

if __name__ == "__main__":
    main()

