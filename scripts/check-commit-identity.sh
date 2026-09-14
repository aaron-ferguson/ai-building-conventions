#!/usr/bin/env bash
#
# Verify every commit reachable from HEAD has an author and committer email on an
# allowed domain.
#
# Commit metadata is published the moment it's pushed, exactly like a tracked file — and
# this repo's `company: none` rule covers everything it publishes, not only tracked
# files (see CLAUDE.md). A corporate identity used from any clone goes out with the next
# push and nothing else catches it.
#
# Usage: scripts/check-commit-identity.sh [repo_dir]
#   repo_dir  defaults to this script's parent (the repo root)
#
# Exits non-zero and prints every offending SHA if any commit's author or committer
# email is outside the allowed domains below.

set -uo pipefail

# States what is permitted, never what is forbidden by example — the corporate domain
# this check exists to catch never appears in the file that catches it.
readonly ALLOWED_DOMAINS=("newheights.coach")

usage() {
  sed -n '3,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="${1:-$(dirname "$script_dir")}"

if [ ! -d "$repo_dir" ]; then
  printf 'error: repo dir not found: %s\n' "$repo_dir" >&2
  exit 2
fi
repo_dir="$(cd "$repo_dir" && pwd)"

is_allowed_email() {
  local email="$1" domain
  domain="${email##*@}"
  local allowed
  for allowed in "${ALLOWED_DOMAINS[@]}"; do
    [ "$domain" = "$allowed" ] && return 0
  done
  return 1
}

failures=0

while IFS='|' read -r sha author_email committer_email; do
  [ -z "$sha" ] && continue
  if ! is_allowed_email "$author_email"; then
    printf '%s  author email %s is not on an allowed domain\n' "$sha" "$author_email"
    failures=$((failures + 1))
  fi
  if ! is_allowed_email "$committer_email"; then
    printf '%s  committer email %s is not on an allowed domain\n' "$sha" "$committer_email"
    failures=$((failures + 1))
  fi
done < <(cd "$repo_dir" && git log --format='%H|%ae|%ce')

if [ "$failures" -ne 0 ]; then
  printf '\n%d disallowed commit identity reference(s).\n' "$failures" >&2
  exit 1
fi

printf '\nAll commits are on an allowed domain.\n'
