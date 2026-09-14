#!/usr/bin/env bash
#
# Verify no tracked file carries an absolute home path or a path under
# ~/.claude/plugins/ — content true of one machine, published on a public remote the
# moment it's committed.
#
# Excludes .git, node_modules and .claude/: the last is this project's own backlog and
# settings machinery, not the conventions this repo exists to publish, and a bug report
# living there sometimes has to quote the very path it is complaining about. Also excludes
# this script and its own test: both have to name the patterns and a fixture path in
# their prose and cases in order to test themselves, which a blunt grep cannot tell from
# a real leak.
#
# The documented, portable settings paths (`~/.claude/settings.json`,
# `.claude/settings.local.json`, `.claude/settings.json`) are never flagged — none of
# them is a path under ~/.claude/plugins/, so a correctly scoped pattern already leaves
# them alone without a separate allowlist.
#
# Usage: scripts/check-machine-specifics.sh [dir]
#   dir  defaults to this script's parent (the repo root)
#
# Exits non-zero and prints file:line for every match.

set -uo pipefail

usage() {
  sed -n '3,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${1:-$(dirname "$script_dir")}"

if [ ! -d "$target_dir" ]; then
  printf 'error: dir not found: %s\n' "$target_dir" >&2
  exit 2
fi
target_dir="$(cd "$target_dir" && pwd)"

failures=0

while IFS= read -r match; do
  [ -z "$match" ] && continue
  printf '%s\n' "$match"
  failures=$((failures + 1))
done < <(
  cd "$target_dir" &&
    grep -rnE '/Users/[A-Za-z0-9_.-]+|/home/[A-Za-z0-9_.-]+|~/\.claude/plugins/' \
      --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' --include='*.json' \
      --exclude-dir='.git' --exclude-dir='node_modules' --exclude-dir='.claude' \
      --exclude='check-machine-specifics.sh' --exclude='check-machine-specifics.test.sh' .
)

if [ "$failures" -ne 0 ]; then
  printf '\n%d machine-specific reference(s).\n' "$failures" >&2
  exit 1
fi

printf '\nNo machine-specific paths found.\n'
