---
id: "0002"
title: Sweep tracked files for machine-specific paths, current state, and real project names
type: bug
next: verify
status: ready
qa_level: unit
size: s
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0001"]
expects:
  - mcp-conventions.md
  - git-conventions.md
  - documentation-conventions.md
  - CLAUDE.md
  - scripts/check-machine-specifics.sh
  - scripts/check-machine-specifics.test.sh
claimed_by:
claimed_at:
touches:
---

## Problem

Three tracked files on a public remote carry content this repo's own rules forbid. Verified
2026-08-26, line numbers current:

- **`mcp-conventions.md:107–114`** — an `## Established Tokens` table. Two defects in one artifact:
  it is **current state living in a durable document**, which `documentation-conventions.md`
  specifically rules out, and its *Used In* column names a real project
  (`mcp-conventions.md:111`). The line `Update this table as new tokens are added` is the tell —
  a document that asks to be kept in sync with reality is an inventory wearing a convention's
  clothes. The same file already gets this right 15 lines earlier, telling the reader to *"record
  the provider's expected token shape in the private repo that owns that integration, not here."*
- **`mcp-conventions.md:141`** — Option B asserts the GitHub plugin is *"already installed at
  `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/github/`"*. That is a
  fact about one machine stated as a fact about any machine, and it is wrong on every reader's.
- **`git-conventions.md:16`** — an example commit message, `Rename package to mandata`, carries a
  real project name into a tracked file.

The reviewer flagged all three:

> "The established tokens table is current state living in a durable document, which is precisely
> the failure the documentation file describes. It also names a real project, and the section above
> it documents a machine specific plugin path."
> — email thread *AI Building Conventions*, 2026-08-14

Together with 0001 these are the same root cause seen three times: the repo's public-and-generic
constraint is stated once, in `CLAUDE.md`, and nothing checks any instance of it.

## Functional requirements

- FR1 — The `## Established Tokens` table is removed from `mcp-conventions.md`. In its place the
  file states where a project's actual token inventory belongs — the private repo that owns the
  integration — matching the answer the same file already gives for token shape.
- FR2 — `mcp-conventions.md`'s Option B no longer asserts an absolute plugin path. It describes how
  a reader locates the installed plugin on their own machine, so the instruction holds on any
  machine and OS.
- FR3 — No example in `git-conventions.md` carries a real project name.
- FR4 — `scripts/check-machine-specifics.sh` fails on any tracked file containing an absolute home
  path (`/Users/…`, `/home/…`) or a path under `~/.claude/plugins/`, printing file and line. It
  must **not** flag the documented settings paths (`~/.claude/settings.json`,
  `.claude/settings.local.json`) that legitimately appear in `claude-code-model-config.md` and
  `mcp-conventions.md` — a check that cries wolf on correct content gets disabled.
- FR5 — That script has `scripts/check-machine-specifics.test.sh` beside it per this repo's
  sibling-test pattern, with a case for each half: a disallowed path exits non-zero, and a file
  containing only the legitimate settings paths exits zero.
- FR6 — `CLAUDE.md`'s Environments block names the new check alongside
  `scripts/check-convention-links.sh` in the same "before finalizing an edit" bullet
  (`CLAUDE.md:49`).
