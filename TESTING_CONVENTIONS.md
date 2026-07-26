# Testing Conventions

This file defines testing expectations for all projects. It is loaded into AI context at the start of every session via each project's CLAUDE.md.

---

## Philosophy

- **TDD always:** write tests first → confirm red → implement → confirm green → commit. No exceptions for functional changes.
- **Failing tests are victories** — they catch bugs before users do. Never treat a test failure as a problem to paper over.
- **Never claim false success** — if a test fails, report it immediately and completely.
- **Run tests as part of the TDD cycle** — after implementing, run the scoped suite automatically. Reserve full-suite runs for explicit user requests.

## Running Tests

- **Scope to the change** — run the minimum suite that validates the change; full-suite runs are expensive and rarely needed.
- **Green phase:** check exit code and failure lines only — don't review every line of output.

## Test Output

- **Lean by default** — configure test runners and reporters for minimal output: no per-test pass lines, no full stack traces on success, summary only. Verbosity should not increase token usage when everything is green.
- **Dig deeper on demand** — when a failure needs investigation, temporarily increase verbosity (e.g. `--reporter=verbose`, `--silent=false`, added `console.log`) to get the signal needed, then revert to lean defaults once resolved.
- **No test-internal logging by default** — do not add `console.log` or debug output inside tests unless actively troubleshooting. Remove it before committing.

## Dev Server Cleanup

- **Stop the dev server after testing** — if you started a dev server for E2E or manual testing, stop it when done to prevent port conflicts on subsequent test runs
- **Command:** `pkill -f "npm run dev"` or manually stop the running process in its terminal
- **Why:** prevents "address already in use" errors when starting the dev server again

## Test Isolation

- **Isolate at the boundary** — tests must not depend on external state or running services. Mock or stub all dependencies beyond the unit or module under test.
- **Independent tests** — each test sets up its own state and cleans up after itself. No test should rely on execution order.

## Test Organization Principles

- **DO test:** business logic, complex conditionals, state management, CRUD operations, error handling, edge cases, win/loss conditions.
- **DON'T test:** simple DOM manipulation, pure delegating functions, static data constants, external library wrappers, animation/timer functions.
- **Adversarial mindset:** after writing happy-path tests, actively try to break your own code — boundary conditions (zero, null, max), invalid states, race conditions, failure modes.

## Project Overrides

Any deviation from these defaults is declared in that project's CLAUDE.md and takes precedence.
