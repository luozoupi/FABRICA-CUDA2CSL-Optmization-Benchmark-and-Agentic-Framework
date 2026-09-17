#!/usr/bin/env python3
"""
Shared helpers for code translation workflows and staged CSL benchmarking.
"""

from __future__ import annotations

import importlib.util
import json
import logging
import glob
import os
import subprocess
import time
from dataclasses import asdict, dataclass
from datetime import datetime
from typing import Any, Dict, List, Optional


DEFAULT_TIMEOUT_SECONDS = 300
DEFAULT_API_KEY_FILE = "~/codex-api-key.txt"

BLOCKED_REASON_PATTERNS = {
    "blocked_container_runtime": [
        "singularity not in $path",
        "apptainer not in $path",
        "singularity: command not found",
        "apptainer: command not found",
        "command not found: singularity",
        "command not found: apptainer",
    ],
}


@dataclass
class CommandResult:
    command: str
    cwd: str
    returncode: int
    stdout: str
    stderr: str
    elapsed_ms: float
    timed_out: bool = False
    blocked_reason: Optional[str] = None

    @property
    def ok(self) -> bool:
        return not self.timed_out and self.returncode == 0

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


def expand_path(path: Optional[str]) -> Optional[str]:
    if path is None:
        return None
    return os.path.abspath(os.path.expanduser(path))


# --- Cerebras SDK root discovery -------------------------------------------
# The framework historically hard-coded ~/cs_sdk-1.4.0, a per-user install that
# need not exist. The ALCF Cerebras user nodes ship the SDKs under
# /software/cerebras. Resolution order: $XKERNEL_SDK_ROOT, then the first
# candidate directory that contains a `cslc` wrapper, then the legacy default
# (kept so error messages stay unchanged when nothing is installed).
SDK_ROOT_CANDIDATES = (
    "~/cs_sdk-1.4.0",
    "/software/cerebras/cs_sdk-1.4.0",
    "/software/cerebras/cs_sdk-2.10",
)
LEGACY_SDK_ROOT = "~/cs_sdk-1.4.0"


def default_sdk_root() -> str:
    env_root = os.environ.get("XKERNEL_SDK_ROOT", "").strip()
    if env_root:
        return env_root
    for candidate in SDK_ROOT_CANDIDATES:
        resolved = os.path.expanduser(candidate)
        if os.path.isfile(os.path.join(resolved, "cslc")):
            return resolved
    return LEGACY_SDK_ROOT


def sdk_sif_path(sdk_root: Optional[str] = None) -> Optional[str]:
    """The SDK container image: $XKERNEL_SDK_SIF, else the *.sif in the SDK root."""
    env_sif = os.environ.get("XKERNEL_SDK_SIF", "").strip()
    if env_sif:
        return env_sif
    root = os.path.expanduser(sdk_root or default_sdk_root())
    matches = sorted(glob.glob(os.path.join(root, "*.sif")))
    return matches[0] if matches else None


def ensure_directory(path: str) -> str:
    os.makedirs(path, exist_ok=True)
    return path


def timestamped_output_dir(base_output: str, prefix: str) -> str:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return ensure_directory(os.path.join(base_output, f"{prefix}_{timestamp}"))


def save_json(data: Dict[str, Any], path: str) -> None:
    ensure_directory(os.path.dirname(path))
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, sort_keys=False)


def maybe_load_dotenv() -> bool:
    spec = importlib.util.find_spec("dotenv")
    if spec is None:
        return False
    from dotenv import load_dotenv  # type: ignore

    load_dotenv()
    return True


def load_shell_setup(shell_setup: Optional[str] = None,
                     shell_setup_file: Optional[str] = None) -> Optional[str]:
    segments = []
    resolved_file = expand_path(shell_setup_file)
    if resolved_file:
        if not os.path.exists(resolved_file):
            raise FileNotFoundError(f"Shell setup file does not exist: {resolved_file}")
        with open(resolved_file, "r", encoding="utf-8") as fh:
            file_text = fh.read().strip()
        if file_text:
            segments.append(file_text)
    if shell_setup and shell_setup.strip():
        segments.append(shell_setup.strip())
    combined = "\n".join(segment for segment in segments if segment).strip()
    return combined or None


def read_api_key_file(path: Optional[str]) -> Optional[str]:
    if not path or not str(path).strip():
        return None
    expanded = expand_path(path or DEFAULT_API_KEY_FILE)
    if not expanded or not os.path.exists(expanded):
        return None
    with open(expanded, "r", encoding="utf-8") as fh:
        value = fh.read().strip()
    return value or None


