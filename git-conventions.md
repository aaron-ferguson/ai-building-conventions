# Git Conventions

This file defines git workflow expectations for all projects. The essentials (commit freely without being asked, atomic commits, stage specific files, never push without approval) are summarized in `CONVENTIONS_CORE.md` (always loaded); load this full file for the complete commit/push/destructive-command and branch-management detail.

**The shape of the whole file in one line: committing is autonomous, pushing is human-gated.** Commits are local and reversible, and they are the audit trail of how a change came to be — so they should be frequent and they never need permission. Push is where a change becomes visible to others and can trigger a deploy, so that is the one place a human decides.

---

## Committing

- **Commit freely as work progresses** — don't wait for permission to create commits. Atomic commits as each logical unit completes are preferred over one large commit at the end.
- **Atomic commits** — one logical change per commit; don't bundle unrelated changes.
- **Commit messages:** imperative mood, sentence case, action-first:
  - `Add dark mode to LoginPage`
  - `Fix TypeScript build errors caused by incomplete coverage`
  - `Rename package to mandata`
  - Common prefixes: `Add`, `Fix`, `Update`, `Implement`, `Rename`, `Remove`
- **Stage specific files** — prefer `git add <file>` over `git add .` or `git add -A` to avoid accidentally committing `.env` files, secrets, or build artifacts.
- **Co-authorship:** include the following trailer in all AI-assisted commits:
  ```
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

## Pushing

Push is the gate because push is what reaches other people and what can trigger a deploy. Whether a given push needs approval depends on **what that push can actually reach** — determined from the project's documented deploy triggers, never guessed.

**The source of truth is the Environments block in the project's CLAUDE.md** (`environment-conventions.md`), whose *deploy trigger* column records what a push to each branch sets in motion. That column is what makes this rule mechanical instead of a judgment call.

- **A push that can trigger a deploy → explicit user approval, every time.** Confirm the push specifically, even when asked to "ship it" or "deploy." Not easily reversible, and it's the same gate as `deployment-conventions.md`'s "a deploy is a decision, never a side effect."
- **A push to a branch other people work from → explicit user approval.** It becomes someone else's problem the moment it lands.
- **A push that can do neither → sync, not release. No approval needed.** A working branch on a repo where that branch triggers nothing, or `main` on a solo project whose production deploy is a documented manual promote. This is off-machine backup, and withholding it means the only copy of the work is one laptop — which `infrastructure-conventions.md` treats as data with no backup at all. For these pushes only, this overrides an assistant default of pushing solely on request.
- **Anything ambiguous → ask.** No Environments block, no documented trigger, a trigger you can't map to this branch, or any doubt about who else reads it: that uncertainty resolves to asking. **Unknown is treated as "can deploy."**

Two things that follow from the ambiguity rule and are worth stating:

- **The prompt is a nudge to document.** If you had to ask because the deploy trigger wasn't written down, write it down — the next push shouldn't need the same conversation.
- **The grading applies to normal pushes only.** Force-pushes, and pushes to shared branches after a rebase, stay under "Destructive Commands" below and always need an explicit request regardless of what the branch triggers.

**Surface unpushed work at natural stopping points.** When commits are accumulating behind a gated push, say so and offer — "N commits unpushed, want these off this machine?" Forgetting is the actual failure mode here, not disagreement.

## Destructive Commands

The following require explicit user request before execution:
- `git push --force` / `git push -f`
- `git reset --hard`
- `git commit --amend` (on published commits)
- `git rebase` (interactive or otherwise, on shared branches)
- Any command with `--no-verify`

Never use these as shortcuts around failing hooks or unexpected state. Investigate the root cause instead.

## Branch Management

Branching *strategy* is a **preference, not a principle** — trunk-based, feature-branch, and GitFlow are all defensible, and none is strictly better for every context. The default below is the general-repo choice; a company profile or a project's CLAUDE.md may override it (`CONVENTIONS_CORE.md` → "How overrides work"). What does *not* flex is the pushing/destructive-command discipline above — that's principle-level.

- **General default (solo):** work directly on `main`; create a branch only for parallel work or a risky spike. No PR overhead when you're the only writer.
- **Collaborative mode:** changes land through pull requests on feature branches with branch protection on `main` — see `collaboration-modes.md` and `cicd-conventions.md`.
- **Company override:** if a company mandates a branching model (e.g. GitFlow, protected release branches), it's recorded in the company profile and wins for that company's projects.
- Whatever the strategy: don't create branches speculatively — only when the workflow actually requires one.

## .gitignore Essentials

Every project should ignore at minimum:
```
node_modules/
dist/
build/
.env
.env.*
coverage/
.DS_Store
*.log
```

Projects with infrastructure definitions add the tooling's state and local override files — `*.tfstate`, `*.tfstate.*`, `.terraform/`, `*.tfvars` and equivalents. State files hold plaintext secrets and must never be committed (`infrastructure-conventions.md`).

## Project Overrides

Any deviation from these defaults (e.g. "never auto-commit", "always ask before committing") is declared in that project's CLAUDE.md and takes precedence over the defaults here.
