#!/usr/bin/env bash
# Scan tracked + staged files for credential-shaped strings. Run before every
# push (exit 1 on a hit). Values are masked in the report.
#   GIT=/path/to/git bash scripts/check_no_secrets.sh
set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.."
GIT="${GIT:-git}"
PATTERN='(sk-ant-[A-Za-z0-9_-]{10,}|sk-[A-Za-z0-9]{32,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----|"(access|refresh)_token"[[:space:]]*:[[:space:]]*"[A-Za-z0-9._-]{20,}|Bearer [A-Za-z0-9._-]{20,})'
files=$( { "$GIT" ls-files; "$GIT" diff --cached --name-only --diff-filter=ACMR; } | sort -u )
hits=$(printf '%s\n' "$files" | xargs -d '\n' grep -nIE "$PATTERN" 2>/dev/null \
       | sed -E 's/[A-Za-z0-9_.\-]{20,}/<MASKED>/g')
if [ -n "$hits" ]; then
  echo "check_no_secrets: possible credentials found:" >&2
  printf '%s\n' "$hits" >&2
  exit 1
fi
echo "check_no_secrets: clean ($(printf '%s\n' "$files" | grep -c .) files)"
