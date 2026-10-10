#!/usr/bin/env bash
# Tests for check-commit-identity.sh.
#
# Each case builds a throwaway git repo, commits under a chosen identity, runs the
# checker against it, and asserts on exit code and output. Run:
# scripts/check-commit-identity.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/check-commit-identity.sh"

PASSED=0
FAILED=0

fail() {
  printf '  FAIL: %s\n' "$1"
  FAILED=$((FAILED + 1))
}

pass() {
  PASSED=$((PASSED + 1))
}

# Builds a throwaway repo in $1, committing one file under the given author/committer
# email (both set the same way, since either field alone being disallowed must be caught).
make_repo_with_identity() {
  local dir="$1" email="$2"
  git init -q "$dir"
  git -C "$dir" config user.name "Fixture Author"
  git -C "$dir" config user.email "$email"
  git -C "$dir" config commit.gpgsign false
  printf 'fixture\n' >"$dir/file.txt"
  git -C "$dir" add file.txt
  git -C "$dir" commit -q -m "Fixture commit"
}

run_case() {
  local name="$1" expected_status="$2" email="$3" expect_sha_in_output="$4"
  local tmp out status sha
  tmp="$(mktemp -d)"
  make_repo_with_identity "$tmp" "$email"
  sha="$(git -C "$tmp" rev-parse HEAD)"

  out="$("$CHECKER" "$tmp" 2>&1)"
  status=$?

  printf '%s\n' "$name"
  if [ "$status" -ne "$expected_status" ]; then
    fail "expected exit $expected_status, got $status. Output:
$out"
  elif [ "$expect_sha_in_output" = "yes" ] && ! printf '%s' "$out" | grep -qF "$sha"; then
    fail "expected output to contain the offending SHA $sha. Output:
$out"
  else
    pass
  fi
  rm -rf "$tmp"
}

run_case "flags a commit whose author/committer email is on a disallowed domain" 1 \
  "someone@disallowed.example" "yes"

run_case "passes a commit whose author/committer email is on an allowed domain" 0 \
  "aaron@newheights.coach" "no"

# Baseline cases: a baseline lists SHAs of already-published violations. Those are reported
# but do not fail; anything else still does.
run_baseline_case() {
  local name="$1" expected_status="$2" baseline_mode="$3" expect_text="$4"
  local tmp out status sha baseline
  tmp="$(mktemp -d)"
  make_repo_with_identity "$tmp" "someone@disallowed.example"
  sha="$(git -C "$tmp" rev-parse HEAD)"
  baseline="$tmp.baseline"
  case "$baseline_mode" in
    covers-head) printf '%s\n' "$sha" >"$baseline" ;;
    covers-other) printf '%s\n' "0000000000000000000000000000000000000000" >"$baseline" ;;
    missing) baseline="$tmp.does-not-exist" ;;
  esac

  out="$(COMMIT_IDENTITY_BASELINE="$baseline" "$CHECKER" "$tmp" 2>&1)"
  status=$?

  printf '%s\n' "$name"
  if [ "$status" -ne "$expected_status" ]; then
    fail "expected exit $expected_status, got $status. Output:
$out"
  elif ! printf '%s' "$out" | grep -qF "$expect_text"; then
    fail "expected output to contain '$expect_text'. Output:
$out"
  else
    pass
  fi
  rm -rf "$tmp" "$tmp.baseline"
}

run_baseline_case "reports but does not fail a violation listed in the baseline" 0 covers-head "known"

run_baseline_case "still fails a violation that is not in the baseline" 1 covers-other "not on an allowed domain"

run_baseline_case "reports a baseline entry that no longer matches any violation as stale" 1 covers-other "stale"

run_baseline_case "fails loudly when the baseline file cannot be read" 2 missing "baseline"

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
