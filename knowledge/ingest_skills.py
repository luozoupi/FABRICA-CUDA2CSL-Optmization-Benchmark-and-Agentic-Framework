#!/usr/bin/env python3
"""Ingest the cerebras-csl-skills repo as a JSONL knowledge base.

Walks /tmp/cerebras-csl-skills/SKILL-*.md, parses each file's YAML frontmatter,
chunks the body on ## H2 boundaries, derives topic tags, and emits a JSONL
corpus that CerebrasKnowledgeBase (knowledge/cerebras_docs.py) can load.

The skills repo is comprehensive reference material covering ground the
xkernel agents don't already have (microthreads model, route tables, debug
API surface, library catalog). Each skill is mapped to one of three audiences:

  - architect    -> SKILL-ROUTES, SKILL-MICROTHREADS, SKILL-SDKLAYOUT,
                    SKILL-HOST-DEVICE
  - implementer  -> SKILL-DSDS, SKILL-DSRS, SKILL-BUILTINS, SKILL-COMPTIME,
                    SKILL-LIBRARIES, SKILL-TASKS, SKILL-TYPES, SKILL-SYNTAX,
                    SKILL-GENERICS, SKILL-MODULES, SKILL-STORAGE,
                    SKILL-TOOLCHAIN, SKILL-SIMD
  - reviewer     -> SKILL-SDKRUNTIME-DEBUG, SKILL-SDKRUNTIME-API,
                    SKILL-SDKRUNTIME, SKILL-SDKRUNTIME-TYPES,
                    SKILL-HOST-DEVICE, SKILL-SDK-UTILS

Some skills (e.g. SKILL-HOST-DEVICE) appear in two audience maps -- that's
intentional: both architect and reviewer benefit from host-side knowledge
but for different reasons. Each chunk is emitted ONCE per audience and the
chunk_id hash includes the audience so the on-disk copies are distinct
retrievable entries.

Usage:
    python knowledge/ingest_skills.py                  # emit corpus
    python knowledge/ingest_skills.py --check          # dry-run + diff
    python knowledge/ingest_skills.py --root <path>    # alternate source
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Set, Tuple

_THIS_DIR = Path(__file__).resolve().parent
if str(_THIS_DIR.parent) not in sys.path:
    sys.path.insert(0, str(_THIS_DIR.parent))

from knowledge.cerebras_docs import KnowledgeChunk, infer_topic_tags

DEFAULT_ROOT = Path("/tmp/cerebras-csl-skills")
DEFAULT_OUT = _THIS_DIR / "data" / "cerebras_skills.jsonl"
DEFAULT_MANIFEST = _THIS_DIR / "data" / "skills_manifest.json"

# Tag chunks at the agent's default target SDK so version filtering keeps
# them visible. Content is largely version-stable; this is a deliberate fudge.
SKILL_SDK_VERSION = "1.4.0"

GITHUB_TREE = "https://github.com/pedronahum/cerebras-csl-skills/tree/main"
GITHUB_BLOB = "https://github.com/pedronahum/cerebras-csl-skills/blob/main"

AUDIENCE_FILES: Dict[str, List[str]] = {
    "architect": [
        "SKILL-ROUTES",
        "SKILL-MICROTHREADS",
        "SKILL-SDKLAYOUT",
        "SKILL-HOST-DEVICE",
    ],
    "implementer": [
        "SKILL-DSDS",
        "SKILL-DSRS",
        "SKILL-BUILTINS",
        "SKILL-COMPTIME",
        "SKILL-LIBRARIES",
        "SKILL-TASKS",
        "SKILL-TYPES",
        "SKILL-SYNTAX",
        "SKILL-GENERICS",
        "SKILL-MODULES",
        "SKILL-STORAGE",
        "SKILL-TOOLCHAIN",
        "SKILL-SIMD",
    ],
    "reviewer": [
        "SKILL-SDKRUNTIME-DEBUG",
        "SKILL-SDKRUNTIME-API",
        "SKILL-SDKRUNTIME",
        "SKILL-SDKRUNTIME-TYPES",
        "SKILL-HOST-DEVICE",
        "SKILL-SDK-UTILS",
    ],
}

CHUNK_TEXT_CAP = 1100   # matches cerebras_docs.to_prompt_block default cap
MIN_CHUNK_CHARS = 80

_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_FRONTMATTER_FIELD_RE = re.compile(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.*)$")


def parse_frontmatter(text: str) -> Tuple[Dict[str, str], str]:
    m = _FRONTMATTER_RE.match(text)
    if not m:
        return {}, text
    fields: Dict[str, str] = {}
    for line in m.group(1).splitlines():
        line = line.rstrip()
        if not line or line.startswith("#"):
            continue
        mm = _FRONTMATTER_FIELD_RE.match(line)
        if mm:
            fields[mm.group(1)] = mm.group(2).strip()
    body = text[m.end():]
    return fields, body


def chunk_on_h2(body: str, top_title: str) -> List[Tuple[str, str]]:
    lines = body.splitlines()
    chunks: List[Tuple[str, str]] = []
    cur_title = top_title
    cur_lines: List[str] = []
    h2_pat = re.compile(r"^##\s+(.+)\s*$")
    for line in lines:
        m = h2_pat.match(line)
        if m:
            if cur_lines:
                txt = "\n".join(cur_lines).strip()
                if len(txt) >= MIN_CHUNK_CHARS:
                    chunks.append((cur_title, txt))
            cur_title = m.group(1).strip()
            cur_lines = [line]
        else:
            cur_lines.append(line)
    if cur_lines:
        txt = "\n".join(cur_lines).strip()
        if len(txt) >= MIN_CHUNK_CHARS:
            chunks.append((cur_title, txt))
    return chunks


def derive_skill_tags(skill_basename: str, chunk_text: str) -> List[str]:
    tags: List[str] = ["Skill"]
    name = skill_basename.upper()
    if "ROUTES" in name:           tags += ["Routes", "Fabric"]
    if "MICROTHREADS" in name:     tags += ["Microthreads", "WSE-3"]
    if "SDKLAYOUT" in name:        tags += ["SdkLayout", "Layout"]
    if "DSDS" in name:             tags += ["DSD"]
    if "DSRS" in name:             tags += ["DSR"]
    if "BUILTINS" in name:         tags += ["Builtins"]
    if "COMPTIME" in name:         tags += ["Comptime"]
    if "LIBRARIES" in name:        tags += ["Libraries"]
    if "TASKS" in name:            tags += ["Tasks"]
    if "TYPES" in name:            tags += ["Types"]
    if "SYNTAX" in name:           tags += ["Syntax"]
    if "GENERICS" in name:         tags += ["Generics"]
    if "MODULES" in name:          tags += ["Modules"]
    if "STORAGE" in name:          tags += ["Storage"]
    if "TOOLCHAIN" in name:        tags += ["Toolchain"]
    if "HOST-DEVICE" in name:      tags += ["Host", "Memcpy"]
    if "SDKRUNTIME-DEBUG" in name: tags += ["Debug", "csdb", "Tooling"]
    if "SDKRUNTIME-API" in name:   tags += ["SdkRuntime", "API"]
    if "SDKRUNTIME-CPP" in name:   tags += ["SdkRuntime", "C++"]
    if "SDKRUNTIME-TYPES" in name: tags += ["SdkRuntime", "Enums"]
    if "SDKRUNTIME-ROUTE" in name: tags += ["SdkRuntime", "Routing"]
    if "SDK-UTILS" in name:        tags += ["sdk_utils"]
    if "SIMD" in name:             tags += ["SIMD"]
    if name == "SKILL-SDKRUNTIME": tags += ["SdkRuntime"]
    tags += infer_topic_tags(chunk_text)
    return sorted({t for t in tags})


def shorthash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:4]


def make_chunk_id(skill_basename: str, audience: str, idx: int, text: str) -> str:
    return (f"cerebras-skill-{skill_basename.lower()}-{audience}-"
            f"{idx}-{shorthash(text + '|' + audience)}")


def walk_skills(root: Path,
                audience_files: Dict[str, List[str]]
                ) -> List[KnowledgeChunk]:
    if not root.is_dir():
        raise FileNotFoundError(f"skills root not found: {root}")

    file_to_audiences: Dict[str, Set[str]] = {}
    for aud, files in audience_files.items():
        for f in files:
            file_to_audiences.setdefault(f, set()).add(aud)

    all_chunks: List[KnowledgeChunk] = []
    for skill_path in sorted(root.glob("SKILL-*.md")):
        basename = skill_path.stem
        audiences = file_to_audiences.get(basename)
        if not audiences:
            continue
        try:
            raw = skill_path.read_text(encoding="utf-8")
        except OSError:
            continue
        fields, body = parse_frontmatter(raw)
        title_m = re.search(r"^#\s+(.+)\s*$", body, re.MULTILINE)
        top_title = title_m.group(1).strip() if title_m else basename
        if title_m:
            body = body[title_m.end():]
        desc = fields.get("description", "")
        chunks_in_file = chunk_on_h2(body, top_title)
        if not chunks_in_file:
            continue

        for audience in sorted(audiences):
            for idx, (sect_title, sect_text) in enumerate(chunks_in_file):
                text = sect_text
                if idx == 0 and desc:
                    text = f"_skill description:_ {desc}\n\n{text}"
                if len(text) > CHUNK_TEXT_CAP:
                    text = text[:CHUNK_TEXT_CAP - 3].rstrip() + "..."
                if idx == 0:
                    display_title = top_title
                else:
                    display_title = f"{top_title}: {sect_title}"
                tags = derive_skill_tags(basename, text)
                chunk_id = make_chunk_id(basename, audience, idx, text)
                all_chunks.append(KnowledgeChunk(
                    chunk_id=chunk_id,
                    source_url=f"{GITHUB_TREE}/{basename}.md",
                    source_rst_url=f"{GITHUB_BLOB}/{basename}.md",
                    title=display_title,
                    sdk_version=SKILL_SDK_VERSION,
                    release_date=None,
                    section=f"csl_skill_{audience}",
                    topic_tags=tags,
                    introduced_in=None,
                    deprecated_in=None,
                    removed_in=None,
                    text=text,
                ))
    return all_chunks


def emit_jsonl(chunks: List[KnowledgeChunk], out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    for c in chunks:
        KnowledgeChunk.from_dict(asdict(c))  # validate schema
    chunks_sorted = sorted(chunks, key=lambda c: c.chunk_id)
    lines = [json.dumps(asdict(c), sort_keys=True, ensure_ascii=False)
             for c in chunks_sorted]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def emit_manifest(root: Path, chunks: List[KnowledgeChunk],
                  manifest_path: Path) -> None:
    inputs: List[Path] = sorted(root.glob("SKILL-*.md"))
    h = hashlib.sha256()
    for path in inputs:
        h.update(f"{path.name}|{path.stat().st_size}\n".encode())
    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_root": str(root),
        "chunk_count": len(chunks),
        "input_files": len(inputs),
        "inputs_sha256": h.hexdigest(),
        "sections_present": sorted({c.section for c in chunks}),
        "audience_file_map": {k: sorted(v) for k, v in AUDIENCE_FILES.items()},
    }
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n",
                             encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    ap.add_argument("--check", action="store_true",
                    help="dry-run: write to temp, diff vs existing; nonzero on drift")
    args = ap.parse_args()

    chunks = walk_skills(args.root, AUDIENCE_FILES)
    if not chunks:
        print(f"WARNING: no chunks emitted from {args.root}", file=sys.stderr)
        return 1

    if args.check:
        import tempfile
        with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl",
                                          delete=False) as tmp:
            tmp_path = Path(tmp.name)
        try:
            emit_jsonl(chunks, tmp_path)
            if args.out.exists():
                if tmp_path.read_bytes() != args.out.read_bytes():
                    print(f"DRIFT: {args.out} differs from regenerated output",
                          file=sys.stderr)
                    return 2
                print(f"OK: {args.out} matches regenerated output "
                      f"({len(chunks)} chunks)")
            else:
                print(f"NO EXISTING OUTPUT; would emit {len(chunks)} chunks")
            return 0
        finally:
            tmp_path.unlink(missing_ok=True)

    emit_jsonl(chunks, args.out)
    emit_manifest(args.root, chunks, args.manifest)
    sections = sorted({c.section for c in chunks})
    per_audience = {s: sum(1 for c in chunks if c.section == s)
                    for s in sections}
    print(f"wrote {args.out}  ({len(chunks)} chunks)")
    print(f"wrote {args.manifest}")
    print(f"per-audience chunk counts: {per_audience}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
