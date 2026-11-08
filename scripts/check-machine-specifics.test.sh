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

# The backlog's bug reports sometimes have to quote the path they complain about, so the
# backlog directory is skipped wherever it lives — `.tickets/` now, `.claude/` before it.
run_excluded_dir_case() {
  local dir="$1" tmp out status
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/$dir/items"
  printf 'Seen at /Users/someone/x.\n' >"$tmp/$dir/items/0001-x.md"

  out="$("$CHECKER" "$tmp" 2>&1)"
  status=$?

  printf 'does not flag a file under %s/\n' "$dir"
  if [ "$status" -ne 0 ]; then
    fail "expected exit 0, got $status. Output:
$out"
  else
    pass
  fi
  rm -rf "$tmp"
}

run_excluded_dir_case ".tickets"
run_excluded_dir_case ".claude"

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
