---
id: "0006"
title: Decide how the conventions are distributed and make them machine-portable
type: feature
next: design
status: ready
qa_level: verify
size: l
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0004", "0007"]
expects:
  - README.md
  - CLAUDE.md
  - CONVENTIONS_CORE.md
  - companies/_template.md
claimed_by:
claimed_at:
touches:
---

## Problem

The conventions are wired into a project by an `@` import of an **absolute path**. The parent
`CLAUDE.md` reads:

```markdown
## Conventions
@/Users/aaronferguson/Documents/AI/ai-building-conventions/CONVENTIONS_CORE.md
```

That works on exactly one machine, for one username, on one OS. Anyone else who clones the public
repo gets a set of documents with no supported way to make a session load them, and the repo's own
`README.md` is the only thing standing in for an install path.

> "Currently looks like single-user tailored, references paths that work on just your machine …
> Consider: Structuring this such that you can have a repo checked out to .claude top-level
> directory with relative paths that work on my machine too. Alternatively, if this is something
> we'd want to share company-wide you can publish it to marketplace as a plugin (automatic updates
> and all that jazz would work out of the box)."
> — email thread *AI Building Conventions*, 2026-08-14

Aaron's stated goal, in the same thread on 2026-08-21: *"This is a system for me to make my AI
usage well-based in principles. I'm trying to organize it in a way that it could be shared
(machine, OS, and company agnostic) but there are still some kinks to work out."*

So the **goal** is settled — portable by design, personal for now — and the **mechanism** is not.
This compounds quietly: every new project wired up adds another absolute path that a future move
has to find and rewrite, which is the same class of problem the repo already hit once when the
directory moved out of iCloud.

## Open design question  *(only while `next: design`)*

- **Question:** how does a project on an arbitrary machine acquire and load these conventions?
  1. **Checkout-relative** — the repo is cloned to a known location relative to the project (a
     sibling directory, or inside `.claude/`), and every import is a relative path. No
     distribution machinery, works offline, and the reader can see exactly what they got. Updates
     are a manual `git pull`, and every project needs the clone in the right place.
  2. **Claude Code plugin, published to a marketplace** — install once, automatic updates,
     versioned, and it is the mechanism that also carries hooks (0004) and Skills (0007). Costs a
     packaging step and a release process, and it puts a distribution channel between the reader
     and the text.
  3. **Both** — the plugin is the supported path and the checkout is the fallback for anyone who
     wants the files without the machinery.
- **Why it blocks specification:** the answer decides whether the deliverable is a documented
  directory layout with relative imports, or a plugin manifest with a version and a release step.
  It also decides where 0004's hooks and 0007's Skills are *installed from*, which is why 0007 is
  blocked on this one.
- **What the decision does not need to settle:** whether this becomes a company-wide distribution.
  The reviewer asked that twice and the answer above is "personal now, portable by design" —
  enough to choose a mechanism. Anything that would only be needed for a company rollout
  (ownership, review process, an internal marketplace) stays out.
- **A constraint:** `CLAUDE.md` records that the local `gh` is a write-level collaborator on the
  public remote and that GitHub answers admin operations with a misleading `404`. Any option
  needing a release, a tag, or a settings change on the remote has to account for being done in
  the web UI as the owner.
- **Settle it with:** `/design`.

## Functional requirements

Re-derived once the decision lands. These hold under every option:

- FR1 — A project on a machine that is not Aaron's can wire itself to these conventions by
  following `README.md` alone, with no path edited to match a username, a home directory, or an OS.
- FR2 — `README.md`'s wiring section gives the install and the update path, and states what happens
  when the conventions move — the failure this repo already survived once.
- FR3 — No wiring instruction in a tracked file contains an absolute home path. This is the same
  guard 0002 builds; this item must leave that check passing rather than reintroducing the class.
- FR4 — This repo's own `CLAUDE.md` profile block is updated if the chosen mechanism changes what
  `company:`, `collaboration:` or `release:` mean for a distributed artifact — a plugin that other
  people install is no longer a repo with no deployable environments, and the Environments block
  currently asserts that it is.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | The install path is the README's job and lands in the same change | `documentation-conventions.md` |
| Dependencies | Whatever mechanism wins, adopting these conventions must not require installing a package manager or a runtime this repo does not already assume | `dependency-conventions.md` |
| Deprecation | If option 1 ships and is later replaced by option 2, projects wired the old way need a replacement path and notice — decide now whether the first mechanism is the one being committed to | `deprecation-conventions.md` |
| Privacy & data | The published artifact is public; the packaging step must not sweep in a company profile, a local settings file, or anything `.gitignore` currently keeps out | `data-privacy-conventions.md` |

## Acceptance criteria

Re-derive with the design answer; un-tick anything the re-specification touches.

- [ ] AC1 — Given a clean machine with a different username and no prior setup, when `README.md`'s
      wiring instructions are followed literally, then a session in a test project loads
      `CONVENTIONS_CORE.md`.
- [ ] AC2 — Given every tracked file, when `scripts/check-machine-specifics.sh` is run, then it
      exits zero, including over the new wiring instructions.
- [ ] AC3 — Given `README.md`, when the wiring section is read, then it states the update path and
      what to do when the conventions directory moves.
- [ ] AC4 — Given `CLAUDE.md`, when the Profile and Environments blocks are read, then they are
      consistent with what the repo now ships.

## QA plan

- **Level:** verify — the deliverable is documentation and layout; no runner applies.
- **Why this level:** the one genuinely executable assertion, AC1, is a manual walkthrough on a
  second machine or a fresh user account, which no suite in this repo can drive.
- **Specific checks:** `scripts/check-machine-specifics.sh` and
  `scripts/check-convention-links.sh` for AC2; AC1 walked by hand and its result written into
  *Notes & decisions*, since a wiring instruction that has never been followed by anyone but its
  author is untested.

## Out of scope

- **A company-wide rollout** — ownership, an internal marketplace, a review process for changes.
  The stated audience is personal-and-portable; building for a rollout nobody has asked for is the
  speculative work `CONVENTIONS_CORE.md` rules out under YAGNI.
- Moving the Skills or hooks themselves. This item decides the *channel*; 0007 and 0004 decide what
  travels through it.

## Notes & decisions

- **Why this outranks the Skills refactor** even though the reviewer raised Skills first: the
  Skills question is "what shape does a rule take", and its answer depends on where rules are
  installed from. A prerequisite outranks its dependent.
- **AC1 is the whole item.** Every other criterion can pass while the repo is still unusable by
  anyone else; only a walkthrough on a machine that is not Aaron's proves the goal was met.
