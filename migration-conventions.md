# Migration Conventions

This file defines how schema and stored-data changes are made. It is loaded into AI context when a task adds, alters, or removes a database column, table, index, or constraint; backfills or transforms existing rows; or changes the shape of anything persisted.

Migrations are the least reversible thing most projects do. Code rolls back in seconds; a dropped column does not come back, and a botched backfill may not be reconstructable at all. `deployment-conventions.md` says to know the rollback move before deploying — for migrations, the honest answer is usually **there isn't one**, and that changes how they get built.

Scope split: `environment-conventions.md` owns where a migration is rehearsed. `infrastructure-conventions.md` owns the backup you need before a destructive step. This file owns the change itself.

---

## Migrations Are Code

- **Every schema change is a migration file in the repo**, versioned, reviewed, and applied by tooling. Never by hand in a console or a client, in any environment — a change made by hand exists in no history, runs in no other environment, and is invisible to the next person (including future you).
- Migrations are **append-only once applied anywhere shared.** Editing a migration that already ran on staging means two environments have silently different schemas from the same commit. Fix it with a new migration.
- **Migrations are reviewed with more care than ordinary code**, because the review is the last cheap moment. The `coding-conventions.md` checklist applies, plus: what does this lock, how long, how many rows, and what happens if it fails halfway?
- **The migration and the code that depends on it are separate deploys.** See the next section — this is the rule everything else follows from.

## Expand, Migrate, Contract — Never One Step

**Never change the schema and the code that depends on it in the same deploy.** During any rollout, old and new code run against the same database at the same time; a change that only works for one of them is an outage. So a breaking change becomes three deploys:

1. **Expand** — add the new shape additively. New column nullable or defaulted, new table, new index. Old code is untouched and still correct.
2. **Migrate** — backfill the data, then ship the code that reads and writes the new shape. Dual-write during the transition if both shapes must stay live.
3. **Contract** — once nothing reads the old shape, remove it. This is a separate, deliberate deploy, and the one where a verified backup is a precondition.

The gap between steps is a feature: it's the window in which you discover the change was wrong while it's still free to abandon. Don't collapse the three into one "for a small change" — the small ones are exactly where this gets skipped and where the surprise lands.

**A release flag is the natural companion to this sequence.** Step 2 requires code that can work with both shapes; the flag is what decides which shape a given request uses, so you can move users across gradually instead of all at once. Roll the flag forward, then contract the schema and delete the flag together (`progressive-delivery-conventions.md`). Don't put the *migration* behind a flag — the migration's own three-step sequence is its rollout.

Practical consequences worth stating outright:

- **Adding a NOT NULL column with no default is a breaking change.** Add it nullable, backfill, then add the constraint.
- **Renaming is add + backfill + dual-write + remove**, not a rename.
- **Narrowing a type or tightening a constraint is destructive** — existing rows may violate it. Validate against production-shaped data before, not during.
- **Dropping anything is contract-phase work.** If you find yourself dropping a column in the same PR that stops using it, split it.

## Production Migrations Are Forward-Only

Down migrations are worth writing for local iteration and worth **not** relying on in production:

- A down migration that reverses a backfill cannot restore what the column held unless you deliberately preserved it. Schema rollback is not data rollback, and most tooling only claims the former.
- Down migrations are almost never tested, so running one during an incident means executing untested destructive code under pressure — the worst combination available.
- A multi-statement migration that fails partway can leave the database in a state neither the up nor the down path expects.

So: **the recovery plan for a migration is a forward fix**, a new migration that compensates. Decide what that forward fix would be *before* applying the original, and write it down in the PR. If you can't describe it, the migration isn't ready.

## Apply Migrations as an Explicit Deploy Step

- **Never on app boot.** A migration that runs when an instance starts will run concurrently on every instance, and a failure crash-loops the fleet instead of failing one clearly-named step.
- **One ordered step in the deploy, with its own visible success or failure**, gated the same way the deploy is (`deployment-conventions.md`).
- **Set a short `lock_timeout` and `statement_timeout`.** A migration that fails fast and gets retried is strictly better than one that queues behind a long transaction and freezes the table while looking like it's working.

## Backfills Are Batched, Resumable, and Observable

