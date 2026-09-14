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

- 2026-09-14 — `[for tools repo]` `/sprint` Step 3 dispatches with
  `--json-schema "$(cat skills/sprint/outcome.schema.json)"`, but that file's
  `"$schema": "https://json-schema.org/draft/2020-12/schema"` key is unresolvable by the
  installed CLI: every dispatch dies instantly with *"--json-schema is not a valid JSON Schema:
  no schema with key or ref …"*, before the stage session starts. Two dispatches lost this way.
  Deleting that one key fixes it. **Step 1's probe cannot catch this** — its inline schema has no
  `$schema` key, so the premise check passes while every real dispatch fails. Either strip the key
  from the shipped schema or make the probe use the real one (pointer:
  `skills/sprint/outcome.schema.json`, `skills/sprint/SKILL.md` Steps 1 and 3).

- 2026-09-14 — `[for tools repo]` `/sprint` Step 3 pre-assigns `--session-id "$RUN_STAGE_UUID"`
  so "the transcript path is a dispatch-time fact in the run log rather than something a dead
  supervisor has to hunt for". It does not hold: the CLI minted its own ids, and none of the three
  dispatched ids appears in any transcript. Recovered the real ones by mtime instead. This breaks
  Step 6's ledger attribution — `sprint-ledger.sh record` pins its harvest to the dispatch events'
  session ids, so every GATE and DESIGN row came back `observed USD 0.00` and had to be annotated
  by hand. One stage also returned an all-zero uuid in its own outcome envelope, so the envelope
  is not a fallback (pointer: `skills/sprint/SKILL.md` Step 3, `tools/sprint-ledger.sh`).

- 2026-09-14 — `scripts/check-commit-identity.sh` prints `134 disallowed commit identity
  reference(s)` and still **exits 0**. That may be deliberate — history on a public remote is
  forward-only and cannot be rewritten, so failing on it would make the guard permanently red —
  but a guard that reports violations without failing is one nobody notices going stale, and
  nothing states the intent either way. Worth deciding explicitly: fail on *new* commits only,
  or document why exit 0 is correct and what the 134 are. Verify passed 0001 on it, so this is a
  question about the guard's contract, not about that verdict (pointer:
  `scripts/check-commit-identity.sh`, item 0001).

- 2026-09-14 — `[for tools repo]` The `/design` skill's Step 1/Step 4 instructions call
  `./claim <id>` and `./handoff <id> <token> <stage>`, but this project's vendored
  `.claude/backlog/` only ships `claim`, `close`, and `next` — no `handoff` script exists.
  Released 0003 manually by replicating `claim`'s lock → edit QUEUE.md (by header-resolved
  column, not position — a first attempt at this by fixed index clobbered the Title column)
  → edit item frontmatter → commit → unlock sequence. Either this project's toolkit predates
  a `handoff` script the skill now assumes, or `handoff` was never vendored for projects set up
  before it existed — worth checking whether other projects on this backlog toolkit have the
  same gap. `tools.path` is unset in `.claude/backlog/config.yml`, so this couldn't route to
  the tools repo's own buffer directly (pointer: `.claude/backlog/claim`, item 0003).

- 2026-09-14 — `[for tools repo]` `./close` refuses with "no DONE.md at ... — nowhere to move
  the row to" if `DONE.md` doesn't already exist, but nothing in `queue`'s scaffolding or
  `develop`'s vendoring creates it — this repo had `QUEUE.md`, `claim`, `close`, `next` and
  `config.yml` but no `DONE.md` until the first ticket (0001) actually closed. Created it by
  hand with the `| ID | Title | Type | QA | Closed | Item |` header `close` expects (matched
  against the plugin's own installed template for this backlog toolkit). Worth having whichever
  script first sets up a project's backlog directory create an empty
  `DONE.md` up front, the same way it creates `QUEUE.md` (pointer: `.claude/backlog/close`,
  item 0001).

