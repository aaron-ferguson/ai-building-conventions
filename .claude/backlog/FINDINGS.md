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

**Every remaining entry below is `[for tools repo]` — this project's `.claude/backlog/config.yml`
has no `tools.path` set, so the `ai-building-tools` buffer cannot be resolved from here, and this
session was explicitly told not to edit that repo. `retro` (2026-09-26) read every entry below,
confirmed each is genuinely about the tools plugin rather than this project, and left them parked
rather than guessing a path per `references/CONVENTIONS.md`'s resolution rules. This buffer is at
8 entries against a `findings_threshold` of 8 — entirely tools-repo-bound findings this project
cannot drain. Setting `tools.path` (or running the next retro from inside the `ai-building-tools`
checkout) is the fix; until then this count will not go down.**

- 2026-09-14 — `[for tools repo]` `/sprint` Step 3 dispatches with
  `--json-schema "$(cat skills/sprint/outcome.schema.json)"`, but that file's
  `"$schema": "https://json-schema.org/draft/2020-12/schema"` key is unresolvable by the
  installed CLI: every dispatch dies instantly with *"--json-schema is not a valid JSON Schema:
  no schema with key or ref …"*, before the stage session starts. Two dispatches lost this way.
  Deleting that one key fixes it. **Step 1's probe cannot catch this** — its inline schema has no
  `$schema` key, so the premise check passes while every real dispatch fails. Either strip the key
  from the shipped schema or make the probe use the real one (pointer:
  `skills/sprint/outcome.schema.json`, `skills/sprint/SKILL.md` Steps 1 and 3). _(retro 2026-09-26:
  reviewed, destination confirmed, not forwarded — see note above.)_

- 2026-09-14 — `[for tools repo]` `/sprint` Step 3 pre-assigns `--session-id "$RUN_STAGE_UUID"`
  so "the transcript path is a dispatch-time fact in the run log rather than something a dead
  supervisor has to hunt for". It does not hold: the CLI minted its own ids, and none of the three
  dispatched ids appears in any transcript. Recovered the real ones by mtime instead. This breaks
  Step 6's ledger attribution — `sprint-ledger.sh record` pins its harvest to the dispatch events'
  session ids, so every GATE and DESIGN row came back `observed USD 0.00` and had to be annotated
  by hand. One stage also returned an all-zero uuid in its own outcome envelope, so the envelope
  is not a fallback (pointer: `skills/sprint/SKILL.md` Step 3, `tools/sprint-ledger.sh`). _(retro
  2026-09-26: reviewed, destination confirmed, not forwarded — see note above.)_

- 2026-09-14 — `[for tools repo]` The `/design` skill's Step 1/Step 4 instructions call
  `./claim <id>` and `./handoff <id> <token> <stage>`, but this project's vendored
  `.claude/backlog/` only ships `claim`, `close`, and `next` — no `handoff` script exists.
  Released 0003 manually by replicating `claim`'s lock → edit QUEUE.md (by header-resolved
  column, not position — a first attempt at this by fixed index clobbered the Title column)
  → edit item frontmatter → commit → unlock sequence. Either this project's toolkit predates
  a `handoff` script the skill now assumes, or `handoff` was never vendored for projects set up
  before it existed — worth checking whether other projects on this backlog toolkit have the
  same gap. `tools.path` is unset in `.claude/backlog/config.yml`, so this couldn't route to
  the tools repo's own buffer directly (pointer: `.claude/backlog/claim`, item 0003). _(retro
  2026-09-26: reviewed, destination confirmed, not forwarded — see note above.)_

- 2026-09-14 — `[for tools repo]` `./close` refuses with "no DONE.md at ... — nowhere to move
  the row to" if `DONE.md` doesn't already exist, but nothing in `queue`'s scaffolding or
  `develop`'s vendoring creates it — this repo had `QUEUE.md`, `claim`, `close`, `next` and
  `config.yml` but no `DONE.md` until the first ticket (0001) actually closed. Created it by
  hand with the `| ID | Title | Type | QA | Closed | Item |` header `close` expects (matched
  against the plugin's own installed template for this backlog toolkit). Worth having whichever
  script first sets up a project's backlog directory create an empty
  `DONE.md` up front, the same way it creates `QUEUE.md` (pointer: `.claude/backlog/close`,
  item 0001). _(retro 2026-09-26: reviewed, destination confirmed, not forwarded — see note
  above.)_

- 2026-09-14 — `[for tools repo]` **a long unattended run is illegible to the person watching it,
  and the turn budget is why.** The `sprint` skill's cost model (*What this costs, and the one
  number you can move*) sets "a budget of three turns per cycle — dispatch, read back, route" and
  rules that "the report turn is conditional on a state change, never automatic". Optimising the
  supervisor's own context that hard traded away the only signal a watching human has: with one
  develop gate running 36+ minutes across four tickets, the user had to ask "are the agents
  actually still working" because nothing was printed between dispatch and the run's end. A stage
  boundary IS a state change — a session finishing and the next being dispatched is exactly the
  condition that clause already permits a report on, so the skill's own rule allows what its turn
  budget discourages. Worth stating positively in Step 9: report at every stage boundary, naming
  what finished, what it produced, and what was dispatched next. One turn per boundary is a few
  hundred tokens against a run that costs dollars, and the alternative is a person polling the
  supervisor, which costs a full floor per question and yields less (pointer: `sprint/SKILL.md`
  *What this costs*, Step 9 *Report*; observed in run-20260914T144927Z). _(retro 2026-09-26: `[for
  tools repo]` tag added — this is about `skills/sprint/SKILL.md`, not this project; reviewed,
  destination confirmed, not forwarded — see note above.)_

