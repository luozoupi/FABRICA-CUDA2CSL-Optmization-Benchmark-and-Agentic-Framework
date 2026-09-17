#!/usr/bin/env python3
"""Extract the Argo Anthropic-proxy key from ~/.claude/settings.json and write it to a file.

The Claude Code harness stores its Argo-shim auth in `~/.claude/settings.json` as an
`apiKeyHelper` shell command (or, less commonly, as `env.ANTHROPIC_API_KEY`). The xkernel
agent framework consumes API keys via `--api-key-file`, so this helper resolves the
harness's key once and drops it into a plain-text file with mode 0600.

Usage:
    python argo_key_from_settings.py [--settings PATH] [--out PATH]
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path


DEFAULT_SETTINGS = "~/.claude/settings.json"
DEFAULT_OUT = "~/.argo-api-key.txt"


def resolve_key(settings_path: Path) -> str:
    if not settings_path.exists():
        raise SystemExit(f"settings file not found: {settings_path}")
    try:
        data = json.loads(settings_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"settings file is not valid JSON: {exc}")

    helper = data.get("apiKeyHelper")
    if isinstance(helper, str) and helper.strip():
        result = subprocess.run(
            helper,
            shell=True,
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode != 0:
            raise SystemExit(
                f"apiKeyHelper exited {result.returncode}: {result.stderr.strip()[:500]}"
            )
        lines = [ln.strip() for ln in result.stdout.splitlines() if ln.strip()]
        if not lines:
            raise SystemExit("apiKeyHelper produced no output")
        return lines[-1]

    env = data.get("env") or {}
    for fallback in ("ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN"):
        value = env.get(fallback)
        if isinstance(value, str) and value.strip():
            return value.strip()

    raise SystemExit(
        "no apiKeyHelper or env.ANTHROPIC_API_KEY found in settings file"
    )


def write_key(token: str, out_path: Path) -> None:
    if not all(32 <= ord(c) < 127 for c in token):
        raise SystemExit("resolved key contains non-printable characters; refusing to write")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix=".argo-key-", dir=str(out_path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            fh.write(token)
        os.chmod(tmp_name, 0o600)
        os.replace(tmp_name, out_path)
    except Exception:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--settings", default=DEFAULT_SETTINGS,
                        help=f"Path to Claude Code settings.json (default: {DEFAULT_SETTINGS})")
    parser.add_argument("--out", default=DEFAULT_OUT,
                        help=f"Output key file path (default: {DEFAULT_OUT})")
    args = parser.parse_args(argv)

    settings_path = Path(os.path.expanduser(args.settings)).resolve()
    out_path = Path(os.path.expanduser(args.out)).resolve()

    token = resolve_key(settings_path)
    write_key(token, out_path)
    print(str(out_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
