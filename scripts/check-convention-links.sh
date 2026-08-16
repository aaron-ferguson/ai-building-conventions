#!/usr/bin/env bash
#
# Verify every reference to a conventions file resolves — with exactly that case.
#
# macOS is case-insensitive, so a wrong-case path opens fine here and fails only once a
# project is cloned onto Linux (CI, a cloud agent, a container). It fails quietly: the
# agent finds nothing at the path and carries on *without the conventions loaded*. The
# environment where these links break is the unattended one where nobody is watching.
#
# Usage: scripts/check-convention-links.sh [conventions_dir] [workspace_dir ...]
#   conventions_dir  defaults to this script's parent (the repo root)
#   workspace_dir    defaults to the conventions dir's parent; scanned for path-shaped
#                    references into the conventions dir from other repos
#
# Exits non-zero on the first run that finds any unresolved reference.

set -uo pipefail

readonly REPO_DIR_NAME="ai-building-conventions"

usage() {
  sed -n '3,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
conventions_dir="${1:-$(dirname "$script_dir")}"

if [ ! -d "$conventions_dir" ]; then
  printf 'error: conventions dir not found: %s\n' "$conventions_dir" >&2
  exit 2
fi
conventions_dir="$(cd "$conventions_dir" && pwd)"

shift 2>/dev/null || true
if [ "$#" -gt 0 ]; then
  workspace_dirs=("$@")
else
  workspace_dirs=("$(dirname "$conventions_dir")")
fi

# The authority on what exists, listed once. Comparisons are literal and whole-line, so
# they stay case-sensitive on a case-insensitive filesystem — which `[ -f ]` would not.
actual_paths="$(cd "$conventions_dir" && find . -name '*.md' -type f | sed 's|^\./||' | sort)"
actual_basenames="$(printf '%s\n' "$actual_paths" | sed 's|.*/||' | sort -u)"

# Case and separator folded away, so a reference that differs from a real doc only by
# those still resembles it — which is exactly the reference worth checking.
normalize() {
  printf '%s' "$1" | tr '[:upper:]_' '[:lower:]-'
}
normalized_basenames="$(printf '%s\n' "$actual_basenames" | tr '[:upper:]_' '[:lower:]-' | sort -u)"

failures=0

report() {
  printf '  %s\n    referenced from %s\n' "$1" "$2"
  failures=$((failures + 1))
}

# `--` throughout: a normalized name can start with a dash (`_template.md` folds to
# `-template.md`), and grep would read it as a flag and exit non-zero — silently turning
# a real check into a skip.
exists() {
  printf '%s\n' "$actual_paths" | grep -qxF -- "$1" ||
    printf '%s\n' "$actual_basenames" | grep -qxF -- "$1"
}

# A backticked filename is a link worth checking when it either follows the conventions
# naming pattern (so a rename away from it is caught) or resembles a doc that exists (so a
# wrong-case or wrong-separator reference is caught). Everything else — `data-privacy.md`
# as a naming example, `NNN-short-title.md` as a template — is prose, and flagging it is
# the noise that gets a checker switched off.
is_link() {
  local normalized
  normalized="$(normalize "$1")"
  case "$normalized" in
    *-conventions.md) return 0 ;;
  esac
  printf '%s\n' "$normalized_basenames" | grep -qxF -- "$normalized"
}

# --- Pass 1: bare backticked filenames inside the conventions repo ---------------------
#
# Only backticked names are checked. Unbackticked prose ("a repo with both data-privacy.md
# and DATA_PRIVACY.md") is illustrative, not a link, and checking it produces noise that
# gets the whole script ignored.

printf 'Checking bare filename references inside %s\n' "$conventions_dir"

while IFS=: read -r file name; do
  [ -z "${name:-}" ] && continue
  is_link "$name" || continue
  exists "$name" || report "$name" "$file"
done < <(
  cd "$conventions_dir" &&
    grep -roE '`[A-Za-z0-9_.-]+\.md`' --include='*.md' . |
    sed 's|^\./||' |
    tr -d '`'
)

# --- Pass 2: path-shaped references from anywhere in the workspace ---------------------
#
# Any string containing `ai-building-conventions/<path>` — @imports, links, prose paths —
# regardless of what precedes the repo directory name.

for workspace in "${workspace_dirs[@]}"; do
  [ -d "$workspace" ] || continue
  workspace="$(cd "$workspace" && pwd)"
  printf 'Checking path references into %s from %s\n' "$REPO_DIR_NAME" "$workspace"

  while IFS=: read -r file ref; do
    [ -z "${ref:-}" ] && continue
    exists "$ref" || report "$REPO_DIR_NAME/$ref" "$file"
  done < <(
    cd "$workspace" &&
      grep -roE "$REPO_DIR_NAME/[A-Za-z0-9_./-]+\.md" \
        --include='*.md' --include='*.yml' --include='*.yaml' --include='*.json' \
        --exclude-dir='.git' --exclude-dir='node_modules' . |
      sed 's|^\./||' |
      sed "s|:.*$REPO_DIR_NAME/|:|"
  )
done

# --- Result ---------------------------------------------------------------------------

if [ "$failures" -ne 0 ]; then
  printf '\n%d unresolved reference(s).\n' "$failures" >&2
  exit 1
fi

printf '\nAll convention links resolve.\n'
