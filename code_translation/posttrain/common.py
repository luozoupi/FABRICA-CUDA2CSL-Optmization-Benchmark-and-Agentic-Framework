"""Shared helpers for the post-training datasets: splits, redaction, code fences, SDK port, leak guard."""
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set, Tuple

CT = Path(__file__).resolve().parents[1]          # code_translation/
REPO = CT.parent
sys.path.insert(0, str(CT))

from workflow_common import extract_code_block  # noqa: E402

# ---------------------------------------------------------------------------------------------------
# Splits. Post-training splits by KERNEL, never by attempt: every sample of an evaluation kernel is
# held out, including its reference program. The spec files' own `split:` field governs what may
# appear in prompts (in-context leakage) and is not used here.
# ---------------------------------------------------------------------------------------------------
EVAL_SPARSE = ["SpMV-CSR", "RowScale-CSR", "ColScale-CSR", "RowReduce-CSR", "SpGEMM-Masked-Dot",
               "SpMV-RowBlock", "SpMM-CSR-Dense", "SpMV-RowBlock-Iter"]     # the IPDPS 2027 benchmark
# Generalization set: one kernel per family of the earlier study (single-PE elementwise, reduction,
# transform, multi-PE fabric, dense linear algebra, attention), fixed before any training run.
EVAL_GENERAL = ["GELU-1PE", "Sum-Reduction-1PE", "Prefix-Sum-1PE", "DFT-1PE", "ParReduce-Sum",
                "Laplacian2D-Halo", "GEMV-Collectives-2D", "Attention-QP"]
_REG: Optional[Dict[str, Dict[str, str]]] = None


def registry() -> Dict[str, Dict[str, str]]:
    """KERNEL_REGISTRY name -> {dir, target}, parsed from cuda2csl.py without importing it."""
    global _REG
    if _REG is None:
        src = (CT / "cuda2csl.py").read_text(errors="replace")
        _REG = {m.group(1): {"dir": m.group(2), "target": m.group(3)}
                for m in re.finditer(r'"([^"]+)":\s*_k\("([^"]+)",\s*"([^"]+)"', src)}
    return _REG


def canonical_kernel(name: str) -> str:
    """Registry name for a registry name or a kernels/ directory name."""
    reg = registry()
    if name in reg:
        return name
    for k, v in reg.items():
        if v["dir"] == name:
            return k
    return name


def split_of(kernel: str) -> str:
    k = canonical_kernel(kernel)
    if k in EVAL_SPARSE:
        return "eval_sparse"
    if k in EVAL_GENERAL:
        return "eval_general"
    return "train"


# ---------------------------------------------------------------------------------------------------
# Redaction: no local paths, hosts, job ids, e-mail addresses or anything that looks like a key.
# ---------------------------------------------------------------------------------------------------
_ANSI = re.compile(r"\x1b\[[0-9;]*m")
_REDACT: List[Tuple[re.Pattern, str]] = [
    (re.compile(r"/home/[^/\s'\"]+/xkernel/code_translation/sandbox/[^\s'\"]*"), "<bundle>"),
    (re.compile(r"/tmp/[^\s'\"]*"), "<tmp>"),
    (re.compile(r"/home/[^/\s'\"]+/xkernel"), "<repo>"),
    (re.compile(r"/home/[^/\s'\"]+"), "<home>"),
    (re.compile(r"/software/cerebras/[^\s'\"/]*"), "<sdk>"),
    (re.compile(r"\bcer-(?:usn|login)-\d+\b"), "<host>"),
    (re.compile(r"\bwsjob-[a-z0-9]+\b"), "<job>"),
    (re.compile(r"[\w.+-]+@[\w-]+\.[\w.]+"), "<email>"),
    (re.compile(r"\b(?:sk|sk-ant|sk-proj)-[A-Za-z0-9_\-]{16,}\b"), "<key>"),
    (re.compile(r"(?i)\b(bearer)\s+[A-Za-z0-9._\-]{20,}"), r"\1 <key>"),
]


def redact(text: Optional[str]) -> str:
    if not text:
        return ""
    text = _ANSI.sub("", text)
    for rx, rep in _REDACT:
        text = rx.sub(rep, text)
    return text


def looks_secret(text: str) -> bool:
    return bool(re.search(r"\b(?:sk|sk-ant|sk-proj)-[A-Za-z0-9_\-]{16,}\b|BEGIN [A-Z ]*PRIVATE KEY", text or ""))


# ---------------------------------------------------------------------------------------------------
# Code fences and SDK port
# ---------------------------------------------------------------------------------------------------
def csl_block(code: str) -> str:
    return "```csl\n" + code.strip("\n") + "\n```"


def first_csl(text: str) -> Optional[str]:
    return extract_code_block(text or "", "csl")


