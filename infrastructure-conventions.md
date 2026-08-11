# Infrastructure Conventions

This file defines how the substrate a project runs on is defined, changed, and recovered. It is loaded into AI context when a task provisions or reconfigures hosting, databases, DNS, queues, storage, or IAM; touches infrastructure definitions or CI config; or concerns backups and recovery.

Two ideas carry the whole file:

- **If you can't recreate it from the repo, you don't have infrastructure — you have a pet.** Every environment should be reproducible from a definition someone can read, review, and re-apply.
- **A backup is not a backup until you have restored from it.** An untested backup is a belief, and the moment you need it is the worst moment to discover it was only that.

Scope split: `environment-conventions.md` says which environments exist and requires that their differences be intentional; this file is *how* that gets enforced rather than hoped for. `deployment-conventions.md` owns shipping application code onto this substrate.

---

## Infrastructure Is Defined in Code

- **The repo is the source of truth for what exists.** Compute, databases, DNS records, storage buckets, queues, IAM roles and policies, environment variable names, scheduled jobs, and CI configuration are all infrastructure.
- **The provider console is for reading, not writing.** A change clicked into a web console exists nowhere, is reviewed by nobody, and silently invalidates every other environment's claim to parity. Treat "I'll just change it in the dashboard" the same way you'd treat editing production source over SSH.
- **Infrastructure changes go through the same gates as code** — reviewed, committed, and applied deliberately (`cicd-conventions.md`, `git-conventions.md`). An infrastructure change is often *more* dangerous than a code change and gets at least as much scrutiny.
- **All environments come from one definition with different inputs.** This is what actually delivers the parity `environment-conventions.md` requires: staging differs from production by a parameter (instance size, replica count), not by a separate hand-built history. If staging and production are described by two unrelated definitions, they will diverge, and you'll find out from a user.

**The mechanism is a preference; reproducibility is the principle.** Three rungs, all acceptable at the right scale, and each should be recorded in the project's CLAUDE.md:

1. **A written runbook** — the exact steps and settings to recreate the environment, in the repo, kept current. Honest floor for a small project. Its failure mode is going stale, so it gets re-read whenever it's used.
2. **Scripts** — the same steps as executable, idempotent code (provider CLI, a setup script). Cheap, and it can't drift from itself.
3. **Declarative IaC** — Terraform, Pulumi, CloudFormation, or the platform's own config-as-code. The real answer once there's more than a couple of environments or more than one person.

Start at whatever rung the project justifies and move up when the trigger fires: a second environment, a second person, or the first time you can't answer "what exactly is deployed?"

## Drift Is Debt With a Deadline

- **Detect it.** Run the drift check your tooling offers on a schedule, or diff reality against the runbook when you touch it. Drift you don't look for gets discovered by an outage.
- **An emergency console change is allowed; leaving it there is not.** Fixing production by hand at 2am is sometimes correct. The change is reconciled back into the definition — and into staging — before the incident is closed, not "when there's time." `environment-conventions.md` states this as changes flowing forward, never sideways into production only.
- **Prefer replacing over mutating.** Where the platform makes it cheap, roll out changes by standing up new resources and cutting over rather than editing live ones. A replaced resource matches its definition by construction; a mutated one only matches until the next hotfix.
- **Every intentional difference between environments is recorded**, so the drift check has a real baseline instead of a list of known-but-undocumented exceptions nobody trusts.

## Infrastructure State Is Sensitive

If the tooling keeps a state file (Terraform and friends), it is a credential-bearing artifact:

- **Never committed.** Add it to `.gitignore` before the first `apply`, and add a CI check that fails if it ever appears in a diff — state files routinely contain plaintext secrets, connection strings, private addresses, and resource identifiers (`security-conventions.md`).
- **Remote backend, encrypted at rest, with locking enabled.** Local state means one laptop is the source of truth and two concurrent applies corrupt it.
- **Separate state per environment.** Shared state is a shared blast radius — a mistake while applying staging should be structurally incapable of touching production.
- **Keep secrets out of state where the tooling allows it** — reference a secret manager rather than passing values through. Where a secret must pass through, treat the state store's access controls as production-grade.

