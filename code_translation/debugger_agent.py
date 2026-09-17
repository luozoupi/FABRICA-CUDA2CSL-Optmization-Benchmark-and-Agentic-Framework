"""Debugger sub-agent — diagnostic specialist for the repair loop.

When the reviewer routes a failure to bucket B with a concrete debug action
and the implementer would otherwise re-attempt blind, the orchestrator may
ask a debugger to produce a structured diagnostic report. The implementer
then sees that report alongside the reviewer's rationale and the builtin
whitelist when forming its repair.

v1 (XKERNEL_DEBUGGER=1): prompt-only — the debugger gets a read-only
knowledge bundle and emits a structured JSON diagnosis.

v2 (XKERNEL_DEBUGGER_V2=1): scoped file reader — the debugger also receives
ALL firewall-safe files from the kernel's reference directory (run.py,
commands_wse3.sh, spec.yaml, layout*.csl). Fixes the tool_use:0 pathology
where the reviewer says "read layout.csl" but the agent can't. pe.csl (the
reference compute file) is NEVER included — canary-hidden by the benchmark
firewall.

See ``code_translation/DEBUGGER_AGENT_DESIGN.md`` for the full design rationale.

Env gates: ``XKERNEL_DEBUGGER`` (default ``"0"``), ``XKERNEL_DEBUGGER_V2``
(default ``"0"``; implies XKERNEL_DEBUGGER=1).
"""

from __future__ import annotations

import json
import logging
import os
import re
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Concrete debug verbs that trigger debugger fire even on first failure
# (otherwise: only fire on repeat failure, see should_fire()).
_DEBUG_ACTION_TRIGGER_VERBS = (
    "run ", "grep ", "cslc", "compile",
    "trace ", "wavelet", "csdb", "inspect ",
    "cs_readelf", "check ", "verify ",
)

# Cap on debugger invocations per kernel (per orchestrator instance).
DEBUGGER_MAX_FIRES_PER_KERNEL = 1

# Filenames the scoped reader is allowed to read from a kernel's reference
# directory.  pe.csl is INTENTIONALLY excluded — it's canary-hidden.
FIREWALL_SAFE_FILES = frozenset({
    "layout.csl", "layout_power.csl", "layout_cg.csl", "layout_pcg.csl",
    "layout_bicgstab.csl", "layout_matvec.csl", "device_layout.csl",
    "run.py", "device_run.py",
    "commands_wse3.sh", "commands.sh",
    "spec.yaml",
})

_MAX_FILE_CHARS = 4000
_MAX_READABLE_TOTAL = 12000


# ---------------------------------------------------------------------------
# ScopedFileReader — v2 file access, constrained to the firewall whitelist
# ---------------------------------------------------------------------------

class ScopedFileReader:
    """Read files from a kernel reference directory, constrained to
    FIREWALL_SAFE_FILES.  pe.csl is NEVER readable."""

    def __init__(self, kernel_dir: str,
                 whitelist: Optional[frozenset] = None):
        self.kernel_dir = Path(kernel_dir) if kernel_dir else Path(".")
        self.whitelist = whitelist or FIREWALL_SAFE_FILES

    def read_all(self) -> Dict[str, str]:
        """Return {filename: content} for every whitelisted file that exists,
        capped so the total stays under _MAX_READABLE_TOTAL."""
        result: Dict[str, str] = {}
        if not self.kernel_dir.is_dir():
            return result
        total = 0
        for name in sorted(self.whitelist):
            p = self.kernel_dir / name
            if not p.is_file():
                continue
            try:
                content = p.read_text(encoding="utf-8")
            except OSError:
                continue
            if len(content) > _MAX_FILE_CHARS:
                content = content[:_MAX_FILE_CHARS] + "\n// ...truncated"
            if total + len(content) > _MAX_READABLE_TOTAL:
                content = content[:max(0, _MAX_READABLE_TOTAL - total)] + "\n// ...truncated (total cap)"
            result[name] = content
            total += len(content)
            if total >= _MAX_READABLE_TOTAL:
                break
        return result


# ---------------------------------------------------------------------------
# Data shapes
# ---------------------------------------------------------------------------

