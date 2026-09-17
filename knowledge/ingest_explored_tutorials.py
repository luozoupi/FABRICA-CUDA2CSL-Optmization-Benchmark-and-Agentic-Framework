#!/usr/bin/env python3
"""Rebuild ``knowledge/explored/ingest/explored_tutorials.jsonl`` from the
markdown files under ``knowledge/explored/tutorials/``.

In normal operation ``explore_promote.py`` appends JSONL chunks per
promotion. This script is the recovery / manual-rerun path — it walks the
tutorials directory and rewrites the JSONL from scratch so the corpus
stays consistent if a row was lost or a tutorial was hand-edited.

Mirrors the section names used by ``knowledge/ingest_tutorials.py`` so the
same TF-IDF retrieval call paths surface these chunks.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import List


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_EXPLORED = REPO_ROOT / "knowledge" / "explored"


SECTIONS = [
    "tutorial_readme_architect",
    "tutorial_csl_implementer",
    "tutorial_readme_reviewer",
]


def rebuild(explored_root: Path) -> int:
    tutorials_dir = explored_root / "tutorials"
    out_path = explored_root / "ingest" / "explored_tutorials.jsonl"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    if not tutorials_dir.is_dir():
        logging.info("[ingest_explored_tutorials] no tutorials dir at %s",
                     tutorials_dir)
        if out_path.exists():
            out_path.unlink()
        return 0
    written = 0
    sdk_version = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    with open(out_path, "w", encoding="utf-8") as fh:
        for md in sorted(tutorials_dir.glob("*_tutorial.md")):
            try:
                text = md.read_text(encoding="utf-8")
            except OSError as exc:
                logging.warning("[ingest_explored_tutorials] %s: %s", md, exc)
                continue
            bench_name = md.stem.replace("_tutorial", "")
            for sec in SECTIONS:
                chunk = {
                    "chunk_id": f"explored_tutorial_{bench_name}_{sec}_{ts}",
                    "source_url": f"explored/tutorials/{md.name}",
                    "source_rst_url": "",
                    "title": f"{bench_name} (explored kernel tutorial)",
                    "sdk_version": sdk_version,
                    "release_date": ts[:8],
                    "section": sec,
                    "topic_tags": ["explored", "tutorial", bench_name],
                    "introduced_in": None,
                    "deprecated_in": None,
                    "removed_in": None,
                    "text": text,
                }
                fh.write(json.dumps(chunk) + "\n")
                written += 1
    logging.info("[ingest_explored_tutorials] wrote %d chunks to %s",
                 written, out_path)
    return written


def main() -> int:
    logging.basicConfig(level=logging.INFO,
                        format="%(asctime)s %(message)s")
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--explored-root", default=str(DEFAULT_EXPLORED))
    args = ap.parse_args()
    rebuild(Path(os.path.expanduser(args.explored_root)).resolve())
    return 0


if __name__ == "__main__":
    sys.exit(main())
