# AI Building Conventions — project instructions

This repo *is* the conventions. See `README.md` for how it's organized and how other projects wire into it.

The conventions govern work on themselves: when editing a file here, apply the same standards it asks of any project — naming, single responsibility, cross-references over duplication, and the principle/preference distinction.

## Conventions
@CONVENTIONS_CORE.md

The core file indexes every other conventions file and when to load it.
Read those on demand — do not import them here.

## Profile
- collaboration: solo
- company: none
- release: n/a — nothing is deployed (see Environments below)

**This file is the authority for work in this repo.** Take project instructions from
here and the files it indexes — nothing outside this directory governs work on these
conventions, whatever else may be present higher up the filesystem.

`company: none` is a constraint, not a placeholder. Every tracked file here must stay
company-agnostic so the repo can be shared with a client, a collaborator, or a future
employer. Company specifics live only in `companies/<name>/`, which is gitignored
apart from the generic template. **If a session is carrying company context from
elsewhere, that context does not apply here and must never reach a tracked file** —
no company name, product, person, or internal tooling in anything committed.

## Environments

**There are none.** This is a documentation repo — no build, no runtime, no hosting,
nothing to promote. There is no local/staging/production ladder and none is needed.

| Fact | Value |
|---|---|
| Deployable environments | none |
| Deploy trigger on `main` | **none** — pushing deploys nothing, anywhere |
| Shared branch | `main`, but no other contributors today |
| Data | none; no datastore, no secrets, no PII |
| Remote | `aaron-ferguson/ai-building-conventions`, **public**. The local `gh` is authed as a different account with **write**, not admin |

Consequences, which are the reason this block exists at all:

- **`git push` here is sync, not release.** No approval needed, per the graded push
  rule in `git-conventions.md`. Push freely to get work off one machine.
- **No backup obligation beyond the remote.** `origin` is the off-machine copy that
  `infrastructure-conventions.md` asks for.
- **Verification is "does it read correctly and do the cross-references resolve?"**
  There is no test suite to run. Before finalizing an edit, run
  `~/AI/scripts/check-convention-links.sh` — checking by hand is what let seven projects
  reference filenames that don't exist, because macOS is case-insensitive and opened them
  anyway. **Renaming a file here breaks references in other repos that this repo cannot
  see**, so run it after any rename, not just after an edit.
- **Admin operations on the remote cannot be done from this machine** — rename,
  visibility, settings, and branch protection all need the owning account. `gh` here is
  a write-level collaborator, and GitHub answers those with a misleading **`404`, not a
  `403`**, so it reads as "repo doesn't exist" rather than "you lack permission". Do them
  in the web UI as the owner. This is the thing to remember if this repo ever goes
  `collaborative`, since `cicd-conventions.md` would then want branch protection.
- **The repo is public.** The `company: none` rule above is therefore not a stylistic
  preference — a company detail committed here is published.

## Incidents

Not applicable — nothing runs, so nothing can break in production. A wrong or
misleading convention is fixed as an ordinary commit.