def load_api_key_from_command(command: Optional[str],
                              timeout: int = 60) -> Optional[str]:
    if not command or not command.strip():
        return None
    result = run_subprocess(command, timeout=timeout)
    if not result.ok:
        raise RuntimeError(
            "API key command failed with return code {returncode}.\n"
            "stdout:\n{stdout}\n"
            "stderr:\n{stderr}".format(
                returncode=result.returncode,
                stdout=result.stdout.strip()[:1000],
                stderr=result.stderr.strip()[:1000],
            )
        )
    token = result.stdout.strip().splitlines()[-1].strip() if result.stdout.strip() else ""
    return token or None


def load_api_key(path: Optional[str],
                 api_key_command: Optional[str] = None) -> Optional[str]:
    maybe_load_dotenv()
    command_value = load_api_key_from_command(api_key_command)
    if command_value:
        return command_value
    file_value = read_api_key_file(path)
    if file_value:
        return file_value
    env_value = os.getenv("OPENAI_API_KEY", "").strip()
    return env_value or None


def create_openai_client(api_key_file: Optional[str] = None,
                         base_url: Optional[str] = None,
                         api_key_command: Optional[str] = None):
    maybe_load_dotenv()
    if importlib.util.find_spec("openai") is None:
        raise RuntimeError(
            "The 'openai' package is not installed in this Python environment. "
            "Use the micromamba agent environment from code_translation/environment.micromamba.yml "
            "or install code_translation/requirements.txt."
        )
    from openai import OpenAI  # type: ignore

    api_key = load_api_key(api_key_file, api_key_command=api_key_command)
    if not api_key:
        raise RuntimeError(
            "No API key found. Provide --api-key-file, --api-key-command, "
            "or set OPENAI_API_KEY."
        )
    resolved_base_url = base_url or os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
    return OpenAI(base_url=resolved_base_url, api_key=api_key)


def package_available(module_name: str) -> bool:
    return importlib.util.find_spec(module_name) is not None


def classify_blocked_reason(stdout: str, stderr: str) -> Optional[str]:
    combined = "\n".join([stdout or "", stderr or ""]).lower()
    for reason, patterns in BLOCKED_REASON_PATTERNS.items():
        if any(pattern in combined for pattern in patterns):
            return reason
    return None


def compose_shell_command(command: str, shell_setup: Optional[str] = None) -> str:
    if not shell_setup or not shell_setup.strip():
        return command
    return "\n".join([
        "set -e",
        shell_setup.strip(),
        command,
    ])


