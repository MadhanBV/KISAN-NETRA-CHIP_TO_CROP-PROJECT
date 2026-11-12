import re
from pathlib import Path
from typing import List, Optional, Dict, Any
from ..config import settings
from ..models import RetrievedPassage
from .ollama_service import OllamaService

class GenerationService:
    def __init__(self, ollama_service: Optional[OllamaService] = None, prompts_dir: Path = settings.PROMPTS_DIR):
        self.ollama_service = ollama_service or OllamaService()
        self.prompts_dir = Path(prompts_dir)
        self._load_prompts()

    def _load_prompts(self):
        farmer_file = self.prompts_dir / "farmer_assistance.txt"
        advisory_file = self.prompts_dir / "disease_advisory.txt"
        
        with open(farmer_file, "r", encoding="utf-8") as f:
            self.farmer_template = f.read()
            
        with open(advisory_file, "r", encoding="utf-8") as f:
            self.advisory_template = f.read()

    def _format_context(self, passages: List[RetrievedPassage]) -> str:
        if not passages:
            return "No matching agricultural passages found."
        formatted = []
        for i, p in enumerate(passages, 1):
            formatted.append(
                f"--- [Passage {i}] Crop: {p.crop.title()} | Section: {p.section} | Similarity: {p.score} ---\n{p.text}"
            )
        return "\n\n".join(formatted)

    LANGUAGE_NAMES = {
        "en": "English",
        "hi": "Hindi (हिन्दी)",
        "kn": "Kannada (ಕನ್ನಡ)",
        "te": "Telugu (తెలుగు)",
        "ta": "Tamil (தமிழ்)",
        "mr": "Marathi (मराठी)",
        "bn": "Bengali (বাংলা)",
        "gu": "Gujarati (ગુજરાતી)",
        "pa": "Punjabi (ਪੰਜਾਬੀ)",
        "ml": "Malayalam (മലയാളം)",
        "or": "Odia (ଓଡ଼ಿଆ)",
        "as": "Assamese (অসমীয়া)",
        "ur": "Urdu (اردو)",
    }

    def generate_farmer_assistance(
        self,
        question: str,
        crop: Optional[str],
        passages: List[RetrievedPassage],
        language: Optional[str] = "en"
    ) -> str:
        """Generates conversational, grounded answer for farmer assistance."""
        context = self._format_context(passages)
        base_prompt = self.farmer_template.format(
            question=question,
            crop=crop.title() if crop else "General Agriculture",
            context=context
        )

        lang_key = (language or "en").lower().split("-")[0]
        if lang_key not in ["en", "english"]:
            lang_name = self.LANGUAGE_NAMES.get(lang_key, lang_key.title())
            base_prompt += (
                f"\n\nCRITICAL LANGUAGE INSTRUCTION:\n"
                f"You MUST write your entire response completely and fluently in {lang_name} language script.\n"
                f"Do NOT answer in English. All advice, remedy points, and steps must be in {lang_name}."
            )

        base_prompt += (
            "\n\nFORMATTING RULES:\n"
            "- Do NOT use markdown dividers like '***' or '---'.\n"
            "- Do NOT use triple asterisks '***'.\n"
            "- Structure your response cleanly with clear paragraphs and bullet points ('•')."
        )

        raw_output = self.ollama_service.generate(prompt=base_prompt, temperature=0.2, num_predict=220)
        
        # Clean up any raw *** or separator lines
        cleaned = re.sub(r'\*{3,}', '', raw_output)
        cleaned = re.sub(r'-{3,}', '', cleaned)
        cleaned = re.sub(r'\n{3,}', '\n\n', cleaned).strip()
        return cleaned

    def generate_disease_advisory(
        self,
        crop: str,
        predicted_disease: str,
        confidence: Optional[float],
        question: str,
        passages: List[RetrievedPassage]
    ) -> Dict[str, Any]:
        """Generates structured disease advisory grounded in retrieved knowledge."""
        context = self._format_context(passages)
        conf_str = f"{confidence * 100:.1f}%" if confidence is not None else "Confidence score not specified"
        
        prompt = self.advisory_template.format(
            crop=crop.title(),
            predicted_disease=predicted_disease,
            confidence_text=conf_str,
            question=question or "What are the symptoms and remedies for this disease?",
            context=context
        )
        raw_output = self.ollama_service.generate(prompt=prompt, temperature=0.2, num_predict=300)
        
        # Parse sections from generated output
        explanation = ""
        symptoms = []
        causes = []
        management = []
        missing_info = None

        sections = re.split(r'###\s+[0-9]+\.\s+', raw_output)
        for sec in sections:
            if not sec.strip():
                continue
            lines = sec.strip().split('\n')
            header = lines[0].strip().lower()
            body_lines = [line.strip() for line in lines[1:] if line.strip()]
            
            if "explanation" in header:
                explanation = " ".join(body_lines)
            elif "symptom" in header:
                symptoms = [line.lstrip("*-•0123456789. ") for line in body_lines if line.strip()]
            elif "cause" in header:
                causes = [line.lstrip("*-•0123456789. ") for line in body_lines if line.strip()]
            elif "management" in header or "prevention" in header:
                management = [line.lstrip("*-•0123456789. ") for line in body_lines if line.strip()]
            elif "missing" in header or "uncertain" in header:
                missing_info = " ".join(body_lines)

        if not explanation:
            explanation = raw_output

        return {
            "explanation": explanation,
            "symptoms": symptoms,
            "causes_or_conditions": causes,
            "management_and_prevention": management,
            "missing_or_uncertain_info": missing_info,
            "raw_answer": raw_output
        }
