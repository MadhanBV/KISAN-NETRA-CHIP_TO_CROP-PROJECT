import logging
import httpx
from typing import Dict, Any, Optional, List, Tuple

from app.config import settings
from app.models.crop_models import DiagnosisContent, KnowledgeSource, QualityReportContent
from app.services.sarvam_service import SarvamService

logger = logging.getLogger("chiptocrop.rag_client")

class RAGClientService:
    def __init__(self, base_url: Optional[str] = None, timeout: Optional[float] = None):
        self.base_url = (base_url or settings.rag_engine_base_url).rstrip("/")
        self.timeout = timeout or settings.rag_timeout_seconds

    def check_health(self) -> Dict[str, Any]:
        """Checks if the external RAG engine is running and healthy."""
        try:
            with httpx.Client(base_url=self.base_url, timeout=5.0) as client:
                res = client.get("/health")
                if res.status_code == 200:
                    return {"connected": True, "details": res.json()}
                return {"connected": False, "error": f"HTTP status {res.status_code}"}
        except Exception as e:
            logger.warning(f"RAG engine health check failed: {e}")
            return {"connected": False, "error": str(e)}

    def get_disease_advisory(
        self,
        crop: str,
        condition: str,
        confidence: float,
        is_healthy: bool = False,
        language: str = "en"
    ) -> Tuple[DiagnosisContent, List[KnowledgeSource]]:
        """
        Retrieves grounded advisory from RAG engine for the predicted condition.
        For healthy plants, asks RAG for optimal crop care and preventive maintenance.
        """
        sources: List[KnowledgeSource] = []

        if is_healthy:
            # Query for healthy crop maintenance & disease prevention
            question = (
                f"What are the best cultivation practices, balanced nutrient management, "
                f"and preventive measures to keep {crop} plants vigorous and disease-free?"
            )
            try:
                with httpx.Client(base_url=self.base_url, timeout=self.timeout) as client:
                    res = client.post("/api/rag/query", json={
                        "question": question,
                        "crop": crop.lower(),
                        "mode": "farmer_assistance",
                        "top_k": 3
                    })
                    if res.status_code == 200:
                        data = res.json()
                        overview = data.get("answer", "")
                        for p in data.get("retrieved_passages", []):
                            sources.append(KnowledgeSource(
                                source_file=p.get("source_file", ""),
                                crop=p.get("crop", crop),
                                section=p.get("section", ""),
                                similarity=p.get("score", 0.0)
                            ))
                    else:
                        overview = (
                            f"The {crop} plant appears healthy and vigorous with no visible signs "
                            f"of active fungal or bacterial infections."
                        )
            except Exception as e:
                logger.warning(f"RAG query for healthy crop failed: {e}")
                overview = (
                    f"The {crop} foliage appears healthy with normal color and structure. "
                    f"Continue regular watering and balanced fertilisation."
                )

            diagnosis = DiagnosisContent(
                overview=overview,
                symptoms=["No foliar lesions, wilting, or yellowing detected."],
                causes=["Optimal growing conditions, adequate nutrition, and effective disease management."],
                favorable_conditions=["Balanced humidity, proper plant spacing, and clean field hygiene."],
                severity="Healthy (No Disease Detected)",
                organic_management=[
                    "Maintain soil organic matter using well-decomposed FYM or compost.",
                    "Apply Trichoderma viride or Pseudomonas fluorescens as soil/root preventive treatment.",
                    "Practice crop rotation with non-host crops."
                ],
                chemical_management=[
                    "No chemical sprays are required for healthy plants.",
                    "Avoid unnecessary preventive fungicide applications to protect beneficial soil microbes."
                ],
                prevention=[
                    "Inspect plants regularly during humid and cloudy weather.",
                    "Use drip irrigation to avoid wet foliage.",
                    "Ensure adequate field drainage to prevent waterlogging."
                ],
                farmer_recommendations=[
                    f"Keep monitoring your {crop} field weekly.",
                    "Maintain balanced N-P-K nutrient application according to soil test recommendations."
                ]
            )

        else:
            # Predicted disease condition
            question = (
                f"What are the visible symptoms, causes, organic management, and chemical remedies "
                f"for {condition} in {crop}?"
            )
            try:
                with httpx.Client(base_url=self.base_url, timeout=self.timeout) as client:
                    res = client.post("/api/rag/disease-advisory", json={
                        "crop": crop.lower(),
                        "predicted_disease": f"{crop} {condition}",
                        "confidence": confidence,
                        "question": question,
                        "top_k": 3
                    })
                    if res.status_code == 200:
                        data = res.json()
                        for p in data.get("retrieved_passages", []):
                            sources.append(KnowledgeSource(
                                source_file=p.get("source_file", ""),
                                crop=p.get("crop", crop),
                                section=p.get("section", ""),
                                similarity=p.get("score", 0.0)
                            ))

                        symptoms = data.get("symptoms", [])
                        causes = data.get("causes_or_conditions", [])
                        management = data.get("management_and_prevention", [])
                        explanation = data.get("explanation", "")

                        # Partition management into organic/cultural and chemical
                        organic_list = []
                        chemical_list = []
                        prevention_list = []

                        for item in management:
                            item_lower = item.lower()
                            if any(w in item_lower for w in ["spray", "fungicide", "copper", "mancozeb", "chemical", "chlorothalonil", "azoxystrobin"]):
                                chemical_list.append(item)
                            elif any(w in item_lower for w in ["prevent", "rotate", "spacing", "drainage", "seed", "clean", "hygiene"]):
                                prevention_list.append(item)
                            else:
                                organic_list.append(item)

                        if not organic_list:
                            organic_list = ["Remove and destroy infected plant debris.", "Use certified disease-free seeds or planting stock."]
                        if not chemical_list:
                            chemical_list = ["Consult local Krishi Vigyan Kendra (KVK) for officially approved chemical treatments and dosages."]
                        if not prevention_list:
                            prevention_list = ["Avoid overhead irrigation.", "Ensure adequate plant spacing for airflow."]

                        diagnosis = DiagnosisContent(
                            overview=explanation or f"{crop} {condition} detected with {confidence * 100:.1f}% confidence.",
                            symptoms=symptoms if symptoms else [f"Visible foliar lesions characteristic of {condition}."],
                            causes=causes if causes else ["Fungal or bacterial pathogen favored by high humidity or poor ventilation."],
                            favorable_conditions=["Warm temperatures and leaf wetness."],
                            severity="Moderate (Early Action Recommended)",
                            organic_management=organic_list,
                            chemical_management=chemical_list,
                            prevention=prevention_list,
                            farmer_recommendations=[
                                f"Isolate infected {crop} plants immediately to prevent pathogen spread.",
                                "Follow local extension (KVK) guidelines before purchasing crop protection chemicals."
                            ]
                        )
                    else:
                        diagnosis = self._generate_fallback_diagnosis(crop, condition, confidence)
            except Exception as e:
                logger.error(f"Error querying RAG engine for disease advisory: {e}", exc_info=True)
                diagnosis = self._generate_fallback_diagnosis(crop, condition, confidence)

        # Optional translation via Sarvam if non-English
        if language and language.lower() not in ["en", "english"] and SarvamService.is_configured():
            try:
                translated_overview = SarvamService.translate_text(
                    text=diagnosis.overview,
                    target_language=language.lower(),
                    source_language="en-IN"
                )
                if translated_overview:
                    diagnosis.overview = translated_overview
            except Exception as err:
                logger.warning(f"Translation failed for language {language}: {err}")

        return diagnosis, sources

    def ask_assistant(
        self,
        question: str,
        crop: Optional[str] = None,
        language: str = "en"
    ) -> Tuple[str, List[KnowledgeSource]]:
        """Handles conversational agricultural chat queries using RAG."""
        sources: List[KnowledgeSource] = []
        answer = ""

        # Query RAG
        try:
            with httpx.Client(base_url=self.base_url, timeout=self.timeout) as client:
                res = client.post("/api/rag/query", json={
                    "question": question,
                    "crop": crop.lower() if crop else None,
                    "mode": "farmer_assistance",
                    "top_k": 3,
                    "language": language
                })
                if res.status_code == 200:
                    data = res.json()
                    answer = data.get("answer", "")
                    for p in data.get("retrieved_passages", []):
                        sources.append(KnowledgeSource(
                            source_file=p.get("source_file", ""),
                            crop=p.get("crop", crop or "general"),
                            section=p.get("section", ""),
                            similarity=p.get("score", 0.0)
                        ))
                else:
                    answer = "I could not retrieve an answer at this time. Please try again shortly."
        except Exception as e:
            logger.error(f"Error in ask_assistant: {e}")
            answer = (
                "The agricultural AI knowledge service is currently connecting. "
                "Please verify your network connection and try again."
            )

        # Translation via Sarvam if non-English and available
        if language and language.lower() not in ["en", "english"] and SarvamService.is_configured():
            try:
                translated = SarvamService.translate_text(
                    text=answer,
                    target_language=language.lower(),
                    source_language="en-IN"
                )
                if translated:
                    answer = translated
            except Exception as err:
                logger.warning(f"Assistant translation failed: {err}")

        # Clean markdown artifacts from AI answer
        import re
        answer = re.sub(r'\*{3,}', '', answer)
        answer = re.sub(r'-{3,}', '', answer)
        answer = re.sub(r'\n{3,}', '\n\n', answer).strip()

        return answer, sources

    def _generate_fallback_diagnosis(self, crop: str, condition: str, confidence: float) -> DiagnosisContent:
        """Safe grounded fallback when RAG server is connecting."""
        return DiagnosisContent(
            overview=f"The AI model identified {condition} on {crop} with {confidence * 100:.1f}% confidence.",
            symptoms=[f"Signs consistent with {condition} observed on plant tissue."],
            causes=["Pathogenic pressure favored by environmental humidity or temperature."],
            favorable_conditions=["High relative humidity, prolonged leaf wetness, or poor canopy airflow."],
            severity="Requires Field Inspection",
            organic_management=["Prune and destroy infected leaves.", "Avoid handling wet foliage."],
            chemical_management=["Consult your local Krishi Vigyan Kendra (KVK) officer for approved treatments."],
            prevention=["Maintain field cleanliness and balanced irrigation."],
            farmer_recommendations=["Inspect neighboring plants and monitor spread closely."]
        )

    def get_quality_advisory(
        self,
        crop: str,
        quality_status: str,
        confidence: float,
        is_fresh: bool = True,
        language: str = "en"
    ) -> Tuple[QualityReportContent, List[KnowledgeSource]]:
        """
        Retrieves grounded post-harvest quality, storage, and freshness advisory from RAG engine.
        Gives tailored handling guidelines for fresh produce and damage segregation for rotten produce.
        """
        sources: List[KnowledgeSource] = []

        if is_fresh:
            question = (
                f"What are the best post-harvest handling guidelines, optimal storage temperature, "
                f"humidity requirements, packaging methods, and grading practices to preserve the freshness and market quality of {crop}?"
            )
        else:
            question = (
                f"What causes post-harvest rot, fungal decay, and spoilage in {crop}? "
                f"How should farmers isolate and manage spoiled produce, sanitize crates, and prevent disease transmission during storage?"
            )

        try:
            with httpx.Client(base_url=self.base_url, timeout=self.timeout) as client:
                res = client.post("/api/rag/query", json={
                    "question": question,
                    "crop": crop.lower(),
                    "mode": "farmer_assistance",
                    "top_k": 3
                })
                if res.status_code == 200:
                    data = res.json()
                    rag_answer = data.get("answer", "")
                    for p in data.get("retrieved_passages", []):
                        sources.append(KnowledgeSource(
                            source_file=p.get("source_file", ""),
                            crop=p.get("crop", crop),
                            section=p.get("section", ""),
                            similarity=p.get("score", 0.0)
                        ))
                    report = self._build_quality_report(
                        crop=crop,
                        quality_status=quality_status,
                        confidence=confidence,
                        is_fresh=is_fresh,
                        rag_answer=rag_answer
                    )
                else:
                    report = self._build_quality_report(
                        crop=crop,
                        quality_status=quality_status,
                        confidence=confidence,
                        is_fresh=is_fresh,
                        rag_answer=""
                    )
        except Exception as e:
            logger.warning(f"RAG query for quality advisory failed: {e}")
            report = self._build_quality_report(
                crop=crop,
                quality_status=quality_status,
                confidence=confidence,
                is_fresh=is_fresh,
                rag_answer=""
            )

        # Optional translation via Sarvam if non-English
        if language and language.lower() not in ["en", "english"] and SarvamService.is_configured():
            try:
                translated_overview = SarvamService.translate_text(
                    text=report.overview,
                    target_language=language.lower(),
                    source_language="en-IN"
                )
                if translated_overview:
                    report.overview = translated_overview
            except Exception as err:
                logger.warning(f"Translation failed for language {language}: {err}")

        return report, sources

    def _build_quality_report(
        self,
        crop: str,
        quality_status: str,
        confidence: float,
        is_fresh: bool,
        rag_answer: str = ""
    ) -> QualityReportContent:
        """Constructs rich, structured quality report based on crop and freshness."""
        crop_clean = crop.title()

        # Crop-specific shelf life estimates
        shelf_life_map = {
            "Tomato": ("7–12 Days at 12–15°C", "0–24 Hours (Immediate Disposal)"),
            "Mango": ("10–14 Days at 11–13°C", "0–24 Hours (Immediate Disposal)"),
            "Potato": ("3–5 Months at 8–10°C (Dark, aerated)", "0–48 Hours (Segregate Immediately)"),
            "Banana": ("5–8 Days at 13–15°C (Well-ventilated)", "0–24 Hours (Immediate Disposal)"),
        }
        shelf_fresh, shelf_rotten = shelf_life_map.get(crop_clean, ("7–10 Days in cool storage", "0–24 Hours"))

        if is_fresh:
            overview = rag_answer if rag_answer and len(rag_answer.strip()) > 30 else (
                f"Prime fresh quality {crop_clean} detected with {confidence * 100:.1f}% confidence. "
                f"The harvested crop displays healthy color, firm skin integrity, and no signs of fungal or bacterial decay. "
                f"It meets premium Grade A standards for immediate mandi dispatch or retail sale."
            )
            return QualityReportContent(
                overview=overview,
                freshness_score=f"{int(confidence * 100)}% (Freshness Index)",
                market_grade="Grade A (Prime Quality)",
                shelf_life_estimate=shelf_fresh,
                storage_guidelines=[
                    f"Store {crop_clean} in a clean, shaded, and well-ventilated packhouse.",
                    "Maintain optimal relative humidity of 85–90% to prevent moisture loss.",
                    "Keep crates on pallets 10–15 cm above ground level to avoid moisture absorption."
                ],
                packaging_and_handling=[
                    f"Pack {crop_clean} in clean plastic or corrugated crates with smooth internal walls.",
                    "Use paper or foam liners to prevent transit bruising and mechanical injury.",
                    "Avoid overstacking crates beyond 5–6 layers to avoid bottom-crate compression."
                ],
                segregation_and_sanitation=[
                    "Lot is uniform and disease-free.",
                    "Ensure separation from overripe fruits emitting high levels of ethylene gas."
                ],
                mandi_advisory=[
                    f"Lot qualifies for premium Grade A pricing at local APMC mandis.",
                    "Transport during early morning or evening hours to avoid daytime heat buildup.",
                    "Keep mandi arrival slip and batch grade tags affixed to crates."
                ],
                prevention_of_spoilage=[
                    "Pre-cool produce before long-distance transit.",
                    "Ensure produce is dry before packing; never pack wet harvested crops.",
                    "Maintain gentle handling during loading and unloading."
                ]
            )
        else:
            overview = rag_answer if rag_answer and len(rag_answer.strip()) > 30 else (
                f"Rotten or spoiled {crop_clean} detected with {confidence * 100:.1f}% confidence. "
                f"Visible tissue degradation, fungal mycelium, or soft rot decay observed. "
                f"Immediate segregation is mandatory to prevent fungal spore transmission to adjacent healthy produce."
            )
            return QualityReportContent(
                overview=overview,
                freshness_score=f"{max(0, int((1.0 - confidence) * 100))}% (Critical Spoilage)",
                market_grade="Rejected / Spoilage Detected",
                shelf_life_estimate=shelf_rotten,
                storage_guidelines=[
                    f"Immediately remove all rotting {crop_clean} from storage rooms and packhouses.",
                    "Increase airflow and reduce storage humidity to inhibit fungal proliferation.",
                    "Do NOT store adjacent to healthy, undamaged produce."
                ],
                packaging_and_handling=[
                    "Do NOT mix damaged or bruised produce into marketable crates.",
                    "Segregate the affected lot into separate disposal bins.",
                    "Handle affected produce with gloves to prevent spreading spores to healthy lots."
                ],
                segregation_and_sanitation=[
                    "Disinfect all harvesting knives, shears, and sorting tables with 0.1% sodium hypochlorite solution.",
                    "Thoroughly wash and air-dry storage crates before reusing them.",
                    "Dispose of rotten produce in an enclosed deep compost pit away from crop storage."
                ],
                mandi_advisory=[
                    "Not eligible for Grade A or standard APMC auction.",
                    "Sort through the lot to salvage unaffected units for immediate local distress sale or processing.",
                    "Never hide decayed units inside crates as APMC inspectors will reject the entire consignment."
                ],
                prevention_of_spoilage=[
                    "Avoid harvesting during rainfall or high leaf wetness.",
                    "Avoid dropping produce from heights during field collection.",
                    "Cure tubers/fruits properly before bulk storage."
                ]
            )