def run_subprocess(command: str,
                   cwd: Optional[str] = None,
                   env: Optional[Dict[str, str]] = None,
                   shell_setup: Optional[str] = None,
                   timeout: int = DEFAULT_TIMEOUT_SECONDS) -> CommandResult:
    start = time.time()
    effective_command = compose_shell_command(command, shell_setup=shell_setup)
    try:
        proc = subprocess.run(
            effective_command,
            shell=True,
            executable="/bin/bash",
            cwd=cwd,
            env=env,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        elapsed_ms = (time.time() - start) * 1000.0
        blocked_reason = classify_blocked_reason(proc.stdout, proc.stderr)
        return CommandResult(
            command=command,
            cwd=os.path.abspath(cwd or os.getcwd()),
            returncode=proc.returncode,
            stdout=proc.stdout,
            stderr=proc.stderr,
            elapsed_ms=round(elapsed_ms, 3),
            blocked_reason=blocked_reason,
        )
    except subprocess.TimeoutExpired as exc:
        elapsed_ms = (time.time() - start) * 1000.0
        stdout = exc.stdout if isinstance(exc.stdout, str) else (exc.stdout or b"").decode("utf-8", "replace")
        stderr = exc.stderr if isinstance(exc.stderr, str) else (exc.stderr or b"").decode("utf-8", "replace")
        blocked_reason = classify_blocked_reason(stdout, stderr)
        return CommandResult(
            command=command,
            cwd=os.path.abspath(cwd or os.getcwd()),
            returncode=124,
            stdout=stdout,
            stderr=stderr or "Command timed out.",
            elapsed_ms=round(elapsed_ms, 3),
            timed_out=True,
            blocked_reason=blocked_reason,
        )


def build_sdk_env(sdk_root: Optional[str] = None,
                  base_env: Optional[Dict[str, str]] = None) -> Dict[str, str]:
    env = dict(os.environ)
    if base_env:
        env.update(base_env)
    resolved_sdk_root = expand_path(sdk_root)
    if resolved_sdk_root:
        env["PATH"] = f"{resolved_sdk_root}:{env.get('PATH', '')}"
        env.setdefault("CEREBRAS_SDK_PATH", resolved_sdk_root)
    return env


def probe_command(command: str,
                  cwd: Optional[str] = None,
                  env: Optional[Dict[str, str]] = None,
                  shell_setup: Optional[str] = None,
                  timeout: int = 30) -> Dict[str, Any]:
    result = run_subprocess(
        command,
        cwd=cwd,
        env=env,
        shell_setup=shell_setup,
        timeout=timeout,
    )
    status = "ready" if result.ok else "blocked" if result.blocked_reason else "fail"
    return {
        "status": status,
        "blocked_reason": result.blocked_reason,
        "returncode": result.returncode,
        "stdout": result.stdout.strip()[:500],
        "stderr": result.stderr.strip()[:500],
        "elapsed_ms": result.elapsed_ms,
    }


def extract_code_block(text: str, lang: str) -> Optional[str]:
    import re

    if not text:
        return None
    aliases = {
        "cuda": ["cuda", "cu", "cpp", "c++"],
        "csl": ["csl"],
    }
    tags = aliases.get(lang, [lang])
    for tag in tags:
        # Match either ``` lang or ``` lang:relpath — the multi-file
        # optimize prompt uses the second form. We want the FIRST
        # such fence regardless of which form it uses, so the legacy
        # caller (which only knows the no-relpath form) still works
        # when the LLM emits a single ``` csl:pe.csl fence.
        pattern = re.compile(
            r"```" + re.escape(tag) + r"(?::[^\n]+)?\s*\n(.*?)```",
            re.DOTALL | re.IGNORECASE,
        )
        match = pattern.search(text)
        if match:
            return match.group(1).strip()
    pattern = re.compile(r"```\w*\s*\n(.*?)```", re.DOTALL)
    match = pattern.search(text)
    if match:
        return match.group(1).strip()
    return None


def extract_multi_file_blocks(text: str,
                              lang: str = "csl") -> Dict[str, str]:
    """Extract per-file fences from an LLM reply.

    The multi-file optimize prompt asks the LLM to emit one
    ``` csl:<relpath> fence per focus file. This parser pulls them out
    and returns ``{relpath: body}``. Order of fences in the reply is
    not preserved (the dict ordering is fence-encounter-order, which is
    Python-dict-insertion-order — same thing in practice).

    Tolerates:
      * extra whitespace before the relpath
      * the legacy single-file fence ``` csl (no relpath) — mapped to
        the empty-string key so single-file callers can detect this case
        and fall back to ``extract_code_block``.
      * arbitrary text between fences (the prompt says no prose but the
        LLM sometimes ignores it).

    Returns {} when no fences match — caller decides whether to retry,
    fall back, or treat as a reject.
    """
    import re
    if not text:
        return {}
    aliases = {
        "cuda": ["cuda", "cu", "cpp", "c++"],
        "csl": ["csl"],
    }
    tags = aliases.get(lang, [lang])
    out: Dict[str, str] = {}
    for tag in tags:
        # Capture group 1: optional relpath after the colon. Group 2:
        # body. The relpath is everything after ":" up to the next
        # whitespace or newline.
        pattern = re.compile(
            r"```" + re.escape(tag) + r"(?::([^\s\n]+))?\s*\n(.*?)```",
            re.DOTALL | re.IGNORECASE,
        )
        for m in pattern.finditer(text):
            relpath = (m.group(1) or "").strip()
            body = m.group(2).rstrip()
            # Strip a single leading newline produced by the fence so
            # the body matches what a fresh file would contain.
            if body.startswith("\n"):
                body = body[1:]
            # Last-fence-wins per relpath (LLM occasionally emits a
            # draft + a final version with the same tag).
            out[relpath] = body
    return out


def _clip_head_tail(s: Any, head: int = 400, tail: int = 800) -> str:
    """Per audit task #34: head-slicing stderr drops the BOTTOM of the stream
    — where compilers put the actual `error:` line and Python tracebacks put
    `ExceptionType: message`. The audit measured 92.3% loss on a Mandelbrot
    run where the dropped 163 cslc warnings were what would have explained
    the failure. Head + tail with an explicit elision marker preserves
    BOTH the initial banner/source-context (head) AND the actual error
    (tail), and tells the LLM that the view is partial."""
    s = s or "(empty)"
    if not isinstance(s, str):
        s = str(s)
    if len(s) <= head + tail:
        return s
    elided = len(s) - head - tail
    return f"{s[:head]}\n... ({elided} chars elided) ...\n{s[-tail:]}"


def format_command_transcript(transcript: Any) -> str:
    lines = []
    for idx, entry in enumerate(transcript, start=1):
        # Fix #3 part 1: include per-step blocked_reason when populated.
        # parse_instrumented_stdout sets this when a step matches a known
        # blocker pattern (e.g. container runtime missing); it's distinct
        # from the top-level failure_reason and useful when multiple
        # steps blocked for different reasons.
        blocked = entry.get("blocked_reason") or ""
        header_extra = f" blocked_reason={blocked}" if blocked else ""
        lines.append(
            "[{idx}] {command}\n"
            "step={step} status={status} returncode={returncode} elapsed_ms={elapsed_ms}{header_extra}\n"
            "stdout:\n{stdout}\n"
            "stderr:\n{stderr}".format(
                idx=idx,
                command=entry.get("command", ""),
                step=entry.get("step", "unknown"),
                status=entry.get("status", "unknown"),
                returncode=entry.get("returncode", ""),
                elapsed_ms=entry.get("elapsed_ms", ""),
                header_extra=header_extra,
                stdout=_clip_head_tail(entry.get("stdout", "")),
                stderr=_clip_head_tail(entry.get("stderr", "")),
            )
        )
    return "\n\n".join(lines) if lines else "(no command transcript available)"


def is_anthropic_model(model: str) -> bool:
    return model.lower().startswith("claude-")


def is_responses_api_model(model: str) -> bool:
    """True for OpenAI models that use client.responses.create() instead of chat.completions."""
    prefixes = ("gpt-5", "o1", "o3", "o4")
    return any(model.lower().startswith(p) for p in prefixes)


def create_anthropic_client(api_key_file: Optional[str] = None,
                            api_key_command: Optional[str] = None):
    maybe_load_dotenv()
    if importlib.util.find_spec("anthropic") is None:
        raise RuntimeError(
            "The 'anthropic' package is not installed. "
            "Run: micromamba run -n xkernel-agent pip install anthropic"
        )
    import anthropic  # type: ignore
    api_key = load_api_key(api_key_file, api_key_command=api_key_command)
    if not api_key:
        raise RuntimeError(
            "No Anthropic API key found. Provide --api-key-file, "
            "--api-key-command, or set OPENAI_API_KEY."
        )
    return anthropic.Anthropic(api_key=api_key)


def _is_rate_limit_error(exc: Exception) -> bool:
    msg = str(exc).lower()
    return "429" in msg or "rate_limit" in msg or "reduce the prompt" in msg or "too many requests" in msg


# --- LLM usage accounting -------------------------------------------------------
# Every provider call passes through llm_complete(); the usage block of each
# response is appended here (gate XKERNEL_USAGE_LOG, default on) and dumped by
# cuda2csl.write_final_artifacts into usage_log.json. Token counts are the
# provider's own; nothing is estimated. `phase` is the nearest calling function
# outside the LLM plumbing (analyse_cuda, design_architecture, translate,
# review_failure, _select_optimization_angle, optimize, ...).
USAGE_LOG: List[Dict[str, Any]] = []
_PLUMBING_FRAMES = {"llm_complete", "_llm_call", "_llm_call_with_trim_on_overflow", "<lambda>",
                    "_record_usage", "wrapper", "inner"}


def _caller_phase() -> str:
    import sys as _sys
    frame = _sys._getframe(1)
    while frame is not None:
        name = frame.f_code.co_name
        if name not in _PLUMBING_FRAMES:
            return name
        frame = frame.f_back
    return "unknown"


def _usage_field(usage: Any, *names: str) -> Optional[int]:
    for n in names:
        v = getattr(usage, n, None) if not isinstance(usage, dict) else usage.get(n)
        if isinstance(v, int):
            return v
    return None


def _record_usage(provider: str, model: str, messages: List[Dict[str, str]], max_tokens: int,
                  usage: Any, reply: str) -> None:
    if os.getenv("XKERNEL_USAGE_LOG", "1") != "1":
        return
    import time as _time
    prompt_chars = sum(len(m.get("content", "") or "") for m in messages if isinstance(m.get("content"), str))
    USAGE_LOG.append({
        "ts": _time.strftime("%Y-%m-%dT%H:%M:%SZ", _time.gmtime()),
        "phase": _caller_phase(),
        "provider": provider,
        "model": model,
        "max_tokens": max_tokens,
        "prompt_chars": prompt_chars,
        "reply_chars": len(reply or ""),
        "input_tokens": _usage_field(usage, "input_tokens", "prompt_tokens"),
        "output_tokens": _usage_field(usage, "output_tokens", "completion_tokens"),
        "cache_read_input_tokens": _usage_field(usage, "cache_read_input_tokens"),
        "cache_creation_input_tokens": _usage_field(usage, "cache_creation_input_tokens"),
    })


def usage_summary() -> Dict[str, Any]:
    """Totals by phase and overall for the calls recorded in this process."""
    totals: Dict[str, Dict[str, Any]] = {}
    for rec in USAGE_LOG:
        bucket = totals.setdefault(rec.get("phase") or "unknown",
                                   {"calls": 0, "input_tokens": 0, "output_tokens": 0,
                                    "cache_read_input_tokens": 0, "missing_usage": 0})
        bucket["calls"] += 1
        if rec.get("input_tokens") is None and rec.get("output_tokens") is None:
            bucket["missing_usage"] += 1
        for k in ("input_tokens", "output_tokens", "cache_read_input_tokens"):
            bucket[k] += int(rec.get(k) or 0)
    overall = {"calls": len(USAGE_LOG),
               "input_tokens": sum(int(r.get("input_tokens") or 0) for r in USAGE_LOG),
               "output_tokens": sum(int(r.get("output_tokens") or 0) for r in USAGE_LOG),
               "cache_read_input_tokens": sum(int(r.get("cache_read_input_tokens") or 0) for r in USAGE_LOG),
               "models": sorted({str(r.get("model")) for r in USAGE_LOG})}
    return {"schema": "usage_log/1", "totals": overall, "by_phase": totals, "calls": list(USAGE_LOG)}


def llm_complete(client: Any,
                 model: str,
                 messages: List[Dict[str, str]],
                 max_tokens: int,
                 max_retries: int = 3) -> str:
    """Route to Anthropic messages, OpenAI responses, or chat.completions based on model name.
    Retries with exponential back-off on rate limit errors."""
    import logging
    import time

    # Per-call timeout (seconds). Cold-start vllm endpoints can otherwise
    # block forever on a single chat.completions.create. Env-controllable so
    # the launcher can tune without code changes.
    call_timeout = float(os.getenv("XKERNEL_LLM_TIMEOUT_S", "180"))
    bound = client.with_options(timeout=call_timeout) if hasattr(client, "with_options") else client

    for attempt in range(max_retries + 1):
        try:
            if is_anthropic_model(model):
                system_parts = [m["content"] for m in messages if m["role"] == "system"]
                non_system = [m for m in messages if m["role"] != "system"]
                kwargs: Dict[str, Any] = dict(model=model, max_tokens=max_tokens, messages=non_system)
                if system_parts:
                    kwargs["system"] = "\n\n".join(system_parts)
                response = bound.messages.create(**kwargs)
                text = response.content[0].text or ""
                _record_usage("anthropic", model, messages, max_tokens, getattr(response, "usage", None), text)
                return text
            elif is_responses_api_model(model):
                response = bound.responses.create(
                    model=model,
                    input=messages,
                    max_output_tokens=max_tokens,
                    reasoning={"effort": "high"},
                )
                text = response.output_text or ""
                _record_usage("openai_responses", model, messages, max_tokens, getattr(response, "usage", None), text)
                return text
            else:
                response = bound.chat.completions.create(
                    model=model,
                    messages=messages,
                    max_tokens=max_tokens,
                )
                msg = response.choices[0].message
                text = msg.content or getattr(msg, "reasoning", None) or ""
                _record_usage("openai_chat", model, messages, max_tokens, getattr(response, "usage", None), text)
                return text
        except Exception as exc:
            is_rate = _is_rate_limit_error(exc)
            is_transient = (
                isinstance(exc, TimeoutError) or
                "timeout" in type(exc).__name__.lower() or
                "503" in str(exc) or
                "internal_endpoint_error" in str(exc) or
                "not ready to receive tasks" in str(exc)
            )
            if (is_rate or is_transient) and attempt < max_retries:
                wait = [15, 45, 90][min(attempt, 2)]
                logging.warning("LLM transient (attempt %d/%d), retrying in %ds: %s",
                                attempt + 1, max_retries, wait, str(exc)[:160])
                time.sleep(wait)
                continue
            raise


def detect_current_python_packages(modules: Any) -> Dict[str, bool]:
    return {name: package_available(name) for name in modules}


def current_python_identity() -> Dict[str, str]:
    return {
        "executable": os.path.abspath(os.sys.executable),
        "version": os.sys.version.splitlines()[0],
    }


# ---------------------------------------------------------------------------
# Multi-provider resolver (used by explore_csl.py)
# ---------------------------------------------------------------------------
#
# The translation orchestrator (cuda2csl.py) hard-codes per-invocation
# CLI flags for a single provider. The exploration workflow needs to be
# more forgiving: try ALCF first, then the local Argo shim, then OpenAI,
# and log every fallback so the user sees what was actually selected.
#
# Auto-fallback order (when --provider=auto):
#   1. argo:    requires ~/.claude/settings.json with `apiKeyHelper` or
#               `env.ANTHROPIC_API_KEY`. ANTHROPIC_BASE_URL env points
#               the client at the local 127.0.0.1 Anthropic-compatible shim
#               (responds on /v1/messages with x-api-key). Default model
#               claude-opus-4-7. This rung is preferred by default per
#               user direction (2026-06-03): it's the most reliable on
#               this node and the Opus 4.7 weights are strong on CSL.
#   2. alcf:    requires ~/.globus/app/.../tokens.json + inference_auth_token
#               module is importable + token mintable within 5 s. Uses the
#               Metis or Sophia endpoint from ALCF_ENDPOINTS in cuda2csl.
#               NOTE: a locally-cached Globus token can show "valid" while
#               the gateway 401's. The resolver only catches mint-time
#               failures; runtime 401's surface as plain LLM errors.
#   3. openai:  requires OPENAI_API_KEY env or a key file.
#
# Explicit --provider X disables fallback for any earlier rung.
# --require-provider forbids silent fallback altogether: the FIRST tried
# provider must succeed.

ALCF_ENDPOINTS_DEFAULT = {
    "metis": {
        "base_url": "https://inference-api.alcf.anl.gov/resource_server/metis/api/v1",
        "default_model": "gpt-oss-120b",
    },
    "sophia": {
        "base_url": "https://inference-api.alcf.anl.gov/resource_server/sophia/vllm/v1",
        "default_model": "openai/gpt-oss-120b",
    },
}

GLOBUS_TOKENS_GLOB = "~/.globus/app/58fdd3bc-e1c3-4ce5-80ea-8d6b87cfb944/inference_app/tokens.json"
DEFAULT_CLAUDE_SETTINGS = "~/.claude/settings.json"


@dataclass
class ProviderHandle:
    """Resolved LLM client + model + provenance.

    `kind` is one of {"alcf", "argo", "openai"}. `model` is the model name to
    pass to llm_complete. `client` is the OpenAI/Anthropic client (the same
    object llm_complete dispatches on). `notes` is a list of human-readable
    decisions for the resolver — log it once at startup so the user sees
    which fallback rungs fired.
    """
    kind: str
    client: Any
    model: str
    base_url: Optional[str] = None
    notes: List[str] = None  # type: ignore[assignment]

    def __post_init__(self) -> None:
        if self.notes is None:
            self.notes = []


def _globus_tokens_exist() -> bool:
    p = os.path.expanduser(GLOBUS_TOKENS_GLOB)
    return os.path.isfile(p)


def _settings_has_argo(settings_path: str) -> bool:
    p = os.path.expanduser(settings_path)
    if not os.path.isfile(p):
        return False
    try:
        data = json.loads(open(p, "r", encoding="utf-8").read())
    except Exception:
        return False
    if isinstance(data.get("apiKeyHelper"), str) and data["apiKeyHelper"].strip():
        return True
    env = data.get("env") or {}
    return any(env.get(k) for k in ("ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN"))


def _try_alcf(endpoint_name: str,
              model_override: Optional[str],
              api_key_file: Optional[str]) -> ProviderHandle:
    """Build an ALCF-backed OpenAI client. Mints a Globus token via the local
    inference_auth_token module (5 s timeout). Raises on failure with a
    descriptive message so the resolver can decide whether to fall back.
    """
    if endpoint_name not in ALCF_ENDPOINTS_DEFAULT:
        raise RuntimeError(f"unknown ALCF endpoint '{endpoint_name}'; "
                           f"choose from {list(ALCF_ENDPOINTS_DEFAULT)}")
    if not _globus_tokens_exist() and not api_key_file:
        raise RuntimeError(
            f"ALCF: no Globus tokens at {GLOBUS_TOKENS_GLOB}; "
            "run `python inference_auth_token.py` once to mint them"
        )
    endpoint = ALCF_ENDPOINTS_DEFAULT[endpoint_name]
    base_url = endpoint["base_url"]
    model = model_override or endpoint["default_model"]
    # Resolve token: prefer the explicit api_key_file (when the caller pre-fetched
    # the bearer); otherwise call get_access_token() with a watchdog timer.
    api_key = read_api_key_file(api_key_file) if api_key_file else None
    if not api_key:
        api_key = _mint_alcf_token_with_timeout(timeout_s=5.0)
    if not api_key:
        raise RuntimeError(
            "ALCF: failed to mint Globus access token within 5 s "
            "(token may be wedged; run `python inference_auth_token.py` "
            "to refresh, or pass --api-key-file with a pre-minted token)"
        )
    if importlib.util.find_spec("openai") is None:
        raise RuntimeError("ALCF: 'openai' package not installed")
    from openai import OpenAI  # type: ignore
    client = OpenAI(base_url=base_url, api_key=api_key)
    return ProviderHandle(kind="alcf", client=client, model=model,
                          base_url=base_url)


def _mint_alcf_token_with_timeout(timeout_s: float) -> Optional[str]:
    """Call inference_auth_token.get_access_token() in a worker thread with
    a wall-clock deadline. Returns None on timeout or any error so the
    resolver can fall back gracefully (the underlying call can block
    indefinitely if Globus auth is wedged).
    """
    try:
        import inference_auth_token  # type: ignore
    except Exception as exc:
        logging.warning("[provider] ALCF: import inference_auth_token failed: %s",
                        str(exc)[:160])
        return None
    import threading
    holder: Dict[str, Any] = {"tok": None, "err": None}

    def _worker() -> None:
        try:
            holder["tok"] = inference_auth_token.get_access_token()
        except Exception as exc:
            holder["err"] = str(exc)[:200]

    t = threading.Thread(target=_worker, daemon=True)
    t.start()
    t.join(timeout=timeout_s)
    if t.is_alive():
        logging.warning("[provider] ALCF: get_access_token() timed out after %.1fs",
                        timeout_s)
        return None
    if holder["err"]:
        logging.warning("[provider] ALCF: get_access_token() error: %s", holder["err"])
        return None
    tok = holder["tok"]
    return tok if isinstance(tok, str) and tok else None


def _try_argo(model_override: Optional[str],
              api_key_file: Optional[str],
              settings_path: str = DEFAULT_CLAUDE_SETTINGS) -> ProviderHandle:
    """Build an Anthropic-shaped client that talks to the local Argo shim
    (or any other Anthropic-compatible base URL).

    Key resolution order:
      1. ``~/.claude/settings.json`` apiKeyHelper / env (this is the
         shim's actual auth). ALWAYS tried first, even when --api-key-file
         is set — most users pass the default ``~/codex-api-key.txt``
         which holds an OpenAI key and would fail the shim's x-api-key
         check with a confusing 401.
      2. Explicit --api-key-file content (only used if it looks like an
         Anthropic-style key — heuristic: not starting with ``sk-proj-``
         which is OpenAI). This lets people override settings.json.
    """
    api_key: Optional[str] = None
    # Step 1: settings.json (authoritative for the local shim).
    try:
        import argo_key_from_settings  # type: ignore
        from pathlib import Path as _P
        api_key = argo_key_from_settings.resolve_key(
            _P(os.path.expanduser(settings_path))
        )
    except SystemExit as exc:
        # settings.json missing or unparseable — try fallback.
        logging.debug("[provider] argo: settings.json unavailable: %s", exc)
        api_key = None
    except Exception as exc:
        logging.debug("[provider] argo: settings.json read failed: %s", exc)
        api_key = None
    # Step 2: --api-key-file fallback. Skip OpenAI-style keys to avoid the
    # surprising 401 case described above.
    if not api_key and api_key_file:
        from_file = read_api_key_file(api_key_file)
        if from_file and not from_file.startswith("sk-proj-"):
            api_key = from_file
    if not api_key:
        raise RuntimeError(
            "argo: no usable key. Add `apiKeyHelper` or "
            "`env.ANTHROPIC_API_KEY` to ~/.claude/settings.json, or pass "
            "--api-key-file pointing at an Anthropic-shaped key."
        )
    base_url = os.getenv("ANTHROPIC_BASE_URL", "http://127.0.0.1:23984/argoapi")
    # Default to Opus 4.7 per the 2026-06-03 user direction; allow override
    # via env or --model. The shim accepts claude-opus-4-7 / claude-sonnet-4-6
    # / claude-haiku-4-5.
    model = model_override or os.getenv("XKERNEL_ARGO_MODEL", "claude-opus-4-7")
    if importlib.util.find_spec("anthropic") is None:
        raise RuntimeError(
            "argo: 'anthropic' package not installed — "
            "run `micromamba run -n xkernel-agent pip install anthropic`"
        )
    import anthropic  # type: ignore
    # The Argo shim authenticates via the standard Anthropic x-api-key
    # header; the SDK's `api_key=` arg sets that header automatically.
    client = anthropic.Anthropic(api_key=api_key, base_url=base_url)
    return ProviderHandle(kind="argo", client=client, model=model,
                          base_url=base_url)


def _try_openai(model_override: Optional[str],
                api_key_file: Optional[str],
                api_key_command: Optional[str]) -> ProviderHandle:
    """Build a vanilla OpenAI client. Final-fallback rung."""
    client = create_openai_client(api_key_file=api_key_file,
                                  api_key_command=api_key_command)
    model = (model_override or os.getenv("OPENAI_MODEL", "gpt-4.1"))
    base_url = os.getenv("OPENAI_BASE_URL")
    return ProviderHandle(kind="openai", client=client, model=model,
                          base_url=base_url)


def _validate_provider_model(kind: str, model: str) -> Tuple[bool, str]:
    """Sanity-check that the model name matches what the client expects.

    Catches the failure mode where a shell-quoting accident drops a
    non-model token (e.g. ``--mode open`` becomes ``model=open``) into
    --model. Without this check, llm_complete dispatches by name prefix
    and crashes 20 rounds later with cryptic AttributeError. Fail at
    resolve time with a one-line, actionable message instead.
    """
    if not model or not str(model).strip():
        return False, f"provider {kind}: empty model name"
    is_claude = str(model).lower().startswith("claude-")
    if kind == "argo":
        if not is_claude:
            return False, (
                f"provider=argo expects an Anthropic model "
                f"(claude-* prefix), got model={model!r}. "
                f"Did a shell flag (e.g. --mode) leak into --model? "
                f"Common valid values: claude-opus-4-7, claude-sonnet-4-6, "
                f"claude-haiku-4-5."
            )
    elif kind in ("openai", "alcf"):
        if is_claude:
            return False, (
                f"provider={kind} expects an OpenAI-shaped model "
                f"(e.g. gpt-4.1, gpt-oss-120b), got model={model!r}. "
                f"For Anthropic/Claude models use --provider argo."
            )
    return True, ""


def resolve_provider(*,
                     provider: str = "auto",
                     alcf_endpoint: str = "metis",
                     model: Optional[str] = None,
                     api_key_file: Optional[str] = None,
                     api_key_command: Optional[str] = None,
                     settings_path: str = DEFAULT_CLAUDE_SETTINGS,
                     require: bool = False) -> ProviderHandle:
    """Resolve an LLM provider, optionally falling back through ranked rungs.

    ``provider`` ∈ {"auto", "alcf", "argo", "openai"}. ``auto`` walks the
    ranked rungs (alcf → argo → openai) until one succeeds, logging each
    failure. Explicit names skip lower-priority rungs but still allow
    fallback to ones BELOW them in priority order. ``require=True`` forbids
    silent fallback — the first attempted rung must succeed.

    Returns a ``ProviderHandle`` ready to use with ``llm_complete``.
    """
    notes: List[str] = []
    # Argo-first by default — Opus 4.7 via the local shim is the most
    # reliable provider on this node. ALCF is the second rung because the
    # Globus token can silently desync from the gateway. OpenAI is the
    # last-resort rung (account quota issues observed mid-2026).
    default_order = ["argo", "alcf", "openai"]
    order: List[str]
    if provider == "auto":
        order = list(default_order)
    elif provider in default_order:
        order = [provider] if require else (
            default_order[default_order.index(provider):]
        )
    else:
        raise ValueError(f"unknown provider: {provider!r}")

    # When the user supplied an explicit --model, validate it AGAINST THE
    # FIRST RUNG before falling back. A coherent-but-wrong model (e.g.
    # `--model open` to argo via a shell-quoting accident) shouldn't be
    # silently re-routed to a different rung that happens to accept the
    # malformed string — that just masks the user error.
    if model:
        # Use the first rung in order as the authoritative kind for the
        # validation. If that rung rejects, the others would dispatch the
        # wrong client method anyway.
        first_kind = order[0] if order else "openai"
        ok, why = _validate_provider_model(first_kind, model)
        if not ok:
            raise RuntimeError(
                f"--model {model!r} is incoherent with --provider "
                f"{first_kind!r}. {why}"
            )

    last_err: Optional[str] = None
    for rung in order:
        try:
            if rung == "alcf":
                handle = _try_alcf(alcf_endpoint, model, api_key_file)
            elif rung == "argo":
                handle = _try_argo(model, api_key_file, settings_path)
            else:
                handle = _try_openai(model, api_key_file, api_key_command)
            # Secondary coherence check on the resolved (possibly default)
            # model name. Catches edge cases where the rung's default
            # model has been overridden via env to something the wrong
            # client shape.
            ok, why = _validate_provider_model(handle.kind, handle.model)
            if not ok:
                raise RuntimeError(why)
            note = f"selected provider={handle.kind} model={handle.model}"
            if handle.base_url:
                note += f" base_url={handle.base_url}"
            notes.append(note)
            handle.notes = notes
            for n in notes:
                logging.info("[provider] %s", n)
            return handle
        except Exception as exc:
            msg = f"[provider] {rung} unavailable: {str(exc)[:240]}"
            notes.append(msg)
            logging.warning(msg)
            last_err = str(exc)
            if require:
                raise RuntimeError(
                    f"--require-provider was set; first rung '{rung}' failed: {exc}"
                )
            continue

    raise RuntimeError(
        "No LLM provider available. Tried: "
        + " | ".join(notes)
        + (f"  (last error: {last_err})" if last_err else "")
    )
