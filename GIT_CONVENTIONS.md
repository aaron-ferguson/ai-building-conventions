# Git Conventions

This file defines git workflow expectations for all projects. It is loaded into AI context at the start of every session via each project's CLAUDE.md.

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

- Default working branch is `main` unless the project specifies otherwise.
- Do not create branches speculatively — only when required for a PR or parallel work stream.

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
