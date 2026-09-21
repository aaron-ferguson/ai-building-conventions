#!/usr/bin/env bash
# Tests for block-sweeping-git-stage.sh.
#
# Each case feeds a JSON envelope on stdin, matching how Claude Code actually invokes a
# PreToolUse hook, and asserts on exit code (and, for refusals, that stderr names
# git-conventions.md). Run: hooks/block-sweeping-git-stage.test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/block-sweeping-git-stage.sh"

PASSED=0
FAILED=0

fail() {
  printf '  FAIL: %s\n' "$1"
  FAILED=$((FAILED + 1))
}

pass() {
  PASSED=$((PASSED + 1))
}

# Feeds a Bash tool-call envelope for the given command and asserts on exit status,
# optionally checking stderr contains a substring.
assert_command() {
  local name="$1" command="$2" expected_status="$3" expected_substring="${4:-}"
  local json out status

  printf '%s\n' "$name"
  json="$(printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(printf '%s' "$command" | jq -R .)")"
  out="$(printf '%s' "$json" | "$HOOK" 2>&1)"
  status=$?

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

# Builds a PATH containing symlinks to every real external tool the hook needs except
# $1, so `command -v $1` fails inside the hook while everything else — including bash
# itself, resolved via `env`'s PATH per the hook's `#!/usr/bin/env bash` shebang —
# still works normally.
stub_path_missing() {
  local missing="$1" dir tool real
  dir="$(mktemp -d)"
  for tool in bash jq sed cat; do
    [ "$tool" = "$missing" ] && continue
    real="$(command -v "$tool" 2>/dev/null)" || continue
    ln -s "$real" "$dir/$tool"
  done
  printf '%s' "$dir"
}

# --- AC1/AC2: sweeping git add / git commit forms are refused --------------------------

test_git_add_dot_refused() {
  assert_command "refuses 'git add .'" "git add ." 2 "git-conventions.md"
}

test_git_add_capital_a_refused() {
  assert_command "refuses 'git add -A'" "git add -A" 2 "git-conventions.md"
}

test_git_add_all_long_refused() {
  assert_command "refuses 'git add --all'" "git add --all" 2 "git-conventions.md"
}

test_git_commit_a_refused() {
  assert_command "refuses 'git commit -a -m x'" "git commit -a -m x" 2 "git-conventions.md"
}

test_git_commit_all_long_refused() {
  assert_command "refuses 'git commit --all -m x'" "git commit --all -m x" 2 "git-conventions.md"
}

test_git_commit_am_combined_refused() {
  assert_command "refuses combined 'git commit -am x'" "git commit -am x" 2 "git-conventions.md"
}

test_chained_git_add_dot_refused() {
  assert_command "refuses 'git add .' chained after another command" "cd foo && git add ." 2 "git-conventions.md"
}

# --- AC3: a specific pathspec is permitted ----------------------------------------------

test_git_add_specific_file_permitted() {
  assert_command "permits 'git add path/to/file.md'" "git add path/to/file.md" 0
}

test_git_commit_pathspec_permitted() {
  assert_command "permits 'git commit -m x -- path/to/file.md'" "git commit -m x -- path/to/file.md" 0
}

# --- AC4: bare git stash is refused, a scoped stash is permitted ------------------------

test_bare_git_stash_refused() {
  assert_command "refuses bare 'git stash'" "git stash" 2 "git-conventions.md"
}

test_git_stash_save_no_path_refused() {
  assert_command "refuses 'git stash save' with no path" "git stash save" 2 "git-conventions.md"
}

test_git_stash_push_flags_only_refused() {
  assert_command "refuses 'git stash push -u' with no path" "git stash push -u" 2 "git-conventions.md"
}

test_git_stash_push_with_path_permitted() {
  assert_command "permits 'git stash push -u some/path'" "git stash push -u some/path" 0
}

test_git_stash_push_dashdash_path_permitted() {
  assert_command "permits 'git stash push -- some/path'" "git stash push -- some/path" 0
}

test_git_stash_pop_always_permitted() {
  assert_command "permits 'git stash pop'" "git stash pop" 0
}

test_git_stash_list_always_permitted() {
  assert_command "permits 'git stash list'" "git stash list" 0
}

# --- FR7: fails closed (blocks) when a dependency it needs is unavailable --------------

test_missing_jq_blocks() {
  local stub out status
  stub="$(stub_path_missing jq)"
  printf 'blocks the command when jq is missing\n'
  out="$(printf '{"tool_name":"Bash","tool_input":{"command":"git add ."}}' | PATH="$stub" "$HOOK" 2>&1)"
  status=$?
  if [ "$status" -ne 2 ]; then
    fail "expected exit 2, got $status. Output:
$out"
  elif ! printf '%s' "$out" | grep -qF "jq"; then
    fail "expected output to name jq. Output:
$out"
  elif ! printf '%s' "$out" | grep -qi 'install'; then
    fail "expected output to say how to install jq. Output:
$out"
  else
    pass
  fi
  rm -rf "$stub"
}

# --- FR7: hook allows silently when its trigger is absent -------------------------------

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

test_unrelated_bash_command_allowed() {
  assert_command "allows an unrelated Bash command" "ls -la" 0
}

test_git_add_dot_refused
test_git_add_capital_a_refused
test_git_add_all_long_refused
test_git_commit_a_refused
test_git_commit_all_long_refused
test_git_commit_am_combined_refused
test_chained_git_add_dot_refused
test_git_add_specific_file_permitted
test_git_commit_pathspec_permitted
test_bare_git_stash_refused
test_git_stash_save_no_path_refused
test_git_stash_push_flags_only_refused
test_git_stash_push_with_path_permitted
test_git_stash_push_dashdash_path_permitted
test_git_stash_pop_always_permitted
test_git_stash_list_always_permitted
test_missing_jq_blocks
test_non_bash_tool_allowed
test_unrelated_bash_command_allowed

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
