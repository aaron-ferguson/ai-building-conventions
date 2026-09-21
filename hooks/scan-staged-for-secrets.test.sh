#!/usr/bin/env bash
# Tests for scan-staged-for-secrets.sh.
#
# The hook scans a real staged git diff, so each case builds a throwaway git repo via
# mktemp -d, stages a fixture file, and feeds the hook a JSON envelope whose `cwd` points
# at that fixture — matching how Claude Code actually invokes a PreToolUse hook. Run:
# hooks/scan-staged-for-secrets.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/scan-staged-for-secrets.sh"

PASSED=0
FAILED=0

fail() {
  printf '  FAIL: %s\n' "$1"
  FAILED=$((FAILED + 1))
}

pass() {
  PASSED=$((PASSED + 1))
}

# Creates a one-commit git repo in a fresh temp dir and prints its path.
make_repo() {
  local dir
  dir="$(mktemp -d)"
  git init -q "$dir"
  git -C "$dir" config user.email "test@example.com"
  git -C "$dir" config user.name "Test"
  printf 'placeholder\n' >"$dir/README.md"
  git -C "$dir" add README.md
  git -C "$dir" commit -q -m "Initial commit"
  printf '%s' "$dir"
}

# Feeds the hook a git-commit envelope with the given cwd and asserts on exit status.
run_hook() {
  local dir="$1"
  jq -n --arg cwd "$dir" '{tool_name: "Bash", tool_input: {command: "git commit -m \"x\""}, cwd: $cwd}' \
    | "$HOOK" 2>&1
}

# Builds a PATH containing symlinks to every real external tool the hook needs except
# $1, so `command -v $1` fails inside the hook while everything else — including bash
# itself, resolved via `env`'s PATH per the hook's `#!/usr/bin/env bash` shebang —
# still works normally.
stub_path_missing() {
  local missing="$1" dir tool real
  dir="$(mktemp -d)"
  for tool in bash jq git grep sed cat; do
    [ "$tool" = "$missing" ] && continue
    real="$(command -v "$tool" 2>/dev/null)" || continue
    ln -s "$real" "$dir/$tool"
  done
  printf '%s' "$dir"
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

# --- AC5: staged secret-shaped content is refused, names file:line, never the value ----

test_aws_key_refused() {
  local dir out status
  dir="$(make_repo)"
  printf 'name: demo\naws_key: AKIAABCDEFGHIJKLMNOP\n' >"$dir/config.yml"
  git -C "$dir" add config.yml

  out="$(run_hook "$dir")"
  status=$?
  assert_result "refuses a staged AWS access key" 2 "$out" "$status" "security-conventions.md"

  if ! printf '%s' "$out" | grep -qF "config.yml:2"; then
    fail "expected output to name config.yml:2. Output:
$out"
  fi
  if printf '%s' "$out" | grep -qF "AKIAABCDEFGHIJKLMNOP"; then
    fail "matched secret value leaked into hook output"
  fi

  rm -rf "$dir"
}

test_generic_secret_assignment_refused() {
  local dir out status
  dir="$(make_repo)"
  printf 'password = "correcthorsebatterystaple"\n' >"$dir/settings.py"
  git -C "$dir" add settings.py

  out="$(run_hook "$dir")"
  status=$?
  assert_result "refuses a staged generic secret assignment" 2 "$out" "$status" "security-conventions.md"

  if printf '%s' "$out" | grep -qF "correcthorsebatterystaple"; then
    fail "matched secret value leaked into hook output"
  fi

  rm -rf "$dir"
}

test_pem_header_refused() {
  local dir out status
  dir="$(make_repo)"
  printf -- '-----BEGIN RSA PRIVATE KEY-----\nMIIBogIBAAJ...\n-----END RSA PRIVATE KEY-----\n' >"$dir/key.pem"
  git -C "$dir" add key.pem

  out="$(run_hook "$dir")"
  status=$?
  assert_result "refuses a staged PEM private key header" 2 "$out" "$status" "security-conventions.md"

  rm -rf "$dir"
}

# --- AC6: staged content with no secret-shaped strings is permitted --------------------

test_clean_staged_content_permitted() {
  local dir out status
  dir="$(make_repo)"
  printf 'placeholder\nsome ordinary line with nothing secret in it\n' >"$dir/README.md"
  git -C "$dir" add README.md

  out="$(run_hook "$dir")"
  status=$?
  assert_result "permits a clean staged diff" 0 "$out" "$status"

  rm -rf "$dir"
}

# --- FR7: fails closed (blocks) when a dependency it needs is unavailable --------------

test_missing_jq_blocks() {
  local stub out status
  stub="$(stub_path_missing jq)"
  printf 'blocks the commit when jq is missing\n'
  out="$(printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | PATH="$stub" "$HOOK" 2>&1)"
  status=$?
  assert_result "blocks when jq is missing" 2 "$out" "$status" "jq"
  if ! printf '%s' "$out" | grep -qi 'install'; then
    fail "expected output to say how to install jq. Output:
$out"
  fi
  rm -rf "$stub"
}

test_missing_git_blocks() {
  local stub out status
  stub="$(stub_path_missing git)"
  printf 'blocks the commit when git is missing\n'
  out="$(printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | PATH="$stub" "$HOOK" 2>&1)"
  status=$?
  assert_result "blocks when git is missing" 2 "$out" "$status" "git"
  if ! printf '%s' "$out" | grep -qi 'install'; then
    fail "expected output to say how to install git. Output:
$out"
  fi
  rm -rf "$stub"
}

test_cwd_missing_blocks() {
  local out status
  printf 'blocks the commit when the target cwd does not exist\n'
  out="$(jq -n --arg cwd "/nonexistent/path/for/0004" '{tool_name: "Bash", tool_input: {command: "git commit -m \"x\""}, cwd: $cwd}' | "$HOOK" 2>&1)"
  status=$?
  assert_result "blocks when cwd does not exist" 2 "$out" "$status"
}

# --- FR7: allows silently when the trigger is absent ------------------------------------

test_non_bash_tool_allowed() {
  local out status
  printf 'allows a non-Bash tool call\n'
  out="$(printf '{"tool_name":"Read","tool_input":{"file_path":"x"}}' | "$HOOK" 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    fail "expected exit 0, got $status. Output:
$out"
  else
    pass
  fi
}

test_non_commit_command_allowed() {
  local dir out status
  dir="$(make_repo)"
  printf 'aws_key: AKIAABCDEFGHIJKLMNOP\n' >"$dir/config.yml"
  git -C "$dir" add config.yml

  out="$(jq -n --arg cwd "$dir" '{tool_name: "Bash", tool_input: {command: "ls -la"}, cwd: $cwd}' | "$HOOK" 2>&1)"
  status=$?
  assert_result "allows a non-commit Bash command even with a secret staged" 0 "$out" "$status"

  rm -rf "$dir"
}

test_aws_key_refused
test_generic_secret_assignment_refused
test_pem_header_refused
test_clean_staged_content_permitted
test_missing_jq_blocks
test_missing_git_blocks
test_cwd_missing_blocks
test_non_bash_tool_allowed
test_non_commit_command_allowed

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