@dataclass
class DebuggerInput:
    """Everything the debugger needs to produce a diagnosis."""
    current_csl: str
    stderr_tail: str           # last ~2 KB of compile/run output
    failure_reason: str        # one-liner from benchmark
    reviewer_rationale: str
    reviewer_debug_action: str
    reference_contract: str
    # The layout.csl body for this kernel, when readable. The debugger uses
    # it to confirm/refute claims about exported symbols and topology.
    layout_csl: str = ""
    # v2: all firewall-safe files from the kernel's reference directory.
    readable_files: Optional[Dict[str, str]] = None


@dataclass
class DebuggerReport:
    """Structured diagnosis emitted by the debugger. All fields are strings;
    confidence is one of {high, medium, low, unknown}.

    The orchestrator injects this into the next implementer fix prompt as
    the {debugger_report} slot. An empty/null report (e.g. when the debugger
    didn't fire or returned unparseable text) is rendered as a single empty
    line so the prompt structure stays intact.
    """
    diagnostic_run: str         # what the debugger would run (or claims it did)
    diagnostic_output: str      # the (claimed) output of that diagnostic
    diagnosis: str              # the debugger's read of the failure
    recommended_patch: str      # a concrete "REPLACE ... WITH ..." or "ADD ..." hint
    confidence: str             # high / medium / low / unknown
    fired: bool = True          # False means this is a sentinel "didn't fire"

    @classmethod
    def empty(cls) -> "DebuggerReport":
        return cls(
            diagnostic_run="",
            diagnostic_output="",
            diagnosis="(debugger did not fire on this attempt)",
            recommended_patch="",
            confidence="unknown",
            fired=False,
        )

    def to_prompt_block(self) -> str:
        """Format the report for injection into a fix prompt. Returns an
        empty string when the debugger didn't fire — keeps prompt cost zero
        on the common path."""
        if not self.fired:
            return ""
        return "\n".join([
            "============================================================",
            "DEBUGGER DIAGNOSIS",
            "============================================================",
            f"Diagnostic run:      {self.diagnostic_run.strip()[:300] or '(none)'}",
            f"Diagnostic output:   {self.diagnostic_output.strip()[:600] or '(none)'}",
            f"Diagnosis:           {self.diagnosis.strip()[:400] or '(none)'}",
            f"Recommended patch:   {self.recommended_patch.strip()[:600] or '(none)'}",
            f"Confidence:          {self.confidence.strip().lower()}",
            "Apply the recommended patch verbatim if it looks correct relative "
            "to the reviewer's rationale. If you disagree, address the underlying "
            "diagnosis another way — but do NOT ignore both this report and the "
            "reviewer.",
        ])


# ---------------------------------------------------------------------------
# Decision: should the debugger fire?
# ---------------------------------------------------------------------------

def _normalize_failure(reason: Optional[str]) -> str:
    """Collapse whitespace, lowercase, take first 80 chars. Used to detect
    repeat failures across attempts (run.py adds path/timestamp noise to
    failure_reason — we want the semantic part)."""
    if not reason:
        return ""
    s = " ".join(str(reason).split()).lower()
    return s[:80]


def should_fire(*,
                bucket: str,
                debug_action: Optional[str],
                current_failure_reason: Optional[str],
                previous_failure_reason: Optional[str],
                fires_used_for_this_kernel: int) -> bool:
    """Return True if the debugger should be invoked for this verdict.

    Conditions (all must hold):
      - bucket == "B"
      - debug_action is non-empty
      - either (a) the failure_reason matches the previous attempt's,
        or (b) the debug_action starts with a concrete-verb prefix
      - debugger fire count for this kernel < cap
    """
    if (os.getenv("XKERNEL_DEBUGGER", "0") == "0"
            and os.getenv("XKERNEL_DEBUGGER_V2", "0") == "0"):
        return False
    if bucket != "B":
        return False
    if not debug_action or not debug_action.strip():
        return False
    if fires_used_for_this_kernel >= DEBUGGER_MAX_FIRES_PER_KERNEL:
        return False
    # Concrete-verb trigger — debugger fires on the FIRST attempt with a
    # concrete diagnostic action.
    da_low = debug_action.strip().lower()
    if any(da_low.startswith(v) for v in _DEBUG_ACTION_TRIGGER_VERBS):
        return True
    # Repeat-failure trigger — failure_reason matches previous attempt's.
    cur = _normalize_failure(current_failure_reason)
    prev = _normalize_failure(previous_failure_reason)
    if cur and prev and cur == prev:
        return True
    return False


