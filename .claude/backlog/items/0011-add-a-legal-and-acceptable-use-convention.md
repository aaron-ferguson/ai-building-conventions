---
id: "0011"
title: Add a legal and acceptable-use convention for AI-assisted work
type: feature
next: design
status: ready
qa_level: verify
size: m
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0001"]
expects:
  - CONVENTIONS_CORE.md
  - git-conventions.md
  - README.md
claimed_by:
claimed_at:
touches:
---

## Problem

`git-conventions.md:24` mandates a co-authorship trailer on every AI-assisted commit:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

It is filed under **Git**, alongside commit message casing and branch naming — as though it were a
formatting preference. It is not. It is a claim about who wrote the code, recorded permanently in
the public history of every repo that follows these conventions, and there is an unsettled legal
question behind it.

> "Legal, e.g. acceptable use, whether things like 'Co-Authored with …' must be in the commit
> message (there is kind of behind-the-scenes serious discussion in the Tech world about copyright
> laws, some company are religious about mandating Co-Authored … stuff while in some developers are
> trying to 'hide' that they used LLMs… the core issue being whether Agent-written code … could be
> copyrighted and current sentiment in the industry is that it can if Agents are used as co-workers
> and potentially not if Agents write all the code, hence saying 'Co-Authored…' in the commit
> message implies that you did the work with ____ assistance)"
> — email thread *AI Building Conventions*, 2026-08-14

So the suite's current posture is probably right and definitely unexplained. A rule whose reason is
not written down is a rule the next person deletes as noise, or applies inconsistently — and the
inconsistency is what would matter, because a history where the trailer appears on some AI-assisted
commits and not others is worse evidence than either consistent practice.

The wider gap is acceptable use: what an agent may be pointed at, what it may not, and who decides.
The suite covers privacy egress and secrets thoroughly and says nothing about the rest.

## Open design question  *(only while `next: design`)*

- **Question:** what is this repo's actual position, and how much of it is a *convention* rather
  than a company policy the convention should defer to?
  The line matters because the repo is `company: none` and public. A universal, defensible
  position — attribute AI assistance consistently, and state why — belongs here. "Which uses are
  sanctioned at your employer" does not; it belongs behind the company-profile extension point that
  `companies/_template.md` already defines.
- **Sub-questions:**
  - Does the trailer stay mandatory, and is the reason recorded as *provenance and honest
    attribution* or as *copyright posture*? They imply different edge-case answers — a commit an
    agent wrote entirely, a commit where an agent only reformatted.
  - Is there a case for recording the *degree* of assistance rather than its presence, given the
    reviewer's point that the industry distinction is co-worker versus sole author?
  - What does acceptable use cover here beyond what `security-conventions.md` and
    `data-privacy-conventions.md` already say, without becoming a second copy of them?
- **Why it blocks specification:** whether the deliverable is a paragraph moved and explained, or a
  new convention file with a company-profile hook, turns entirely on this. And the answer is a
  legal-posture judgement — `CONVENTIONS_CORE.md` lists product and security judgement as things
  not to delegate to AI, and this is squarely that.
- **Settle it with:** `/design`, with Aaron making the call rather than an agent proposing one.

## Functional requirements

Re-derived once the decision lands. These hold under any answer:

- FR1 — The co-authorship trailer's **reason** is recorded where the rule is stated, so it reads as
  a posture rather than a formatting preference.
- FR2 — The rule says what to do in the edge cases the reason implies — at minimum, a change an
  agent produced end to end, and a change where a human wrote the code and an agent only reviewed
  it. A rule that only covers the ordinary case is applied inconsistently in the cases that matter.
- FR3 — Acceptable use is addressed at the level this repo can own — universal and
  company-agnostic — and anything company-specific is deferred to the profile extension point in
  `companies/_template.md` rather than written here. This repo is public; a company's policy in a
  tracked file is a published policy.
- FR4 — `CONVENTIONS_CORE.md`'s AI Workflow section points at whatever this produces, with a
  trigger.
- FR5 — The position is stated as a position, with its uncertainty intact. The underlying copyright
  question is genuinely unsettled, and a convention that asserts a settled answer will be wrong in
  one direction or the other.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Privacy & data | The acceptable-use content must not weaken the existing egress line, and must contain no company policy — the repo is public | `data-privacy-conventions.md` |
| Security | Anything said about what an agent may be pointed at has to be consistent with the existing standing-access and secrets rules, not a parallel statement of them | `security-conventions.md` |
| Documentation | Cite, never restate; and the reasoning lands in the same change as the rule | `documentation-conventions.md` |
| Deprecation | If the trailer's wording or requirement changes, existing histories are not retroactively wrong — say so, or every past commit becomes ambiguous evidence | `deprecation-conventions.md` |

## Acceptance criteria

Re-derive with the design answer; un-tick anything the re-specification touches.

- [ ] AC1 — Given the co-authorship rule, when it is read, then its reason is stated at the point
      of the rule.
- [ ] AC2 — Given the rule, when the two edge cases in FR2 are looked up, then each has a stated
      answer.
- [ ] AC3 — Given every tracked file changed by this item, when read, then none names a company,
      a company policy, or an internal tool.
- [ ] AC4 — Given `companies/_template.md`, when read, then it carries the extension point any
      company-specific acceptable-use policy plugs into.
- [ ] AC5 — Given `CONVENTIONS_CORE.md`, when its AI Workflow section is read, then it points at
      the new content with a trigger.
- [ ] AC6 — Given the copyright rationale, when read, then it is stated as the current unsettled
      position it is, not as established law.

## QA plan

- **Level:** verify — prose, no runner.
- **Why this level:** nothing executes.
- **Specific checks:** `scripts/check-convention-links.sh`; `scripts/check-machine-specifics.sh`
  once 0002 has landed; AC3 read by hand, and AC6 read by hand — "does this overclaim" is a
  judgement, and naming it as one is more honest than a grep that would pass either way.

## Out of scope

- **Legal advice, and any assertion about what the law is.** The deliverable is a stated posture
  and its reasoning, explicitly marked as such. If Aaron wants a position that binds anyone at a
  company, that is a conversation with that company's counsel and it does not happen in a public
  repo.
- Licence choice for this repo. Related, genuinely separate, and not what the reviewer raised.

## Notes & decisions

- **The current posture is probably already correct** — the trailer is mandated, which is the
  conservative side of the industry split the reviewer describes. What is missing is the reason,
  the edge cases, and the acceptable-use half. That is why this is Tier 4 rather than higher:
  nothing is bleeding, and the practice in place is the defensible one.
