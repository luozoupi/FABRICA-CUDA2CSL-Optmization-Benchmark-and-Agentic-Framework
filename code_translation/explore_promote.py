#!/usr/bin/env python3
"""Promote successful exploration results into the benches and the
ingestable tutorial corpus.

Two-stage flow per success in ``knowledge/explored/successes/`` that
hasn't already been promoted:

  1. **Promote to benches**: copy the bundle into ``kernels/<name>/`` so
     the existing translate / optimize / batch workflows can pick it up
     like any other hand-curated kernel. Generate a spec.yaml and append
     a row to ``kernels/baselines_wse3.json``.

  2. **Tutorial-ize**: ask the LLM (via the caller-supplied callable) to
     turn DESIGN.md + lessons.md into a concept-level tutorial. Run a
     bundle-token leak check before saving the tutorial. The tutorial is
     ingested into a SEPARATE corpus (``explored_tutorials.jsonl``) that
     the existing tutorial_context() pulls in.

The bench copy happens regardless of tutorial outcome. Only the tutorial
requires the leak check to pass.

Run as a script (``python -m code_translation.explore_promote``) or
imported and called via ``promote_pending``.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import logging
import os
import re
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from knowledge_persistence import (  # type: ignore
    DEFAULT_EXPLORED_ROOT,
    bundle_identifier_set,
    tutorial_leak_check,
)


logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s - %(filename)s:%(lineno)d - %(message)s")
logger = logging.getLogger("explore_promote")


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_KERNELS = REPO_ROOT / "kernels"
BASELINES_JSON = DEFAULT_KERNELS / "baselines_wse3.json"
LEAK_CHECK_DEFAULT_THRESHOLD = 3
LEAK_CHECK_MAX_RETRIES = 1   # one regenerate attempt with stricter prompt


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def _read_text(p: Path) -> str:
    try:
        return p.read_text(encoding="utf-8")
    except OSError:
        return ""


def _slug_for_bench(stem: str) -> str:
    """Convert kernel_id__timestamp -> human-readable bench dir name."""
    stem = stem.split("__")[0]
    out = []
    for ch in stem:
        if ch.isalnum():
            out.append(ch)
        elif out and out[-1] != "_":
            out.append("_")
    name = "".join(out).strip("_") or "kernel"
    # Convert snake_case to Title-Case for kernels/ convention.
    parts = [p.capitalize() for p in name.split("_") if p]
    return "-".join(parts) or "ExploredKernel"


def _ensure_unique_bench_dir(base: Path, name: str) -> Path:
    p = base / name
    if not p.exists():
        return p
    # collision: suffix with a short hash of the source dir.
    h = hashlib.sha1(name.encode("utf-8")).hexdigest()[:6]
    return base / f"{name}-{h}"


def _commands_sh_default() -> str:
    return (
        "#!/usr/bin/env bash\n"
        "set -e\n"
        "cslc --arch=wse3 ./layout.csl --fabric-dims=11,6 --fabric-offsets=4,1 "
        "--memcpy --channels=1 -o out\n"
        "cs_python run.py --name out\n"
    )


# ---------------------------------------------------------------------------
# Tutorial prompt + leak check
# ---------------------------------------------------------------------------

_TUTORIALIZE_PROMPT_TEMPLATE = """You are turning a successful exploration result into a
TUTORIAL chapter for future learners (or future LLMs). The tutorial will be ingested
into the same knowledge base the translation agents use — therefore it MUST NOT leak
bench-specific answers.

## What you receive
### DESIGN.md
{design_md}

### Lessons
{lessons}

### Mesh / pattern used
{mesh_pattern}

## Hard constraints
- DO NOT copy any verbatim function name, struct field name, comptime param value,
  fabric dimension, or numeric tolerance from the actual bundle.
- DO NOT show the full kernel. Show patterns as <= 10-line CSL skeletons.
- Refer to the kernel generically ("the row-softmax kernel") — never by file name.
- Anti-patterns (what NOT to do) are MORE valuable than worked answers. Lead with
  them when available.
- Tutorial length: 200-600 words of prose + at most 3 short CSL skeletons.

{extra_strictness}

Output: a single Markdown document. Begin with a level-1 heading naming the idiom
(e.g. "# Online-softmax reduction on a single PE"). End with a "What to watch for"
section listing the anti-patterns.

