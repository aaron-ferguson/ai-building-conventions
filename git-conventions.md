# Git Conventions

This file defines git workflow expectations for all projects. The essentials (atomic commits, stage specific files, never push without approval) are summarized in `CONVENTIONS_CORE.md` (always loaded); load this full file for the complete commit/push/destructive-command and branch-management detail.

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

- **Never push without explicit user approval.** Pushing can trigger production deploys and is not easily reversible. Always confirm before pushing, even when asked to "ship it" or "deploy" — confirm the push specifically.
- Pushing is the user's decision, not the AI's default action.

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

## Project Overrides

Any deviation from these defaults (e.g. "never auto-commit", "always ask before committing") is declared in that project's CLAUDE.md and takes precedence over the defaults here.
