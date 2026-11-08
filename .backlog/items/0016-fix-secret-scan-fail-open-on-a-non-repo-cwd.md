---
id: "0016"
title: Fix scan-staged-for-secrets.sh failing open when cwd exists but isn't a git repo
type: bug
next: develop
status: ready
qa_level: unit
size: s
created: 2026-09-26
source: agent
parent:
blocked_by: []
relates: ["0004"]
expects:
  - hooks/scan-staged-for-secrets.sh
  - hooks/scan-staged-for-secrets.test.sh
claimed_by:
claimed_at:
touches:
---

## Problem

`hooks/scan-staged-for-secrets.sh` fails closed on a missing dependency (`jq`/`git`) and on a
`cwd` that does not exist (FR7/AC10 of item 0004), but not on the narrower case of a `cwd` that
**exists and simply isn't a git working tree**.

Reproduced live while verifying 0004 (2026-09-26, token `af71` — see that item's QA evidence,
*"Residual scope gap found while probing"*): fed the hook a real temp directory (exists, no
`.git`) as `cwd` alongside a `git commit` command envelope. `git diff --cached` (line 67 of the
script) fails inside the hook; its `2>/dev/null || true` swallows the error, `diff_output` comes
back empty, and line 68's `[ -n "$diff_output" ] || exit "$ALLOW"` reads that as "nothing staged"
and exits 0 — silently, with no message, on exactly the class of condition FR7's own text names
("a condition it cannot evaluate") as a fail-closed trigger.

Judged in 0004's verification not to block that ticket's close, because this coincides with cases
where the guarded `git commit` itself would also fail (no repo to commit into), so it doesn't look
like an exploitable bypass on its own — but it is the one sub-case of "unscannable cwd" the shipped
code doesn't cover, and per `security-conventions.md`'s landed principle ("A Security Control That
Cannot Run Blocks"), an unscannable cwd should refuse exactly like a missing dependency does.

## Functional requirements

- FR1 — Distinguish "`git diff --cached` found nothing staged" from "`git diff --cached` could not
  run" — currently both produce an empty `diff_output` and read identically at line 68. Check
  `git -C "$repo_dir" rev-parse --is-inside-work-tree` (or the diff command's own exit status,
  captured rather than discarded by `|| true`) before treating an empty result as "nothing
  staged."
- FR2 — When `repo_dir` is not a git working tree, refuse with a message naming the path and
  citing `security-conventions.md`, in the same style as the existing missing-dependency and
  missing-directory refusals.
- FR3 — The existing behavior is unchanged for every case already covered: no match found in a
  real repo still allows (exit 0); a genuine secret match still refuses (exit 2); a missing `jq`,
  missing `git`, or nonexistent `cwd` still refuses exactly as today.

## Non-functional requirements

| Dimension | Requirement for this item | How it would red | Convention |
|---|---|---|---|
| Security | The fix must not weaken the existing fail-closed behavior for the cases FR3 protects | any of item 0004's AC5/AC6/AC10 regresses | `security-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given a real temp directory that exists but has no `.git`, when fed as `cwd` alongside
      a `git commit` command, then the hook exits 2 (refuse) and names the path.
- [ ] AC2 — Given a real git repository with nothing staged, when the hook runs, then it still
      exits 0 (allow) — FR1's distinction must not turn "nothing staged" into a false refusal.
- [ ] AC3 — Given a real git repository with a staged secret-shaped match, when the hook runs,
      then it still exits 2 and names the file and line (0004's AC5, unchanged).
- [ ] AC4 — Given the hook's `.test.sh`, when the `unit` command runs, then all existing cases
      still pass and a new case covers AC1.

## QA plan

- **Level:** unit — extends `hooks/scan-staged-for-secrets.test.sh`, matching 0004's pattern.
- **Why this level:** a pure input-to-verdict function over a `cwd` string and a staged diff.
- **Specific checks:** `config.yml`'s `unit` command; also drive AC1 live per 0004's verification
  precedent (a stubbed real temp directory, not just the test harness), since 0004's own QA
  evidence notes the value of testing the actual shipped script rather than only its test file.

## Out of scope

- Any other class of "unscannable cwd" beyond "exists but not a git repo" — FR7's text is broader
  than this ticket's scope; this fixes the one specific gap found, not a general audit (that is
  its own item, 0017).

## Notes & decisions

- 2026-09-26 — Filed by `retro`, draining `.claude/backlog/FINDINGS.md` (2026-09-26). The bug and
  its root cause were already fully diagnosed in item 0004's own QA evidence (verified 2026-09-26,
  token `af71`) but not filed as a ticket there, per *A stage writes only the ticket it holds* —
  `verify` correctly recorded what still needed filing without filing it itself. This ticket is
  that filing.