def port_to_sdk(code: str, target_sdk: str, is_layout: bool = False) -> Tuple[str, int]:
    """Mechanical SDK 1.x -> 2.x port of removed constructs (the harness's own sdk_compat)."""
    try:
        from sdk_compat import fixup_csl_for_sdk
    except Exception:
        return code, 0
    return fixup_csl_for_sdk(code, target_sdk, is_layout=is_layout)


_FENCE = re.compile(r"(```csl[^\n]*\n)(.*?)(```)", re.S)


def port_fenced(text: str, target_sdk: str) -> Tuple[str, int]:
    total = 0

    def _sub(m):
        nonlocal total
        body, n = port_to_sdk(m.group(2), target_sdk, is_layout="layout" in m.group(1) or "@set_rectangle" in m.group(2))
        total += n
        return m.group(1) + body + m.group(3)
    return _FENCE.sub(_sub, text or ""), total


def strip_analysis(prompt: str) -> str:
    """Remove the analyst model's 'CUDA analysis:' section from a template-completion prompt, so the
    prompt contains only the task, the template, the documentation and the CUDA source."""
    i = prompt.find("CUDA analysis:")
    j = prompt.find("CUDA source:", i + 1) if i >= 0 else -1
    if i >= 0 and j > i:
        return prompt[:i] + prompt[j:]
    return prompt


def strip_model_outputs(prompt: str) -> str:
    """Remove model-written sections from a harness prompt: the analyst's 'CUDA analysis:' and the
    architect's '# DESIGN.md' (up to the next '## ' heading that is not part of it)."""
    prompt = strip_analysis(prompt)
    i = prompt.find("# DESIGN.md")
    if i >= 0:
        j = prompt.find("\n## layout.csl", i)
        if j < 0:
            j = prompt.find("\nCUDA source:", i)
        if j > i:
            prompt = prompt[:i] + prompt[j + 1:]
    return prompt


_DOC_START = ("## CSL Type Rules", "## CSL DSD Patterns", "## CSL Task System", "## Known CSL Gotchas",
              "## Recurring W1 translation traps", "## Cerebras SDK Release Notes", "## CSL Tutorials Context",
              "## CSL Skills Reference", "## Wafer-scale CSL patterns", "## Retrieved", "## Knowledge")
_DOC_END = ("## layout.csl", "Task description:", "CUDA source:", "## CSL TEMPLATE")


def compact_prompt(prompt: str) -> str:
    """Drop the retrieved documentation (and anything between it and the interface) from a harness prompt,
    keeping the instructions, the template, the task, the layout interface and the CUDA source."""
    prompt = strip_model_outputs(prompt)
    starts = [prompt.find(h) for h in _DOC_START if prompt.find(h) >= 0]
    if not starts:
        return prompt
    i = min(starts)
    ends = [prompt.find(h, i) for h in _DOC_END if prompt.find(h, i) > i]
    if not ends:
        return prompt
    return prompt[:i] + prompt[min(ends):]


def sha(text: str) -> str:
    return hashlib.sha256((text or "").encode("utf-8")).hexdigest()[:16]


# ---------------------------------------------------------------------------------------------------
# Leak guard: lines that occur only in evaluation kernels' reference programs
# ---------------------------------------------------------------------------------------------------
def _ref_lines(kdir: Path) -> Set[str]:
    out: Set[str] = set()
    for f in list((kdir / "CSL").rglob("*.csl")) if (kdir / "CSL").is_dir() else []:
        try:
            for line in f.read_text(errors="replace").splitlines():
                s = " ".join(line.split())
                if len(s) >= 40 and not s.startswith("//"):
                    out.add(s)
        except Exception:
            pass
    return out


def eval_only_lines() -> Set[str]:
    """Reference lines of evaluation kernels that appear in no training kernel's reference."""
    kroot = REPO / "kernels"
    ev: Set[str] = set(); tr: Set[str] = set()
    for kdir in kroot.iterdir():
        if not kdir.is_dir() or kdir.name.startswith("_"):
            continue
        name = canonical_kernel(kdir.name)
        lines = _ref_lines(kdir)
        (tr if split_of(name) == "train" else ev).update(lines)
    return ev - tr


def leaks(text: str, guard: Set[str], threshold: int = 3) -> int:
    hits = 0
    for line in (text or "").splitlines():
        if " ".join(line.split()) in guard:
            hits += 1
            if hits >= threshold:
                break
    return hits


def write_jsonl(path: Path, rows: Iterable[dict]) -> int:
    path.parent.mkdir(parents=True, exist_ok=True)
    n = 0
    with open(path, "w", encoding="utf-8") as fh:
        for r in rows:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
            n += 1
    return n
