#!/usr/bin/env python3
"""Score probe responses: group A/C by compiling (SDK, compile only), group B/D by keys.
Writes <out> CSV rows: model, id, group, score (0/1), detail."""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from workflow_common import build_sdk_env, default_sdk_root  # noqa: E402

FENCE_RE = re.compile(r"```(?:csl|zig)?\s*\n(.*?)```", re.S)
LETTER_RE = re.compile(r"(?<![A-Za-z])([ABCD])(?![A-Za-z])")


def numeric_answer(reply: str, n: int):
    """The first n numbers of the ANSWER, and which rule found them.

    Every numeric item's prompt says "reply with the answer first, then one sentence of
    justification", so the answer is at the START. Reading the LAST n numbers instead (the
    rule used until 2026-09-20) scores a correctly formatted reply as wrong whenever the
    justification mentions any number -- "1, 3, 5, 7 | xs selects x[0], x[2], x[4], x[6]"
    was scored against 0, 2, 4, 6. Prefer the first line that carries at least n numbers,
    then fall back to the first n anywhere.
    """
    num = lambda t: [float(x) for x in re.findall(r"-?\d+(?:\.\d+)?", t)]
    for line in (reply or "").splitlines():
        vals = num(line)
        if len(vals) >= n:
            return vals[:n], "first_line"
    vals = num(reply or "")
    return (vals[:n], "first_anywhere") if len(vals) >= n else (vals, "too_few")


def extract_csl(reply: str) -> str:
    m = FENCE_RE.search(reply or "")
    return (m.group(1) if m else reply or "").strip() + "\n"


def extract_letter(reply: str):
    m = LETTER_RE.search((reply or "").strip())
    return m.group(1) if m else None


def compile_only(layout: str, pe: str, params: dict, cslc_args: str, sdk_root: str, timeout: int = 600):
    """Stage layout.csl + pe.csl in a fresh dir under the repo (the container cannot bind /tmp) and run cslc."""
    work = Path(tempfile.mkdtemp(prefix="probe_", dir=str(HERE.parent / "sandbox")))
    (work / "layout.csl").write_text(layout); (work / "pe.csl").write_text(pe)
    p = ",".join(f"{k}:{v}" for k, v in params.items())
    cmd = f"cslc ./layout.csl {cslc_args} --params={p} -o out"
    r = subprocess.run(cmd, shell=True, cwd=str(work), env=build_sdk_env(sdk_root), capture_output=True, text=True, timeout=timeout)
    err = (r.stderr or "") + (r.stdout or "")
    first = next((l for l in err.splitlines() if "error" in l.lower()), "")
    return r.returncode == 0, first[:200]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("responses_dir")
    ap.add_argument("--out", required=True)
    ap.add_argument("--sdk-root", default=os.environ.get("XKERNEL_SDK_ROOT") or default_sdk_root())
    ap.add_argument("--no-compile", action="store_true", help="score only the key-based groups")
    a = ap.parse_args()
    items = {yaml.safe_load(f.read_text())["id"]: yaml.safe_load(f.read_text()) for f in (HERE / "items").glob("*.yaml")}
    rows = []
    for line in (Path(a.responses_dir) / "responses.jsonl").read_text().splitlines():
        if not line.strip():
            continue
        r = json.loads(line); it = items.get(r["id"])
        if not it:
            continue
        g = it["group"]; score, detail = 0, ""
        if g == "D_api":
            got = extract_letter(r["reply"]); score = int(got == it["expected"]["choice"]); detail = f"got={got} key={it['expected']['choice']}"
        elif g == "B_semantics":
            key = it["expected"]
            if "choice" in key:
                got = extract_letter(r["reply"]); score = int(got == key["choice"]); detail = f"got={got} key={key['choice']}"
            else:
                want = [float(x) for x in key["values"]]
                got, rule = numeric_answer(r["reply"] or "", len(want))
                score = int(len(got) == len(want)
                            and all(abs(x - y) <= 1e-3 * max(1.0, abs(y)) for x, y in zip(got, want)))
                detail = f"want={want} got={got} via={rule}"
        elif g in ("A_syntax", "C_repair"):
            if a.no_compile:
                continue
            pe = extract_csl(r["reply"])
            ok, first_err = compile_only(it["fixed_layout"], pe, it.get("compile_params", {}), it.get("cslc_args", "--arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 --memcpy --channels=1"), a.sdk_root)
            score = int(ok); detail = "compiled" if ok else first_err
            if ok and g == "C_repair":
                changed = sum(1 for x, y in zip(it["defective_pe"].splitlines(), pe.splitlines()) if x != y) + abs(len(it["defective_pe"].splitlines()) - len(pe.splitlines()))
                score = int(changed <= it["expected"].get("max_changed_lines", 6)); detail += f"; changed_lines={changed}"
        rows.append({"model": r["model"], "id": r["id"], "group": g, "score": score, "detail": detail})
        print(f"{r['id']:22s} {score} {detail[:90]}")
    out = Path(a.out); out.parent.mkdir(parents=True, exist_ok=True)
    exists = out.exists()
    with open(out, "a", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["model", "id", "group", "score", "detail"])
        if not exists:
            w.writeheader()
        w.writerows(rows)
    by_group = {}
    for r in rows:
        by_group.setdefault(r["group"], []).append(r["score"])
    for g, s in sorted(by_group.items()):
        print(f"{g:14s} {sum(s)}/{len(s)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
