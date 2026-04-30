# AI-Assisted Development Conventions

This file defines how to write code effectively when working alongside AI coding tools (Claude Code, Copilot, Cursor, etc.). It is loaded into AI context at the start of every session via each project's CLAUDE.md.

---

## Write Code AI Can Reason About

AI coding tools produce significantly better output when the code they read is clear and explicit. The following practices improve both AI output quality and human readability — they are not in tension.

### Use Types

Prefer typed code in all new work. TypeScript over JavaScript; Python with full type hints; Go and Rust natively.

- Types are the cheapest form of documentation — they tell the AI exactly what a value is without requiring it to trace the runtime.
- Untyped code forces the AI to infer types from usage, which produces more errors.
- If adding to an existing untyped codebase, type the module you are touching.

### Keep Related Code Co-located

AI tools have finite context windows. Code that requires importing many files to understand produces worse completions than code where everything relevant is nearby.

- Vertical slice organization (see `ARCHITECTURE_CONVENTIONS.md`) is the structural expression of this principle.
- Avoid patterns where a single logical operation is spread across deeply nested inheritance chains or many indirection layers.
- A longer, explicit function is usually better than a short one that requires tracing several levels of abstraction to understand.

### Small, Well-Named Functions

The AI uses function names as strong signals for what code does. Descriptive names reduce hallucination.

- Prefer many small functions with precise names over fewer large ones.
- A function named `buildJiraAdfFromIssueDescription` tells the AI everything; `processData` tells it nothing.
- This reinforces the Single Responsibility principle in `CODING_CONVENTIONS.md`.

---

## Tests as Specification

Write tests before implementation when working with AI. Tests become the contract the AI codes against.

- A failing test with a clear name is the most precise instruction you can give an AI.
- AI-generated code that passes your tests is verifiably correct against your specification.
- This makes TDD more valuable, not less, when using AI tools.

See `TESTING_CONVENTIONS.md` for testing standards.

---

## Review AI Output Like a Junior Engineer's PR

AI-generated code is confident, fluent, and sometimes subtly wrong. Treat every AI-generated diff as a PR from a smart junior who may have missed a constraint.

- Does this match the intent, or just the letter of the instruction?
- Are there edge cases the AI didn't handle?
- Does this introduce any security vulnerabilities (injection, over-permissioning, exposed secrets)?
- Does this follow the conventions in this repo, or did the AI default to its own style?

Never ship AI-generated code without reading it. Test coverage is the primary defense against accumulated AI errors.

---

## What Not to Delegate to AI

AI tools are poor at:
- **Architectural decisions** — they generate plausible architecture that fits common patterns, not your specific constraints.
- **Security-sensitive design** — always review auth flows, credential handling, and access control yourself.
- **Judgment calls about what to build** — that is product thinking, not code generation.

Use AI for: implementation within a defined structure, boilerplate, refactoring to a known pattern, test generation for known behavior.
