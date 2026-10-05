#!/usr/bin/env python3
"""Assemble the paper's figures/ipdps_scaling.csv (RQ3) from

  * scale_retained.py JSON(s)        agent programs (O0/O1) at every size, simulator;
  * the kernels' spec.yaml sizes[]   reference cycles per size (simulator, re-baselined);
  * an expert JSON (optional)        hand-written / WaferLLM numbers per size
                                     [{kernel, P, pes, size, cycles, platform, source}];
  * hw_replay.py JSON(s) (optional)  hardware cycles for the same bundles; rows are
                                     matched on (kernel, series, size) via the label
                                     "<series>__<size>/seed_<n>" of the pseudo-run tree
                                     scale_retained.py writes next to its JSON (a
                                     --reference pass maps to series "reference").

Schema (one row per point):
  kernel, series {reference,O0,O1,expert}, P, pes, size, cycles, platform {hw,sim}, status
Every (kernel, series, size) attempted appears once per platform; non-scaling
failures keep status compile_fail / verify_fail with empty cycles.

Usage:
  python aggregate_scaling.py --scaling results/scaling/scaling_*.json \
      --expert docs/data/expert_scaling.json --hw results/hw_scaling_*.json \
      --out /path/to/paper/figures/ipdps_scaling.csv
"""
from __future__ import annotations

import argparse
import csv
import glob
import json
import statistics
import sys
from pathlib import Path
from typing import Any, Dict, List

sys.path.insert(0, str(Path(__file__).resolve().parent))

from rebaseline_references import kernel_dir, _load_yaml  # noqa: E402
from scale_retained import mesh_side, pe_count  # noqa: E402

FIELDS = ["kernel", "series", "P", "pes", "size", "cycles", "platform", "status"]


def reference_rows(kernels: List[str]) -> List[Dict[str, Any]]:
    out = []
    for k in kernels:
        kdir = kernel_dir(k)
        spec = _load_yaml(kdir / "spec.yaml")
        reg = spec.get("kernel_id") or kdir.name.replace(" ", "-")
        for s in spec.get("sizes") or []:
            if not isinstance(s, dict):
                continue
            cyc = (s.get("wse3_reference") or {}).get("cycles_send")
            params = s.get("params") or {}
            out.append({"kernel": reg, "series": "reference", "P": mesh_side(params), "pes": pe_count(params),
                        "size": s.get("name"), "cycles": cyc if cyc else "",
                        "platform": "sim", "status": "pass" if cyc else "not_run"})
    return out


def agent_rows(paths: List[str]) -> List[Dict[str, Any]]:
    """Median over seeds per (kernel, series, size); a size fails if every seed failed."""
    groups: Dict[tuple, List[Dict[str, Any]]] = {}
    for p in paths:
        for r in json.loads(Path(p).read_text()).get("rows") or []:
            groups.setdefault((r["kernel"], r["series"], r["size"]), []).append(r)
    out = []
    for (k, series, size), rs in sorted(groups.items()):
        passing = [r["cycles"] for r in rs if r.get("status") == "pass" and r.get("cycles")]
        if passing:
            out.append({"kernel": k, "series": series, "P": rs[0].get("P"), "pes": rs[0].get("pes"), "size": size,
                        "cycles": int(statistics.median(passing)), "platform": "sim", "status": "pass"})
        else:
            st = "compile_fail" if all(r.get("status") == "compile_fail" for r in rs) else "verify_fail"
            out.append({"kernel": k, "series": series, "P": rs[0].get("P"), "pes": rs[0].get("pes"), "size": size,
                        "cycles": "", "platform": "sim", "status": st})
    return out


def expert_rows(path: str) -> List[Dict[str, Any]]:
    if not path:
        return []
    rows = json.loads(Path(path).read_text())
    rows = rows.get("rows") if isinstance(rows, dict) else rows
    out = []
    for r in rows:
        out.append({"kernel": r["kernel"], "series": "expert", "P": r.get("P"), "pes": r.get("pes"), "size": r.get("size") or "",
                    "cycles": r.get("cycles") or "", "platform": r.get("platform") or "sim",
                    "status": "pass" if r.get("cycles") else (r.get("status") or "not_run")})
    return out


def hw_rows(paths: List[str], sim_rows: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Attach hardware cycles from hw_replay results to the known (kernel, series, size) points."""
    known = {(r["kernel"], r["series"], r["size"]): r for r in sim_rows}
    out = []
    for p in paths:
        for r in json.loads(Path(p).read_text()):
            hw = (r.get("arms") or {}).get("hw") or {}
            label = str(r.get("label") or "")          # scale_retained tree: '<arm>__<size>/seed_<n>'
            head = label.split("/")[0]
            if "__" in head:
                series, size = head.split("__", 1)
            else:
                series, size = "O1", r.get("size") or "small"
            if r.get("pass_kind") == "reference":
                series = "reference"
            base = known.get((r.get("kernel"), series, size))
            if not base:
                continue
            ok = hw.get("status") == "pass" and isinstance(hw.get("cycles_send"), int)
            out.append({**base, "cycles": hw.get("cycles_send") if ok else "", "platform": "hw",
                        "status": "pass" if ok else (hw.get("status") or "not_run")})
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--scaling", nargs="*", default=[], help="scale_retained.py JSON files (globs ok)")
    ap.add_argument("--kernels", default=None, help="reference rows for these kernels (default: kernels in --scaling)")
    ap.add_argument("--expert", default=None)
    ap.add_argument("--hw", nargs="*", default=[], help="hw_replay.py JSON files (globs ok)")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    scaling = [f for g in a.scaling for f in sorted(glob.glob(g))]
    hw = [f for g in a.hw for f in sorted(glob.glob(g))]
    agent = agent_rows(scaling)
    kernels = [k for k in a.kernels.split(",") if k] if a.kernels else sorted({r["kernel"] for r in agent})
    rows = reference_rows(kernels) + agent + expert_rows(a.expert)
    rows += hw_rows(hw, rows)
    out = Path(a.out); out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=FIELDS); w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in FIELDS})
    n_fail = sum(1 for r in rows if r["status"] in ("compile_fail", "verify_fail"))
    print(f"wrote {out}: {len(rows)} rows ({len(kernels)} kernels, {n_fail} non-scaling failures)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
