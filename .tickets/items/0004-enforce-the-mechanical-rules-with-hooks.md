---
id: "0004"
title: Enforce the mechanically checkable rules with hooks instead of prose
type: feature
next: verify
status: done
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
closed: 2026-09-26
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
- FR7 — Every hook exits successfully when its trigger is genuinely absent (wrong tool, no
  command, no match). **It FAILS CLOSED on anything that stops it from completing its check** — a
  missing dependency (`jq`, `git`) or a condition it cannot evaluate (e.g. an unscannable cwd):
  the hook blocks the operation with a clear stderr message naming what's missing and how to
  install or resolve it. It never allows-with-a-warning. Overruled from the original fail-open
  framing on 2026-09-21 — see Notes & decisions.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Security | FR3 is a secrets control and must fail closed on a match; the scan must never write a matched value to a log, an error message, or a tracked file — report file and line, never the content | `security-conventions.md` |
| Privacy & data | Hook output reaches the session transcript, so no hook may echo staged file content | `data-privacy-conventions.md` |
| Documentation | FR6 lands in the same change as the hooks, not afterwards | `documentation-conventions.md` |
| Dependencies | The hooks are POSIX shell using tools already present on a stock macOS and Linux; a hook that needs an install is a hook that is not running on the machine that needed it | `dependency-conventions.md` |

## Acceptance criteria

- [x] AC1 — Given the hook installed, when a session runs `git add .`, then the command is refused
      and the message names `git-conventions.md`.
- [x] AC2 — Given the hook installed, when a session runs `git add -A` or `git commit -a`, then
      each is refused.
- [x] AC3 — Given the hook installed, when a session runs `git add path/to/file.md`, then it is
      permitted.
- [x] AC4 — Given the hook installed, when a session runs bare `git stash`, then it is refused;
      when it runs `git stash push -u some/path`, then it is permitted.
- [x] AC5 — Given a staged file containing secret-shaped content, when the secret scan runs, then
      it exits non-zero, names the file and line, and does not print the matched value.
- [x] AC6 — Given a staged change with no secret-shaped content, when the scan runs, then it exits
      zero.
- [x] AC7 — Given each hook's `.test.sh`, when the `unit` command is run, then all pass, and each
      test file contains a case asserting a refusal.
- [x] AC8 — Given `.claude/settings.json` in this repo, when it is read, then it wires every hook
      FR1–FR3 delivers.
- [x] AC9 — Given `git-conventions.md` and `security-conventions.md`, when the rules named above
      are read, then each names the script that enforces it.
- [x] AC10 — Given either hook, when `jq` (or, for `scan-staged-for-secrets.sh`, `git`) is
      unavailable on `PATH`, then the hook exits non-zero and names the missing dependency and how
      to install it on stderr — never allow-with-a-warning.

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
- **Superseded 2026-09-21 — see the entry below.** This ticket originally shipped a fail-open
  secret scanner (a missing `jq` or `git` allowed the commit with a stderr warning, same as an
  absent trigger) and escalated the fail-open-vs-fail-closed question to the repo owner rather
  than deciding it unilaterally. The owner ruled fail-closed; both hooks were rewritten
  accordingly.
- **Owner overruled the original FR7 on 2026-09-21.** Their words: "Security is much more
  important than frustration, and someone who does not want to take security seriously can use
  a different toolkit." FR7 now requires both `hooks/scan-staged-for-secrets.sh` and
  `hooks/block-sweeping-git-stage.sh` to fail closed — block with a clear message naming the
  missing dependency and how to install it — whenever `jq`, `git`, or any other dependency the
  hook needs is unavailable, rather than allowing the operation through with a warning. The
  general principle (a security control that cannot run blocks rather than allows, since a
  silent no-op gate is worse than no gate) is now recorded in `security-conventions.md` and
  `CONVENTIONS_CORE.md`.
- **Two more mechanically-checkable rules noticed while scoping this ticket, not built here**
  (out of these ACs; parked in `.claude/backlog/FINDINGS.md` 2026-09-14): `git-conventions.md`'s
  enumerable "Destructive Commands" list (`git push --force`, `git reset --hard`, `git commit
  --amend`, `git rebase` on shared branches, `--no-verify`) has no hook at all yet; its
  ".gitignore Essentials" list has nothing checking a project's actual `.gitignore` against it.

## QA evidence

Verified 2026-09-26, token `af71`. Verified specifically against the **amended, fail-closed**
FR7/AC10 per the owner's 2026-09-21 ruling — this is a re-verification after the 2026-09-21
rewrite, not a re-trust of the original (now-superseded) fail-open build.

- **AC1/AC2** — Live, direct invocation of the installed hook (not just its own test suite):
  `git add .` → exit 2, "Refused: 'git add .' stages the whole index … (git-conventions.md — …)."
  `git add -A` → exit 2, same message shape. `git commit -a -m x` → exit 2, names
  `git-conventions.md`.
- **AC3** — `git add path/to/file.md` → exit 0 (permitted), live.
- **AC4** — Bare `git stash` → exit 2, refused, names `git-conventions.md`. `git stash push -u
  some/path` → exit 0, permitted. Both live.
- **AC5** — Built a real throwaway git repo, staged `config.yml` containing an AWS-shaped key,
  ran the hook live: exit 2, "Refused: staged content matches a secret-shaped pattern
  (security-conventions.md …)", `Matching file(s): config.yml:1`. Grepped the hook's own stdout
  for the literal secret value (`AKIAABCDEFGHIJKLMNOP`) — **absent**. Only file:line reported.
