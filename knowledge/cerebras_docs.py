#!/usr/bin/env python3
"""
Tiny retrieval interface for processed Cerebras SDK documentation.

The goal is not to replace a vector DB. This module provides a stable, local,
version-aware interface that the translation prompts can use without requiring
network access during an agent run.
"""

from __future__ import annotations

import json
import math
import os
import re
import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_KB_PATH = REPO_ROOT / "knowledge" / "data" / "cerebras_sdk_docs.jsonl"
DEFAULT_TARGET_SDK = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")

STOPWORDS = {
    "a", "an", "and", "are", "as", "at", "be", "by", "can", "for", "from",
    "has", "in", "into", "is", "it", "its", "may", "new", "no", "not", "of",
    "on", "or", "the", "this", "to", "use", "used", "using", "with",
}

TOPIC_PATTERNS = {
    "CSL": [r"\bcsl\b", r"@get_", r"@set_", r"\btask\b", r"\bcomptime\b"],
    "WSE-3": [r"\bwse-?3\b", r"\bcs-3\b"],
    "WSE-2": [r"\bwse-?2\b", r"\bcs-2\b"],
    "SdkRuntime": [r"\bsdkruntime\b", r"\bmemcpy_h2d\b", r"\bmemcpy_d2h\b"],
    "SdkLayout": [r"\bsdklayout\b", r"\blayout\b"],
    "DSD": [r"\bdsd\b", r"\bdsr\b", r"\bxdsr\b", r"\bfabin_dsd\b", r"\bfabout_dsd\b"],
    "Queues": [r"\bqueue\b", r"\bfifo\b", r"@initialize_queue", r"@allocate_fifo"],
    "Compiler": [r"\bcslc\b", r"\bcompiler\b", r"\bcompile\b"],
    "Debug": [r"\bdebug\b", r"\bcsdb\b", r"\btrace\b", r"\bsimprint\b"],
    "Deprecation": [r"\bdeprecat", r"\bremoved\b", r"\bno longer\b"],
}


@dataclass(frozen=True)
class KnowledgeChunk:
    chunk_id: str
    source_url: str
    source_rst_url: str
    title: str
    sdk_version: Optional[str]
    release_date: Optional[str]
    section: str
    topic_tags: List[str]
    introduced_in: Optional[str]
    deprecated_in: Optional[str]
    removed_in: Optional[str]
    text: str

    @classmethod
    def from_dict(cls, payload: Dict[str, object]) -> "KnowledgeChunk":
        return cls(
            chunk_id=str(payload.get("chunk_id", "")),
            source_url=str(payload.get("source_url", "")),
            source_rst_url=str(payload.get("source_rst_url", "")),
            title=str(payload.get("title", "")),
            sdk_version=_optional_str(payload.get("sdk_version")),
            release_date=_optional_str(payload.get("release_date")),
            section=str(payload.get("section", "")),
            topic_tags=list(payload.get("topic_tags", []) or []),
            introduced_in=_optional_str(payload.get("introduced_in")),
            deprecated_in=_optional_str(payload.get("deprecated_in")),
            removed_in=_optional_str(payload.get("removed_in")),
            text=str(payload.get("text", "")),
        )

    def to_prompt_block(self, max_chars: int = 1200) -> str:
        tags = ", ".join(self.topic_tags) if self.topic_tags else "untagged"
        header = (
            f"[{self.chunk_id}] SDK {self.sdk_version or 'n/a'} | "
            f"{self.section} | {tags}"
        )
        text = self.text.strip()
        if len(text) > max_chars:
            text = text[: max_chars - 3].rstrip() + "..."
        return f"{header}\n{text}"


