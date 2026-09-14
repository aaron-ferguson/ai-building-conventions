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

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
