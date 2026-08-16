# Data Privacy Conventions

This file defines how projects handle personal and sensitive data. It is loaded into AI context when a task touches user data, PII, logging, analytics, or sending data to a third party (including a model provider).

Security (`security-conventions.md`) is about keeping attackers out. Data privacy is about handling the data you're *trusted* with correctly, even when nothing is under attack. They overlap; both apply.

**Two axes.** The principles here are universal. The *specific* limits — which providers are approved for which data, residency, retention schedules, regulatory regimes — are company-specific and live in that company's profile (see `companies/_template.md`). When a project declares a company, its profile's limits are authoritative and tighter than these defaults. When it doesn't, apply the strict defaults below.

---

## Know What You Hold

- **Classify data at the point it enters the system.** Every input is one of: public, internal, personal (PII), or sensitive (health, financial, legal, biometric, credentials). You cannot protect data correctly if you don't know its class.
- The highest-classification field sets the handling bar for the record. One PII field makes the whole row PII.
- If you don't know a field's classification, treat it as sensitive until confirmed — never the reverse.

## Know Which Legal Regimes Bind You

Which laws and standards apply depends on jurisdiction, data type, and who the users are — so the *specific* binding set (with citations) lives in the company profile (see `companies/_template.md`), and for a personal project in its own CLAUDE.md. This determination is made **with legal counsel**, not by an engineer or an AI; the rules here are the floor, and a binding regime is almost always stricter. What the general baseline requires is that you *identify* which of these categories apply before building, not that you memorize any one of them:

- **Comprehensive privacy laws** — US state consumer-privacy laws (many states, thresholds and government/court-records exemptions vary) and, for any EU/UK residents' data, GDPR / UK GDPR.
- **Sector-specific law** — health (HIPAA, when PHI is in scope), financial (GLBA), education (FERPA), children's data (COPPA).
- **Domain-specific rules** — for justice/government work: criminal-justice information (CJIS Security Policy) and court-records access, sealing, and redaction rules, which are often stricter than general privacy law.
- **Breach notification** — statutory obligations exist regardless of the above; have a notification plan before you have users. The clock runs from *discovery*, not from the end of your investigation, which is why a suspected exposure escalates immediately rather than after you're sure (`incident-conventions.md`, Path B).
- **Payment data** — PCI DSS if card data is handled (contractual, but binding).
- **Professional duties** — e.g. attorney-client confidentiality obligations for legal products.
- **Contract** — DPAs, BAAs, and customer/agency contract terms, frequently the tightest constraint of all.

When a task introduces a new data class or destination, confirm the applicable regime is recorded in the profile — an unconfirmed obligation is treated as the stricter interpretation until counsel says otherwise.

## Collect the Minimum

- Collect only data the current feature needs. "We might analyze it later" is not a reason to collect it now — it's YAGNI applied to data, and unused sensitive data is pure liability.
- Prefer deriving over storing. If you can compute it from something you already hold, don't store a second copy.
- Every stored sensitive field is a question you'll have to answer in a breach, an audit, or a deletion request. Fewer fields, fewer questions.

## PII Never Lands in Logs, Traces, or Analytics

- Logs, error traces, and analytics events are low-trust, widely-readable, long-retained surfaces. Sensitive data does not belong in any of them.
- Log identifiers (a user ID, a record ID), never contents (name, email, case detail, token). See `observability-conventions.md`.
- This includes exception messages and stack-trace variables — scrub before they reach the error tracker.
- Redact at the boundary where data enters the logging path, not by hoping no one logs the wrong variable.

## Redact Before Data Leaves Your Boundary

- Any data sent to a third-party service — analytics, support tools, and **especially model providers** — leaves your control. Assume it may be retained, logged, or used for training unless a contract says otherwise.
- Before sending data to an external service, strip or tokenize anything not strictly required for that service to do its job.
- **Sending data to an LLM is a data-egress event, not an internal function call.** Whether a given class of data may be sent to a given provider is a company-profile decision (see `companies/_template.md`), governed by the contract with that provider (zero-retention / DPA / BAA). With no company profile and no such contract, the default is: **no personal or sensitive data leaves to an external model.** See `ai-product-conventions.md` for the redaction and grounding mechanics.

## Retention and Deletion Are Features, Not Afterthoughts

- Data has a lifecycle. Decide, when you first store a class of data, how long it lives and what deletes it — don't discover this during a legal request.
- Support deletion from the start if you hold personal data: a real path to remove a user's data, including from backups and downstream copies (analytics, caches, the model provider if applicable). Backups are the one people discover late — an unbounded backup archive silently defeats the retention policy in front of it (`infrastructure-conventions.md`).
- Default retention schedules are company- and often contract-specific — record them in the company profile.

## Least-Privilege Access to Data

- Access to personal/sensitive data is granted by need, not by convenience. Not every service, job, or teammate needs read access to the sensitive store. The system-level counterpart — production accounts, MFA, break-glass, audit trails — is in `security-conventions.md`.
- The server decides who sees what (`security-conventions.md` — "The Server Is the Authority"). Never ship sensitive data to a client that isn't authorized to see it and rely on the UI to hide it.
- Test/dev/staging environments use synthetic or anonymized data, never a copy of production personal data — and hold no production credentials that could reach the real store. This is a hard line, not a best-effort: a production dump on a developer laptop is a breach with a delay on it, and for regulated data it may be reportable regardless of intent. Mechanics and the seed-data expectation: `environment-conventions.md`.

## When to Do a Privacy Pass

Run a deliberate privacy review — beyond the normal checklist — when a change:

- Introduces a new class of personal or sensitive data, or a new field on an existing sensitive record.
- Sends existing data to a new destination (a new third party, a new model provider, a new analytics sink).
- Changes retention, deletion, or who can access a sensitive store.
- Adds an AI feature that reads personal or sensitive data. Pair this with the AI-specific rules in `security-conventions.md` and `ai-product-conventions.md`.
