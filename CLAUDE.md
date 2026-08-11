# AI Coding Conventions — project instructions

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

`company: none` is deliberate and takes precedence over any company declared by a
parent-directory CLAUDE.md. Every tracked file here must stay company-agnostic so
the repo can be shared; company specifics live only in `companies/<name>/`, which
is gitignored apart from the generic template.

## Environments

**There are none.** This is a documentation repo — no build, no runtime, no hosting,
nothing to promote. There is no local/staging/production ladder and none is needed.

| Fact | Value |
|---|---|
| Deployable environments | none |
| Deploy trigger on `main` | **none** — pushing deploys nothing, anywhere |
| Shared branch | `main`, but no other contributors today |
| Data | none; no datastore, no secrets, no PII |

Consequences, which are the reason this block exists at all:

- **`git push` here is sync, not release.** No approval needed, per the graded push
  rule in `git-conventions.md`. Push freely to get work off one machine.
- **No backup obligation beyond the remote.** `origin` is the off-machine copy that
  `infrastructure-conventions.md` asks for.
- **Verification is "does it read correctly and do the cross-references resolve?"**
  There is no test suite to run. Before finalizing an edit, check that every
  `` `*.md` `` reference in the changed files points at a file that exists.

## Incidents

Not applicable — nothing runs, so nothing can break in production. A wrong or
misleading convention is fixed as an ordinary commit.