- 2026-09-26 — `[for tools repo]` **the harness's auto-mode "Security Weaken" classifier blocks
  the exact mutation-test pattern `verify`'s Step 3 asks for on a security hook.** Verifying 0004,
  Step 3 calls for editing a committed guard to reintroduce the behavior it exists to catch,
  confirming the test suite goes red, then restoring — standard practice for proving a check isn't
  wired to nothing. Editing `hooks/scan-staged-for-secrets.sh` in place to reintroduce its
  pre-amendment fail-open behavior, then running that file's own `.test.sh`, was refused by the
  classifier as weakening a security control, even though the edit was local, immediately
  reverted, and never committed. Worked around by black-box testing the *unmodified* shipped hook
  against a stubbed `PATH` instead (proves current behavior; doesn't prove the test suite would
  catch a future regression the way a source mutation would). Worth knowing before the next
  security-hook ticket reaches `verify`: budget for the source-mutation step to be denied and have
  the stubbed-PATH black-box approach ready as the fallback, rather than discovering the denial
  mid-verification (pointer: `hooks/scan-staged-for-secrets.sh`, `verify` skill Step 3; observed
  verifying items/0004; fully reproduced and independently re-verified in that item's own QA
  evidence, 2026-09-26, token `af71`). _(retro 2026-09-26: `[for tools repo]` tag added — the
  action item is a change to `skills/verify/SKILL.md` Step 3's guidance, not to this project;
  reviewed, destination confirmed, not forwarded — see note above.)_

- 2026-09-25 — `[for tools repo]` **`--json-schema` outcome enforcement was unreliable across this
  run's stage dispatches: 3 of 4 failed to produce a schema-conforming object** — once returning
  prose instead of JSON, once returning valid JSON of the wrong shape (schema-conforming syntax,
  non-conforming structure), once returning prose again. `sprint` Step 4 ("Read the outcome, and
  nothing else") treats the envelope as the sole channel a driven run trusts — FR13's whole
  contract depends on the CLI actually enforcing `--json-schema` against what the stage prints, not
  merely accepting the flag. This is a different failure than the `$schema`-key rejection already
  parked above (that one kills the dispatch before the stage runs; this one is the stage running
  to completion and still not producing a conforming envelope). Worth a dedicated reliability check
  in `skills/sprint/SKILL.md` Step 4 or the outcome schema's own handling — an unattended run
  driving on `./next --drive` has no human to notice a prose reply and route around it (pointer:
  `skills/sprint/SKILL.md` Step 3–4, `skills/sprint/outcome.schema.json`; observed this run,
  flagged directly by the repo owner as a lesson that must not be lost). _(retro 2026-09-25:
  parked directly by `retro` at the dispatching supervisor's request — `tools.path` unresolved,
  not forwarded.)_

- 2026-09-25 — `[for tools repo]` **a supervisor dispatch prompt that over-constrains a stage's
  output can stop the stage from doing its job at all.** A dispatch that appended an instruction
  like "print only JSON, nothing else" to a `verify` invocation produced a session that returned a
  report and performed zero backlog action — no claim, no close, no commit — even though the
  `--json-schema` envelope is a separate, structured channel that does not require suppressing the
  stage's normal work. `sprint/SKILL.md` Step 3's dispatch already carries the schema as its own
  flag; an added prose instruction narrowing "what may be printed" apparently read as narrowing
  "what may be done." Worth an explicit warning in Step 3 (alongside its existing `--json-schema`,
  `--session-id`, and `< /dev/null` gotchas): a stage's own slash-command invocation should not be
  wrapped in supervisor instructions about its output shape beyond the `--json-schema` flag itself
  — the schema is the contract; anything layered in the prompt on top of it risks crowding out the
  stage's actual job (pointer: `skills/sprint/SKILL.md` Step 3; observed this run, flagged
  directly by the repo owner as a lesson that must not be lost). _(retro 2026-09-25: parked
  directly by `retro` at the dispatching supervisor's request — `tools.path` unresolved, not
  forwarded.)_
