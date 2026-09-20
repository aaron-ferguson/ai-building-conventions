# Findings — parked against these conventions

Things a session noticed **while working in another repo** that turn out to be gaps in *these*
files, and could not be fixed from where they were found.

**This file is for gaps found from outside; `.claude/backlog/FINDINGS.md` is for gaps found from
inside.** This file said, until 2026-09-07, that the repo had no backlog and that the answer if it
grew was a backlog rather than a longer file. The backlog exists now, so that sentence has been
corrected rather than left to read as current — a stale rule is followed.

The two files are not duplicates and neither sweeps the other. An entry **here** was noticed while
working in another repo and names a gap in these conventions, so it is read when someone next works
on the file it names; an entry in the backlog's buffer is a lesson from work done *in this repo* and
is swept by `retro` on a cadence. If an entry here would be better served by a specified, ranked
unit of work, move it into the backlog rather than leaving it in both.

Format: `- YYYY-MM-DD — **what happened.** why it might matter (pointer: file)`. The date goes
outside the bold. Entries name the repo when they point outside this one.

---

- 2026-08-24 — **the base suite has no home for a solo profile, only a company one.**
  `CONVENTIONS_CORE.md` resolves preferences through `companies/<name>/`, and this repo is public,
  so a *solo* preference (which feedback product, which personal tooling) has nowhere to live that
  is both private and discoverable. `ai-building-tools` 0030 hit this deciding where its
  `NOTION.md` should move to and could only answer "not here"; it deleted the file and pointed at
  git history instead. Every future "move X behind a profile" ticket hits the same wall
  (pointer: CONVENTIONS_CORE.md "Profiles & How Overrides Work", `companies/_template.md`,
  ai-building-tools items/0030 FR4).

- 2026-08-24 — **removing a preference from the base suite leaves a follow-up nothing owns.**
  `ai-building-tools` 0030 took Notion out of the base tool suite and documented the
  `external_feedback:` extension point a profile plugs into, but *wiring the author's own solo
  projects back up* is named in that ticket's *Out of scope* and therefore has no ticket at all.
  Any solo project with `notion.enabled: true` in a live `config.yml` now has a stated wiring path
  and no one carrying it out. The general shape is worth a rule here: a ticket that moves a
  preference behind a profile creates a second, smaller ticket by construction — the port — and
  *Out of scope* is where it silently goes to die (pointer: `companies/_template.md`,
  ai-building-tools items/0030 and references/EXTERNAL-FEEDBACK.md "If you had `notion:`
  configured").

- 2026-09-09 — **a new guard reported a defect it could not name, on a clean tree, because its
  `elif` read a pipeline's status.** `elif hits=$(git grep -nE "$PAT" | cut -d: -f1,2); then` takes
  `cut`'s exit status, and `cut` succeeds on empty input — so the branch fired whenever the search
  found *nothing*. It was caught only because the failure went the harmless way; the mirror
  (`grep | head`, `grep | sort`) fails silent and is the one that ships. `testing-conventions.md`
  already warns that `exits non-zero` is satisfied by the wrong thing and to assert the message
  rather than the status; the rule does not yet say that a *search whose result you then format*
  must be a separate statement from its formatting (pointer: `testing-conventions.md` "a guard that
  is wired and still cannot fail"; ai-building-tools `tests/measurement.test.sh`, item 0143).

- 2026-09-10 — **`migration-conventions.md`'s rename rule is stated unqualified, so it reads as
  governing prose renames it was never about.** Line 33 says "Renaming is add + backfill +
  dual-write + remove, not a rename." `ai-building-tools` 0067 had to argue its way out of that
  sentence to settle how a repo-wide vocabulary rename lands: expand/contract governs *schema under
  running code*, where both shapes must be live because both old and new code are, and prose has no
  old code still running — its dual-write step would leave two live names for one concept, which is
  the exact defect the rename exists to remove. The ticket recorded the exemption in its own repo
  (`references/CONCURRENCY-INCIDENTS.md`), but the sentence here stays unqualified, so the next
  project to rename a term in documentation reads a principle that forbids the correct answer. Worth
  one clause naming the scope — schema and stored data — and saying forward-only is what survives for
  a record (pointer: migration-conventions.md line 33, ai-building-tools items/0067 NFR table).

- 2026-09-10 — **extracting a seam to make a fix testable can move the control off the branch that
  carries the defect, and every control still passes.** `ai-building-tools` 0148 fixed a guard that
  read `git grep`'s 128 (pattern would not compile) as 1 (no match), so a malformed name list left a
  privacy check green with a leak in the tree. The fix pulled the search into a function and the
  falsification controls drove that function — status distinguished, diagnostic withheld, all green.
  Reverting only the *consumer* to the conflating form restored the original defect with the suite
  still at `0 failed`: the controls reached the extracted helper and nothing reached the decision.
  `testing-conventions.md` covers a seam that widens the production surface (line 18) and says to
  build a mutation list from every decision site (line 16), but not this: the refactor that makes a
  thing testable is also the refactor that relocates what the tests cover, and the helper is the
  attractive place to point a control precisely because it is the new, clean interface. The fix was
  to give the *decision* a return value and drive that. Worth a clause where line 16 names decision
  sites — after extracting a seam, ask which branch the control now misses (pointer:
  testing-conventions.md lines 16 and 18, ai-building-tools items/0148 FR3).
- 2026-09-20 — **A presence grep scoped to a section is satisfied by prose that EXPLAINS the thing,
  not only by the thing.** A guard asserted that a skill's command line passes a new flag, scoped to
  the section holding that command. The same section also documents the flag in a paragraph, so
  deleting the flag from the command left the guard green — caught only by mutating it, never by
  reading it. The shape is general: on a file that both carries an artifact and describes it, a
  presence assertion must be bound to the artifact (the fenced block, the line), never to the
  region containing both. This is the adjacent-prose sibling of the negative-assertion trap already
  named — same cause, opposite sign (pointer: testing-conventions.md, anchor an assertion to the
  claim; ai-building-tools items/0168 AC7, commit 13ac559).
