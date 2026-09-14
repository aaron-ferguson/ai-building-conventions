#!/usr/bin/env bash
# Tests for check-core-drift.sh.
#
# Each case builds a throwaway conventions dir, runs the checker against it, and asserts
# on exit code and output. Run: scripts/check-core-drift.test.sh
#
# Staleness (AC3/AC4) is a git-history comparison, so those fixtures need a real
# throwaway git repo with two commits at distinct, explicit timestamps (GIT_AUTHOR_DATE /
# GIT_COMMITTER_DATE), so the ordering is deterministic rather than racing the clock.
#
# The broken-anchor fixture (AC2) needs no git history at all: the checker treats a file
# with no git log output as "cannot check staleness, but anchor resolution still applies"
# (see check-core-drift.sh), so a plain non-git temp directory already exercises that
# path and is simpler than standing up a repo just to prove the anchor check fires.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/check-core-drift.sh"

PASSED=0
FAILED=0

fail() {
  printf '  FAIL: %s\n' "$1"
  FAILED=$((FAILED + 1))
}

pass() {
  PASSED=$((PASSED + 1))
}

assert_result() {
  local name="$1" expected_status="$2" out="$3" status="$4" expected_substring="${5:-}"
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
}

# --- AC2: an anchor that does not resolve in its source file ---------------------------
#
# No git repo at all — proves anchor resolution works independently of staleness, and
# that a file with no git history is skipped for staleness rather than crashing the run.

test_broken_anchor() {
  local tmp out status
  tmp="$(mktemp -d)"

  cat >"$tmp/CONVENTIONS_CORE.md" <<'EOF'
# Core

- Some rule restated here (`source-conventions.md` → "A Heading That Was Renamed").
EOF

  cat >"$tmp/source-conventions.md" <<'EOF'
# Source Conventions

## A Different Heading Entirely

The heading above was renamed and the core's pointer was never updated.
EOF

  out="$("$CHECKER" "$tmp" 2>&1)"
  status=$?
  assert_result "flags an anchor that no longer resolves in its source file" 1 "$out" "$status" \
    'A Heading That Was Renamed'

  rm -rf "$tmp"
}

# --- AC3: a cited source file committed more recently than the core --------------------

make_git_fixture() {
  local dir="$1"
  git init -q "$dir"
  git -C "$dir" config user.email "test@example.com"
  git -C "$dir" config user.name "Test"

  cat >"$dir/CONVENTIONS_CORE.md" <<'EOF'
# Core

- Some rule restated here (`source-conventions.md` → "The Real Heading").
EOF

  cat >"$dir/source-conventions.md" <<'EOF'
# Source Conventions

## The Real Heading

Original wording.
EOF

  GIT_AUTHOR_DATE="2024-01-01T00:00:00" GIT_COMMITTER_DATE="2024-01-01T00:00:00" \
    git -C "$dir" add CONVENTIONS_CORE.md source-conventions.md
  GIT_AUTHOR_DATE="2024-01-01T00:00:00" GIT_COMMITTER_DATE="2024-01-01T00:00:00" \
    git -C "$dir" commit -q -m "Initial commit"
}

test_stale_source() {
  local tmp out status
  tmp="$(mktemp -d)"
  make_git_fixture "$tmp"

  # Reword the source's prose (not the heading) in a second commit that never touches
  # the core — the source is now newer than the core in git history.
  cat >"$tmp/source-conventions.md" <<'EOF'
# Source Conventions

## The Real Heading

Reworded wording, unrelated to the core's restatement, committed after the core.
EOF
  GIT_AUTHOR_DATE="2024-01-02T00:00:00" GIT_COMMITTER_DATE="2024-01-02T00:00:00" \
    git -C "$tmp" add source-conventions.md
  GIT_AUTHOR_DATE="2024-01-02T00:00:00" GIT_COMMITTER_DATE="2024-01-02T00:00:00" \
    git -C "$tmp" commit -q -m "Reword source prose"

  out="$("$CHECKER" "$tmp" 2>&1)"
  status=$?
  assert_result "flags a source file committed more recently than the core" 1 "$out" "$status" \
    'source-conventions.md'

  rm -rf "$tmp"
}

# --- AC4: anchors resolve and the core is not stale -------------------------------------

test_clean_repo() {
  local tmp out status
  tmp="$(mktemp -d)"
  make_git_fixture "$tmp"

  cat >"$tmp/source-conventions.md" <<'EOF'
# Source Conventions

## The Real Heading

Reworded wording, unrelated to the core's restatement, committed after the core.
EOF
  GIT_AUTHOR_DATE="2024-01-02T00:00:00" GIT_COMMITTER_DATE="2024-01-02T00:00:00" \
    git -C "$tmp" add source-conventions.md
  GIT_AUTHOR_DATE="2024-01-02T00:00:00" GIT_COMMITTER_DATE="2024-01-02T00:00:00" \
    git -C "$tmp" commit -q -m "Reword source prose"

  # Touch the core after the source edit, so the core's last commit is not older.
  printf '\n<!-- reviewed against source-conventions.md -->\n' >>"$tmp/CONVENTIONS_CORE.md"
  GIT_AUTHOR_DATE="2024-01-03T00:00:00" GIT_COMMITTER_DATE="2024-01-03T00:00:00" \
    git -C "$tmp" add CONVENTIONS_CORE.md
  GIT_AUTHOR_DATE="2024-01-03T00:00:00" GIT_COMMITTER_DATE="2024-01-03T00:00:00" \
    git -C "$tmp" commit -q -m "Re-touch core after reviewing source"

  out="$("$CHECKER" "$tmp" 2>&1)"
  status=$?
  assert_result "passes when anchors resolve and the core is not stale" 0 "$out" "$status"

  rm -rf "$tmp"
}

# --- Bad-path handling -------------------------------------------------------------------

test_missing_dir() {
  local out status
  out="$("$CHECKER" "/no/such/directory-$$" 2>&1)"
  status=$?
  assert_result "errors cleanly on a missing conventions dir" 2 "$out" "$status"
}

test_broken_anchor
test_stale_source
test_clean_repo
test_missing_dir

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
