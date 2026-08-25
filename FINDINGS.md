# Findings — parked against these conventions

Things a session noticed **while working in another repo** that turn out to be gaps in *these*
files, and could not be fixed from where they were found.

**This repo has no backlog and no automated sweeper**, so nothing empties this file on a cadence —
it is read when someone next works on the file an entry names. That makes it a parking spot, not a
queue, and the difference is worth stating: an entry here survives only because a person comes
looking. If this file grows, the answer is a backlog, not a longer file.

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
