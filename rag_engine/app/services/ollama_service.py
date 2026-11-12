import httpx
from typing import List, Dict, Any, Optional
from ..config import settings

class OllamaService:
    def __init__(
        self,
        base_url: str = settings.OLLAMA_BASE_URL,
        embedding_model: str = settings.EMBEDDING_MODEL,
        llm_model: str = settings.LLM_MODEL,
        timeout: float = settings.OLLAMA_TIMEOUT_SECONDS
    ):
        self.base_url = base_url.rstrip("/")
        self.embedding_model = embedding_model
        self.llm_model = llm_model
        self.timeout = timeout
        # Persistent client with keep-alive connection pool
        self._client = httpx.Client(
            base_url=self.base_url,
            timeout=self.timeout,
            limits=httpx.Limits(max_keepalive_connections=5, max_connections=10)
        )

    def close(self):
        try:
            self._client.close()
        except Exception:
            pass

    def __del__(self):
        self.close()

    def check_health(self) -> Dict[str, Any]:
        """Checks if Ollama is reachable and whether required models are installed."""
        try:
            res = self._client.get("/api/tags", timeout=5.0)
            if res.status_code == 200:
                data = res.json()
                models = [m.get("name", "") for m in data.get("models", [])]
                has_emb = any(self.embedding_model in m for m in models)
                has_llm = any(self.llm_model in m for m in models)
                return {
                    "connected": True,
                    "models": models,
                    "embedding_model_available": has_emb,
                    "llm_model_available": has_llm
                }
            return {
                "connected": False,
                "error": f"HTTP status {res.status_code}",
                "models": []
            }
        except Exception as e:
            return {
                "connected": False,
                "error": str(e),
                "models": []
            }

    def get_embedding(self, text: str) -> List[float]:
        """Calls Ollama /api/embeddings for a single text chunk."""
        payload = {
            "model": self.embedding_model,
            "prompt": text
        }
        res = self._client.post("/api/embeddings", json=payload)
        if res.status_code != 200:
            raise RuntimeError(f"Ollama embedding failed ({res.status_code}): {res.text}")
        data = res.json()
        embedding = data.get("embedding", [])
        if not embedding:
            raise ValueError("Ollama returned empty embedding array")
        return embedding

    def get_embeddings_batch(self, texts: List[str]) -> List[List[float]]:
        """Sequentially embeds a list of texts using the persistent connection pool."""
        embeddings: List[List[float]] = []
        for text in texts:
            emb = self.get_embedding(text)
            embeddings.append(emb)
        return embeddings

    def generate(
        self,
        prompt: str,
        system: Optional[str] = None,
        temperature: float = 0.2,
        top_p: float = 0.9,
        num_predict: Optional[int] = 512,
        stream: bool = False
    ) -> str:
        """
        Generates text using Ollama /api/chat with think=False for Qwen3,
        ensuring fast, direct inference without wasting CPU cycles on internal CoT tokens.
        """
        options: Dict[str, Any] = {
            "temperature": temperature,
            "top_p": top_p
        }
        if num_predict is not None:
            options["num_predict"] = num_predict

        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})

        chat_payload = {
            "model": self.llm_model,
            "messages": messages,
            "stream": stream,
            "think": False,
            "options": options
        }

        try:
            res = self._client.post("/api/chat", json=chat_payload)
            if res.status_code == 200:
                data = res.json()
                msg = data.get("message", {})
                content = msg.get("content", "").strip()
                if content:
                    return content
                # Fallback to thinking if content is empty
                thinking = msg.get("thinking", "").strip()
                if thinking:
                    return thinking
        except Exception:
            pass

        # Fallback to /api/generate
        payload = {
            "model": self.llm_model,
            "prompt": prompt,
            "stream": stream,
            "options": options
        }
        if system:
            payload["system"] = system

        res = self._client.post("/api/generate", json=payload)
        if res.status_code != 200:
            raise RuntimeError(f"Ollama generation failed ({res.status_code}): {res.text}")
        data = res.json()
        resp = data.get("response", "").strip()
        if not resp and data.get("thinking"):
            resp = data.get("thinking", "").strip()
        return resp
