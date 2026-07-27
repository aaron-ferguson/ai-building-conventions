# API Design Conventions

This file defines conventions for designing APIs — the contracts between your code and its consumers. It is loaded into AI context when a task creates or changes an endpoint, a public function signature, or a data contract crossing a module or service boundary.

An API is a promise. The cost of a bad internal function is a refactor; the cost of a bad *published* API is every consumer who now depends on the mistake. Design the contract deliberately.

---

## Design the Contract First

- Decide the inputs, outputs, and error shapes before implementing. The contract is the interface `coding-conventions.md` talks about, made external.
- Name resources and operations for what they are, exactly as you'd name functions and files. A consumer should be able to guess the endpoint.
- Keep the surface small. Every endpoint, field, and parameter is something you'll support. YAGNI applies to API surface with extra force — you can add a field later far more easily than you can remove one.

## Consistency Over Cleverness

- Pick conventions and apply them uniformly: resource naming, pluralization, casing, pagination, filtering, timestamps (ISO 8601, UTC). A predictable API is one a consumer can learn once.
- Use HTTP semantics as intended (for REST): correct methods, correct status codes, idempotent operations where the method implies it. Don't return `200` with an error body.
- The style choice (REST vs. GraphQL vs. RPC, casing, envelope shape) is a *preference* — pick one per project (or inherit the company's) and be consistent. Consistency is the principle; the specific style is the preference.

## Explicit, Validated Boundaries

- Every endpoint validates its inputs at the boundary and rejects bad input with a clear, structured error (`security-conventions.md` — external input is hostile until validated).
- Errors are part of the contract: return a consistent error shape (a machine-readable code plus a human-readable message), not ad-hoc strings that vary per endpoint. Never leak internals (stack traces, SQL) in an error response.
- Authorization is checked on every request, server-side, default-deny (`security-conventions.md`). The API never trusts the client's claim about who it is or what it may see.

## Versioning and Compatibility

- Once an API has a consumer you don't control, changes are either backward-compatible or versioned. Breaking a live consumer without a version bump is the cardinal API sin.
- Additive changes (new optional field, new endpoint) are safe. Removing or renaming a field, changing a type, or tightening validation is breaking — version it.
- Prefer the backward-compatible sequencing from `deployment-conventions.md`: ship the code that accepts both shapes, migrate consumers, then remove the old shape.

## Document at the Boundary

- A public API has reference documentation a consumer can use without reading your source — ideally generated from the contract (OpenAPI, GraphQL schema, typed client) so it can't drift.
- Document the auth model, error codes, pagination, and rate limits once, centrally. `documentation-conventions.md` applies: document the contract and the *why*, not a restatement of the code.

## By Collaboration Mode

- **Solo / internal-only:** the "consumer" is your own other module. Keep contracts clean and validated, but don't build formal versioning for an API only you consume — add it when a second, independent consumer appears (the same trigger as `coding-conventions.md` Tier 2).
- **Collaborative / published:** versioning, generated reference docs, and compatibility discipline are required from the first external consumer.

Company-specific API standards (gateway, auth scheme, required headers) live in the company profile.
