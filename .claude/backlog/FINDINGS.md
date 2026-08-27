# Findings — parked, not yet placed

**One or two lines each, dated, newest at the top.** This is a buffer, not a second backlog: it
holds findings whose home is **not local and not yet decided** — a possible row, a suspected skill
or convention problem, a cost pattern nobody has named yet.

**If a finding's home is obvious, write it there instead and do not park it.** A mechanism goes in
a comment beside the code, a rule goes in a test that fails, a unit of work goes to `queue` as a
row. Parking those is how a session ends with nothing written down *and* a growing file.

**Two sweepers empty this file, and they take different things.** `queue` takes the entries that
are **units of work** and specifies and ranks each one properly. `retro` takes the **lessons** and
lands them where they will be read again. **An entry that is both is taken by both** — classifying
at write time would put friction exactly where it is least wanted, at the moment of noticing, so
nothing here is tagged and neither sweeper waits for the other.

**Each sweeper removes only the entries it processed, and commits in the same turn.** Leaving a
processed entry is how the next sweep pays to read it again; removing an unprocessed one is how the
other sweeper's half disappears silently.

Every entry ends as a row, an edit, or a drop with a stated reason — so the normal state of this
file is empty. Entries older than about two weeks are dropped rather than processed: a finding
nobody acted on in two weeks was not worth acting on, and saying so is more honest than re-reading
it forever.

**If this file has grown, that is itself the finding** — retros are not running, or not emptying.

Format: `- YYYY-MM-DD — what happened, why it might matter (pointer: file, item id)`

---

- 2026-08-26 — **this repo's root `FINDINGS.md` predicted this backlog and nothing connects them.**
  It states: *"This repo has no backlog and no automated sweeper … If this file grows, the answer is
  a backlog, not a longer file."* The backlog now exists, and its two entries — both units of work
  about profile resolution for solo projects — are still sitting in a file no sweeper reads. Either
  they get specified and ranked here, or the root file's paragraph is now wrong and says so
  (pointer: `FINDINGS.md` at the repo root, `.claude/backlog/FINDINGS.md`).

- 2026-08-26 — **`config.yml`'s `commands:` block had no correct answer for a documentation repo.**
  The template offers unit/integration/e2e/lint/typecheck and assumes a package runner. This repo
  has no build and no framework — what it has is a sibling-`.test.sh` beside each script, so `unit`
  became a shell loop over `scripts/*.test.sh`. Two consequences the template does not warn about:
  the glob is a *path* decision baked into config, so 0004 adding `hooks/` silently falls outside
  the runner unless that item widens it; and a project with no runner at all has no honest value to
  put here, which pushes every ticket to `qa_level: verify` whether or not that is right
  (pointer: queue `templates/config.yml`, items/0004 QA plan).

- 2026-08-26 — **`source: external:<report-id>` has no resolvable meaning without the opt-in
  feedback block.** Twelve items here are sourced from an email thread, recorded as
  `external:email-2026-08-14-bozidar`. `external_feedback:` is deliberately absent from `config.yml`
  (correctly — there is no product holding these reports), so the id points at nothing any tool can
  follow, and a later reader has only the string. The vocabulary assumes the block exists; a plain
  "a human told me, here is where" case has no field (pointer: queue `templates/item.md` `source:`,
  `references/EXTERNAL-FEEDBACK.md`).
