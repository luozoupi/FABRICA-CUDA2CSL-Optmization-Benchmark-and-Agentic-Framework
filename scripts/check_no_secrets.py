#!/usr/bin/env python3
"""Scan tracked working-tree and staged contents without printing secret values."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PATTERN = re.compile(
    rb"sk-ant-[A-Za-z0-9_-]{20,}|sk-(?:proj-)?[A-Za-z0-9_-]{32,}"
    rb"|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}"
    rb"|xox[baprs]-[A-Za-z0-9-]{10,}"
    rb"|-----BEGIN (?:RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----"
    rb'|"(?:access|refresh)_token"\s*:\s*"[A-Za-z0-9._-]{20,}'
    rb"|Bearer [A-Za-z0-9._-]{20,}"
)


def main():
    paths = subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=ROOT
    ).split(b"\0")
    found = 0
    count = 0
    for raw in filter(None, paths):
        name = raw.decode("utf-8")
        path = ROOT / name
        count += 1
        staged = subprocess.check_output(["git", "show", f":{name}"], cwd=ROOT)
        versions = [("staged", staged)]
        if path.is_file():
            versions.append(("working tree", path.read_bytes()))
        for label, data in versions:
            for number, line in enumerate(data.splitlines(), 1):
                if PATTERN.search(line):
                    print(f"{name}:{number}: possible credential ({label}; value hidden)")
                    found += 1
    print(f"Scanned {count} tracked files; {found} possible credentials.")
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main())
