# AI Product Conventions

This file defines conventions for building products and features that incorporate AI (LLMs, embeddings, agents). It is loaded into AI context when a task builds or changes an AI feature — not every session. `CONVENTIONS_CORE.md` (always loaded) carries the AI-workflow essentials; load this file for the full detail.

These are principles — they apply to every AI feature regardless of collaboration mode. The *company-specific* limits they defer to (which model providers are approved for which data, contractual retention terms, residency) live in the company profile (`companies/<name>/`). With no company profile, apply the strict defaults noted below.

A framing to keep throughout: an LLM is a *fluent, confident, non-deterministic* component that will occasionally be wrong in ways that read as right. Every convention here exists because that combination breaks assumptions traditional software lets you make.

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

## Structured Output Is a Contract

When code consumes a model's output, that output has a schema — enforce it, don't hope for it.

- Define the expected output as a schema (JSON Schema, a typed struct, a validation model) and validate every response against it before anything downstream touches it.
- Use the provider's structured-output / tool-calling / JSON-mode features to constrain generation — don't parse freeform prose with regex.
- A response that fails validation is a handled failure: retry with feedback, or fall back — never pass an unvalidated blob forward.
- The boundary between the model and your code is a trust boundary (`security-conventions.md`). Model output is untrusted input; validate it like anything user-supplied.

---

## Ground Answers in Sources; Refuse to Fabricate

For any feature where correctness matters — and in legal/judicial products it always does — an ungrounded, confident answer is the most dangerous output the system can produce.

- **Cite or abstain.** If a claim can't be traced to a retrieved source, the feature says so or declines — it does not fill the gap with a plausible invention. A fabricated fact is not a bug to fix later; it is a trust-destroying failure and, in a professional context, a potential liability.
- Answers that reference authority must carry the source (document, section, record ID) so a human can verify it. An unverifiable citation is treated as no citation.
- Prefer extractive/grounded generation over free recall for factual claims. RAG (below) exists partly to make grounding checkable.
- Build evals specifically for hallucination: inputs where the correct behavior is "I don't have that" or "cannot determine from the provided sources." Reward abstention; penalize confident fabrication harder than a miss.
- Surface uncertainty to the user honestly. A calibrated "I'm not sure — verify here" beats a confident wrong answer every time in a domain where the user will act on it.

---

## RAG Before Fine-Tuning

Default to Retrieval-Augmented Generation (RAG) for grounding model responses in specific knowledge.

- RAG is cheaper to update: add or remove documents without retraining.
- RAG is easier to debug: you can inspect what context was retrieved.
- RAG failures are usually retrieval failures, not model failures — easier to diagnose and fix. When an answer is wrong, check what was retrieved before blaming the model.

Fine-tune only when:
- RAG demonstrably cannot provide the required response quality.
- The task requires a specific behavior or tone that cannot be achieved via prompting.
- Latency constraints make retrieval infeasible.

---

## Redact Before the Model Sees It

Sending data to a model is a data-egress event, not an internal function call (`data-privacy-conventions.md`).

- Send the minimum the model needs. Strip or tokenize PII and sensitive fields that aren't essential to the task.
- **Whether a class of data may be sent to a given provider is a company-profile decision**, governed by the contract with that provider (zero-retention / DPA / BAA). With no company profile and no such contract, the default is: **no personal or sensitive data goes to an external model.**
- Self-hosted / in-boundary inference changes this calculus — but only for the specific data the boundary actually covers. Record which is which in the company profile.
- Never paste real secrets or sensitive records into an AI *development* conversation to "help debug" either — redact first.

---

## Guardrails on Input and Output

The model sits between untrusted input and consequential action. Both edges need defenses.