- FR7 — `documentation-conventions.md` gains a line making "no real project name and no
  machine-specific path in a tracked file" part of what an edit here is checked against, since FR4
  cannot detect the project-name half (see *Out of scope*).

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Privacy & data | The removed table and the project names are content published to a public remote; the replacement text must name no project and no machine | `data-privacy-conventions.md` |
| Security | Removing the token table must not remove the *secret-handling* guidance around it — the storage, rotation and verification sections of `mcp-conventions.md` are the file's reason to exist and stay untouched | `security-conventions.md` |
| Documentation | The current-state-in-a-durable-document rule is the one being enforced here; cite it rather than restating it, and land FR7 in the same change | `documentation-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given `mcp-conventions.md`, when `grep -c 'Established Tokens'` is run, then the count
      is 0.
- [ ] AC2 — Given `mcp-conventions.md`, when `grep -ci 'traitors'` is run, then the count is 0.
- [ ] AC3 — Given `mcp-conventions.md`, when `grep -c 'marketplaces/claude-plugins-official'` is
      run, then the count is 0.
- [ ] AC4 — Given `git-conventions.md`, when `grep -c 'mandata'` is run, then the count is 0.
- [ ] AC5 — Given `mcp-conventions.md` after the edit, when the secret-store section is read, then
      the storing, rotating and verifying guidance is intact and the file still tells the reader
      where a real token inventory belongs.
- [ ] AC6 — Given `scripts/check-machine-specifics.sh` run over a fixture containing
      `/Users/someone/x`, when it completes, then it exits non-zero and prints that file and line.
- [ ] AC7 — Given the same script run over a fixture containing only `~/.claude/settings.json`,
      when it completes, then it exits zero.
- [ ] AC8 — Given the whole repo, when `scripts/check-machine-specifics.sh` is run with no
      arguments, then it exits zero.
- [ ] AC9 — Given `CLAUDE.md:49`'s verification bullet, when it is read, then it names
      `scripts/check-machine-specifics.sh`.

## QA plan

- **Level:** unit — the deliverable includes a script, and this repo's runner is the
  sibling-`.test.sh` pattern.
- **Why this level:** no runtime, no seam; the doc assertions are greps run alongside.
- **Specific checks:** `config.yml`'s `unit` command for AC6–AC7; the literal greps in AC1–AC4 and
  AC9; `scripts/check-convention-links.sh` after the edits, because FR1 and FR2 delete text that
  other files may reference.

## Out of scope

- **Detecting real project names automatically.** There is no set of project names this repo owns,
  so any grep list would be false the day a new project exists, having read green the whole way.
  FR7 puts the rule where a reviewer reads it instead; that is the honest ceiling for this half.
- The corporate email in commit metadata — that is 0001, and the two are deliberately separate
  because one edits files and the other edits git config and history policy.

## Notes & decisions

- **Why the fixture-based ACs.** AC6 and AC7 name fixtures rather than real repo files so the check
  stays provably red-capable after AC8 makes the real repo clean. A guard whose only evidence is a
  clean repo is a guard nobody has seen fail (`testing-conventions.md`).
- **Fixtures must be independent of the tree** — build them under the scratchpad or a temp dir the
  test creates, not by pointing at a repo file that a later edit will change out from under the
  test.
- **Scoping decision, not in the FRs: `check-machine-specifics.sh` excludes `.claude/`.** FR4 reads
  "any tracked file", but `.claude/backlog/items/0002-*.md` and `0006-*.md` quote real absolute
  paths as part of describing the bugs they're about (this ticket's own Problem section, and 0006's
  worked example of a machine-specific `@import`) — exactly the content a bug report about paths
  has to quote. Scanning the whole repo literally would fail AC8 today on that quoting, not on a
  live leak. Treated `.claude/` as tooling/self-management rather than "the conventions this repo
  publishes" (`CLAUDE.md`: "This repo *is* the conventions"), the same boundary
  `check-convention-links.sh` already draws around `.git`/`node_modules`. FR7's documented rule
  still applies there on manual review; only the automated sweep is scoped out.
- **The checker also had to exclude itself and its own test.** Both name the patterns and a fixture
  path (`/Users/someone/x`, `~/.claude/plugins/...`) in prose and test cases in order to prove the
  guard works, and a blunt `grep` cannot tell that from a real leak — confirmed by running the
  checker over the whole repo and watching it flag its own lines first.
- **CLAUDE.md's own new sentence about the guard tripped the guard.** Describing what
  `check-machine-specifics.sh` catches by writing the literal `~/.claude/plugins/` pattern into the
  verification bullet made that bullet itself a match. Rephrased to name the mechanism
  ("an installed-plugin path") rather than the pattern. Same shape as the checker excluding its own
  source — a guard's prose about itself is not exempt from itself just because it's true.
