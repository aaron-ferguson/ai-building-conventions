# Architecture Conventions

This file defines architectural decision defaults for all projects. It is loaded into AI context when a task involves a structural or architectural decision — not every session. Load it before choosing module boundaries, adding infrastructure, or deciding whether to extract a service.

---

## Default: Modular Monolith

Start every project as a modular monolith. Do not design for microservices speculatively.

- A modular monolith has clean internal boundaries (modules, domains) but deploys as a single unit.
- Internal module boundaries should be as strict as if they were service boundaries — explicit interfaces, no reaching into another module's internals.
- This gives you the option to extract services later without requiring it.

**Extract a service only when a demonstrated need exists:**
- A specific component needs to scale independently and the monolith cannot accommodate it.
- A separate team needs fully autonomous deploy cadence.
- A polyglot runtime requirement exists (different language or execution environment).

Do not extract services in anticipation of these needs. Premature decomposition is more expensive than a later extraction.

---

## File and Module Organization: Vertical Slices

Organize code by feature or domain, not by technical layer.

```
// Bad — layer-first
src/
  controllers/
    orders.js
    payments.js
  services/
    orders.js
    payments.js
  repos/
    orders.js
    payments.js

// Good — feature-first
src/
  orders/
    controller.js
    service.js
    repo.js
  payments/
    controller.js
    service.js
    repo.js
```

- Related code lives together. A change to one feature touches one folder, not three.
- Shared infrastructure (auth, logging, database client) lives in a `shared/` or `lib/` directory — not as a domain.
- Do not create a generic `utils/` dumping ground. Named utility modules are fine (`src/lib/pagination.js`); a catch-all `utils.js` is not.

---

## No Speculative Architecture

Apply YAGNI to architecture the same way you apply it to code.

- Do not add a message queue because "we might need async later."
- Do not add a caching layer because "performance might be a concern."
- Do not add an API gateway because "we might add more services."

Build the simplest thing that works. Add infrastructure when a specific, demonstrated problem requires it.

---

## When to Revisit

Flag this section for review when:
- A monolith component has a materially different scaling profile from the rest of the system and is causing real problems.
- A second team needs to own a domain and is blocked by shared deployment.
- A specific compliance or runtime requirement cannot be met within the monolith.
