# Company Profile — <Company Name>

> **This file is the interface, not a profile.** It documents what a company profile must
> contain. Real profiles do **not** live in this repo — each one lives in that company's own
> private repo, alongside that company's knowledge, and a project's CLAUDE.md names the path.
> A profile must **not reference any other company**, which is what lets you hand over the
> general conventions — or one company's repo — without leaking anyone else's.
>
> **Why profiles moved out.** They used to sit here under a gitignore. That was fail-open in
> two directions: one `git add -f` would have published them, and a fresh clone silently
> omitted them, so a session ran against general defaults while believing it had the
> company's constraints. A missing profile must be **loud**, and the only way to guarantee
> that is for it to live somewhere the conventions repo cannot pretend to have.
>
> **Policy, not secrets.** Credentials still live in the OS secret store (`mcp-conventions.md`),
> never in a profile. A profile records *constraints and decisions*, so even if it leaked it
> would expose policy, not keys.

A project opts in via its CLAUDE.md, which **must** give the resolvable path:

```markdown
## Profile
- collaboration: collaborative
- company: <name>
  # profile: <path-to-company-repo>/config/<name>-profile.md
```

**Resolution is fail-closed.** If `company:` names a company and the profile is not at the
declared path, **stop and say so** — never continue on general defaults. Running with the
wrong constraints while reporting nothing is the failure this arrangement exists to prevent.

When a project declares a company, the general conventions still apply in full. This profile does two distinct things to them:

- **Adds constraints / tightens defaults** — for *principles* (correctness- and safety-based rules). A profile can only make these stricter, never looser.
- **Overrides preferences** — for conventions where the general repo picked one reasonable default among equals (e.g. git branching strategy). A company may substitute its own equally-valid house choice.

Precedence for an overridable preference: **project CLAUDE.md > this profile > general default** (most-specific wins). Principles sit above all of it and cannot be overridden by anyone. See `CONVENTIONS_CORE.md` → "How overrides work".

---

## 1. Data & privacy constraints

The general principles are in `data-privacy-conventions.md`. This section records the company-specific limits that only the company can answer.

- **Data classifications handled** — what categories of data this company's products touch (PII, PHI, financial, court records, etc.).
- **What may leave the trust boundary** — and to which third parties. Explicitly: what may **not**.
- **Residency requirements** — regions data must stay in.
- **Retention & deletion** — how long data is kept; deletion obligations.
- **Regulatory regimes** — the specific laws/standards that bind these products.

## 2. AI provider constraints

The company-specific answers to "may we send this data to a model?"

- **Approved model providers** — and for which data classifications each is approved.
- **Contractual posture** — is there a BAA / DPA / zero-retention agreement in place with each provider? A provider with no signed data agreement is **not** approved for regulated data, full stop.
- **On-prem / self-hosted requirements**, if any.
- **Redaction requirements** before data reaches a model — see `data-privacy-conventions.md`.

## 3. Design system & brand

- **Design system** — name, source of truth, how to access it (tokens, components, tooling).
- **Accessibility target** — the conformance level this company commits to (see `accessibility-conventions.md`).

## 4. Infrastructure & accounts

- **The environment set and its names** — this company's actual ladder (`dev`/`test`/`uat`/`pre-prod`/`prod`), which may be longer than the general `local → staging → production` default (`environment-conventions.md`).
- **Hosting / platform per environment** — and *which account owns each piece* (the ambiguity `deployment-conventions.md` warns about).
- **Deploy triggers and promotion gates** specific to this company — what must be true to move between each pair of environments, and who approves.
- **Verification level required before production** — the rung from `environment-conventions.md`, plus any mandated UAT or release sign-off.
- **Non-production data policy** — how test data is produced for this company's regulated data classes, since a production copy is never an option.
- **IaC tooling and where definitions live** — plus which resources are *not* under it and why (`infrastructure-conventions.md`).
- **Backup, retention, and recovery commitments** — the recovery point/time this company commits to, restore-drill cadence, and any contractual DR obligation.
- **Production access model** — who may reach production, how access is granted and revoked, the break-glass procedure, and audit-log retention (`security-conventions.md`).
- **Migration approval** — whether a DBA, change-advisory, or maintenance-window process gates production schema changes (`migration-conventions.md`).
- **Progressive delivery** (`progressive-delivery-conventions.md`) — flag platform or library, naming convention, and who may turn a flag *on* in production. Turning a flag *off* is never gated.
- **Rollout cohorts and change notification** — the cohort unit for each product (individual users, or the whole team/organization where people share records), and the **allowlist of customers confirmed by contract to be exempt from change-notification requirements**, with the date each was verified, its re-check trigger, and who confirmed it. Default is that notification *is* required; absence from the allowlist means a customer is not eligible for an early ring. Name the person who owns contract determinations — it is never the engineer, PM, or an AI reading contract language.
- **Token/secret service names** used by this company's projects (secret-store keys only — never values).

## 5. Internal tooling & process

- Issue tracker / docs conventions (e.g. Jira project keys, Confluence spaces).
- **Incident response** (`incident-conventions.md`) — the security/privacy escalation contact and chain, severity definitions if they differ from the default, paging and on-call arrangements, response-time commitments, the external/customer notification procedure and who approves it, and **where incident records and postmortems live** (never in the conventions directory).
- Review, approval, and compliance sign-off requirements that go beyond `collaboration-modes.md` collaborative mode.

## 6. House preferences (overrides of general defaults)

*Preferences only* — conventions where the general repo picked one reasonable default and this company prefers a different, equally-valid one. Do **not** list principle-level rules here; a company cannot override those. For each entry, name the general default being overridden and the company's choice.

- **Git branching strategy** — e.g. general default is trunk-based/direct-to-`main`; company mandates GitFlow / release branches / mandatory feature branches.
- **Commit message format** — any house format that differs from `git-conventions.md` (e.g. Conventional Commits, ticket-prefix requirements).
- **Package manager / toolchain**, **formatter/linter config**, **repo topology** (monorepo vs multi-repo), or any other preference-level default this company standardizes.

Anything not listed here inherits the general default.

---

_Last reviewed: YYYY-MM-DD. Keep dates absolute (`documentation-conventions.md`)._
