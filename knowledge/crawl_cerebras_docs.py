#!/usr/bin/env python3
"""
Crawl and process Cerebras SDK docs into a local JSONL knowledge base.

Default scope is the cumulative SDK release notes. The script prefers Jupyter
Book `.rst.txt` sources because they are cleaner and easier to chunk than HTML.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from knowledge.cerebras_docs import infer_change_versions, infer_topic_tags


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_URL = "https://sdk.cerebras.net/sdk-release-notes/sdk-rel-notes-cumulative"
DEFAULT_RST_URL = "https://sdk.cerebras.net/_sources/sdk-release-notes/sdk-rel-notes-cumulative.rst.txt"
DEFAULT_RAW_DIR = REPO_ROOT / "knowledge" / "raw"
DEFAULT_OUTPUT = REPO_ROOT / "knowledge" / "data" / "cerebras_sdk_docs.jsonl"
DEFAULT_MANIFEST = REPO_ROOT / "knowledge" / "data" / "manifest.json"

SECTION_MAP = {
    "New features and enhancements": "new_features",
    "Resolved issues": "resolved_issues",
    "Known issues": "known_issues",
    "Deprecations": "deprecations",
    "Notes for future releases": "future_notes",
    "Requirements and unsupported features": "requirements_unsupported",
}


@dataclass
class CrawlDoc:
    source_url: str
    source_rst_url: str
    title: str
    content: str
    sha256: str
    fetched_at: str


def fetch_url(url: str, timeout: int = 60) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": "xkernel-doc-crawler/0.1"})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        return response.read().decode(charset, "replace")


def html_url_to_rst_url(url: str) -> str:
    if "/_sources/" in url or url.endswith(".rst.txt"):
        return url
    prefix = "https://sdk.cerebras.net/"
    if not url.startswith(prefix):
        return url
    path = url[len(prefix):].strip("/")
    return f"{prefix}_sources/{path}.rst.txt"


def crawl_release_notes(source_url: str, rst_url: Optional[str] = None) -> CrawlDoc:
    resolved_rst = rst_url or html_url_to_rst_url(source_url)
    try:
        content = fetch_url(resolved_rst)
        source_rst_url = resolved_rst
    except urllib.error.URLError:
        content = fetch_url(source_url)
        source_rst_url = ""
    digest = hashlib.sha256(content.encode("utf-8")).hexdigest()
    return CrawlDoc(
        source_url=source_url,
        source_rst_url=source_rst_url,
        title="SDK Release Notes",
        content=content,
        sha256=digest,
        fetched_at=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    )


def normalize_rst(text: str) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text


def parse_release_notes(doc: CrawlDoc) -> List[Dict[str, object]]:
    content = normalize_rst(doc.content)
    version_matches = list(
        re.finditer(r"(?m)^Version\s+([0-9][0-9.]*)(?:\s*\n[-=~`^\"#*+]+)?", content)
    )
    chunks: List[Dict[str, object]] = []
    for idx, match in enumerate(version_matches):
        version = match.group(1)
        start = match.start()
        end = version_matches[idx + 1].start() if idx + 1 < len(version_matches) else len(content)
        version_text = content[start:end].strip()
        release_date = _extract_release_date(version_text)
        chunks.extend(_chunk_version(doc, version, release_date, version_text))
    return chunks


def _chunk_version(doc: CrawlDoc,
                   version: str,
                   release_date: Optional[str],
                   version_text: str) -> List[Dict[str, object]]:
    section_patterns = "|".join(re.escape(title) for title in SECTION_MAP)
    section_matches = list(
        re.finditer(rf"(?m)^({section_patterns})(?:\s*\n[-=~`^\"#*+]+)?", version_text)
    )
    if not section_matches:
        return [_make_chunk(doc, version, release_date, "release_notes", version_text)]

    chunks: List[Dict[str, object]] = []
    preamble = version_text[: section_matches[0].start()].strip()
    if preamble:
        chunks.append(_make_chunk(doc, version, release_date, "release_preamble", preamble))

    for idx, match in enumerate(section_matches):
        section_title = match.group(1)
        start = match.end()
        end = section_matches[idx + 1].start() if idx + 1 < len(section_matches) else len(version_text)
        section = SECTION_MAP.get(section_title, _slug(section_title))
        section_text = version_text[start:end].strip()
        for piece in _split_section(section_text):
            chunks.append(_make_chunk(doc, version, release_date, section, piece))
    return chunks


def _split_section(text: str, max_chars: int = 2200) -> Iterable[str]:
    text = text.strip()
    if not text:
        return []
    paragraphs = re.split(r"\n\s*\n", text)
    pieces: List[str] = []
    current = ""
    for paragraph in paragraphs:
        paragraph = paragraph.strip()
        if not paragraph:
            continue
        if current and len(current) + len(paragraph) + 2 > max_chars:
            pieces.append(current.strip())
            current = paragraph
        else:
            current = f"{current}\n\n{paragraph}".strip() if current else paragraph
    if current:
        pieces.append(current.strip())
    return pieces


def _make_chunk(doc: CrawlDoc,
                version: Optional[str],
                release_date: Optional[str],
                section: str,
                text: str) -> Dict[str, object]:
    cleaned = _clean_rst(text)
    tags = infer_topic_tags(cleaned)
    introduced, deprecated, removed = infer_change_versions(section, version, cleaned)
    chunk_hash = hashlib.sha1(
        "\n".join([doc.source_url, version or "", section, cleaned[:400]]).encode("utf-8")
    ).hexdigest()[:12]
    return {
        "chunk_id": f"cerebras-sdk-{version or 'unknown'}-{section}-{chunk_hash}",
        "source_url": doc.source_url,
        "source_rst_url": doc.source_rst_url,
        "title": doc.title,
        "sdk_version": version,
        "release_date": release_date,
        "section": section,
        "topic_tags": tags,
        "introduced_in": introduced,
        "deprecated_in": deprecated,
        "removed_in": removed,
        "text": cleaned,
    }


def _extract_release_date(version_text: str) -> Optional[str]:
    match = re.search(r"Released\s+([0-9]{1,2}\s+[A-Za-z]+\s+[0-9]{4})", version_text)
    return match.group(1) if match else None


def _clean_rst(text: str) -> str:
    text = re.sub(r"\.\.\s+_[^:]+:\s*", "", text)
    text = re.sub(r"\.\.\s+note::", "Note:", text)
    text = re.sub(r"\.\.\s+code-block::\s*([A-Za-z0-9_+-]+)?", r"Code example:", text)
    text = re.sub(r":ref:`([^`]+)`", r"`\1`", text)
    text = re.sub(r"`([^`<]+)\s*<[^`]+>`_", r"`\1`", text)
    text = re.sub(r"``([^`]+)``", r"`\1`", text)
    text = re.sub(r"(?m)^[ \t]*[-=~`^\"#*+]{3,}\s*$", "", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def _slug(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def write_outputs(doc: CrawlDoc,
                  chunks: List[Dict[str, object]],
                  raw_dir: Path,
                  output_path: Path,
                  manifest_path: Path) -> None:
    raw_dir.mkdir(parents=True, exist_ok=True)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    raw_path = raw_dir / "sdk-rel-notes-cumulative.rst.txt"
    raw_path.write_text(doc.content, encoding="utf-8")
    with output_path.open("w", encoding="utf-8") as fh:
        for chunk in chunks:
            fh.write(json.dumps(chunk, ensure_ascii=False, sort_keys=False) + "\n")
    versions = sorted(
        {str(chunk["sdk_version"]) for chunk in chunks if chunk.get("sdk_version")},
        key=lambda version: [int(part) for part in re.findall(r"\d+", version)],
        reverse=True,
    )
    manifest = {
        "generated_at": doc.fetched_at,
        "source_url": doc.source_url,
        "source_rst_url": doc.source_rst_url,
        "raw_path": str(raw_path),
        "output_path": str(output_path),
        "sha256": doc.sha256,
        "chunk_count": len(chunks),
        "versions": versions,
    }
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=False) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build local Cerebras SDK docs knowledge base")
    parser.add_argument("--source-url", default=DEFAULT_SOURCE_URL)
    parser.add_argument("--rst-url", default=DEFAULT_RST_URL)
    parser.add_argument("--raw-dir", default=str(DEFAULT_RAW_DIR))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    args = parser.parse_args()

    doc = crawl_release_notes(args.source_url, args.rst_url)
    chunks = parse_release_notes(doc)
    write_outputs(
        doc=doc,
        chunks=chunks,
        raw_dir=Path(args.raw_dir).expanduser(),
        output_path=Path(args.output).expanduser(),
        manifest_path=Path(args.manifest).expanduser(),
    )
    print(json.dumps({
        "source": doc.source_rst_url or doc.source_url,
        "chunks": len(chunks),
        "output": str(Path(args.output).expanduser()),
        "sha256": doc.sha256,
    }, indent=2))


if __name__ == "__main__":
    main()