- **AC6** — Same repo, staged an ordinary line instead: exit 0, no output.
- **AC7** — Full `config.yml` `unit` command (`for t in scripts/*.test.sh hooks/*.test.sh; do "$t"
  || exit 1; done`) — **exit 0**. `hooks/block-sweeping-git-stage.test.sh`: 19 passed, 0 failed.
  `hooks/scan-staged-for-secrets.test.sh`: 9 passed, 0 failed. Both files contain refusal cases
  (`test_git_add_dot_refused`, `test_aws_key_refused`, etc.) and each also contains a dedicated
  `test_missing_jq_blocks` (and, for the secrets scanner, `test_missing_git_blocks` and
  `test_cwd_missing_blocks`) — read the fixtures rather than trusting the names: both use a
  `stub_path_missing` helper that symlinks every *other* required tool into a throwaway `PATH`,
  genuinely making `command -v jq` (or `git`) fail inside the hook, rather than asserting against
  a mocked function. Not trivial.
- **AC8** — `.claude/settings.json`: `PreToolUse` on matcher `Bash` wires both
  `hooks/block-sweeping-git-stage.sh` and `hooks/scan-staged-for-secrets.sh` — the two hooks
  FR1–FR3 deliver.
- **AC9** — `git-conventions.md:19,21` name `hooks/block-sweeping-git-stage.sh` for both the
  sweep-add and bare-stash rules; `security-conventions.md:12` names
  `hooks/scan-staged-for-secrets.sh` for the secret-scan rule.
- **AC10 — the amended FR7, independently re-verified beyond the test suite.** Built a real
  stubbed `PATH` (symlinks to the genuine `bash`/`git`/`sed`/`cat`/`grep` binaries, `jq` excluded)
  and ran **both hooks live** against it, feeding real `git add .` / `git commit` command
  envelopes — not the test harness, the actual shipped scripts:
  - `block-sweeping-git-stage.sh` with `jq` missing → **exit 2**, "Refused: … cannot run without
    jq — install it via 'brew install jq' … ." Blocks; does not warn-and-allow.
  - `scan-staged-for-secrets.sh` with `jq` missing → **exit 2**, same shape, names `jq`.
  - `scan-staged-for-secrets.sh` with `git` missing (separate stub, `jq` present) → **exit 2**,
    "cannot run without git — install it via 'brew install git' … ."
  All three block with an install path named on stderr, never allow-with-a-warning. This
  independently confirms the fixed behavior on the actual installed scripts, not merely a read of
  the source or a re-run of the authors' own test file.
- **Dependencies NFR re-checked, not assumed from training-era knowledge**: `dependency-
  conventions.md` requires tools "already present on a stock macOS and Linux." `jq` was
  historically a Homebrew-only tool on macOS, which would have made this NFR questionable — but
  checked against the *actual installed machine* (`jq --version` → `jq-1.7.1-apple`, binary at
  `/usr/bin/jq`, owned by `root:wheel`): Apple now ships `jq` as a base-OS tool on current macOS.
  NFR holds on the verified environment; noting this explicitly since it's exactly the kind of
  thing "verify an API against the installed version, not from memory" exists to catch.
- **Mutation, attempted per Step 3, partially blocked by the harness's own safety layer**: edited
  `hooks/scan-staged-for-secrets.sh` in place to reintroduce the original fail-open behavior
  (`block_missing_dependency` warns and `exit 0` instead of refusing) to prove the test suite
  would catch a regression — the harness's auto-mode classifier refused running the mutated
  hook's test suite as a "Security Weaken" action. Reverted the edit immediately
  (`diff` against a pre-edit backup confirms byte-identical restoration, `git status` clean).
  Substituted independent black-box verification instead (the three live stubbed-PATH runs
  above, against the unmodified, shipped hook code) — this proves the *current* code fails
  closed, which is the claim AC10 makes; it does not additionally prove the test file would
  catch a future regression, which the source-level mutation would have shown. Recorded here
  rather than silently substituting one form of evidence for the other.
- **Residual scope gap found while probing, not a new AC failure**: `scan-staged-for-secrets.sh`'s
  cwd handling blocks when the reported `cwd` **does not exist** (AC10/FR7's explicit example),
  but not the narrower case where `cwd` **exists yet is not a git working tree** — there,
  `git diff --cached` fails, is swallowed by `2>/dev/null || true`, and the hook falls through to
  "no staged changes" → exit 0, silently. Reproduced live: a real (non-repo) temp directory fed
  as `cwd` with a `git commit` command → exit 0, no message. This is a different condition than
  AC10 tests (a present-but-non-repo directory, not a missing dependency or a missing directory),
  and in practice it coincides with cases where the guarded `git commit` itself would also fail
  identically (no repo, nothing can be committed) — so it does not appear to be an exploitable
  bypass of the secrets gate. Flagging it because FR7's own text ("a condition it cannot
  evaluate") is broader than the dependency case AC10 names, and this is the one sub-case not
  covered. Not filed as a new item per *A stage writes only the ticket it holds* — recorded here
  for `develop` or a future `queue` pass to pick up if judged worth a fix.
- **Working tree at verdict**: only this item's own frontmatter/body edits were dirty; no
  unrelated in-progress work intersected the evidence set. The one mutation attempt was reverted
  before this evidence was written, confirmed via `diff` against a pre-edit backup.