## Environments Are Provisioned and Destroyed on Purpose

- **Standing up a new environment should be a command, not a project.** If it isn't, the ephemeral-preview option in `environment-conventions.md` isn't really available to you, and neither is fast recovery.
- **Ephemeral environments are destroyed when their change merges.** An orphaned preview environment is a recurring bill and an unmonitored, unpatched, internet-reachable surface — often still holding a database and credentials.
- **Everything provisioned is tagged or named with its environment and owner**, so an unrecognized resource can be traced instead of being left alone because nobody dares delete it.
- **Know what a thing costs before creating it, and check afterward.** Cost is a real constraint on solo projects and the usual reason infrastructure gets abandoned rather than torn down properly.

## Backups Are Not Backups Until You've Restored One

Every project holding data anyone would miss needs this, at any scale.

- **Know what must be recoverable, and what doesn't need to be.** The database and any user-uploaded files, almost always. Derived data, caches, and search indexes usually just need to be rebuildable — which is a different plan, and one you should confirm actually works.
- **Copies in more than one place, at least one of them somewhere separate.** The full 3-2-1 formulation (three copies, two media, one off-site) is the enterprise form; the principle that survives at every scale is that **no single event — a bad migration, a deleted account, a compromised credential, a provider region failure — may be able to destroy both the data and every copy of it.** A snapshot living in the same account as the database it protects fails this test.
- **Point-in-time recovery where the platform offers it.** Nightly snapshots mean the worst case is losing a day; most managed databases will give you recovery to the minute for very little effort. Take it.
- **Write down what you're willing to lose and how long you can be down** — the recovery point and recovery time you're targeting. They don't need to be aggressive; they need to be *stated*, because an unstated target is one you'll discover you missed. "Up to 24 hours of data, back within a day" is a legitimate answer for a small project and a completely illegitimate one for a system of record.
- **Restore drills are the only thing that makes any of the above real.** Restore into a scratch environment, confirm the application runs against it, and note how long the whole thing took. Do this when you set backups up, whenever the schema or storage layout changes materially, and periodically after that — quarterly is a reasonable cadence for a released project. **A backup job reporting success is not evidence.**
- **Automate the verification if you can** — a scheduled job that restores the latest backup, runs a few validation queries, and reports the result turns an intention into a fact.
- **Backup access is separate from production access, and more restricted.** The same credential that can drop the database must not be able to delete its backups; immutable or delete-protected retention where the platform supports it. This is the difference between an incident and an unrecoverable one, whether the cause is ransomware or a tired evening.
- **Backups of personal data inherit every privacy obligation.** They're encrypted, their retention is bounded and deliberate, and a deletion request reaches them — `data-privacy-conventions.md` already requires deletion to cover backups and downstream copies, and that is only achievable if you designed for it. An unbounded backup archive of PII quietly defeats your retention policy.

## By Project Scale

The floor at every scale — including a solo weekend project:

- You could rebuild the environment from what's in the repo.
- The data is backed up somewhere a single failure can't reach, and you have restored from it at least once.
- No production secret sits in a state file, a console note, or a committed config.

What scales up with `release: released`, a second contributor, or a company profile: declarative IaC over runbooks, scheduled drift detection, per-environment state separation, automated restore verification, a stated recovery target, and documented ownership of every account. See `environment-conventions.md` for the triggers.

## Company & Project Overrides

Cloud provider, IaC tooling, region and residency requirements, retention schedules, disaster-recovery commitments, and account ownership are company-specific and live in the company profile (`companies/<name>/`) — where they may only tighten these defaults. Tooling and provider choice are **preferences**; reproducibility, tested restores, backup isolation, and keeping state out of the repo are principles.
