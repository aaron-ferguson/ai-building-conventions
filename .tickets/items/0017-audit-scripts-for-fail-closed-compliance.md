---
id: "0017"
title: Audit this repo's scripts for compliance with "a security control that cannot run blocks"
type: chore
next: develop
status: ready
qa_level: verify
size: s
created: 2026-09-26
source: agent
parent:
blocked_by: []
relates: ["0004", "0013", "0016"]
expects:
  - scripts/check-convention-links.sh
  - scripts/check-core-drift.sh
  - scripts/check-machine-specifics.sh
claimed_by:
claimed_at:
touches:
---

## Problem

The owner's 2026-09-21 ruling on item 0004 — *"Security is much more important than frustration,
and someone who does not want to take security seriously can use a different toolkit"* — landed as
a general principle in `security-conventions.md` ("A Security Control That Cannot Run Blocks") and
is cited from `CONVENTIONS_CORE.md`. That ticket's own Notes & decisions name the scope explicitly:
*"every guard in this suite needs auditing against this rule, and any dependency a security hook
needs becomes a hard prerequisite rather than an optional enhancement."*

Only the two hooks item 0004 built (`block-sweeping-git-stage.sh`, `scan-staged-for-secrets.sh`)
have actually been checked against the rule — and one of them, `scan-staged-for-secrets.sh`, was
still found to have a gap after that check (see item 0016). The remaining scripts under
`scripts/` (`check-convention-links.sh`, `check-core-drift.sh`, `check-machine-specifics.sh`) have
never been read against this question. `check-commit-identity.sh` is excluded — its own
fail-open-vs-intentional question is item 0013's, a design decision rather than an audit finding.

## Functional requirements

- FR1 — For each of `check-convention-links.sh`, `check-core-drift.sh`, and
  `check-machine-specifics.sh`: identify every point where the script could fail to complete its
  check (a missing dependency, an unreadable file, a `2>/dev/null || true` or similar swallowed
  error) and state, for each, whether the current behavior on that failure is "blocks" or "allows
  silently."
- FR2 — Where a script currently allows silently on a condition it cannot evaluate, either fix it
  to block (matching the pattern in `hooks/scan-staged-for-secrets.sh`'s dependency checks) or
  record in this ticket's Notes & decisions why that script's failure mode is not a security
  control in the sense the rule addresses — these are consistency/drift checkers over the repo's
  own documentation, not gates on a live action, and the rule's applicability to that class of
  script is itself part of what this audit settles.
- FR3 — Where FR2 finds a real gap and fixes it, the fix carries its own test case in that script's
  existing `.test.sh`.

## Non-functional requirements

| Dimension | Requirement for this item | How it would red | Convention |
|---|---|---|---|
| Documentation | The audit's findings (covered / gap-and-fixed / not-applicable-and-why) are recorded per script | a reader of this ticket cannot tell what was checked | `documentation-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given this ticket's Notes & decisions, when read, then each of the three named scripts
      has a stated verdict: blocks correctly, fixed, or not-applicable-with-reason.
- [ ] AC2 — Given any script fixed under FR2, when its `.test.sh` runs, then a new case exercises
      the failure condition and asserts the refusal.
- [ ] AC3 — Given the full `unit` command, when it runs after this ticket's changes, then it is
      green.

## QA plan

- **Level:** verify — the audit itself is a read-and-judge pass with no single mechanical check;
  any FR2 fixes are covered by their own `.test.sh` cases at `unit` level.
- **Why this level:** "does this failure mode count as a security control" is a judgment call per
  script, not something a runner decides.
- **Specific checks:** read each script in full against FR1's question; run `unit` after any fix.

## Out of scope

- `check-commit-identity.sh` — covered by item 0013's design decision instead.
- Any hook not yet written (item 0014's destructive-commands hook, item 0016's fix) — those carry
  their own fail-closed requirement in their own FRs, checked when they're built.

## Notes & decisions

- 2026-09-26 — Filed by `retro`, closing the "scope beyond 0004" half of the fail-closed lesson
  parked in `.claude/backlog/FINDINGS.md` (2026-09-21). The principle itself was already landed in
  `security-conventions.md` and `CONVENTIONS_CORE.md` by the session that closed 0004; this ticket
  is the follow-through the finding named but the writing session correctly did not perform itself
  (`CONCURRENCY.md` — *a stage writes only the ticket it holds*).
