import os
from pathlib import Path
from typing import List, Dict, Any
from ..config import settings

EXPECTED_FILES = [
    "KISAN NETRA BANANA RAG REPO.txt",
    "KISAN NETRA MANGO RAG REPO.txt",
    "KISAN NETRA POTATO RAG REPO.txt",
    "KISAN NETRA TOMATO RAG REPO.txt",
    "training model.txt"
]

class DocumentLoader:
    def __init__(self, documents_dir: Path = settings.DOCUMENTS_DIR):
        self.documents_dir = Path(documents_dir)

    def discover_documents(self) -> List[Path]:
        if not self.documents_dir.exists():
            raise FileNotFoundError(f"Documents directory not found: {self.documents_dir}")
        
        found = list(self.documents_dir.glob("*.txt"))
        return sorted(found, key=lambda p: p.name)

    def load_document(self, file_path: Path) -> Dict[str, Any]:
        """Loads a single document preserving UTF-8 text and handling BOM cleanly."""
        file_name = file_path.name
        
        # Determine crop and source type
        fn_upper = file_name.upper()
        if "BANANA" in fn_upper:
            crop = "banana"
            source_type = "crop_disease"
        elif "MANGO" in fn_upper:
            crop = "mango"
            source_type = "crop_disease"
        elif "POTATO" in fn_upper:
            crop = "potato"
            source_type = "crop_disease"
        elif "TOMATO" in fn_upper:
            crop = "tomato"
            source_type = "crop_disease"
        else:
            crop = "general"
            source_type = "general_agriculture"

        # utf-8-sig transparently strips BOM if present, and parses standard UTF-8 perfectly
        with open(file_path, "r", encoding="utf-8-sig") as f:
            content = f.read()

        return {
            "file_name": file_name,
            "file_path": str(file_path),
            "crop": crop,
            "source_type": source_type,
            "char_count": len(content),
            "content": content
        }

    def load_all(self) -> List[Dict[str, Any]]:
        docs = []
        files = self.discover_documents()
        for f in files:
            docs.append(self.load_document(f))
        return docs

