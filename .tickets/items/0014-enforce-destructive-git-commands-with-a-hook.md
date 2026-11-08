---
id: "0014"
title: Enforce git-conventions.md's Destructive Commands list with a PreToolUse hook
type: feature
next: develop
status: ready
qa_level: unit
size: m
created: 2026-09-26
source: agent
parent:
blocked_by: []
relates: ["0004"]
expects:
  - hooks/block-destructive-git-commands.sh
  - hooks/block-destructive-git-commands.test.sh
  - .claude/settings.json
  - git-conventions.md
claimed_by:
claimed_at:
touches:
---

## Problem

`git-conventions.md`'s *Destructive Commands* section names a closed, fully enumerable set of
command shapes — exactly the kind of rule item 0004 proved a `PreToolUse`/`Bash` hook can enforce
— and none of it is covered by either hook 0004 shipped (`block-sweeping-git-stage.sh` only
refuses sweeping `add`/`commit`/bare `stash`; `scan-staged-for-secrets.sh` only scans staged
content). Today these five shapes are prose only:

- `git push --force` / `git push -f`
- `git reset --hard`
- `git commit --amend` on a published (already-pushed) commit
- `git rebase` on a shared branch
- any `--no-verify`

Noticed while scoping 0004 (`.claude/backlog/FINDINGS.md`, 2026-09-14) and not built there since it
was outside that ticket's own acceptance criteria.

## Functional requirements

- FR1 — A `PreToolUse` hook on `Bash` refuses `git push --force` and `git push -f` in any command
  form (bare, chained, with other flags), naming `git-conventions.md` and the safer alternative
  (`--force-with-lease`, or asking first) in its refusal message.
- FR2 — The same hook refuses `git reset --hard`, per the same file.
- FR3 — The same hook refuses any `--no-verify` flag on a git command.
- FR4 — The same hook refuses `git commit --amend`. Unlike FR1–FR3, "amend" is only destructive
  when the commit being amended is already published — decide in `develop` whether the hook can
  cheaply distinguish local-only from published commits (e.g. via `git status` / the upstream
  tracking ref) or whether it refuses amend unconditionally and documents the false-positive as
  the accepted cost, the same tradeoff item 0004's Notes & decisions made for its own
  not-a-shell-parser hooks.
- FR5 — `git rebase` against a branch with an upstream tracking ref is refused; a rebase with no
  upstream (a fresh local branch) is permitted.
- FR6 — The hook has a sibling `.test.sh` per this repo's established pattern, with one case per
  FR asserting the refusal and one case per FR asserting the safe form is permitted, following
  0004's precedent (`hooks/block-sweeping-git-stage.test.sh`).
- FR7 — The hook is wired into `.claude/settings.json` alongside 0004's two hooks.
- FR8 — `git-conventions.md`'s *Destructive Commands* section states that a hook enforces it and
  names the script, per 0004's FR6 precedent.
- FR9 — Per `security-conventions.md`'s now-landed "A Security Control That Cannot Run Blocks"
  principle, the hook fails closed on a missing dependency (`jq`) or an unscannable input, exactly
  as 0004's two hooks do — this is not optional just because the new hook enforces git hygiene
  rather than a secrets control; the principle is not scoped to secrets.

## Non-functional requirements

| Dimension | Requirement for this item | How it would red | Convention |
|---|---|---|---|
| Security | The hook fails closed per FR9 | a missing `jq` produces a refusal, not a silent allow | `security-conventions.md` |
| Dependencies | POSIX shell using tools already on a stock macOS/Linux, matching 0004 | a hook that needs an install is a hook not running on the machine that needed it | `dependency-conventions.md` |
| Documentation | FR8 lands in the same change as the hook | `git-conventions.md` names no script after this ticket closes | `documentation-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given the hook installed, when `git push --force` or `git push -f` runs, then it is
      refused and the message names `git-conventions.md`.
- [ ] AC2 — Given the hook installed, when `git push --force-with-lease` runs, then it is permitted.
- [ ] AC3 — Given the hook installed, when `git reset --hard` runs, then it is refused.
- [ ] AC4 — Given the hook installed, when any git command carries `--no-verify`, then it is
      refused.
- [ ] AC5 — Given the hook installed, when `git commit --amend` runs, then it is handled per the
      FR4 decision made in `develop` (refused unconditionally, or refused only when the current
      branch has an upstream and the commit being amended is already pushed) — record which in
      Notes & decisions.
- [ ] AC6 — Given the hook installed, when `git rebase` runs on a branch with an upstream tracking
      ref, then it is refused; when run on a branch with no upstream, it is permitted.
- [ ] AC7 — Given the hook's `.test.sh`, when the `unit` command runs, then all cases pass,
      including a missing-`jq` case asserting a refusal (per FR9).
- [ ] AC8 — Given `.claude/settings.json`, when it is read, then it wires this hook alongside
      0004's two.
- [ ] AC9 — Given `git-conventions.md`'s *Destructive Commands* section, when it is read, then it
      names this hook.

## QA plan

- **Level:** unit — hook script with the repo's sibling-`.test.sh` pattern, matching 0004.
- **Why this level:** each check is a pure input-to-verdict function over a command string, no
  runtime to integrate with.
- **Specific checks:** `config.yml`'s `unit` command; AC1–AC6 also driven by hand in a live
  session per 0004's precedent, since a hook that passes its own test and is mis-wired in
  `settings.json` looks identical from the test alone.

## Out of scope

- Detecting "published" via anything beyond the upstream tracking ref (e.g. querying the remote
  to see if the exact SHA is reachable there) — FR4/FR5 use the cheap, local signal only.
- A real shell parser. Same tradeoff 0004 accepted: obfuscated commands (subshells, `eval`,
  unusual quoting) can evade this, same as 0004's two hooks.

## Notes & decisions

- 2026-09-26 — Filed by `retro`, draining `.claude/backlog/FINDINGS.md` (2026-09-14, "Destructive
  Commands hook gap", noticed while scoping 0004 and parked rather than built there).
