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

