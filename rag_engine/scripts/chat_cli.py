import sys
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services.retrieval_service import RetrievalService
from app.services.generation_service import GenerationService

def main():
    print("=" * 65)
    print("   KISAN NETRA - RAG Engine Terminal Chat")
    print("=" * 65)
    print("Type your agricultural question below.")
    print("Type 'exit' or 'quit' to close.\n")

    retrieval = RetrievalService()
    generation = GenerationService()

    while True:
        try:
            print("-" * 65)
            crop_input = input("Enter Crop (tomato / potato / mango / banana / or press Enter for general): ").strip()
            if crop_input.lower() in ["exit", "quit"]:
                break
            crop = crop_input.lower() if crop_input else None

            question = input("Enter your question: ").strip()
            if question.lower() in ["exit", "quit"]:
                break
            if not question:
                print("Question cannot be empty. Try again.")
                continue

            print("\n[1/2] Retrieving relevant knowledge from ChromaDB...")
            passages = retrieval.retrieve(query=question, crop=crop, top_k=3)
            
            print(f"       Found {len(passages)} passages:")
            for idx, p in enumerate(passages, 1):
                print(f"       {idx}. [{p.crop.upper()}] {p.source_file} (similarity: {p.score:.3f})")

            print("\n[2/2] Generating grounded answer with Qwen3...")
            answer = generation.generate_farmer_assistance(
                question=question,
                crop=crop,
                passages=passages
            )

            print("\n" + "=" * 25 + " AI RESPONSE " + "=" * 25)
            print(answer)
            print("=" * 63 + "\n")

        except KeyboardInterrupt:
            print("\nExiting chat. Goodbye!")
            break
        except Exception as e:
            print(f"\n[Error]: {e}\n")

if __name__ == "__main__":
    main()

