#!/usr/bin/env bash
#
# PreToolUse hook (matcher: Bash). Refuses git commands that sweep the shared index or
# take another session's uncommitted work — see git-conventions.md:
#   - "Stage specific files": never `git add .`, `git add -A`/`--all`, or
#     `git commit -a`/`--all` (including combined short flags like `-am`).
#   - "Never bare `git stash`" in a shared tree: only `git stash push`/`save` with an
#     actual pathspec is safe; other stash subcommands (pop, apply, list, drop, clear,
#     branch, show) never sweep anything and are always permitted.
#
# Reads the tool-call JSON on stdin (see Claude Code PreToolUse hook contract). Exits 0
# (allow) whenever the trigger isn't present at all — wrong tool, no command, jq missing
# — per the rule that a hook must never hard-fail on a command it doesn't understand.
# Exits 2 (refuse) only for the exact shapes above, with the reason on stderr.
#
# Scope note: this is a word-splitting check, not a shell parser. It splits on `;`,
# `&&`, `||` and `|` to look at each command in a chain, and does not handle quoting,
# subshells, or `git -C <dir>` before the subcommand. That is enough to catch the
# sweeping forms this hook exists to block without becoming a general command parser.

set -uo pipefail

REFUSE=2
ALLOW=0

if ! command -v jq >/dev/null 2>&1; then
  printf 'block-sweeping-git-stage.sh: jq not found, allowing (cannot inspect command)\n' >&2
  exit "$ALLOW"
fi

input="$(cat)"

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"
if [ "$tool_name" != "Bash" ]; then
  exit "$ALLOW"
fi

command_str="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
if [ -z "$command_str" ]; then
  exit "$ALLOW"
fi

# Split the command into segments on shell chaining operators so each `git ...`
# invocation in something like `cd foo && git add .` is checked on its own.
segments="$(printf '%s' "$command_str" | sed -E 's/(;|&&|\|\||\|)/\n/g')"

refuse() {
  local reason="$1"
  printf 'Refused: %s (git-conventions.md — stage/stash specific paths, not everything).\n' "$reason" >&2
  exit "$REFUSE"
}

is_flag() {
  case "$1" in
    -*) return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r segment; do
  [ -z "$segment" ] && continue
  # shellcheck disable=SC2206
  tokens=($segment)
  [ "${#tokens[@]}" -lt 2 ] && continue
  [ "${tokens[0]}" != "git" ] && continue

  subcommand="${tokens[1]}"

  if [ "$subcommand" = "add" ]; then
    for ((i = 2; i < ${#tokens[@]}; i++)); do
      case "${tokens[$i]}" in
        "."|"-A"|"--all")
          refuse "'git add ${tokens[$i]}' stages the whole index — use 'git add <file>' for the paths you actually changed"
          ;;
      esac
    done
  fi

  if [ "$subcommand" = "commit" ]; then
    for ((i = 2; i < ${#tokens[@]}; i++)); do
      tok="${tokens[$i]}"
      case "$tok" in
        "--all")
          refuse "'git commit --all' commits the whole index — use 'git commit -m \"…\" -- <paths>' instead"
          ;;
        -[A-Za-z]*)
          # Single-dash short-flag cluster (e.g. -a, -am, -ma). Refuse only if it
          # actually contains the 'a' ("--all") flag.
          rest="${tok#-}"
          case "$rest" in
            *a*)
              refuse "'git commit $tok' commits the whole index — use 'git commit -m \"…\" -- <paths>' instead"
              ;;
          esac
          ;;
      esac
    done
  fi

  if [ "$subcommand" = "stash" ]; then
    third="${tokens[2]:-}"
    case "$third" in
      pop|apply|list|drop|clear|branch|show)
        continue
        ;;
    esac

    # Bare `git stash`, `git stash save`, or `git stash push` — a "create" operation.
    # Safe only if an actual pathspec token (not a flag) follows.
    start=2
    case "$third" in
      push|save) start=3 ;;
    esac

    has_path=0
    seen_dashdash=0
    for ((i = start; i < ${#tokens[@]}; i++)); do
      tok="${tokens[$i]}"
      if [ "$seen_dashdash" -eq 1 ]; then
        has_path=1
        break
      fi
      if [ "$tok" = "--" ]; then
        seen_dashdash=1
        continue
      fi
      if ! is_flag "$tok"; then
        has_path=1
        break
      fi
    done

    if [ "$has_path" -eq 0 ]; then
      refuse "bare 'git stash' takes another session's uncommitted work with it — use 'git stash push -u <path>...'"
    fi
  fi
done <<EOF
$segments
EOF

exit "$ALLOW"
