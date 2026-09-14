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

- 2026-09-14 — `git-conventions.md`'s "Destructive Commands" list (`git push --force`/`-f`,
  `git reset --hard`, `git commit --amend` on published commits, `git rebase` on shared
  branches, any `--no-verify`) is a closed, fully enumerable set of command shapes — exactly
  the kind of rule 0004 just proved a `PreToolUse`/`Bash` hook can enforce — and none of it is
  covered by either hook 0004 built (those only refuse sweeping `add`/`commit`/bare `stash`).
  A hook matching these five shapes could refuse or `ask` before Claude ever runs one. Noticed
  while scoping 0004; not built there since it's outside that ticket's own ACs — a candidate
  for its own ticket (pointer: `git-conventions.md` "Destructive Commands",
  `hooks/block-sweeping-git-stage.sh`, item 0004).

- 2026-09-14 — `git-conventions.md`'s ".gitignore Essentials" list (`node_modules/`, `dist/`,
  `build/`, `.env`, `.env.*`, `coverage/`, `.DS_Store`, `*.log`) is stated as a minimum every
  project should have, but nothing checks a project's actual `.gitignore` against it — a
  `SessionStart` hook (or a `scripts/`-style check script) could diff a new project's
  `.gitignore` against this list and warn on anything missing. Noticed while scoping 0004;
  lower value than the Destructive Commands gap above since a missing `.gitignore` entry is
  self-correcting the first time it causes a problem, so parking rather than building
  (pointer: `git-conventions.md` ".gitignore Essentials").

- 2026-09-14 — **a long unattended run is illegible to the person watching it, and the turn budget is why.** The `sprint` skill's cost model (*What this costs, and the one number you can move*) sets "a budget of three turns per cycle — dispatch, read back, route" and rules that "the report turn is conditional on a state change, never automatic". Optimising the supervisor's own context that hard traded away the only signal a watching human has: with one develop gate running 36+ minutes across four tickets, the user had to ask "are the agents actually still working" because nothing was printed between dispatch and the run's end. A stage boundary IS a state change — a session finishing and the next being dispatched is exactly the condition that clause already permits a report on, so the skill's own rule allows what its turn budget discourages. Worth stating positively in Step 9: report at every stage boundary, naming what finished, what it produced, and what was dispatched next. One turn per boundary is a few hundred tokens against a run that costs dollars, and the alternative is a person polling the supervisor, which costs a full floor per question and yields less (pointer: `sprint/SKILL.md` *What this costs*, Step 9 *Report*; observed in run-20260914T144927Z).

- 2026-09-14 — **`check-commit-identity.sh` reports 134 pre-existing violations and nothing owns fixing them.** The script works: it correctly flags that 134 commits reachable from `main` carry a corporate committer/author email (e.g. `d7d9826`) on what `CLAUDE.md` *Environments* states is a **public** remote. The local git config is right (`aaron@newheights.coach`) and every commit this run made is clean, so the guard is doing its job for new work — but it was added without remediating the history it was built to catch, so it now fails on every run and a permanently-failing check is one people learn to ignore. The general shape: **a guard introduced against an already-dirty baseline needs a remediation ticket created in the same change, or it trains the team to skip it.** Remediation is a decision, not a task — history rewrite on a public remote vs. accepting the baseline vs. a `.mailmap` — and no agent should pick (pointer: `scripts/check-commit-identity.sh`, `CLAUDE.md` *Environments*; observed in run-20260914T144927Z).
