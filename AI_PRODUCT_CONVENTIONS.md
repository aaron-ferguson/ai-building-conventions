# AI Product Conventions

This file defines conventions for building products and features that incorporate AI (LLMs, embeddings, agents). It is loaded into AI context at the start of every session via each project's CLAUDE.md.

---

## Evals Are the New Unit Tests

LLM behavior is non-deterministic. Traditional pass/fail unit tests are insufficient for validating AI features. Evaluations are the primary quality gate.

- Every AI feature must have an eval suite: a set of (input, expected output or scoring criteria) pairs.
- Evals run on every model change, prompt change, or context change — just as tests run on every code change.
- An eval failure is a regression. Treat it the same way.
- Tools: LangSmith, Langfuse, Braintrust, or a simple custom eval harness.

Do not ship an AI feature without evals. "It looked good in testing" is not a quality gate.

---

## Prompts Are Code

Prompts are versioned, reviewed, and deployed like any other artifact.

- Prompts live in source control — not in a database, not hardcoded in a function body as an unreviewed string.
- Prompt changes go through the same review process as code changes.
- A prompt has a version. When you change it, the old version is recoverable.
- Document the intent of a prompt the same way you document a complex function: what it does, what constraints it operates under, what it must not do.

---

## RAG Before Fine-Tuning

Default to Retrieval-Augmented Generation (RAG) for grounding model responses in specific knowledge.

- RAG is cheaper to update: add or remove documents without retraining.
- RAG is easier to debug: you can inspect what context was retrieved.
- RAG failures are usually retrieval failures, not model failures — easier to diagnose and fix.

Fine-tune only when:
- RAG demonstrably cannot provide the required response quality.
- The task requires a specific behavior or tone that cannot be achieved via prompting.
- Latency constraints make retrieval infeasible.

---

## Observability From Day One

AI systems fail silently in ways traditional systems do not. You cannot debug what you cannot observe.

Every LLM call must be traced with:
- Input (prompt + context)
- Output
- Model used
- Latency
- Token usage

This is not optional for production systems. Add tracing before the first production deploy, not after the first incident.

---

## Feature Flags on Model Versions

Treat a model upgrade the same way you treat a feature change: behind a flag, with the ability to roll back.

- Never hard-code a model identifier that cannot be changed without a deploy.
- Model upgrades can change behavior in ways evals don't catch — maintain the option to roll back instantly.
- A/B testing model versions is a normal and expected workflow.

---

## Handle Non-Determinism Explicitly

LLM outputs vary across identical inputs. Design for this.

- Do not assert exact string equality on LLM outputs in tests — use evals with scoring criteria instead.
- Build retry logic for transient failures (rate limits, timeouts), not for outputs you dislike.
- If determinism is required for a specific output (e.g. structured JSON), enforce it via output parsing and validation, not by relying on model compliance.
- Surface model errors to users in a consistent, recoverable way — never let a model failure cascade silently.
