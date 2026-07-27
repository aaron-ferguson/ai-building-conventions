# Observability Conventions

This file defines how a running system makes itself understandable — logging, error tracking, and metrics. It is loaded into AI context when a task touches logging, error handling in production paths, or instrumentation.

The rule of thumb: **you should be able to reconstruct what happened from the outside, without adding code and redeploying.** If diagnosing a production problem requires you to add a log line and ship it, your observability was insufficient before the incident.

Scope note: `deployment-conventions.md` says *that* a project needs error tracking and logs before it has users. This file says *how* to do logging, errors, and metrics well. AI-specific tracing (prompts, tokens, model, latency per call) is in `ai-product-conventions.md` and is stricter — this is the baseline underneath it.

---

## Structured Logs, Not Prose

- Log structured events (key–value / JSON), not interpolated sentences. `{event: "order_failed", orderId, reason}` is queryable; `"Order 123 failed because ..."` is not.
- Every log line carries enough context to be understood alone: what happened, which entity (by ID), and a correlation ID that ties together all events from one request or job.
- Use levels deliberately: `error` = something needs a human; `warn` = degraded but handled; `info` = notable state change; `debug` = off in production. If everything is `info`, nothing is.
- **Never log secrets or PII** (`security-conventions.md`, `data-privacy-conventions.md`). Log the record ID, never the record contents. This is a hard line, including in exception messages and stack-trace locals.

## Errors Reach a Human Without a User Reporting Them

- Wire an error tracker (Sentry or equivalent) before the first real users arrive, not after the first incident.
- An unhandled exception in a production path is a defect that must surface to you automatically, with the stack trace, correlation ID, and enough scrubbed context to reproduce.
- This is the same discipline as "fail loudly" (`coding-conventions.md`) extended to production: a swallowed error you can't see is worse than a crash you can.
- Distinguish *expected* handled conditions (a validation rejection) from *unexpected* failures (a null where there shouldn't be one). Only the latter should page or alert.

## Measure What You'd Want in an Incident

Instrument the few signals you'd reach for when something is wrong — no more:

- **Rate** — how often the core operations run.
- **Errors** — how often they fail.
- **Duration** — how long they take (track a percentile, e.g. p95, not just an average — averages hide the tail that users feel).

Add a metric when you have a question it answers. Don't build a dashboard of vanity numbers nobody acts on — that's the observability form of speculative code.

## Health and Smoke Signals

- Expose a health check that reflects real readiness (can it reach its database and critical dependencies?), not a hardcoded `200 OK`.
- The post-deploy smoke check (`deployment-conventions.md`) should be observable: if the core action fails right after a deploy, your logs and error tracker should already show it before you go looking.

## By Collaboration Mode

The baseline above applies to every project — a solo project with real users needs error tracking exactly as much as a team's does; silent failures don't care how many developers there are. What flexes:

- **Solo / pre-users:** local structured logging is enough; wire the error tracker as soon as anyone but you depends on the app.
- **Collaborative / production:** error tracking and the core rate/error/duration signals are required before launch, with alerting routed to whoever is on the hook.

Specific tools, retention, and alert routing are company-specific — record them in the company profile (`companies/<name>/`).
