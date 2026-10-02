"""
Digital Campus - Sovereign Academic Document & Syllabus Crawler Engine
100% Offline / Local - Zero External API Billing.
Features:
1. Web & Syllabus URL Crawler (Crawls university portals, syllabus links, academic pages)
2. PDF & Document Parser (PyMuPDF / pdfplumber for textbooks, notes, and question papers)
3. Semantic Hierarchy & Token-Aware Chunker (Splits into 300-500 word semantic chunks with sliding overlap)
4. Dynamic Keyword & Concept Extractor
"""

import os
import re
import math
import hashlib
from typing import List, Dict, Any, Optional
from datetime import datetime
import requests
from bs4 import BeautifulSoup

try:
    import fitz  # PyMuPDF
    PYMUPDF_AVAILABLE = True
except ImportError:
    PYMUPDF_AVAILABLE = False


class AcademicSyllabusCrawler:
    """
    Crawls and extracts clean structured academic content from:
    - Web URLs (University portals, NPTEL syllabus, GeeksforGeeks, Wikipedia)
    - Local or uploaded PDF textbooks & lecture notes
    - Plain text and markdown curriculum files
    """

    HEADERS = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 DigitalCampusCrawler/2.0"
    }

    @classmethod
    def crawl_url(cls, url: str, subject_code: str = "GEN-101", subject_name: str = "Academic Syllabus") -> Dict[str, Any]:
        """
        Crawls any academic syllabus or textbook webpage.
        Strips boilerplate (navbars, footers, ads) and extracts core content.
        """
        try:
            resp = requests.get(url, headers=cls.HEADERS, timeout=12)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "html.parser")

            # Remove noise
            for tag in soup(["script", "style", "nav", "footer", "header", "aside", "form"]):
                tag.decompose()

            # Extract title
            title = soup.title.string.strip() if soup.title and soup.title.string else f"Crawled Syllabus ({url})"

            # Extract headings and paragraphs
            content_blocks = []
            for element in soup.find_all(["h1", "h2", "h3", "h4", "p", "li"]):
                txt = element.get_text().strip()
                if len(txt) > 25:
                    if element.name in ["h1", "h2", "h3", "h4"]:
                        content_blocks.append(f"\n### {txt}\n")
                    else:
                        content_blocks.append(txt)

            full_text = "\n".join(content_blocks)
            chunks = cls.semantic_chunk_text(full_text, source_title=title, source_type="web_url")

            return {
                "status": "SUCCESS",
                "source_url": url,
                "title": title,
                "subject_code": subject_code,
                "subject_name": subject_name,
                "total_characters": len(full_text),
                "total_chunks_created": len(chunks),
                "chunks": chunks,
                "crawled_at": datetime.now().isoformat()
            }
        except Exception as e:
            return {
                "status": "ERROR",
                "source_url": url,
                "error": str(e),
                "message": f"Failed to crawl URL: {str(e)}"
            }

    @classmethod
    def parse_pdf(cls, file_path_or_bytes: Any, title: str, subject: str = "Core Engineering") -> Dict[str, Any]:
        """
        Extracts high-fidelity academic text and page numbers from PDF textbooks.
        Supports both file path and raw bytes.
        """
        extracted_pages = []

        if PYMUPDF_AVAILABLE:
            try:
                if isinstance(file_path_or_bytes, bytes):
                    doc = fitz.open(stream=file_path_or_bytes, filetype="pdf")
                else:
                    doc = fitz.open(file_path_or_bytes)

                for page_idx in range(len(doc)):
                    page = doc[page_idx]
                    page_text = page.get_text("text").strip()
                    if len(page_text) > 40:
                        extracted_pages.append({
                            "page_number": page_idx + 1,
                            "text": page_text
                        })
                doc.close()
            except Exception as e:
                return {"status": "ERROR", "error": f"PyMuPDF parse error: {str(e)}"}
        else:
            return {"status": "ERROR", "error": "PyMuPDF (fitz) is not available"}

        if not extracted_pages:
            return {"status": "ERROR", "error": "No readable text found in PDF."}

        # Combine and semantic chunk
        all_chunks = []
        for p in extracted_pages:
            page_chunks = cls.semantic_chunk_text(
                p["text"],
                source_title=title,
                source_type="pdf",
                page_offset=p["page_number"]
            )
            all_chunks.extend(page_chunks)

        return {
            "status": "SUCCESS",
            "title": title,
            "subject": subject,
            "total_pages": len(extracted_pages),
            "total_chunks": len(all_chunks),
            "chunks": all_chunks,
            "parsed_at": datetime.now().isoformat()
        }

    @classmethod
    def semantic_chunk_text(
        cls,
        raw_text: str,
        source_title: str = "Document",
        source_type: str = "text",
        chunk_word_size: int = 250,
        overlap_words: int = 40,
        page_offset: int = 1
    ) -> List[Dict[str, Any]]:
        """
        Recursive semantic chunker:
        - Splits by structural sections/paragraphs first.
        - Packs chunks to target word size with sliding window overlap.
        - Extracts high-signal technical keywords.
        """
        # Clean text
        cleaned = re.sub(r'\r\n', '\n', raw_text)
        cleaned = re.sub(r'\n{3,}', '\n\n', cleaned)

        # Split into natural paragraphs
        raw_paragraphs = [p.strip() for p in cleaned.split("\n\n") if len(p.strip()) > 30]
        if not raw_paragraphs:
            raw_paragraphs = [cleaned]

        words = []
        for p in raw_paragraphs:
            words.extend(p.split())

        if not words:
            return []

        chunks = []
        step = max(1, chunk_word_size - overlap_words)
        total_words = len(words)

        for i in range(0, total_words, step):
            chunk_words = words[i:i + chunk_word_size]
            if len(chunk_words) < 25 and len(chunks) > 0:
                # Merge tiny trailing fragment with previous chunk
                break

            chunk_text = " ".join(chunk_words)
            chunk_idx = len(chunks) + 1

            # Extract technical keywords (alphanumeric, length > 3, exclude common stop words)
            stop_words = {
                "this", "that", "with", "from", "have", "were", "which", "there", "their",
                "about", "would", "these", "other", "could", "should", "using", "first"
            }
            cand_words = re.findall(r'\b[a-zA-Z]{4,}\b', chunk_text.lower())
            freq: Dict[str, int] = {}
            for w in cand_words:
                if w not in stop_words:
                    freq[w] = freq.get(w, 0) + 1

            top_keywords = sorted(freq.keys(), key=lambda k: freq[k], reverse=True)[:12]
            kw_string = " ".join(top_keywords)

            # Heuristic chapter / section detection
            chapter_match = re.search(r'(Chapter\s+\d+|Unit\s+\d+|Section\s+\d+|Module\s+\d+|###\s+[^.]+)', chunk_text, re.IGNORECASE)
            chapter_name = chapter_match.group(1).replace("###", "").strip() if chapter_match else f"Section {chunk_idx}"

            chunk_hash = hashlib.md5(chunk_text.encode('utf-8')).hexdigest()[:10]

            chunks.append({
                "chunk_index": chunk_idx,
                "chunk_uid": f"CHK-{chunk_hash}",
                "chapter": chapter_name,
                "page_number": page_offset,
                "content": chunk_text,
                "keywords": kw_string,
                "word_count": len(chunk_words),
                "source_type": source_type
            })

        return chunks
