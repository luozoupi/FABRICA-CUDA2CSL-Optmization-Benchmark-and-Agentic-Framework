#!/usr/bin/env python3
"""Ingest the Cerebras CSL tutorials corpus into a JSONL knowledge base.

Walks ~/csl-examples/tutorials/, chunks each tutorial's README and
CSL source files deterministically, and emits a JSONL corpus that
CerebrasKnowledgeBase (knowledge/cerebras_docs.py) can load.

Idempotent: chunk_ids are hash-stable, the list is sorted before write, so
re-running produces byte-identical output. The Cerebras-authored benchmark
implementations (~/csl-examples/benchmarks/) are EXPLICITLY EXCLUDED
to avoid teaching the agent answers to its own test set.

Each chunk gets one of three section labels for per-agent dispatch:
  - tutorial_readme_architect   -> for_architect lens
  - tutorial_readme_reviewer    -> for_reviewer lens
  - tutorial_csl_implementer    -> for_implementer lens

Usage:
    python knowledge/ingest_tutorials.py                  # emit corpus
    python knowledge/ingest_tutorials.py --check          # dry-run + diff
    python knowledge/ingest_tutorials.py --root <path>    # alternate source
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Make the sibling cerebras_docs module importable when run as a script.
_THIS_DIR = Path(__file__).resolve().parent
if str(_THIS_DIR.parent) not in sys.path:
    sys.path.insert(0, str(_THIS_DIR.parent))

from knowledge.cerebras_docs import KnowledgeChunk, infer_topic_tags

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DEFAULT_ROOT = Path.home() / "csl-examples" / "tutorials"
DEFAULT_OUT = _THIS_DIR / "data" / "cerebras_tutorials.jsonl"
DEFAULT_MANIFEST = _THIS_DIR / "data" / "tutorials_manifest.json"

# Hard-asserted: nothing under benchmarks/ is allowed in the corpus.
BENCHMARKS_TOKEN = "/benchmarks/"

# SDK version the tutorials currently target. (The csl-examples repo is
# branch-tagged; rel-sdk-1.4.0 is the active branch on this host.)
TUTORIAL_SDK_VERSION = "1.4.0"

# GitHub source roots for the chunk URLs.
GITHUB_TREE = "https://github.com/Cerebras/csl-examples/tree/master/tutorials"
GITHUB_BLOB = "https://github.com/Cerebras/csl-examples/blob/master/tutorials"

# Max chars per chunk's text body. Matches the 1200-char cap in
# CerebrasKnowledgeBase.to_prompt_block (cerebras_docs.py:158); leave a tiny
# margin so the prompt-format header fits.
CHUNK_TEXT_CAP = 1100

# ---------------------------------------------------------------------------
# Tag derivation: tutorial-name -> base tags
# ---------------------------------------------------------------------------

def name_tags(name: str) -> List[str]:
    """Tags derived from the tutorial directory name. Deterministic."""
    tags: List[str] = ["Tutorial"]
    n = name.lower()
    if n.startswith("gemv-"):
        tags.append("GEMV")
        if n == "gemv-00-basic-syntax":
            tags.append("Basics")
        if "routes" in n:
            tags += ["Routes", "Fabric"]
        if "streaming" in n:
            tags.append("Streaming")
        if "memcpy" in n:
            tags.append("Memcpy")
        if "memory-dsds" in n:
            tags.append("DSD")
        if "params" in n:
            tags.append("Params")
        # gemv-05/06/07/08 are multi-PE
        for s in ("05-multiple-pes", "06-routes-1", "07-routes-2", "08-routes-3"):
            if s in n:
                tags.append("MultiPE")
                break
    elif n.startswith("pipeline-"):
        tags.append("Pipeline")
        if "fifo" in n:
            tags.append("FIFO")
        if "multiple" in n:
            tags.append("MultiStage")
    elif n.startswith("sdklayout-"):
        # Beta API; tagged so retrieval can downweight later if needed.
        tags += ["SdkLayout", "Beta"]
    elif n.startswith("topic-"):
        # Single-purpose feature tutorials.
        topic_tags = {
            "topic-01-arrays-and-pointers":   ["Arrays", "Pointers"],
            "topic-02-libraries":              ["Libraries", "Imports"],
            "topic-03-streaming-wavelet-data": ["Streaming", "Wavelet"],
            "topic-04-sparse-tensors":         ["Sparse", "DSD"],
            "topic-05-sentinels":              ["Sentinels", "Tasks"],
            "topic-06-switches":               ["Switches", "Fabric"],
            "topic-07-switches-entrypt":       ["Switches", "Fabric"],
            "topic-08-filters":                ["Filters", "Fabric"],
            "topic-09-fifos":                  ["FIFO", "DSD", "Fabric"],
            "topic-10-map-builtin":            ["Map", "Builtin"],
            "topic-11-collectives":            ["Collectives", "MultiPE"],
            "topic-12-debug-library":          ["Debug", "Tooling"],
            "topic-13-simprint":               ["Debug", "simprint"],
            "topic-14-color-swap":             ["Colors", "Fabric"],
            "topic-15-wse3-microthreads":      ["WSE-3", "Microthreads"],
        }
        tags += topic_tags.get(n, [])
    return tags


def merge_tags(name_based: List[str], content_based: List[str]) -> List[str]:
    """Merge two tag lists, dedupe case-insensitively, sort for determinism."""
    seen_lower = set()
    out: List[str] = []
    for t in list(name_based) + list(content_based):
        if t.lower() in seen_lower:
            continue
        seen_lower.add(t.lower())
        out.append(t)
    return sorted(out)


# ---------------------------------------------------------------------------
# Chunk-id construction (sha256 short hash for stability)
# ---------------------------------------------------------------------------

def shorthash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:4]


def make_chunk_id(tutorial_dir: str, file_stem: str, block_kind: str,
                  block_index: int, text: str) -> str:
    return (f"cerebras-tutorial-{tutorial_dir}-{file_stem}-{block_kind}-"
            f"{block_index}-{shorthash(text)}")


# ---------------------------------------------------------------------------
# README chunking
# ---------------------------------------------------------------------------

def strip_rst_title(lines: List[str]) -> Tuple[str, List[str]]:
    """Pop the first non-empty title + its underline. Returns (title, rest)."""
    body = list(lines)
    title = ""
    while body and not body[0].strip():
        body.pop(0)
    if not body:
        return title, body
    title = body[0].rstrip()
    # If next line is an underline, drop both.
    if len(body) > 1 and body[1].rstrip() and set(body[1].strip()) <= {"=", "-", "~", "^"}:
        body = body[2:]
    else:
        body = body[1:]
    return title, body


def split_readme_sections(body: List[str]) -> List[Tuple[str, str]]:
    """Split a README body on RST section underlines.

    Returns [(section_title, section_text)] -- ALWAYS at least one entry.
    Short READMEs (<= 40 lines or no section underlines) return one entry
    with empty section_title and the full body.
    """
    if len(body) <= 40:
        return [("", "\n".join(body).strip())]
    sections: List[Tuple[str, str]] = []
    cur_title = ""
    cur_lines: List[str] = []
    i = 0
    while i < len(body):
        line = body[i]
        # Detect an RST underline: next line is `---` or `~~~~` of length >= line.
        is_underline = (i + 1 < len(body)
                        and body[i + 1].strip()
                        and set(body[i + 1].strip()) <= {"-", "~", "^"}
                        and line.strip()
                        and len(body[i + 1].strip()) >= len(line.strip()))
        if is_underline:
            # Flush previous section.
            if cur_lines:
                sections.append((cur_title, "\n".join(cur_lines).strip()))
                cur_lines = []
            cur_title = line.strip()
            i += 2  # skip the title + underline
            continue
        cur_lines.append(line)
        i += 1
    if cur_lines:
        sections.append((cur_title, "\n".join(cur_lines).strip()))
    return sections or [("", "\n".join(body).strip())]


def chunk_readme(tutorial_dir: str, readme_path: Path,
                 base_tags: List[str]) -> List[KnowledgeChunk]:
    """Emit one architect + one reviewer chunk per README section.

    Two-audience duplication is intentional: the existing CerebrasKnowledgeBase
    section filter dispatches via section name, so we want distinct sections
    even though the text is the same.
    """
    try:
        raw = readme_path.read_text(encoding="utf-8")
    except OSError:
        return []
    lines = raw.splitlines()
    title, body = strip_rst_title(lines)
    sections = split_readme_sections(body)

    chunks: List[KnowledgeChunk] = []
    source_url = f"{GITHUB_TREE}/{tutorial_dir}"
    source_rst_url = f"{GITHUB_BLOB}/{tutorial_dir}/README.rst"
    full_title = title or tutorial_dir

    for audience in ("architect", "reviewer"):
        for idx, (sect_title, sect_text) in enumerate(sections):
            if not sect_text.strip():
                continue
            text = sect_text
            if len(text) > CHUNK_TEXT_CAP:
                text = text[:CHUNK_TEXT_CAP - 3].rstrip() + "..."
            # Multi-section READMEs: prefix sub-section title for retrieval context.
            if sect_title:
                text = f"### {sect_title}\n\n{text}"
            content_tags = infer_topic_tags(text)
            tags = merge_tags(base_tags, content_tags)
            display_title = (f"{full_title} (section: {sect_title})"
                             if sect_title else full_title)
            chunk_id = make_chunk_id(
                tutorial_dir,
                f"readme-{audience}",
                "section",
                idx,
                text + f"|{audience}",  # audience in hash so dup chunks differ
            )
            chunks.append(KnowledgeChunk(
                chunk_id=chunk_id,
                source_url=source_url,
                source_rst_url=source_rst_url,
                title=display_title,
                sdk_version=TUTORIAL_SDK_VERSION,
                release_date=None,
                section=f"tutorial_readme_{audience}",
                topic_tags=tags,
                introduced_in=None,
                deprecated_in=None,
                removed_in=None,
                text=text,
            ))
    return chunks


# ---------------------------------------------------------------------------
# CSL chunking
# ---------------------------------------------------------------------------

COPYRIGHT_PREFIX = "// Copyright"


def strip_copyright(text: str) -> str:
    """Drop the 13-line Apache copyright header if present."""
    lines = text.splitlines()
    if not lines or not lines[0].startswith(COPYRIGHT_PREFIX):
        return text
    # Skip lines until we leave the comment block (first non-// line OR a
    # blank line followed by a non-//).
    i = 0
    while i < len(lines) and lines[i].startswith("//"):
        i += 1
    # Also eat a single trailing blank line so the preamble doesn't start
    # with whitespace.
    while i < len(lines) and not lines[i].strip():
        i += 1
    return "\n".join(lines[i:])


def split_csl_blocks(source: str) -> Tuple[str, List[Tuple[str, str, str]]]:
    """Split a CSL source into (preamble, [(block_kind, block_name, block_text)]).

    Block detection: top-level `fn `, `task `, or `comptime {`. Brace-balanced
    so nested braces don't false-split. Anything before the first such block
    is the preamble (params, consts, vars, imports).
    """
    lines = source.splitlines()
    n = len(lines)

    # Find the first top-level block start.
    def is_block_start(line: str) -> Optional[Tuple[str, str]]:
        stripped = line.lstrip()
        # No leading whitespace for top-level.
        if line.startswith((" ", "\t")):
            return None
        for kind in ("fn ", "task ", "comptime"):
            if stripped.startswith(kind):
                # Extract name after the keyword (for fn/task) up to '(' or '{'.
                rest = stripped[len(kind):].strip()
                if kind == "comptime":
                    # comptime block — name it by its position; rest should start with `{`.
                    if rest.startswith("{"):
                        return ("comptime", "block")
                    continue
                # fn / task : name = identifier up to '(' or whitespace
                name = ""
                for ch in rest:
                    if ch in "( \t<{":
                        break
                    name += ch
                if name:
                    return (kind.strip(), name)
        return None

    # Find first block.
    first_idx = None
    for i, line in enumerate(lines):
        if is_block_start(line):
            first_idx = i
            break
    if first_idx is None:
        # No fn/task/comptime — whole file is "preamble". Skip ingestion.
        return source, []
    preamble = "\n".join(lines[:first_idx]).rstrip()

    # Walk blocks, tracking brace depth.
    blocks: List[Tuple[str, str, str]] = []
    i = first_idx
    while i < n:
        start_info = is_block_start(lines[i])
        if start_info is None:
            i += 1
            continue
        kind, name = start_info
        depth = 0
        block_start = i
        # Find the opening `{` (may be on same line or next non-empty line).
        # Then track brace balance until depth returns to 0.
        seen_open = False
        j = i
        while j < n:
            for ch in lines[j]:
                if ch == "{":
                    depth += 1
                    seen_open = True
                elif ch == "}":
                    depth -= 1
            if seen_open and depth == 0:
                break
            j += 1
        block_end = min(j + 1, n)
        block_text = "\n".join(lines[block_start:block_end]).rstrip()
        blocks.append((kind, name, block_text))
        i = block_end
    return preamble, blocks


def chunk_csl_file(tutorial_dir: str, csl_path: Path,
                   base_tags: List[str]) -> List[KnowledgeChunk]:
    """Emit one implementer chunk per fn/task/comptime block. Inline preamble."""
    try:
        raw = csl_path.read_text(encoding="utf-8")
    except OSError:
        return []
    source = strip_copyright(raw)
    preamble, blocks = split_csl_blocks(source)
    if not blocks:
        return []

    file_stem = csl_path.stem
    source_url = f"{GITHUB_TREE}/{tutorial_dir}"
    source_rst_url = f"{GITHUB_BLOB}/{tutorial_dir}/{csl_path.name}"

    chunks: List[KnowledgeChunk] = []
    for idx, (kind, name, block_text) in enumerate(blocks):
        # Inline preamble for self-containment.
        text = (f"{preamble}\n\n// --- {kind} {name} ---\n\n{block_text}"
                if preamble else block_text)
        if len(text) > CHUNK_TEXT_CAP:
            # Truncate the block tail (keep preamble + the start of the block),
            # not the preamble. Comment-rich tails are the cheapest to lose.
            preamble_block = (preamble + "\n\n// --- "
                              + kind + " " + name + " ---\n\n") if preamble else ""
            budget = CHUNK_TEXT_CAP - len(preamble_block) - 4
            if budget < 200:
                # Pathological: preamble alone exceeds the cap. Trim preamble.
                text = text[:CHUNK_TEXT_CAP - 3].rstrip() + "..."
            else:
                text = preamble_block + block_text[:budget].rstrip() + "\n..."
        content_tags = infer_topic_tags(text)
        tags = merge_tags(base_tags, content_tags)
        block_kind_id = (f"{kind}-{name}" if kind != "comptime"
                         else "comptime")
        chunk_id = make_chunk_id(tutorial_dir, file_stem, block_kind_id, idx, text)
        chunks.append(KnowledgeChunk(
            chunk_id=chunk_id,
            source_url=source_url,
            source_rst_url=source_rst_url,
            title=f"{tutorial_dir}: {kind} {name} ({csl_path.name})",
            sdk_version=TUTORIAL_SDK_VERSION,
            release_date=None,
            section="tutorial_csl_implementer",
            topic_tags=tags,
            introduced_in=None,
            deprecated_in=None,
            removed_in=None,
            text=text,
        ))
    return chunks


# ---------------------------------------------------------------------------
# Top-level walk + emit
# ---------------------------------------------------------------------------

def walk_tutorials(root: Path,
                   include_only: Optional[List[str]] = None) -> List[KnowledgeChunk]:
    """Walk tutorial directories, emit chunks.

    If ``include_only`` is provided (non-empty list of tutorial dir names),
    only those directories are ingested. Used by the narrow-corpus ablation.
    Names are matched exactly against ``tutorial_dir.name``.
    """
    if not root.is_dir():
        raise FileNotFoundError(f"tutorials root not found: {root}")
    include_set = set(include_only) if include_only else None
    all_chunks: List[KnowledgeChunk] = []
    for tutorial_dir in sorted(p for p in root.iterdir() if p.is_dir()):
        # Defense-in-depth: never ingest anything under /benchmarks/.
        assert BENCHMARKS_TOKEN not in str(tutorial_dir), (
            f"refusing to ingest from {tutorial_dir} (benchmarks excluded)")
        name = tutorial_dir.name
        if include_set is not None and name not in include_set:
            continue
        base_tags = name_tags(name)
        # README
        readme = tutorial_dir / "README.rst"
        if readme.exists():
            all_chunks.extend(chunk_readme(name, readme, base_tags))
        # CSL source files (sorted for determinism). Skip run.py + commands_*.sh.
        for csl_path in sorted(tutorial_dir.glob("*.csl")):
            all_chunks.extend(chunk_csl_file(name, csl_path, base_tags))
    return all_chunks


def emit_jsonl(chunks: List[KnowledgeChunk], out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    # Validate every chunk roundtrips before write.
    for c in chunks:
        KnowledgeChunk.from_dict(asdict(c))  # raises on schema violation
    chunks_sorted = sorted(chunks, key=lambda c: c.chunk_id)
    lines = [json.dumps(asdict(c), sort_keys=True, ensure_ascii=False)
             for c in chunks_sorted]
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def emit_manifest(root: Path, chunks: List[KnowledgeChunk],
                  manifest_path: Path) -> None:
    # Hash inputs: every README + CSL file ingested, sorted.
    input_files: List[Path] = []
    for d in sorted(p for p in root.iterdir() if p.is_dir()):
        for path in sorted([d / "README.rst"] + sorted(d.glob("*.csl"))):
            if path.exists():
                input_files.append(path)
    h = hashlib.sha256()
    for path in input_files:
        rel = path.relative_to(root)
        size = path.stat().st_size
        h.update(f"{rel}|{size}\n".encode())
    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_root": str(root),
        "chunk_count": len(chunks),
        "input_files": len(input_files),
        "inputs_sha256": h.hexdigest(),
        "sections_present": sorted({c.section for c in chunks}),
    }
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n",
                             encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", type=Path, default=DEFAULT_ROOT,
                    help="tutorials source root")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT,
                    help="JSONL output path")
    ap.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST,
                    help="manifest output path")
    ap.add_argument("--check", action="store_true",
                    help="dry-run: write to temp, diff vs existing; exit "
                         "nonzero on drift")
    ap.add_argument("--include-only", type=str, default=None,
                    help="Comma-separated tutorial-directory names to ingest. "
                         "When set, only those tutorials are included (used "
                         "for narrow-corpus ablations). Example: "
                         "--include-only=topic-09-fifos,topic-11-collectives,"
                         "topic-12-debug-library,gemv-06-routes-1")
    args = ap.parse_args()

    include_only = None
    if args.include_only:
        include_only = [s.strip() for s in args.include_only.split(",") if s.strip()]
        print(f"include-only mode: {len(include_only)} tutorials -> {include_only}")

    chunks = walk_tutorials(args.root, include_only=include_only)
    if not chunks:
        print(f"WARNING: no chunks emitted (empty root: {args.root})",
              file=sys.stderr)
        return 1

    if args.check:
        import tempfile
        with tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl",
                                          delete=False) as tmp:
            tmp_path = Path(tmp.name)
        try:
            emit_jsonl(chunks, tmp_path)
            if args.out.exists():
                new_bytes = tmp_path.read_bytes()
                old_bytes = args.out.read_bytes()
                if new_bytes != old_bytes:
                    print(f"DRIFT: {args.out} differs from regenerated output",
                          file=sys.stderr)
                    print(f"  existing: {len(old_bytes)} bytes",
                          file=sys.stderr)
                    print(f"  regenerated: {len(new_bytes)} bytes",
                          file=sys.stderr)
                    return 2
                print(f"OK: {args.out} matches regenerated output "
                      f"({len(chunks)} chunks)")
                return 0
            else:
                print(f"NO EXISTING OUTPUT at {args.out}; would emit "
                      f"{len(chunks)} chunks")
                return 0
        finally:
            tmp_path.unlink(missing_ok=True)

    emit_jsonl(chunks, args.out)
    emit_manifest(args.root, chunks, args.manifest)
    sections = sorted({c.section for c in chunks})
    print(f"wrote {args.out}  ({len(chunks)} chunks)")
    print(f"wrote {args.manifest}")
    print(f"sections present: {sections}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
