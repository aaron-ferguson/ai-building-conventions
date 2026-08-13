# Product Definition Conventions

This file defines how a validated problem becomes something buildable. It is loaded into AI context when a task writes or reviews requirements, acceptance criteria, a ticket, an epic, or a scope decision.

Scope split: `discovery-conventions.md` decides *whether* to build. This file decides *what exactly*, and hands `testing-conventions.md` something it can write a failing test against. A definition that can't be turned into a failing test isn't finished.

---

## One Unit of Work, One Outcome

Every ticket, story, or epic states:

- **The outcome** — the change in the user's situation, in their words. Not the feature, the change: "a clerk files a case without re-keying party data," not "add party autofill."
- **The non-goals** — what this deliberately does not do. Scope is defined by its edges; an unstated edge is an argument waiting to happen mid-build, usually with the estimate already given.
- **How we'll know it worked** — the success measure, with a number and a date (`measurement-conventions.md`).
- **The link back to the evidence** (`discovery-conventions.md`). A requirement that traces to nothing is a signal to stop and ask where it came from — it's usually someone's solution, inherited without its problem.

## Acceptance Criteria Are Observable and Testable

- Written as **observable behavior**: given this state, when this happens, then this is true. Anything that requires opening the implementation to check is not an acceptance criterion.
- **No unfalsifiable criteria.** "Intuitive," "fast," "robust," "user-friendly" are not criteria — replace them with the observable thing meant: a task completed without help, a p95 under 400ms, a specific recovery from a specific failure.
- **Criteria are the input to TDD.** They become the failing tests, so vagueness here becomes untested behavior later.
- **The unhappy paths are criteria too**, and they are the ones that get dropped: what happens on invalid input, on a permission the user lacks, on a timeout, on an empty result, on the second concurrent attempt.

## Define the States, Not Just the Success Case

A definition that only describes the happy path guarantees the rest gets invented under deadline by whoever picks it up. Name explicitly:

- **Empty, loading, error, partial, and populated** for anything with an interface (`ui-conventions.md`).
- **Permissions** — who can see it, who can do it, and what someone without the permission sees.
- **What happens to data already in the system** that predates this change (`migration-conventions.md`).
- **Volume and scale** — how many of these will exist, how fast they arrive, how large one can get. "It works with my three test records" is where performance surprises are born.

## Non-Functional Requirements Are Requirements

They get written into the definition, not discovered in review:

- Performance budget, data retention and deletion behavior (`data-privacy-conventions.md`), audit expectations (`product-readiness-conventions.md`), accessibility conformance (`accessibility-conventions.md`), and what has to be logged for support to answer a question about it (`observability-conventions.md`).
- **Name the data this creates**: what is stored, its classification, who owns it, how long it lives, and whether it must be exportable (`data-conversion-conventions.md`).

## Slice Vertically and Thinly

- A slice is **the thinnest path that delivers the outcome end to end** — data, logic, and interface — not a horizontal layer (`architecture-conventions.md`). "Build the API this sprint, the UI next" delivers nothing testable by a user until both land.
- **If it can't be finished in a few days, it isn't a slice yet** — split by user, by case, by data volume, or by stripping the outcome to its narrowest real version. Splitting by technical layer is not splitting.
- **Cut scope, not quality.** Under pressure, the correct move is fewer slices done to standard, never all slices with tests, error handling, or accessibility removed. That trade is the one that compounds.

## MVP Means Minimum *Viable*

The most-abused term in the lifecycle, and the source of the surprises this repo exists to prevent.

- **An MVP is the smallest thing a real user can rely on to get a real outcome** — under the full standard of these conventions: tested, secure, observable, accessible, with a migration path and a way to get data out.
- **It is not a prototype with customers on it.** The distinction is not polish; it is whether anyone depends on it. Once someone does, `release: released` applies and everything that follows from that applies with it (`environment-conventions.md`).
- Minimum applies to **scope** — fewer use cases, fewer configurations, narrower segment. It never applies to correctness or safety.
- What *is* deliberately deferred gets written into the project's CLAUDE.md as a decision, with the trigger that reopens it. Deferred-and-recorded is a plan; deferred-and-forgotten is the surprise.

## Definition of Ready and Definition of Done

Two short, project-specific lists, kept honest:

- **Ready** — the outcome, non-goals, acceptance criteria, states, and success measure exist, and the open questions are answered. Work that starts un-ready gets its definition invented mid-build by whoever is closest.
- **Done** — merged, tested per `testing-conventions.md`, instrumented per `measurement-conventions.md`, documented per `documentation-conventions.md`, and behind a flag if it's user-facing on a released project (`progressive-delivery-conventions.md`). Not "the code works on my machine."

## What AI Does and Doesn't Do Here

- **Does:** draft criteria from a stated outcome, enumerate the edge cases and states a definition is missing, spot criteria that can't be tested, split an oversized slice, and challenge a definition for internal contradictions. This is one of the highest-value uses available — AI is markedly better at *completeness* than most humans under deadline.
- **Doesn't:** decide the scope, the priority, or the trade-off. Those are product judgment (`coding-conventions.md`).
- Treat an AI-drafted definition as a draft with unmarked assumptions in it — read it for the things it quietly decided.

## By Collaboration Mode

- **Solo:** definitions can be terse, but they are still written *before* building, not reconstructed after. You are the one who'll misremember the non-goals.
- **Collaborative:** the definition is reviewed by someone other than the author before work starts — the cheapest review in the lifecycle, and the one most often skipped (`cicd-conventions.md`).

## Company & Project Overrides

Ticket format, estimation practice, workflow states, and required fields are company-specific (`companies/<name>/`) and are **preferences**. What a definition must contain — outcome, non-goals, testable criteria, success measure — is a principle.
