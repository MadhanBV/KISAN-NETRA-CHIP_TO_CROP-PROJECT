import re
import hashlib
from typing import List, Dict, Any, Tuple
from ..config import settings
from ..models import Chunk

class ChunkingService:
    def __init__(self, chunk_size: int = settings.CHUNK_SIZE, chunk_overlap: int = settings.CHUNK_OVERLAP):
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        
        # Regex for major headings
        self.major_topic_regex = re.compile(
            r'^(?:(?:MANGO|TOMATO)\s+TOPIC\s+[0-9]+[^\n]*|[0-9]+\.\s+[A-Z\s–—\-]{4,}[^\n]*|={5,}\s*PART\s+[0-9]+[^\n]*|PART\s+[0-9]+[^\n]*)',
            re.IGNORECASE
        )
        
        # Regex for sub-topics / subsections
        self.sub_topic_regex = re.compile(
            r'^(?:Conversation:\s*[^\n]+|[0-9]+\.[0-9]+\s+[^\n]+|[0-9]+\.\s+(?:Disease|Symptoms|Causes|Integrated|Chemical|Organic|Preventive|Healthy|What\s+is|Biological|Cultural|Causal|Field|Key|Scientific)[^\n]*)',
            re.IGNORECASE
        )

    def _split_into_sections(self, content: str) -> List[Tuple[str, str]]:
        """Splits document content into structured sections based on actual document headings."""
        lines = content.split('\n')
        sections: List[Tuple[str, str]] = []
        
        current_major = "General"
        current_sub = "Overview"
        buffer: List[str] = []
        
        def flush():
            text = '\n'.join(buffer).strip()
            if text:
                title = f"{current_major} - {current_sub}" if current_major != current_sub else current_major
                # Clean up repeated separators or dashes
                title = re.sub(r'\s+', ' ', title).strip(" -—=")
                sections.append((title, text))
                
        for line in lines:
            stripped = line.strip()
            if not stripped:
                buffer.append('')
                continue
                
            m_major = self.major_topic_regex.match(stripped)
            if m_major and len(stripped) < 120 and not stripped.startswith('*'):
                flush()
                buffer = []
                current_major = stripped.replace('=', '').strip()
                current_sub = current_major
                continue
                
            m_sub = self.sub_topic_regex.match(stripped)
            if m_sub and len(stripped) < 120 and not stripped.startswith('*'):
                flush()
                buffer = []
                current_sub = stripped.strip()
                continue
                
            buffer.append(line)
            
        flush()
        return sections

    def _split_text_with_overlap(self, text: str) -> List[str]:
        """Splits large text by paragraph boundaries, then sentence boundaries, with overlap."""
        if len(text) <= self.chunk_size:
            return [text]
            
        paragraphs = [p.strip() for p in text.split('\n\n') if p.strip()]
        chunks: List[str] = []
        current_paras: List[str] = []
        current_len = 0
        
        for p in paragraphs:
            # If a single paragraph is itself longer than chunk_size, split by sentences
            if len(p) > self.chunk_size:
                if current_paras:
                    chunks.append('\n\n'.join(current_paras))
                    current_paras = []
                    current_len = 0
                
                # Split paragraph by sentences
                sentences = re.split(r'(?<=[.!?\n])\s+', p)
                sent_buf: List[str] = []
                sent_len = 0
                for s in sentences:
                    if sent_len + len(s) > self.chunk_size and sent_buf:
                        chunks.append(' '.join(sent_buf))
                        # Retain overlap from end of sent_buf
                        overlap_text = sent_buf[-1] if len(sent_buf[-1]) <= self.chunk_overlap else sent_buf[-1][-self.chunk_overlap:]
                        sent_buf = [overlap_text, s]
                        sent_len = len(overlap_text) + len(s) + 1
                    else:
                        sent_buf.append(s)
                        sent_len += len(s) + 1
                if sent_buf:
                    chunks.append(' '.join(sent_buf))
                continue

            if current_len + len(p) + 2 > self.chunk_size and current_paras:
                chunks.append('\n\n'.join(current_paras))
                # Add overlap from last paragraph
                last_para = current_paras[-1]
                if len(last_para) <= self.chunk_overlap * 2:
                    current_paras = [last_para, p]
                    current_len = len(last_para) + len(p) + 2
                else:
                    overlap_snippet = last_para[-self.chunk_overlap:]
                    current_paras = [f"...{overlap_snippet}", p]
                    current_len = len(overlap_snippet) + len(p) + 5
            else:
                current_paras.append(p)
                current_len += len(p) + 2
                
        if current_paras:
            chunks.append('\n\n'.join(current_paras))
            
        return chunks

    def chunk_document(self, doc_data: Dict[str, Any]) -> List[Chunk]:
        """Processes a loaded document into a list of Chunk models with deterministic IDs."""
        source_file = doc_data["file_name"]
        crop = doc_data["crop"]
        source_type = doc_data["source_type"]
        content = doc_data["content"]
        
        sections = self._split_into_sections(content)
        all_chunks: List[Chunk] = []
        
        doc_chunk_idx = 0
        for section_title, section_text in sections:
            split_texts = self._split_text_with_overlap(section_text)
            
            for part_idx, text_part in enumerate(split_texts):
                # Contextual header for vector embedding and LLM prompt
                annotated_text = f"[{crop.upper()} - {section_title}]\n{text_part}".strip()
                
                # Deterministic seed combining source file, section, doc sequence and content
                id_seed = f"{source_file}::{section_title}::{doc_chunk_idx}::{text_part}"
                hash_hex = hashlib.sha256(id_seed.encode('utf-8')).hexdigest()[:10]
                chunk_id = f"{crop}_{doc_chunk_idx:04d}_{hash_hex}"
                
                chunk = Chunk(
                    chunk_id=chunk_id,
                    source_file=source_file,
                    crop=crop,
                    source_type=source_type,
                    section=section_title,
                    chunk_index=doc_chunk_idx,
                    text=annotated_text
                )
                all_chunks.append(chunk)
                doc_chunk_idx += 1
                
        return all_chunks
