# Measurement Conventions

This file defines how a product change proves whether it worked. It is loaded into AI context when a task defines a success metric, adds analytics or product instrumentation, plans an experiment, or reviews a launch's results.

Scope split: `observability-conventions.md` owns whether the **system** is healthy — errors, latency, saturation, the signals you want during an incident. This file owns whether the **product** is working — whether behavior changed and whether the bet paid off. They answer different questions and are often confused; a feature can be perfectly healthy and completely unused.

---

## The Success Measure Is Declared Before the Build

- Written into the definition (`product-definition-conventions.md`) as **a number and a date**: what will be true, for whom, by when. "Adoption improves" is not a measure; "60% of active clerks file at least one case through the new flow within 30 days of rollout" is.
- **Declared in advance, or it isn't a measure.** A metric chosen after the results are in will be the one that looks best — reliably, and usually without anyone intending it.
- **Name the guardrails at the same time**: what must *not* get worse. Nearly every feature can improve its own metric by degrading something else — support volume, error rate, time-to-complete elsewhere, cost per transaction.
- **If you can't state how you'd know it worked, that's a discovery gap, not a measurement gap.** Go back (`discovery-conventions.md`).

## Measure Outcomes, Not Output

- **Output** — we shipped it. Says nothing about value, and is the easiest thing to celebrate.
- **Adoption** — people found and used it. Necessary, not sufficient.
- **Outcome** — the behavior or situation actually changed: less re-keying, fewer failed filings, faster resolution. This is the one the definition promised.
- **Impact** — the business result: retention, expansion, cost, win rate. Slow, noisy, and rarely attributable to one change — track it, don't pretend one feature moved it.

Report the outcome. A launch summary that only reports output is a status update, not a result.

## Instrumentation Ships With the Feature

- **In the same change, not a follow-up ticket.** The follow-up doesn't happen, and by the time anyone asks how the feature is doing the answer is "we can't tell" — which costs a full measurement window to fix.
- **A feature that can't be measured isn't done** (`product-definition-conventions.md` — definition of done).
- **Verify the events fire before release**, in a real environment, the same way you'd verify any other behavior. Silent instrumentation failure looks exactly like "nobody used it," and it is a genuinely common way to kill a feature that was working.

## Events Are a Contract

Analytics data is consumed by dashboards, reports, and decisions that outlive the code that emits it. Treat the event schema with the discipline of `api-conventions.md`:

- **Named consistently and documented** — one naming convention, defined once, in a schema in the repo. Ad-hoc event names are unusable within a year, and nobody ever cleans them up.
- **Typed and validated at the boundary**, like any other contract.
- **Additive changes only.** Renaming or re-purposing an event breaks every historical comparison silently — the reports keep rendering, they're just wrong. This is `migration-conventions.md`'s expand/contract, applied to analytics.
- **A change to an event's meaning is a versioned change**, and the dashboards that read it are the callers.

## No Personal Data in Analytics

- **PII never lands in analytics, logs, or traces** — this is already a hard rule (`data-privacy-conventions.md`), and analytics is where it most often leaks, because event properties are added casually and third-party analytics is an egress path.
- **Identify by stable pseudonymous identifiers**, not names, emails, or case data. Free-text fields are never sent as event properties; someone will eventually type something sensitive into one.
- **Analytics vendors are processors** — sending data to one is data leaving your boundary, and it is subject to the same rules as any other external transfer, including consent where the regime requires it (`data-privacy-conventions.md`). Where a company profile forbids external egress, that governs, and self-hosted measurement is the answer.

## Read Results Honestly

- **Segment by rollout cohort.** During progressive rollout, aggregate numbers mix exposed and unexposed users and will mislead you in whichever direction is most flattering (`progressive-delivery-conventions.md`).
- **Wait for the window you declared.** Reading early and stopping when the number looks good is how noise gets shipped as a finding.
- **Novelty and recency distort early numbers** — first-week usage of anything new is not a run rate.
- **Correlation is not the claim.** Without a control or a genuine before/after with nothing else changing, the honest phrasing is "consistent with," not "caused."
- **Small numbers stay small numbers.** Percentages over a handful of users are theatre; report the count.

## The Verdict Gets Recorded

- **At the declared date, someone writes down the result and the decision**: it worked and we invest more, it partly worked and here's the next slice, or it didn't work and here's what we're doing about it. A decision record is the right home (`documentation-conventions.md`).
- **"It didn't work" is the most valuable entry in the file** — it is the only thing that stops the same idea being rebuilt in eighteen months, and the only reason anyone will trust the ones that say it worked.
- **A feature that didn't deliver its outcome is a candidate for removal**, not a permanent maintenance cost. That's a deprecation decision (`deprecation-conventions.md`), and it should be a normal one.

## Don't Instrument What You Won't Look At

Every event is code to maintain, storage to pay for, and a privacy surface to review. Instrument the questions you have actually committed to answering, and delete instrumentation for questions that stopped mattering — this is YAGNI applied to data (`coding-conventions.md`). A dashboard nobody has opened in six months is not evidence of a measurement culture.

## AI Features Are Measured Differently

Model-backed features need quality measurement alongside product measurement: eval pass rates, refusal and fabrication rates, human-override rate, and cost and latency per call (`ai-product-conventions.md`). **The override rate is the honest product metric** — how often a human rejected what the model produced tells you more than any satisfaction score.

## By Project Scale

- **Personal / solo:** the success measure can be one sentence and the instrumentation a counter. Declaring it up front is the part that matters, and it costs nothing.
- **Real users:** an event schema in the repo, cohort-aware reporting, and a recorded verdict per launch.
- **Contracted or enterprise-scoped work:** the customer often defines the success measure in the agreement. Find it, restate it in terms you can instrument, and confirm the restatement — before build, not at acceptance.

## Company & Project Overrides

Analytics tooling and hosting, event naming conventions, dashboard ownership, and whether measurement data may leave the company boundary at all are company-specific (see `companies/_template.md`) and may only tighten what's here.
