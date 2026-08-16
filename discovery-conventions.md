# Discovery Conventions

This file defines how an idea earns the right to be built. It is loaded into AI context when a task proposes new work, evaluates a request, sizes an opportunity, plans research, or builds a prototype.

The failure this prevents is the most expensive one available: a well-engineered product nobody needed. Every convention in this repo makes building *correct* — this file is about building the *right thing*, and it runs before them.

Scope split: this file owns deciding **whether and what** to build. `product-definition-conventions.md` owns turning that decision into something buildable. `measurement-conventions.md` owns proving afterwards whether the bet paid.

---

## Nothing Gets Built Without a Stated Problem

Before any work starts, three things are written down — a few sentences, not a document:

- **The problem**, stated as the user's situation, not as a solution. "Clerks re-key case data from three systems" is a problem; "we need a bulk import screen" is a solution wearing a problem's clothes.
- **Who has it** — a specific role or segment, not "users." If you can't name who, you don't know yet.
- **The evidence they have it**, and how strong it is.

"A customer asked for it" is a data point, not evidence — it tells you one person's proposed solution, not how many people have the underlying problem or what it costs them. Ask what they were doing when they hit it.

## Weight Evidence by What It Actually Proves

In descending order of strength:

1. **Observed behavior** — what people already do, including the workarounds they built. A spreadsheet maintained by hand for two years is the strongest signal there is.
2. **Historical behavior** — usage data, support tickets, sales-loss reasons, churn interviews.
3. **Stated experience** — what people say they *did* and how it went. Reliable about the past.
4. **Stated intent** — what people say they *would* do, or would pay. Weak, and systematically over-optimistic. Never the sole basis for a build decision.
5. **Our conviction** — the weakest. It is a hypothesis, and it gets labelled as one.

A build decision resting entirely on rungs 4–5 is a bet. Bets are allowed; pretending they are evidence is not.

## Test the Riskiest Assumption First

List what has to be true for this to work, then rank by *what would hurt most if false*. Four kinds of risk, and they are not equally likely to be the killer:

- **Value** — will anyone actually use or buy it? Usually the riskiest, and usually the least tested.
- **Usability** — can they figure it out?
- **Feasibility** — can we build and run it at the required scale, cost, and latency?
- **Viability** — does it work for the business: pricing, support load, legal, contractual obligations?

**Test the top-ranked one with the smallest artifact that could kill the idea** — an interview, a clickable prototype, a spreadsheet model, a hand-run manual version of the service, a feasibility spike timeboxed to days. Build the artifact that answers the question, not the artifact that demonstrates the solution.

## A Prototype Is Built to Be Thrown Away

**A prototype that ships is a defect, not a shortcut.** It carries no tests, no error handling, no authorization model, and no migration path, and every one of those absences becomes a production surprise months later, usually at the worst moment.

- Prototypes are for **learning**: to answer a named question, then be deleted or archived.
- Say the question out loud before building one, and stop when it's answered — prototypes expand to fill the time available.
- Prototype code is exempt from TDD and the coding conventions **only for as long as it stays a prototype.** The moment anyone proposes shipping it, it is rewritten under `testing-conventions.md` and `coding-conventions.md`, not promoted.
- If schedule pressure makes "just ship the prototype" tempting, that pressure is the argument for writing the decision down (`documentation-conventions.md`), not for skipping the rewrite.

## Write the Kill Criteria Before the Test

Decide *in advance* what result would make you stop, and what result would make you proceed. Written afterwards, any result looks encouraging.

- State the threshold concretely: how many of how many, by when.
- **"Keep going and gather more data" is not a criterion** — it's the absence of one.
- Killing an idea on evidence is a success of the process. Record it (`documentation-conventions.md`) so the same idea doesn't return in six months with no memory of why it lost.

## Size the Opportunity Before Committing

Rough numbers beat no numbers, and both beat precise numbers derived from nothing:

- **How many** have the problem, **how often** they hit it, **what it costs them** today.
- **What it costs us** — build, plus the part people forget: support, hosting, and the maintenance of every branch this adds forever.
- **What it displaces.** Capacity is finite; the real question is never "is this worth doing" but "is this worth doing *instead of* the alternatives."

## Discovery Is Continuous; the Commit Is a Gate

Discovery isn't a phase that ends when development begins — evidence keeps arriving from support, usage, and sales for the life of the product. What is a gate is the **decision to build**: it happens once, deliberately, with the problem, evidence, riskiest assumption, and kill criteria in front of you.

New evidence that contradicts the premise is a reason to stop mid-build. Sunk cost is not a counter-argument.

## Research Data Is Personal Data

Interview recordings, transcripts, session recordings, and survey responses are personal data and often contain a third party's confidential information too.

- They fall under `data-privacy-conventions.md` in full: consent, minimum collection, retention limits, and redaction before anything leaves your boundary — including before it reaches an external model.
- Recruit and store participants' details deliberately, not in whatever tool was handy.

## What AI Does and Doesn't Do Here

- **Does:** synthesize transcripts and tickets, find patterns across sources, draft interview guides and survey instruments, model opportunity sizing, argue the opposite case, and build throwaway prototypes fast.
- **Doesn't:** decide which problem is worth solving, judge what customers value, or supply the evidence. An AI-generated market rationale with no source underneath it is fabrication, and it is convincing enough to survive a review that isn't looking (`coding-conventions.md` — what not to delegate; `ai-product-conventions.md` — ground answers in sources).
- Every claim in a discovery write-up is traceable to a source or explicitly marked as an assumption.

## By Project Scale

The principles don't flex — a weekend project built on an untested assumption is still wasted weekends. Ceremony does:

- **Personal / solo:** the whole of this file can be five sentences in a decision record. Write them anyway; the act of writing "what would prove me wrong" is where most of the value is.
- **Real users:** evidence-gathering becomes a habit rather than an event — a standing channel from support and usage data into the backlog.
- **Contracted or enterprise-scoped work:** the commitment often precedes the discovery. That inverts the risk: discovery's job becomes finding out what was actually promised, what the customer's real workflow is, and what data they are sitting on — before the design assumes any of it (`data-conversion-conventions.md`).

## Company & Project Overrides

Research tooling, participant recruitment and incentive rules, whether customer contact requires an account owner's approval, and any regulated-industry limits on subject research are company-specific (see `companies/_template.md`) and may only tighten what's here.
