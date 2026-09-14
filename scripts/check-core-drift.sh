#!/usr/bin/env bash
#
# Guard CONVENTIONS_CORE.md against drifting from the files it restates.
#
# CONVENTIONS_CORE.md restates roughly forty rules that also live in their own
# *-conventions.md files, each restatement ending in a pointer of the form
# `file-name.md` -> "Exact Heading Text". This checks the two things a human skim and
# `check-convention-links.sh` both miss:
#
#   1. Anchor resolution — the named heading must exist, literally, as a Markdown
#      heading (#, ##, ### or ####) in the file it points to. A source file that gets
#      restructured can leave a pointer aimed at a heading that no longer exists.
#   2. Staleness — no source file cited anywhere in the core may have a more recent git
#      commit than the core file itself. A newer source commit means the core's
#      restatement may no longer match what it claims to mirror.
#
# Usage: scripts/check-core-drift.sh [conventions_dir]
#   conventions_dir  defaults to this script's parent (the repo root); must contain
#                    CONVENTIONS_CORE.md
#
# Staleness is a git-history comparison, so it only means anything against committed
# work — run it after committing, not mid-edit. A file with no git history at all
# (untracked, or a fixture with no repository behind it) is skipped for staleness rather
# than failed, so only anchor resolution applies to it.
#
# Exits non-zero listing every unresolved anchor and every stale source file; exits 0
# with an all-clear message otherwise.

set -uo pipefail

usage() {
  sed -n '3,21p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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

core_file="$conventions_dir/CONVENTIONS_CORE.md"
if [ ! -f "$core_file" ]; then
  printf 'error: CONVENTIONS_CORE.md not found in %s\n' "$conventions_dir" >&2
  exit 2
fi

failures=0

report() {
  printf '  %s\n' "$1"
  failures=$((failures + 1))
}

# --- Extract every `file.md` -> "Heading" pointer ---------------------------------------
#
# Each match is self-contained — backticked filename, arrow, quoted heading — so one
# `grep -oE` over the whole file finds every pointer regardless of how many share a line
# or a parenthetical (a bullet citing two files writes two of these side by side).

pointer_pattern='`[A-Za-z0-9_.-]+\.md`[[:space:]]*→[[:space:]]*"[^"]+"'
pointers="$(grep -oE "$pointer_pattern" "$core_file" || true)"

if [ -z "$pointers" ]; then
  printf 'error: no `file.md` -> "Heading" pointers found in %s\n' "$core_file" >&2
  exit 2
fi

printf 'Checking anchors in %s\n' "$core_file"

# --- Pass 1: every anchor must resolve to a real heading in its source file ------------

while IFS= read -r pointer; do
  [ -z "$pointer" ] && continue
  file="$(printf '%s' "$pointer" | sed -E 's/^`([^`]+)`.*/\1/')"
  heading="$(printf '%s' "$pointer" | sed -E 's/.*"(.*)"$/\1/')"
  source_path="$conventions_dir/$file"

  if [ ! -f "$source_path" ]; then
    report "\`$file\` (pointed at \"$heading\") does not exist in $conventions_dir"
    continue
  fi

  headings="$(grep -E '^#{1,4}[[:space:]]+' "$source_path" | sed -E 's/^#{1,4}[[:space:]]+//; s/[[:space:]]+$//')"
  if ! printf '%s\n' "$headings" | grep -qFx -- "$heading"; then
    report "\`$file\` -> \"$heading\" does not resolve — no such heading in $file"
  fi
done <<<"$pointers"

# --- Pass 2: no cited source file may be newer, in git, than the core -------------------

distinct_files="$(printf '%s\n' "$pointers" | sed -E 's/^`([^`]+)`.*/\1/' | sort -u)"

core_ts="$(cd "$conventions_dir" && git log -1 --format=%ct -- "$(basename "$core_file")" 2>/dev/null || true)"

if [ -z "$core_ts" ]; then
  printf 'CONVENTIONS_CORE.md has no git history here — skipping staleness checks.\n'
else
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    source_path="$conventions_dir/$file"
    [ -f "$source_path" ] || continue # already reported above as an unresolved reference

    src_ts="$(cd "$conventions_dir" && git log -1 --format=%ct -- "$file" 2>/dev/null || true)"
    if [ -z "$src_ts" ]; then
      continue # no git history for this file — nothing to compare, skip gracefully
    fi

    if [ "$src_ts" -gt "$core_ts" ]; then
      report "\`$file\` was committed more recently than CONVENTIONS_CORE.md — the core may be stale"
    fi
  done <<<"$distinct_files"
fi

# --- Result ------------------------------------------------------------------------------

if [ "$failures" -ne 0 ]; then
  printf '\n%d drift issue(s) found.\n' "$failures" >&2
  exit 1
fi

printf '\nAll anchors resolve and no cited source is newer than the core.\n'
