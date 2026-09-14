#!/usr/bin/env bash
# Tests for check-machine-specifics.sh.
#
# Each case builds a throwaway directory, runs the checker against it, and asserts on
# exit code and output. Run: scripts/check-machine-specifics.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/check-machine-specifics.sh"

PASSED=0
FAILED=0

fail() {
  printf '  FAIL: %s\n' "$1"
  FAILED=$((FAILED + 1))
}

pass() {
  PASSED=$((PASSED + 1))
}

run_case() {
  local name="$1" expected_status="$2" body="$3" expected_substring="${4:-}"
  local tmp out status
  tmp="$(mktemp -d)"
  printf '%s\n' "$body" >"$tmp/doc.md"

  out="$("$CHECKER" "$tmp" 2>&1)"
  status=$?

  printf '%s\n' "$name"
  if [ "$status" -ne "$expected_status" ]; then
    fail "expected exit $expected_status, got $status. Output:
$out"
  elif [ -n "$expected_substring" ] && ! printf '%s' "$out" | grep -qF "$expected_substring"; then
    fail "expected output to contain '$expected_substring'. Output:
$out"
  else
    pass
  fi
  rm -rf "$tmp"
}

run_case "flags an absolute home path" 1 \
  'The file lives at /Users/someone/x on that machine.' \
  '/Users/someone/x'

run_case "flags a path under ~/.claude/plugins/" 1 \
  'Installed at `~/.claude/plugins/marketplaces/some-marketplace/github/`.' \
  '~/.claude/plugins/'

run_case "does not flag the documented settings paths" 0 \
  'Global settings live in `~/.claude/settings.json`; project overrides in `.claude/settings.local.json`.'

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