# ---------------------------------------------------------------------------
# Prompt + parser
# ---------------------------------------------------------------------------

_SYSTEM_PROMPT_V1 = (
    "You are the DEBUGGER. The implementer wrote CSL that failed; the "
    "reviewer suggested a diagnostic action. Your job is to play out that "
    "diagnostic mentally using ONLY the read-only bundle below (you have no "
    "real tool access in this version), and produce a structured JSON report "
    "that names the most likely root cause and a minimal patch. Do not "
    "hallucinate diagnostic output you can't justify from the bundle — set "
    "confidence to 'low' or 'unknown' instead. The implementer will read your "
    "report verbatim and is likely to apply your recommended_patch."
)

_SYSTEM_PROMPT_V2 = (
    "You are the DEBUGGER (v2). The implementer wrote CSL that failed; the "
    "reviewer suggested a diagnostic action. You have read access to ALL "
    "firewall-safe files from the kernel's reference directory (layout.csl, "
    "run.py, commands_wse3.sh, spec.yaml — but NOT pe.csl, which is hidden). "
    "Use these files to ground your diagnosis: check the actual exported "
    "symbols in layout.csl, verify the expected I/O protocol in run.py, and "
    "confirm the build commands in commands_wse3.sh. Produce a structured JSON "
    "report naming the most likely root cause and a minimal patch. Do not "
    "hallucinate — if the files don't contain enough to ground a claim, set "
    "confidence to 'low'. The implementer will apply your recommended_patch."
)


_DIAGNOSE_PROMPT = """REVIEWER VERDICT:
  bucket: B (implementation bug)
  rationale: {reviewer_rationale}
  suggested debug action: {reviewer_debug_action}

BENCHMARK FAILURE:
  failure reason: {failure_reason}

STDERR TAIL (last ~2 KB):
```
{stderr_tail}
```

CURRENT CSL COMPUTE FILE (the file the implementer wrote):
```csl
{current_csl}
```

REFERENCE CONTRACT (the layout.csl + exported-symbol contract the file must satisfy):
{reference_contract}

LAYOUT.CSL (the actual layout.csl content for this kernel, when readable):
```csl
{layout_csl}
```

Your task: produce a JSON object on a single line (no markdown fence, no
prose outside the JSON) with EXACTLY these keys:

  {{
    "diagnostic_run":      "<the command or inspection step you would run if you could; describe it precisely>",
    "diagnostic_output":   "<what you expect / can infer from the bundle that that diagnostic would show>",
    "diagnosis":           "<one or two sentences naming the most likely root cause>",
    "recommended_patch":   "<a concrete 'REPLACE <old> WITH <new>' or 'ADD <code>' hint, terse>",
    "confidence":          "<high | medium | low | unknown>"
  }}

Rules:
- ONE JSON object. No code fences, no prose before/after.
- Strings ≤ 300 chars each (the orchestrator truncates further on display).
- Use confidence='unknown' if the bundle doesn't have enough to ground a diagnosis.
- Cite line numbers from the CSL when you can — the file shown above starts at line 1.
- The recommended_patch should be the SMALLEST possible change that addresses the diagnosis.
"""


_READABLE_FILES_SECTION = """
REFERENCE-DIRECTORY FILES (read-only, firewall-safe — pe.csl is withheld):
{readable_files_block}
"""

_JSON_FALLBACK_RE = re.compile(r"\{[^{}]*\"diagnostic_run\".*?\}", re.DOTALL)


