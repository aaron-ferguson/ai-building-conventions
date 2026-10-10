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
# Contract for history that is already published: a commit listed in the baseline file
# (scripts/commit-identity-baseline.txt, override with COMMIT_IDENTITY_BASELINE) is a
# known violation. It is reported but does not fail, because history on a public remote
# cannot be un-published and a check that is permanently red for a reason nobody can act
# on stops being read. Any violation NOT in the baseline still fails, so a new leak is
# caught. The baseline holds SHAs only, never addresses. A baseline entry that no longer
# matches a violation is reported as stale (history was rewritten, or it was added by
# mistake) but does not fail. An unreadable baseline exits 2: a gate that cannot run must
# block, not silently allow.
#
# Exits 1 and prints every non-baselined offending SHA if any commit's author or
# committer email is outside the allowed domains below.

set -uo pipefail

# States what is permitted, never what is forbidden by example — the corporate domain
# this check exists to catch never appears in the file that catches it.
readonly ALLOWED_DOMAINS=("newheights.coach")

usage() {
  sed -n '3,26p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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

baseline_file="${COMMIT_IDENTITY_BASELINE:-$script_dir/commit-identity-baseline.txt}"
if [ ! -r "$baseline_file" ]; then
  printf 'error: baseline file not readable: %s\n' "$baseline_file" >&2
  exit 2
fi
# Strip comments and blank lines; one SHA per line.
baseline_shas="$(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$baseline_file" | grep -v '^$' || true)"

is_baselined() {
  printf '%s\n' "$baseline_shas" | grep -qxF "$1"
}

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
known=0
declare -a seen_baselined=()

while IFS='|' read -r sha author_email committer_email; do
  [ -z "$sha" ] && continue
  if is_allowed_email "$author_email" && is_allowed_email "$committer_email"; then
    continue
  fi
  if is_baselined "$sha"; then
    known=$((known + 1))
    seen_baselined+=("$sha")
    continue
  fi
  if ! is_allowed_email "$author_email"; then
    printf '%s  author email %s is not on an allowed domain\n' "$sha" "$author_email"
    failures=$((failures + 1))
  fi
  if ! is_allowed_email "$committer_email"; then
    printf '%s  committer email %s is not on an allowed domain\n' "$sha" "$committer_email"
    failures=$((failures + 1))
  fi
done < <(cd "$repo_dir" && git log --format='%H|%ae|%ce')

stale=0
while IFS= read -r base_sha; do
  [ -z "$base_sha" ] && continue
  if ! printf '%s\n' "${seen_baselined[@]:-}" | grep -qxF "$base_sha"; then
    printf 'stale baseline entry (no longer a violation): %s\n' "$base_sha"
    stale=$((stale + 1))
  fi
done <<<"$baseline_shas"

if [ "$known" -ne 0 ]; then
  printf '\n%d known pre-existing violating commit(s) in the baseline (reported, not failing).\n' "$known"
fi

if [ "$failures" -ne 0 ]; then
  printf '\n%d disallowed commit identity reference(s).\n' "$failures" >&2
  exit 1
fi

if [ "$known" -ne 0 ]; then
  printf 'No new violations.\n'
else
  printf '\nAll commits are on an allowed domain.\n'
fi