class CerebrasKnowledgeBase:
    def __init__(self, path: Optional[os.PathLike[str] | str] = None) -> None:
        self.path = Path(path) if path else DEFAULT_KB_PATH
        self.chunks = self._load_chunks(self.path)
        self._doc_freq = _document_frequency(self.chunks)

    @staticmethod
    def _load_chunks(path: Path) -> List[KnowledgeChunk]:
        if not path.exists():
            return []
        chunks: List[KnowledgeChunk] = []
        with path.open("r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                chunks.append(KnowledgeChunk.from_dict(json.loads(line)))
        return chunks

    def query(self,
              text: str,
              *,
              target_sdk: str = DEFAULT_TARGET_SDK,
              arch: str = "wse3",
              sections: Optional[Sequence[str]] = None,
              tags: Optional[Sequence[str]] = None,
              top_k: int = 6,
              include_future: bool = False) -> List[KnowledgeChunk]:
        if not self.chunks:
            return []
        query_terms = _tokenize(" ".join([text, arch]))
        section_filter = {s.lower() for s in sections or []}
        tag_filter = {t.lower() for t in tags or []}
        scored: List[Tuple[float, KnowledgeChunk]] = []
        for chunk in self.chunks:
            if section_filter and chunk.section.lower() not in section_filter:
                continue
            if tag_filter and not tag_filter.intersection(t.lower() for t in chunk.topic_tags):
                continue
            if not include_future and chunk.sdk_version:
                if compare_versions(chunk.sdk_version, target_sdk) > 0:
                    continue
            score = _score_chunk(query_terms, chunk, self._doc_freq, len(self.chunks))
            if score > 0:
                scored.append((score, chunk))
        scored.sort(key=lambda item: item[0], reverse=True)
        return [chunk for _, chunk in scored[:top_k]]

    def prompt_context(self,
                       text: str,
                       *,
                       target_sdk: str = DEFAULT_TARGET_SDK,
                       arch: str = "wse3",
                       sections: Optional[Sequence[str]] = None,
                       tags: Optional[Sequence[str]] = None,
                       top_k: int = 5,
                       max_chars: int = 4500,
                       include_future: bool = False) -> str:
        chunks = self.query(
            text,
            target_sdk=target_sdk,
            arch=arch,
            sections=sections,
            tags=tags,
            top_k=top_k,
            include_future=include_future,
        )
        if not chunks:
            return ""
        blocks: List[str] = []
        remaining = max_chars
        for chunk in chunks:
            block = chunk.to_prompt_block(max_chars=min(1200, max(400, remaining)))
            if len(block) > remaining:
                break
            blocks.append(block)
            remaining -= len(block) + 2
        return "\n\n".join(blocks)

    def compatibility_context(self,
                              *,
                              target_sdk: str = DEFAULT_TARGET_SDK,
                              arch: str = "wse3",
                              max_chars: int = 3000) -> str:
        query = (
            f"{arch} CSL compiler DSD queues memcpy task SdkRuntime known issues "
            "deprecations removed no longer supported"
        )
        return self.prompt_context(
            query,
            target_sdk=target_sdk,
            arch=arch,
            top_k=6,
            max_chars=max_chars,
            include_future=False,
        )


def load_default() -> CerebrasKnowledgeBase:
    return CerebrasKnowledgeBase()


def infer_topic_tags(text: str) -> List[str]:
    lowered = text.lower()
    tags = []
    for tag, patterns in TOPIC_PATTERNS.items():
        if any(re.search(pattern, lowered, flags=re.IGNORECASE) for pattern in patterns):
            tags.append(tag)
    return tags


def infer_change_versions(section: str,
                          sdk_version: Optional[str],
                          text: str) -> Tuple[Optional[str], Optional[str], Optional[str]]:
    lowered = " ".join([section, text]).lower()
    introduced = sdk_version if any(
        word in lowered for word in ["introduces", "adds", "new ", "support for"]
    ) else None
    deprecated = sdk_version if "deprecat" in lowered else None
    removed = sdk_version if any(
        phrase in lowered for phrase in ["removed", "no longer supported", "no longer allowed"]
    ) else None
    return introduced, deprecated, removed


def compare_versions(left: str, right: str) -> int:
    l_parts = _version_parts(left)
    r_parts = _version_parts(right)
    width = max(len(l_parts), len(r_parts))
    l_parts.extend([0] * (width - len(l_parts)))
    r_parts.extend([0] * (width - len(r_parts)))
    if l_parts == r_parts:
        return 0
    return 1 if l_parts > r_parts else -1


def _optional_str(value: object) -> Optional[str]:
    if value is None:
        return None
    text = str(value)
    return text or None


def _version_parts(version: str) -> List[int]:
    return [int(part) for part in re.findall(r"\d+", version)]


def _tokenize(text: str) -> Set[str]:
    tokens = {
        token.lower()
        for token in re.findall(r"[A-Za-z_@][A-Za-z0-9_@.-]{1,}", text)
    }
    return {token for token in tokens if token not in STOPWORDS}


def _document_frequency(chunks: Iterable[KnowledgeChunk]) -> Dict[str, int]:
    df: Dict[str, int] = {}
    for chunk in chunks:
        for token in _tokenize(" ".join([chunk.title, chunk.section, " ".join(chunk.topic_tags), chunk.text])):
            df[token] = df.get(token, 0) + 1
    return df


def _score_chunk(query_terms: Set[str],
                 chunk: KnowledgeChunk,
                 doc_freq: Dict[str, int],
                 total_docs: int) -> float:
    haystack = " ".join([chunk.title, chunk.section, " ".join(chunk.topic_tags), chunk.text])
    doc_terms = _tokenize(haystack)
    overlap = query_terms.intersection(doc_terms)
    if not overlap:
        return 0.0
    score = 0.0
    for token in overlap:
        idf = math.log((1 + total_docs) / (1 + doc_freq.get(token, 0))) + 1
        score += idf
        if token in chunk.section.lower():
            score += 0.5
        if any(token == tag.lower() for tag in chunk.topic_tags):
            score += 0.75
    if chunk.section.lower() in {"known_issues", "deprecations"}:
        score += 0.4
    return score


def main() -> None:
    parser = argparse.ArgumentParser(description="Query the local Cerebras SDK knowledge base")
    parser.add_argument("query", nargs="*", help="Query terms")
    parser.add_argument("--kb", default=str(DEFAULT_KB_PATH))
    parser.add_argument("--target-sdk", default=DEFAULT_TARGET_SDK)
    parser.add_argument("--arch", default="wse3")
    parser.add_argument("--top-k", type=int, default=5)
    parser.add_argument("--include-future", action="store_true",
                        help="Allow chunks from SDK versions newer than --target-sdk.")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    kb = CerebrasKnowledgeBase(args.kb)
    query = " ".join(args.query) or "CSL WSE-3 compiler known issues deprecations"
    chunks = kb.query(
        query,
        target_sdk=args.target_sdk,
        arch=args.arch,
        top_k=args.top_k,
        include_future=args.include_future,
    )
    if args.json:
        print(json.dumps([chunk.__dict__ for chunk in chunks], indent=2, sort_keys=False))
    else:
        for chunk in chunks:
            print(chunk.to_prompt_block())
            print()


if __name__ == "__main__":
    main()