- **Bounded chunks with a pause between them**, never one statement over a large table. A single long transaction holds locks and grows undo/WAL until something else breaks.
- **Resumable** — track progress so an interrupted backfill continues instead of restarting or double-applying. Make the operation idempotent.
- **Observable** — log progress as structured events (`observability-conventions.md`) so you can tell "slow" from "stuck" without guessing.
- **Separate from the schema migration** where the volume is real. A backfill is a data job with a runtime measured in minutes or hours; it does not belong inside a DDL step holding a lock.

## Rehearse Before Production

- **Every migration runs on staging first**, against a dataset shaped like production — comparable row counts and comparable data messiness, synthetic or anonymized (`data-privacy-conventions.md`). A migration verified against 50 rows has told you nothing about the one that matters.
- This is rung 4 in `environment-conventions.md`, and a schema change is the canonical reason to step up to it. Time the migration on staging; if it takes 40 minutes there, you need to know that before production, not during.
- **A destructive or irreversible step requires a verified, restorable backup taken immediately before** — verified meaning you know a restore works, not that a backup job reported success (`infrastructure-conventions.md`).

- **Without staging, rehearse locally: apply every migration to an empty database *and* to a seeded one**, then assert the rows survived. Valid, idempotent SQL still fails against existing rows — a `NOT NULL` without a default, a narrowed type, a `UNIQUE` that duplicates violate. Rehearse re-applying the whole schema too, since that is what a deploy does. Watch the ordering: an idempotency check failing first can mask the populated-table failure entirely. This runs on every commit, but still can't tell you the migration's runtime at production scale.

## Migrations Get Tested

TDD applies (`testing-conventions.md`); the target is just less obvious than usual:

- **The assumption gets a test.** If the migration relies on "no rows have a null here" or "these values are unique," assert that in the migration or in a test, and fail loudly if it isn't true. A migration that silently skips the rows that don't fit is worse than one that stops.
- **Backfill logic is a pure function where possible**, unit-tested against the awkward rows: nulls, empty strings, duplicates, encoding oddities, out-of-range dates.
- **An integration test runs the migration** against a real test database with representative fixtures — this is exactly the seam integration tests exist for.
- **Run the suite against the migrated schema** before promoting. A migration that passes and leaves the application broken has not succeeded.

## Seed and Fixture Data Is a Committed Artifact

Non-production environments need usefully-shaped data, and the only acceptable source is one you build (`environment-conventions.md` — non-production never holds production data).

- **A seed script or fixture set lives in the repo, versioned alongside the schema.** A migration that changes shape updates the seeds in the same commit; stale seeds are how "works locally" stops meaning anything.
- **Seeds produce realistic shape, not realistic content** — plausible volumes, distributions, edge cases, and messiness, with synthetic values. Include the awkward records deliberately: the record with no optional fields, the maximum-length string, the unicode name, the timezone edge.
- **Anonymization is a last resort, not a shortcut.** If a production-derived dataset is genuinely needed, it is transformed before it leaves production, the transform is code and reviewed, and re-identification risk is assessed — never "we removed the name column." For regulated data this needs the company profile's sign-off (`companies/<name>/`).
- **The fixture asserts its own shape** — row counts, states present, the awkward cases still there — and fails loudly when they stop holding. Seeds decay as the schema moves under them, and one degraded to a few empty rows makes every rehearsal pass while testing nothing.
- **"Send me a copy of your local database" is banned.** It's the main way production data reaches laptops.

## By Project Scale

The principles above don't flex — expand/contract, forward-only, rehearse before production, and no hand-run SQL apply to a solo weekend project too, because a solo developer with a dropped column has exactly the same problem a team does. What scales with the project:

- **Pre-release, solo:** a destructive migration on a database you can rebuild from seeds is a non-event. Reset and move on; the discipline that matters here is that the migration is a file in the repo and the seeds still work.
- **Released:** the full expand/contract sequence, staging rehearsal, backup-before-destructive, and a written forward fix. The moment real data exists, "I'll just fix it in the console" stops being available.
- **Collaborative:** add migration review as a named step — someone other than the author looks at locking, volume, and the contract-phase plan before it merges (`cicd-conventions.md`).

Zero-downtime tooling for large tables (online schema change, shadow tables, `pgroll`-style tools) is an **advanced technique with a trigger**, same shape as the list in `testing-conventions.md`: adopt it when a migration's lock time on real volume is genuinely unacceptable. Don't add it speculatively.

## Company & Project Overrides

Migration tooling, naming, and whether a DBA or change-advisory sign-off is required before a production migration are company-specific (`companies/<name>/`) and may only tighten what's here. Tooling choice is a **preference**; every rule above is a principle.