Do not wrap the whole output in a code fence. Just emit the markdown.
"""


_EXTRA_STRICTNESS = (
    "STRICTER REGENERATION: the previous draft echoed too many bundle-specific tokens. "
    "Use only generic identifiers (e.g. 'compute_kernel', 'partial_sum', 'tile_size'). "
    "Replace every numeric literal with a symbolic placeholder. The tutorial must be "
    "compileable IDIOMS, not a copy of the kernel."
)


def _tutorialize_once(*,
                      design_md: str,
                      lessons_md: str,
                      mesh_pattern: str,
                      llm_caller: Callable[[str], str],
                      stricter: bool = False) -> str:
    prompt = _TUTORIALIZE_PROMPT_TEMPLATE.format(
        design_md=(design_md or "(no DESIGN.md)").strip()[:4000],
        lessons=(lessons_md or "(no lessons recorded)").strip()[:2000],
        mesh_pattern=mesh_pattern or "(unspecified)",
        extra_strictness=_EXTRA_STRICTNESS if stricter else "",
    )
    try:
        return llm_caller(prompt) or ""
    except Exception as exc:
        logger.warning("[tutorialize] LLM call failed: %s", str(exc)[:200])
        return ""


# ---------------------------------------------------------------------------
# Core entry points
# ---------------------------------------------------------------------------

def _load_promoted_index(explored_root: Path) -> Dict[str, Dict[str, Any]]:
    p = explored_root / "promoted.jsonl"
    if not p.is_file():
        return {}
    out: Dict[str, Dict[str, Any]] = {}
    with open(p, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
                key = row.get("source_dir") or row.get("kernel_id")
                if key:
                    out[key] = row
            except json.JSONDecodeError:
                pass
    return out


def _append_promoted(explored_root: Path, row: Dict[str, Any]) -> None:
    p = explored_root / "promoted.jsonl"
    with open(p, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(row) + "\n")


def _list_unpromoted_successes(explored_root: Path,
                               since_ts: Optional[str] = None) -> List[Path]:
    successes = explored_root / "successes"
    if not successes.is_dir():
        return []
    promoted = _load_promoted_index(explored_root)
    out: List[Path] = []
    for entry in sorted(successes.iterdir()):
        if not entry.is_dir():
            continue
        if str(entry) in promoted or entry.name in promoted:
            continue
        if since_ts:
            # Names end with __<ts> (Y%m%dT%H%M%SZ). Compare lexicographically.
            if "__" in entry.name and entry.name.split("__")[-1] < since_ts:
                continue
        out.append(entry)
    return out


def _read_metrics(success_dir: Path) -> Dict[str, Any]:
    p = success_dir / "metrics.json"
    if not p.is_file():
        return {}
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _read_lessons_md(success_dir: Path) -> str:
    return _read_text(success_dir / "lessons.md")


def _promote_one(success_dir: Path,
                 kernels_root: Path,
                 explored_root: Path,
                 llm_caller: Optional[Callable[[str], str]],
                 leak_threshold: int) -> Dict[str, Any]:
    """Copy bundle to kernels/, generate spec.yaml, append baseline,
    tutorial-ize. Returns the promoted.jsonl row."""
    kernels_root.mkdir(parents=True, exist_ok=True)
    bench_name = _slug_for_bench(success_dir.name)
    bench_dir = _ensure_unique_bench_dir(kernels_root, bench_name)
    csl_dir = bench_dir / "CSL"
    csl_dir.mkdir(parents=True, exist_ok=True)

    # 1. Copy the bundle.
    for fname in ("pe.csl", "layout.csl", "run.py", "launch.csl"):
        src = success_dir / fname
        if src.is_file():
            shutil.copy2(src, csl_dir / fname)
    # commands_wse3.sh: copy from explored if present, else synthesise.
    cmd_src = success_dir / "commands_wse3.sh"
    cmd_dst = csl_dir / "commands_wse3.sh"
    if cmd_src.is_file():
        shutil.copy2(cmd_src, cmd_dst)
    else:
        cmd_dst.write_text(_commands_sh_default(), encoding="utf-8")
    cmd_dst.chmod(0o755)

    # 2. spec.yaml (prefer the one in the success dir).
    spec_src = success_dir / "spec.yaml"
    spec_dst = bench_dir / "spec.yaml"
    if spec_src.is_file():
        shutil.copy2(spec_src, spec_dst)
    else:
        spec_dst.write_text(
            f"kernel_id: {bench_name}\n"
            f"title: {bench_name}\n"
            f"build_command: bash CSL/commands_wse3.sh\n"
            "wse3_reference:\n  cycles_send: null\n",
            encoding="utf-8",
        )

    # 3. README from DESIGN.md if available — kept inside the bench dir for
    # human readers. (NOT ingested into the agent KB.)
    design_src = success_dir / "DESIGN.md"
    if design_src.is_file():
        shutil.copy2(design_src, bench_dir / "README.md")

    # 4. Baselines.
    metrics = _read_metrics(success_dir)
    cycles = metrics.get("cycles_send")
    if cycles:
        try:
            data: Dict[str, Any] = {}
            if BASELINES_JSON.is_file():
                data = json.loads(BASELINES_JSON.read_text(encoding="utf-8"))
            row = data.get(bench_name) or {}
            row["cycles_send"] = int(cycles)
            row["wse3_reference"] = int(cycles)
            row["source"] = "explored"
            row["source_dir"] = str(success_dir.relative_to(explored_root))
            data[bench_name] = row
            BASELINES_JSON.write_text(json.dumps(data, indent=2),
                                      encoding="utf-8")
        except Exception as exc:
            logger.warning("[promote] baselines_wse3.json append failed: %s",
                           str(exc)[:200])

    # 5. Tutorial-ize (LLM optional).
    tutorial_path: Optional[Path] = None
    leak_status = "skipped"
    if llm_caller is not None:
        bundle_text = "\n".join([
            _read_text(success_dir / "pe.csl"),
            _read_text(success_dir / "layout.csl"),
            _read_text(success_dir / "run.py"),
        ])
        design_md = _read_text(success_dir / "DESIGN.md")
        lessons_md = _read_lessons_md(success_dir)
        # Mesh pattern: parse from spec.yaml if present, else "unspecified".
        mesh_pattern = "unspecified"
        if spec_dst.is_file():
            for line in spec_dst.read_text(encoding="utf-8").splitlines():
                if line.startswith("suggested_mesh:"):
                    mesh_pattern = line.split(":", 1)[1].strip()
                    break

        tutorial_text = _tutorialize_once(
            design_md=design_md, lessons_md=lessons_md,
            mesh_pattern=mesh_pattern, llm_caller=llm_caller, stricter=False,
        )
        for attempt in range(LEAK_CHECK_MAX_RETRIES + 1):
            leak_msg = tutorial_leak_check(tutorial_text, bundle_text,
                                           threshold=leak_threshold)
            if leak_msg is None:
                leak_status = "passed"
                break
            logger.warning("[promote] %s — %s", success_dir.name, leak_msg)
            if attempt < LEAK_CHECK_MAX_RETRIES:
                tutorial_text = _tutorialize_once(
                    design_md=design_md, lessons_md=lessons_md,
                    mesh_pattern=mesh_pattern, llm_caller=llm_caller,
                    stricter=True,
                )
            else:
                leak_status = "dropped"
                tutorial_text = ""
        if tutorial_text:
            tutorials_dir = explored_root / "tutorials"
            tutorials_dir.mkdir(parents=True, exist_ok=True)
            tutorial_path = tutorials_dir / f"{bench_name}_tutorial.md"
            tutorial_path.write_text(tutorial_text, encoding="utf-8")
            # 6. Append KB-ready chunks (one per audience) to ingest jsonl.
            _append_explored_tutorial_chunks(explored_root, bench_name,
                                             tutorial_text)

    row = {
        "ts": datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ"),
        "kernel_id": bench_name,
        "source_dir": str(success_dir.relative_to(explored_root)),
        "bench_path": str(bench_dir.relative_to(REPO_ROOT)),
        "tutorial_path": (str(tutorial_path.relative_to(explored_root))
                          if tutorial_path else None),
        "leak_check": leak_status,
        "baseline_cycles": int(cycles) if cycles else None,
    }
    _append_promoted(explored_root, row)
    return row


def _append_explored_tutorial_chunks(explored_root: Path,
                                      bench_name: str,
                                      tutorial_text: str) -> None:
    """Emit one KB chunk per audience role so the existing tutorial_context
    retrieval picks this up. The section names mirror what ingest_tutorials.py
    uses (tutorial_readme_architect / tutorial_csl_implementer /
    tutorial_readme_reviewer).
    """
    ingest_dir = explored_root / "ingest"
    ingest_dir.mkdir(parents=True, exist_ok=True)
    path = ingest_dir / "explored_tutorials.jsonl"
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    sdk_version = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    sections = [
        "tutorial_readme_architect",
        "tutorial_csl_implementer",
        "tutorial_readme_reviewer",
    ]
    with open(path, "a", encoding="utf-8") as fh:
        for sec in sections:
            chunk = {
                "chunk_id": f"explored_tutorial_{bench_name}_{sec}_{ts}",
                "source_url": f"explored/tutorials/{bench_name}_tutorial.md",
                "source_rst_url": "",
                "title": f"{bench_name} (explored kernel tutorial)",
                "sdk_version": sdk_version,
                "release_date": ts[:8],
                "section": sec,
                "topic_tags": ["explored", "tutorial", bench_name],
                "introduced_in": None,
                "deprecated_in": None,
                "removed_in": None,
                "text": tutorial_text,
            }
            fh.write(json.dumps(chunk) + "\n")


def promote_pending(*,
                    explored_root: str | Path = DEFAULT_EXPLORED_ROOT,
                    kernels_root: str | Path = DEFAULT_KERNELS,
                    llm_caller: Optional[Callable[[str], str]] = None,
                    since_ts: Optional[str] = None,
                    leak_threshold: int = LEAK_CHECK_DEFAULT_THRESHOLD,
                    ) -> List[Dict[str, Any]]:
    """Promote every unpromoted success. Returns rows written to
    promoted.jsonl. Idempotent: a second call skips already-promoted dirs.
    """
    explored = Path(os.path.expanduser(str(explored_root))).resolve()
    kr = Path(kernels_root).resolve()
    unpromoted = _list_unpromoted_successes(explored, since_ts=since_ts)
    if not unpromoted:
        logger.info("[promote] nothing to promote in %s", explored)
        return []
    rows: List[Dict[str, Any]] = []
    for sd in unpromoted:
        try:
            row = _promote_one(sd, kr, explored, llm_caller, leak_threshold)
            logger.info("[promote] %s -> %s  (leak_check=%s, cycles=%s)",
                        sd.name, row["bench_path"], row["leak_check"],
                        row["baseline_cycles"])
            rows.append(row)
        except Exception as exc:
            logger.warning("[promote] %s failed: %s", sd.name, str(exc)[:200])
    return rows


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--explored-root", default=DEFAULT_EXPLORED_ROOT)
    ap.add_argument("--kernels-root", default=str(DEFAULT_KERNELS))
    ap.add_argument("--since", default=None,
                    help="Only promote successes whose timestamp >= this Y%%m%%dT%%H%%M%%SZ")
    ap.add_argument("--leak-threshold", type=int,
                    default=LEAK_CHECK_DEFAULT_THRESHOLD)
    ap.add_argument("--no-llm", action="store_true",
                    help="Skip the tutorialize step (bench-copy only).")
    args = ap.parse_args()

    llm_caller: Optional[Callable[[str], str]] = None
    if not args.no_llm:
        # Resolve a provider via the shared resolver — we tutorial-ize
        # in-process so we don't need a separate worker. Fall back to no-LLM
        # mode (bench-copy only) if resolution fails.
        try:
            from workflow_common import resolve_provider, llm_complete  # type: ignore
            handle = resolve_provider(provider="auto")
            llm_caller = lambda p: llm_complete(handle.client, handle.model,
                                                [{"role": "user", "content": p}],
                                                2048)
        except Exception as exc:
            logger.warning("[main] provider unavailable; skipping tutorialize: %s",
                           str(exc)[:200])
            llm_caller = None

    rows = promote_pending(
        explored_root=args.explored_root,
        kernels_root=args.kernels_root,
        llm_caller=llm_caller,
        since_ts=args.since,
        leak_threshold=args.leak_threshold,
    )
    for r in rows:
        print(json.dumps(r))
    return 0


if __name__ == "__main__":
    sys.exit(main())
