---
id: "0004"
title: Enforce the mechanically checkable rules with hooks instead of prose
type: feature
next: verify
status: ready
qa_level: unit
size: m
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0006", "0008"]
expects:
  - .claude/settings.json
  - hooks/block-sweeping-git-stage.sh
  - hooks/block-sweeping-git-stage.test.sh
  - hooks/scan-staged-for-secrets.sh
  - hooks/scan-staged-for-secrets.test.sh
  - git-conventions.md
  - security-conventions.md
  - README.md
claimed_by:
claimed_at:
touches:
---

## Problem

This repo is entirely documentation and has no enforcement mechanism. Verified 2026-08-26: there is
no `.claude/` directory, no `settings.json`, and no hook of any kind anywhere in the tree. Every
rule is a sentence hoping to be read.

Several of the strongest rules in the suite are **mechanically checkable and currently unenforced**:

- `git-conventions.md` — *never `git add .`, `git add -A`, or `git commit -a`*, with a stated
  reason (the index is shared, so a swept commit silently carries off another session's work). A
  `PreToolUse` hook on `Bash` can refuse the command outright.
- `git-conventions.md` — *never bare `git stash`* in a shared tree. Same shape, same hook.
- `security-conventions.md` — *secrets never appear in source, config, commits, or AI context*. A
  staged-content scan can fail the commit; a CI check can fail the build.
- `CONVENTIONS_CORE.md` — *"Stop what you started"*: a server, database, container or emulator
  spun up to test gets stopped in the same turn. That is a `Stop` hook.

The reviewer's framing, and the reason this is a defect rather than a nice-to-have:

> "I am a strong believer that rules are either enforced or they are not going to be happening,
> either immediately or as time goes on or with simply 'rogue' employee … Right now, it is all
> documentation and no enforcement mechanism."
> — email thread *AI Building Conventions*, 2026-08-14

and, from the same thread: *"if you don't want me to do something make sure you prevent me from
doing it in the first place."*

This compounds. Every project wired to these conventions inherits the unenforced version, and the
suite keeps growing rules faster than it grows ways to hold them.

## Functional requirements

- FR1 — A `PreToolUse` hook on `Bash` refuses `git add .`, `git add -A`, `git add --all`, and
  `git commit -a`/`--all`, returning a message that names `git-conventions.md` and the pathspec
  form to use instead. Refusal, not a warning — a hook that prints and proceeds is prose with extra
  steps.
- FR2 — The same hook refuses a bare `git stash` (no pathspec), per the same file.
- FR3 — A hook scans the staged diff for secret-shaped content before a commit is allowed, failing
  with the matching file and line, and citing `security-conventions.md`.
- FR4 — Each hook script has a sibling `.test.sh` per this repo's established pattern, and each
  test contains a case feeding the exact command the hook exists to block and asserting the
  refusal — a guard only ever seen passing is indistinguishable from one wired to nothing
  (`testing-conventions.md`).
- FR5 — The hooks are wired in a `.claude/settings.json` **committed to this repo**, so this repo
  enforces its own rules on itself and the wiring is a working example rather than a description.
- FR6 — `README.md` gains a section telling another project how to adopt the hooks, and each
  enforced rule's own convention file states that a hook enforces it and names the script. A rule
  whose enforcement is invisible from where the rule is written gets re-litigated.
- FR7 — Every hook exits successfully when its trigger is absent, and never blocks on its own
  failure to run. A hook that hard-fails on an unrelated command turns the whole convention suite
  into something people disable.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Security | FR3 is a secrets control and must fail closed on a match; the scan must never write a matched value to a log, an error message, or a tracked file — report file and line, never the content | `security-conventions.md` |
| Privacy & data | Hook output reaches the session transcript, so no hook may echo staged file content | `data-privacy-conventions.md` |
| Documentation | FR6 lands in the same change as the hooks, not afterwards | `documentation-conventions.md` |
| Dependencies | The hooks are POSIX shell using tools already present on a stock macOS and Linux; a hook that needs an install is a hook that is not running on the machine that needed it | `dependency-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given the hook installed, when a session runs `git add .`, then the command is refused
      and the message names `git-conventions.md`.
- [ ] AC2 — Given the hook installed, when a session runs `git add -A` or `git commit -a`, then
      each is refused.
- [ ] AC3 — Given the hook installed, when a session runs `git add path/to/file.md`, then it is
      permitted.
- [ ] AC4 — Given the hook installed, when a session runs bare `git stash`, then it is refused;
      when it runs `git stash push -u some/path`, then it is permitted.
- [ ] AC5 — Given a staged file containing secret-shaped content, when the secret scan runs, then
      it exits non-zero, names the file and line, and does not print the matched value.
- [ ] AC6 — Given a staged change with no secret-shaped content, when the scan runs, then it exits
      zero.
- [ ] AC7 — Given each hook's `.test.sh`, when the `unit` command is run, then all pass, and each
      test file contains a case asserting a refusal.
- [ ] AC8 — Given `.claude/settings.json` in this repo, when it is read, then it wires every hook
      FR1–FR3 delivers.
- [ ] AC9 — Given `git-conventions.md` and `security-conventions.md`, when the rules named above
      are read, then each names the script that enforces it.

## QA plan

- **Level:** unit — hook scripts with the repo's sibling-`.test.sh` pattern.
- **Why this level:** each hook is a pure input-to-verdict function over a command string or a
  staged diff, which is exactly what a unit test covers; there is no runtime to integrate with.
- **Specific checks:** `config.yml`'s `unit` command over all `scripts/*.test.sh` and the new hook
  tests — **confirm the runner actually reaches `hooks/`**, since `config.yml` currently globs
  `scripts/*.test.sh` only; widening that glob is part of this item. Then AC1–AC4 driven by hand in
  a live session, because a hook that passes its unit test and is mis-wired in `settings.json`
  looks identical from the test alone.

## Out of scope

- **A CI GitHub Action for the secret scan.** The reviewer suggested it, and it is right, but this
  repo's `CLAUDE.md` records that the local `gh` is a write-level collaborator and cannot change
  settings on the remote — branch protection and required checks need the owning account in the web
  UI. The scan lands as a script here; wiring it to CI is a separate item that needs Aaron's
  account.
- **The `Stop` hook for "stop what you started".** It is the right shape but this repo has no
  server, database or emulator to leave running, so it cannot be proved here. It belongs to
  whichever project first has a runtime.
- Deciding how the hooks reach other machines and projects — that is 0006.

## Notes & decisions

- **Why the hooks live in this repo rather than in a global `~/.claude/settings.json`.** A global
  setting is invisible to anyone cloning the repo and dies with the machine. Committed here they
  are portable, reviewable, and the repo becomes its own worked example — which is also what makes
  0006's distribution question answerable later.
- **Why refuse rather than warn.** The rule already exists in prose and is already being ignored;
  a warning adds a second prose channel. The reviewer's point is that unenforced rules decay, and
  a non-blocking hook is unenforced.
- **Build (2026-09-14): verified the hook JSON contract against the installed CLI (2.1.270)
  rather than recalling it** — `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/
  plugin-dev/skills/hook-development/` ships a full reference plus a working
  `examples/validate-bash.sh` this repo doesn't have its own copy of. Confirmed: stdin JSON with
  `tool_name`/`tool_input.command`; exit 2 = blocking refusal with stderr fed back to Claude;
  `.claude/settings.json` uses the direct (unwrapped) format, `{"hooks": {"PreToolUse": [...]}}`.
- **Refusal exit code is 2 for both hooks**, matching Claude Code's own "blocking error" code —
  not a value this ticket invented.
- **Neither hook is a shell parser.** Both split/match on the command string's tokens and shell
  chaining operators (`;`, `&&`, `||`, `|`) rather than a real AST, so a sufficiently obfuscated
  command (nested subshells, `eval`, unusual quoting) could evade either check. That's judged
  acceptable for what this ticket asks — catching the ordinary sweeping/secret-leaking shapes a
  session actually types — not for defeating deliberate evasion, which is a different (and much
  larger) problem than "the rule already exists in prose and is being ignored."
- **`git stash push`/`save` with only flags (no path token) is treated as bare** — e.g. `git
  stash push -u` alone still refuses, since `-u` without a path stashes everything untracked too.
  Only an actual pathspec (a bare token, or anything after `--`) counts as scoped.
- **The secret scanner's pattern set is deliberately small (three shapes)** — an AWS key ID, a
  generic `key|secret|token|password = "..."` assignment, and a PEM header — not an exhaustive
  scanner. `security-conventions.md`'s own rule is a floor ("scan the staged diff for anything
  that looks like a credential"), and a giant fragile pattern list would fail differently (false
  positives eroding trust in the hook) than a small honest one (some real secrets pass through).
- **A missing `jq` or `git` fails open (allow, with a stderr warning) on the secret scanner, same
  as an absent trigger.** This means a machine without `jq` gets a secrets gate that silently
  no-ops rather than blocking every commit — flagged for a human call rather than decided
  unilaterally, since "fail open" and "fail closed" are both defensible and this ticket's own
  FR7 argues for open (a hook that hard-fails on what it can't run gets the whole mechanism
  disabled by a frustrated user).
- **Two more mechanically-checkable rules noticed while scoping this ticket, not built here**
  (out of these ACs; parked in `.claude/backlog/FINDINGS.md` 2026-09-14): `git-conventions.md`'s
  enumerable "Destructive Commands" list (`git push --force`, `git reset --hard`, `git commit
  --amend`, `git rebase` on shared branches, `--no-verify`) has no hook at all yet; its
  ".gitignore Essentials" list has nothing checking a project's actual `.gitignore` against it.