- **Prompt injection is real and unsolved.** Content retrieved from users, documents, or the web can contain instructions aimed at your model. Design so that injected instructions *cannot* trigger privileged actions — the model's authority is bounded by code, not by asking it nicely in the system prompt.
- Treat retrieved/user content as data, not instructions. Keep a clear separation between trusted system instructions and untrusted content in the prompt.
- Validate output before it acts: model output never flows unchecked into a shell, a query, an `eval`, a file write, or an API call with side effects (`security-conventions.md`).
- Apply content/safety checks appropriate to the domain on both input and output where the product warrants it.

---

## Human in the Loop for Consequential Actions

Autonomy is earned per action, based on the cost of being wrong.

- A model may draft, suggest, summarize, and retrieve freely. It does **not** unilaterally take a consequential or hard-to-reverse action — filing a document, sending an external communication, moving money, altering a record of legal significance — without a human approving the specific action.
- The reversibility rule from the rest of these conventions applies with extra force here: the more irreversible the action, the more explicit the human gate.
- Design the approval to be *meaningful*: show the human what will happen and the grounds for it, not a rubber-stamp "OK?". A human approving output they can't evaluate is not a safeguard.
- What counts as "consequential" is partly a company/compliance decision — record the required approval and sign-off gates in the company profile.

---

## Agents and Tool Use: Least Privilege and Bounded Autonomy

When a model can call tools, it can act — scope that ability tightly.

- Give an agent the **minimum toolset** for its task. A tool the agent doesn't need is attack surface and a way to be surprised.
- Each tool enforces its own authorization independently — never rely on the model to "decide" it's allowed. The permission check lives in the tool, server-side (`security-conventions.md`).
- Read tools and write tools are different risk classes. Default write/side-effecting tools to human-gated (above) unless the action is cheap and reversible.
- Bound the loop: cap iterations, tool calls, and spend per task so a confused agent fails safe instead of running away.
- Trace every tool call (below) — an agent you can't replay is an agent you can't debug or trust.

---

## Budget Cost and Latency Deliberately

Tokens are a recurring cost and latency is a UX property; neither manages itself.

- Know the per-request and per-user cost of an AI feature before it ships. A feature that's cheap in a demo can be ruinous at scale — model this the way you'd model any recurring cost.
- Right-size the model to the task. Use a smaller/cheaper model where evals show it suffices; reserve the largest models for the steps that actually need them. Model choice is a per-step decision, not one global setting.
- Use prompt caching, retrieval scoping, and output-length limits to control cost and latency — but only where they don't compromise grounding or correctness.
- Set budgets/limits so a runaway loop or a traffic spike can't produce an unbounded bill. Alert on cost the way you alert on errors.
- Streaming and partial responses are latency tools; use them for perceived speed, but don't let streaming skip the output validation above.

---

## Observability From Day One

AI systems fail silently in ways traditional systems do not. You cannot debug what you cannot observe. This is stricter than the baseline in `observability-conventions.md`.

Every LLM call must be traced with:
- Input (prompt + retrieved context)
- Output
- Model used (and version)
- Latency
- Token usage (and cost)
- For agents: the tool calls made and their results

Add tracing before the first production deploy, not after the first incident. Redaction still applies — trace what you need to debug without logging sensitive contents (`data-privacy-conventions.md`).

---

## Feature Flags on Model Versions

Treat a model upgrade the same way you treat a feature change: behind a flag, with the ability to roll back.

- Never hard-code a model identifier that cannot be changed without a deploy.
- Model upgrades can change behavior in ways evals don't catch — maintain the option to roll back instantly.
- Re-run the full eval suite against a new model version before promoting it. A newer or "better" model is still a regression risk for *your* task until the evals say otherwise.
- A/B testing model versions is a normal and expected workflow.

---

## Handle Non-Determinism Explicitly

LLM outputs vary across identical inputs. Design for this.

- Do not assert exact string equality on LLM outputs in tests — use evals with scoring criteria instead.
- Build retry logic for transient failures (rate limits, timeouts), not for outputs you dislike.
- Where determinism is required (structured data), enforce it via the schema-validation contract above — not by relying on model compliance.
- Surface model errors to users in a consistent, recoverable way — never let a model failure cascade silently.
