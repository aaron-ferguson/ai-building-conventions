---
id: "0001"
title: Stop publishing the corporate identity in this repo's commit metadata
type: bug
next: develop
status: in-progress
qa_level: unit
size: s
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0002"]
expects:
  - CLAUDE.md
  - scripts/check-commit-identity.sh
  - scripts/check-commit-identity.test.sh
claimed_by: "4c3b"
claimed_at: 2026-09-14T14:19:19Z
touches: [CLAUDE.md, scripts/check-commit-identity.sh, scripts/check-commit-identity.test.sh]
---

## Problem

This repo's `CLAUDE.md` declares `company: none` and states: *"Every tracked file here must stay
company-agnostic so the repo can be shared with a client, a collaborator, or a future employer …
no company name, product, person, or internal tooling in anything committed."* The remote is
public.

The rule says **tracked file**. Commit metadata is not a tracked file, and it is published too.
Verified 2026-08-26:

```
$ git log --format='%an <%ae>' | sort -u
aaron-ferguson <aaron@newheights.coach>
aaronferguson-neumo <aaron.ferguson@neumo.com>
```

So the repo's own headline constraint is violated by the mechanism it does not cover, and nothing
catches it. The reviewer put it together with the project names elsewhere in the repo (see 0002):

> "Every commit on the public remote is authored from a corporate email domain, while the repo's
> own CLAUDE.md declares no company and forbids any company detail from reaching a tracked file.
> Put that together with the project names in the handoff file and the association is trivial to
> make — commit metadata is published too."
> — email thread *AI Building Conventions*, 2026-08-14

The failure mode is not the individual address. It is that `company: none` was read as a rule
about file contents when it is a rule about **everything this repo publishes**, and a reader
following the rule as written would make the same mistake again.

## Functional requirements

- FR1 — This repo's local git config sets a `user.name` and `user.email` on a non-corporate
  domain, so commits made here from this machine carry no employer association regardless of the
  global git identity.
- FR2 — The `company: none` paragraph in `CLAUDE.md` is widened from tracked files to everything
  the repo publishes, naming commit author, committer, and message trailers explicitly. Closing
  the reasoning gap is the point; fixing only the config leaves the next person to rediscover it.
- FR3 — `scripts/check-commit-identity.sh` reports every commit reachable from `HEAD` whose author
  or committer email is outside an allowlist of permitted domains, printing the offending SHAs and
  exiting non-zero. The allowlist lives in the script, not in a convention file.
- FR4 — That script has `scripts/check-commit-identity.test.sh` beside it, per this repo's
  established sibling-test pattern, and the test contains a case that feeds a disallowed domain
  and asserts a non-zero exit — a guard only ever seen passing is indistinguishable from one wired
  to nothing (`testing-conventions.md`).
- FR5 — `CLAUDE.md`'s Environments block names the new check alongside
  `scripts/check-convention-links.sh`, so the verification step a session actually reads lists both.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Privacy & data | The author address is personal data and an employer association being published to a public remote. No newly published metadata may carry a company domain, and the check must not itself record the corporate address anywhere tracked — the allowlist states what is permitted, never what is forbidden by example | `data-privacy-conventions.md` |
| Documentation | The widened `company: none` rule lands in `CLAUDE.md` in the same change as the fix, not afterwards | `documentation-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given a commit newly made in this repo, when `git log -1 --format='%ae %ce'` is read,
      then neither address is on a company domain.
- [ ] AC2 — Given `CLAUDE.md`, when the `company: none` paragraph is read, then it names commit
      author and committer metadata as published output, not only tracked files.
- [ ] AC3 — Given `scripts/check-commit-identity.sh` run against a history containing a commit on a
      disallowed domain, when it completes, then it exits non-zero and prints that commit's SHA.
- [ ] AC4 — Given `scripts/check-commit-identity.sh` run against a history where every commit is on
      an allowed domain, when it completes, then it exits zero.
- [ ] AC5 — Given `scripts/check-commit-identity.test.sh`, when it is run, then it passes, and the
      file contains a case asserting the non-zero exit of AC3.
- [ ] AC6 — Given `CLAUDE.md`'s Environments block, when the verification bullet is read, then it
      names `scripts/check-commit-identity.sh`.

## QA plan

- **Level:** unit — the deliverable is a script, and this repo's runner is the sibling-`.test.sh`
  pattern already used by `check-convention-links.sh`.
- **Why this level:** integration has no seam to cross here; there is no runtime.
- **Specific checks:** run `config.yml`'s `unit` command (all `scripts/*.test.sh`). Then
  `git log -1 --format='%ae %ce'` on a fresh commit for AC1, and
  `grep -c 'check-commit-identity' CLAUDE.md` for AC6.

## Out of scope

- **Rewriting the existing published history.** The commits are already on a public remote, and
  the reasoning is recorded below: a rewrite does not un-publish them, and it is Aaron's call, not
  an agent's. AC3 is written against a constructed history precisely so this item stays provable
  without it.
- Anything about the *other* identity (`aaron@newheights.coach`). It is not a company domain and
  is out of what the rule covers.

## Notes & decisions

- **Why forward-only.** Rewriting history on a public GitHub remote does not retract what was
  published: existing clones, forks, and GitHub's own cached and unreachable-object refs keep the
  old commits addressable by SHA long after a force-push. So the rewrite buys presentation, not
  privacy, and costs every downstream clone. Treated as a decision to surface rather than an action
  to take.
- **Why the check runs over history rather than as a commit hook.** A hook is per-machine and this
  repo's whole complaint (0006) is that it assumes one machine. A script in `scripts/` runs
  anywhere the repo is cloned. If 0004 lands hook infrastructure, wiring this script into it is
  cheap and belongs to that item.
- **The test fixture almost repeated the exact defect this ticket fixes.** The first draft of
  `check-commit-identity.test.sh` used the real corporate domain as its disallowed-domain fixture —
  publishing the company association in a tracked file on this public remote, which is precisely
  what `CLAUDE.md`'s widened `company: none` paragraph (FR2) now forbids. Caught before commit and
  replaced with `disallowed.example`; AC3 only requires *a* disallowed domain, not the real one.
  Worth a grep (`grep -rn '<company>' --exclude-dir=.git`) on any future ticket that has to
  construct a "bad" example of something this repo's own rules forbid.
- **FR1 (local git identity) is config, not a commit** — `git config --local user.name/user.email`
  in this checkout, verified by `git log -1 --format='%ae %ce'` on the commit that landed FR2/FR5
  (`a09caa8`). It only protects commits made from this machine; a clone with its own global
  identity still needs the same local override, which `check-commit-identity.sh` cannot enforce —
  it can only catch a corporate identity that already landed in history.
