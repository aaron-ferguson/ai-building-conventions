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