def _parse_debugger_reply(raw: str) -> DebuggerReport:
    """Parse the debugger's reply into a DebuggerReport. Robust to:
      - markdown code fences around the JSON
      - extra prose before/after
      - missing keys (filled with empty string)
      - bad JSON (returns empty report tagged 'unknown' confidence)
    """
    if not raw or not raw.strip():
        return DebuggerReport.empty()
    # Strip markdown fences if present
    text = raw.strip()
    if text.startswith("```"):
        # remove opening ``` or ```json line
        text = re.sub(r"^```(?:json)?\s*\n", "", text)
        text = re.sub(r"\n```\s*$", "", text)
    # First try: full JSON
    obj: Optional[Dict[str, Any]] = None
    try:
        obj = json.loads(text)
        if not isinstance(obj, dict):
            obj = None
    except json.JSONDecodeError:
        obj = None
    # Fallback: regex-extract the first {...} that has diagnostic_run
    if obj is None:
        m = _JSON_FALLBACK_RE.search(text)
        if m:
            try:
                obj = json.loads(m.group(0))
                if not isinstance(obj, dict):
                    obj = None
            except json.JSONDecodeError:
                obj = None
    if obj is None:
        # Unparseable. Wrap the raw text as a low-confidence diagnosis so the
        # implementer still gets *some* signal rather than nothing.
        return DebuggerReport(
            diagnostic_run="",
            diagnostic_output="",
            diagnosis=("debugger reply was not parseable JSON; raw text: "
                       + raw.strip()[:200]),
            recommended_patch="",
            confidence="unknown",
            fired=True,
        )
    confidence = str(obj.get("confidence", "unknown")).strip().lower()
    if confidence not in {"high", "medium", "low", "unknown"}:
        confidence = "unknown"
    return DebuggerReport(
        diagnostic_run=str(obj.get("diagnostic_run", ""))[:600],
        diagnostic_output=str(obj.get("diagnostic_output", ""))[:1200],
        diagnosis=str(obj.get("diagnosis", ""))[:600],
        recommended_patch=str(obj.get("recommended_patch", ""))[:800],
        confidence=confidence,
        fired=True,
    )


# ---------------------------------------------------------------------------
# Agent class
# ---------------------------------------------------------------------------

class DebuggerAgent:
    """Stateless single-shot debugger that delegates LLM calls back to the
    orchestrator's client.

    Usage:
        dbg = DebuggerAgent(llm_call=orchestrator._llm_call,
                            max_tokens=1024)
        report = dbg.diagnose(input)
    """

    def __init__(self, llm_call, max_tokens: int = 1024):
        """``llm_call`` must be a callable ``(messages, max_tokens=None) ->
        str`` (matches CUDA2CSLOrchestrator._llm_call)."""
        self._llm_call = llm_call
        self.max_tokens = max_tokens

    @staticmethod
    def _format_readable_files(files: Optional[Dict[str, str]]) -> str:
        """Format a readable-files dict into a prompt section."""
        if not files:
            return "(no reference-directory files available)"
        parts = []
        for name, content in files.items():
            parts.append(f"--- {name} ---\n{content}")
        return "\n\n".join(parts)

    def diagnose(self, inp: DebuggerInput) -> DebuggerReport:
        def cap(s: str, n: int) -> str:
            s = s or ""
            return s if len(s) <= n else s[:n - 16] + "\n// ...truncated"

        v2 = os.getenv("XKERNEL_DEBUGGER_V2", "0") == "1"

        prompt = _DIAGNOSE_PROMPT.format(
            reviewer_rationale=cap(inp.reviewer_rationale, 400),
            reviewer_debug_action=cap(inp.reviewer_debug_action, 400),
            failure_reason=cap(inp.failure_reason, 400),
            stderr_tail=cap(inp.stderr_tail, 2000),
            current_csl=cap(inp.current_csl, 5000),
            reference_contract=cap(inp.reference_contract, 1500),
            layout_csl=cap(inp.layout_csl, 1200),
        )

        if v2 and inp.readable_files:
            files_block = self._format_readable_files(inp.readable_files)
            prompt += _READABLE_FILES_SECTION.format(
                readable_files_block=files_block,
            )

        system_prompt = _SYSTEM_PROMPT_V2 if v2 else _SYSTEM_PROMPT_V1
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ]
        try:
            raw = self._llm_call(messages, max_tokens=self.max_tokens)
        except Exception as exc:
            logging.warning("[debugger] LLM call failed: %s", str(exc)[:200])
            return DebuggerReport(
                diagnostic_run="",
                diagnostic_output="",
                diagnosis=f"(debugger LLM call errored: {str(exc)[:200]})",
                recommended_patch="",
                confidence="unknown",
                fired=True,
            )
        return _parse_debugger_reply(raw)


# ---------------------------------------------------------------------------
# Helper: read layout.csl from a kernel reference dir
# ---------------------------------------------------------------------------

def read_layout_csl(kernel_dir: Optional[str]) -> str:
    """Return the layout.csl body for this kernel, or empty string if unavailable."""
    if not kernel_dir:
        return ""
    candidates = ["layout.csl", "device_layout.csl"]
    for name in candidates:
        p = Path(kernel_dir) / name
        if p.is_file():
            try:
                return p.read_text(encoding="utf-8")
            except OSError:
                pass
    return ""
