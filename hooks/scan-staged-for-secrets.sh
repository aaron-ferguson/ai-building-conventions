#!/usr/bin/env bash
#
# PreToolUse hook (matcher: Bash). Refuses a commit when the staged diff contains
# secret-shaped content — see security-conventions.md ("Secrets Never Touch the Repo":
# "Before any commit that touched config: scan the staged diff for anything that looks
# like a credential").
#
# Reads the tool-call JSON on stdin. Triggers only when tool_name is "Bash" and
# tool_input.command looks like a `git commit` invocation (any form: `git commit`,
# `git commit -m "..."`, chained after `&&`, etc). Runs `git diff --cached` in the repo
# at the JSON's `cwd` (falling back to $CLAUDE_PROJECT_DIR, then the current directory)
# and inspects only the *added* lines.
#
# Deliberately small starting pattern set — three real shapes, not an exhaustive list:
#   1. AWS access key ID:      AKIA[0-9A-Z]{16}
#   2. generic key/secret/token/password assignment to a quoted 12+ char value
#   3. a PEM private key header
#
# Exit codes: 0 = allow (no trigger, no match, or a missing dependency — see below).
# 2 = refuse. On refusal, stderr names the file and line of the match and never the
# matched text itself, so the refusal message can't itself leak the secret into the
# transcript.
#
# A missing `jq` or `git` is treated as "allow, with a warning" rather than "block the
# commit" — a repo without jq shouldn't have its whole git workflow wedged by a scanner
# that can't run. This is a deliberate fail-open tradeoff for a missing dependency,
# distinct from "no match found" (also allow) and "trigger absent" (also allow); a human
# should weigh whether a security control that can silently no-op is acceptable here.

set -uo pipefail

REFUSE=2
ALLOW=0

warn_allow() {
  printf 'scan-staged-for-secrets.sh: %s, allowing\n' "$1" >&2
  exit "$ALLOW"
}

command -v jq >/dev/null 2>&1 || warn_allow "jq not found (cannot inspect command)"
command -v git >/dev/null 2>&1 || warn_allow "git not found (cannot scan staged diff)"

input="$(cat)"

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"
[ "$tool_name" = "Bash" ] || exit "$ALLOW"

command_str="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -n "$command_str" ] || exit "$ALLOW"

# Looks like a `git commit` invocation in any form — bare, with flags, or chained after
# another command. Not a full shell parser; see block-sweeping-git-stage.sh for the same
# tradeoff.
printf '%s' "$command_str" | grep -qE '(^|[;&|]+[[:space:]]*)git[[:space:]]+commit([[:space:]]|$)' \
  || exit "$ALLOW"

cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"
repo_dir="${cwd:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"

[ -d "$repo_dir" ] || warn_allow "cwd '$repo_dir' does not exist (cannot scan staged diff)"

diff_output="$(git -C "$repo_dir" diff --cached --unified=0 2>/dev/null || true)"
[ -n "$diff_output" ] || exit "$ALLOW"

# Secret-shaped patterns (see file header). Combined with -e so one grep pass covers all
# three; case-insensitive so "Secret:", "SECRET=", etc. all match.
match_secret_shape() {
  printf '%s' "$1" | grep -qiE \
    -e 'AKIA[0-9A-Z]{16}' \
    -e '(key|secret|token|password)[[:space:]]*[:=][[:space:]]*['\''"][^'\''"[:space:]]{12,}['\''"]' \
    -e '^-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
}

current_file=""
new_line=0
findings=0
findings_report=""

while IFS= read -r line; do
  case "$line" in
    "diff --git "*)
      current_file=""
      ;;
    "+++ "*)
      current_file="${line#+++ }"
      current_file="${current_file#b/}"
      ;;
    "@@ "*)
      # @@ -old_start,old_count +new_start,new_count @@ ...
      hunk_new="$(printf '%s' "$line" | sed -E 's/^@@ -[0-9]+(,[0-9]+)? \+([0-9]+)(,[0-9]+)? @@.*/\2/')"
      case "$hunk_new" in
        ''|*[!0-9]*) new_line=0 ;;
        *) new_line="$hunk_new" ;;
      esac
      ;;
    "+++"|"---"*)
      : # header lines already handled above
      ;;
    "+"*)
      content="${line#+}"
      if [ -n "$current_file" ] && match_secret_shape "$content"; then
        findings=$((findings + 1))
        findings_report="${findings_report}${current_file}:${new_line}
"
      fi
      [ "$new_line" -gt 0 ] && new_line=$((new_line + 1))
      ;;
  esac
done <<EOF
$diff_output
EOF

if [ "$findings" -gt 0 ]; then
  {
    printf 'Refused: staged content matches a secret-shaped pattern (security-conventions.md — "Secrets Never Touch the Repo").\n'
    printf 'Matching file(s):\n'
    printf '%s' "$findings_report"
    printf 'Remove the secret from the staged content (rotate it if it is real) before committing.\n'
  } >&2
  exit "$REFUSE"
fi

exit "$ALLOW"
