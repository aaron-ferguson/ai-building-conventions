# Testing Conventions

This file defines testing expectations for all projects. The essentials are summarized in `CONVENTIONS_CORE.md` (always loaded); load this full file when a task involves writing or changing tests and needs the complete TDD cycle, isolation, and organization detail.

---

## Philosophy

- **TDD always:** write tests first → confirm red → implement → confirm green → commit. No exceptions for functional changes.
- **Failing tests are victories** — they catch bugs before users do. Never treat a test failure as a problem to paper over.
- **Never claim false success** — if a test fails, report it immediately and completely.
- **Run tests as part of the TDD cycle** — after implementing, run the scoped suite automatically. Reserve full-suite runs for explicit user requests.
- **Every bug fix starts with a failing test** — reproduce the bug in a test first → confirm red → fix → confirm green. The test stays as a permanent guard so the bug can never silently return. This is the single highest-leverage habit for stability.

## Test Levels

Aim for a pyramid: **many unit, some integration, few E2E.** Each level catches what the ones below it can't; using a higher level to test logic a lower one covers is the main source of slow, brittle suites.

- **Unit** — one module in isolation, dependencies mocked. Fast and deterministic; the bulk of coverage. This is where business logic, conditionals, and edge cases get exercised.
- **Integration** — the seams between units: a service against a real (test) database, a module against its adapter, an API route through to persistence. Catches what unit tests structurally cannot — wiring, contracts, serialization, migrations, transaction boundaries. Do **not** mock the boundary under test; mock only what lies beyond it (third-party network, clock, randomness).
- **E2E** — a handful of critical paths exercised end to end through the real entry point: a UI journey in a browser, a full CLI invocation, an API request flowing through to persistence and back (e.g. sign in → perform the core action → confirm the result). Slow and brittle by nature, so reserve them for paths whose breakage is unacceptable. Not a substitute for unit or integration coverage — if an E2E test is checking logic a unit test could, drop it down a level.

## Running Tests

- **Scope to the change** — run the minimum suite that validates the change; full-suite runs are expensive and rarely needed.
- **Green phase:** check exit code and failure lines only — don't review every line of output.

## Test Output

- **Lean by default** — configure test runners and reporters for minimal output: no per-test pass lines, no full stack traces on success, summary only. Verbosity should not increase token usage when everything is green.
- **Dig deeper on demand** — when a failure needs investigation, temporarily increase verbosity (e.g. `--reporter=verbose`, `--silent=false`, added `console.log`) to get the signal needed, then revert to lean defaults once resolved.
- **No test-internal logging by default** — do not add `console.log` or debug output inside tests unless actively troubleshooting. Remove it before committing.

## Background Process Cleanup

- **Stop what you started** — any long-running process spun up for testing (dev/app server, API server, database or emulator, container, headless browser) should be stopped when done, so it doesn't hold a port or resource on the next run.
- **How:** stop it in its own terminal (`Ctrl+C`), or kill it by match — `pkill -f "<the command you launched>"` on macOS/Linux, `Stop-Process` / `taskkill` on Windows. Match the specific command you started, not the whole runtime (kill `pkill -f "myapp serve"`, not every `node`/`python`/`java` process on the machine).
- **Why:** prevents "address already in use" / port-conflict and stale-state errors when starting the process again.

## Test Isolation

- **Isolate at the boundary** — tests must not depend on external state or running services. Mock or stub all dependencies beyond the unit or module under test.
- **The boundary moves with the level** — the rule above describes a *unit* test's boundary. An integration test's boundary sits further out: it keeps the seam it exists to verify (e.g. the real test database) and mocks only what lies beyond that. Never mock the thing you're trying to test.
- **Independent tests** — each test sets up its own state and cleans up after itself. No test should rely on execution order.

## Test Organization Principles

- **DO test:** business logic, complex conditionals, state management, CRUD operations, error handling, edge cases, win/loss conditions.
- **DON'T test:** simple DOM manipulation, pure delegating functions, static data constants, external library wrappers, animation/timer functions.
- **Adversarial mindset:** after writing happy-path tests, actively try to break your own code — boundary conditions (zero, null, max), invalid states, race conditions, failure modes.

## Coverage & Reliability

- **Coverage is a diagnostic, not a target** — use it to find untested branches and error paths, never as a number to chase. 100% coverage of trivial code is overkill; 70% that skips the failure modes is a gap. Judge by risk, not percentage.
- **Zero tolerance for flaky tests** — a test that passes and fails without a code change is worse than no test: it trains everyone to ignore red. Fix the nondeterminism or quarantine the test the moment it's spotted; never just re-run until green.

## The CI Gate

- **Green before merge** — once a project has CI, the suite passing is an un-skippable gate, not a courtesy. In collaborative mode no change merges red; solo, the same gate catches the mistake you'd otherwise push. The gate itself and how it's enforced by mode live in `cicd-conventions.md` — this file owns what the suite *is*, that file owns when it *blocks*.

## Advanced Techniques — Reference, Not Rule

These are **not** part of the default expectation. They're tools to reach for when a specific project crosses a threshold that makes them worth the cost — the Tier 3 "level up when the codebase matures" trigger in `coding-conventions.md`. Adopt one when its trigger below is real; don't add them speculatively (YAGNI applies to test infrastructure too).

- **Property-based testing** — when a function's correctness is a rule over a large input space (parsers, serializers, math, encoders), generate cases instead of hand-picking them. Trigger: you keep finding edge cases the examples missed.
- **Contract testing** — when independently deployed services must agree on a shape, pin the contract so one side can't break the other silently. Trigger: a real service boundary with separate release cadences.
- **Mutation testing** — when you need to know whether the *tests* are any good, not just whether they pass. It measures whether your suite actually catches injected faults. Trigger: coverage looks high but bugs still escape.
- **Fuzzing** — when untrusted input hits a parser or decoder and a crash is a security event. Trigger: you're handling adversarial input at a trust boundary (`security-conventions.md`).
- **Load / performance testing** — when latency or throughput is itself a requirement. Trigger: real-user scale, or an SLA. Lives with `observability-conventions.md`.

## Project Overrides

Any deviation from these defaults is declared in that project's CLAUDE.md and takes precedence.
