#!/usr/bin/env bash
# Tests for check-convention-links.sh.
#
# Each case builds a throwaway conventions dir + workspace, runs the checker against it,
# and asserts on exit code and output. Run: scripts/check-convention-links.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/check-convention-links.sh"

PASSED=0
FAILED=0

fail() {
  printf '  FAIL: %s\n' "$1"
  FAILED=$((FAILED + 1))
}

pass() {
  PASSED=$((PASSED + 1))
}

# Builds a minimal conventions dir in $1 with two real convention files.
make_conventions_dir() {
  local dir="$1"
  mkdir -p "$dir/companies"
  printf '# Core\n' >"$dir/CONVENTIONS_CORE.md"
  printf '# Readme\n' >"$dir/README.md"
  printf '# Git\n' >"$dir/git-conventions.md"
  printf '# Testing\n' >"$dir/testing-conventions.md"
  printf '# Template\n' >"$dir/companies/_template.md"
}

run_case() {
  local name="$1" expected_status="$2" body="$3" expected_substring="${4:-}"
  local tmp conventions workspace out status
  tmp="$(mktemp -d)"
  conventions="$tmp/ai-building-conventions"
  workspace="$tmp"
  make_conventions_dir "$conventions"
  printf '%s\n' "$body" >"$conventions/coding-conventions.md"

  out="$("$CHECKER" "$conventions" "$workspace" 2>&1)"
  status=$?

  printf '%s\n' "$name"
  # A clean exit is not enough: a crashed grep inside the classifier reads as "not a link"
  # and skips the check silently, so an all-clear can mean "nothing was examined".
  if printf '%s' "$out" | grep -qE 'invalid option|usage: grep|command not found'; then
    fail "checker emitted a tool error, so its all-clear proves nothing. Output:
$out"
  elif [ "$status" -ne "$expected_status" ]; then
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

# --- Bare backticked convention filenames inside the repo -----------------------------

run_case "resolves a correct bare reference" 0 \
  'Branching rules live in `git-conventions.md`.'

run_case "flags a renamed-away convention file" 1 \
  'See `branching-conventions.md` for detail.' \
  'branching-conventions.md'

run_case "flags a wrong-case reference macOS would open anyway" 1 \
  'See `Git-Conventions.md` for detail.' \
  'Git-Conventions.md'

run_case "ignores an illustrative filename that is not a convention file" 0 \
  'A repo with both `data-privacy.md` and `DATA_PRIVACY.md` reads as unmaintained.'

run_case "ignores an unbackticked mention" 0 \
  'The file branching-conventions.md does not exist but is not a link.'

run_case "flags a wrong-separator reference to a non-conventions doc" 1 \
  'Start at `CONVENTIONS-CORE.md`.' \
  'CONVENTIONS-CORE.md'

run_case "resolves a bare reference to a doc in a subdirectory" 0 \
  'Copy `_template.md` into the company repo.'

# --- Path references from elsewhere in the workspace ----------------------------------

run_path_case() {
  local name="$1" expected_status="$2" line="$3" expected_substring="${4:-}"
  local tmp conventions workspace out status
  tmp="$(mktemp -d)"
  conventions="$tmp/ai-building-conventions"
  workspace="$tmp"
  make_conventions_dir "$conventions"
  mkdir -p "$workspace/some-project"
  printf '%s\n' "$line" >"$workspace/some-project/CLAUDE.md"

  out="$("$CHECKER" "$conventions" "$workspace" 2>&1)"
  status=$?

  printf '%s\n' "$name"
  # A clean exit is not enough: a crashed grep inside the classifier reads as "not a link"
  # and skips the check silently, so an all-clear can mean "nothing was examined".
  if printf '%s' "$out" | grep -qE 'invalid option|usage: grep|command not found'; then
    fail "checker emitted a tool error, so its all-clear proves nothing. Output:
$out"
  elif [ "$status" -ne "$expected_status" ]; then
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

run_path_case "resolves an absolute import path" 0 \
  '@/somewhere/ai-building-conventions/CONVENTIONS_CORE.md'

run_path_case "flags a wrong-case import path" 1 \
  '@/somewhere/ai-building-conventions/conventions_core.md' \
  'conventions_core.md'

run_path_case "flags an import path to a file that does not exist" 1 \
  '@/somewhere/ai-building-conventions/CONVENTIONS.md' \
  'CONVENTIONS.md'

run_path_case "resolves a nested path reference" 0 \
  'Copy `ai-building-conventions/companies/_template.md` into the company repo.'

# --- Reporting ------------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
