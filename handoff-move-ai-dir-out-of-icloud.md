# Handoff — move the AI directory out of iCloud-synced Documents

Paste the block between the lines into a new Claude Code session. Start that session from a
directory **outside** the tree being moved (e.g. `cd ~` first), or the working directory
disappears mid-task.

Survey performed 2026-08-12; re-verify the numbers before trusting them.

---

Move `~/Documents/Professional/AI` out of the iCloud-synced Documents folder to
`~/Developer/AI`, and fix every reference the move breaks.

## Why

`~/Documents` is iCloud-synced (Desktop & Documents sync is on — confirm with
`ls -d ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents`). The sync is generating
` 2` conflict-copy duplicates inside working trees. This already broke a build:
`node_modules/.bin/playwright` became `playwright 2`, so the binary vanished and
`npx playwright test` failed with `command not found` until node_modules was rebuilt.
Duplicates were also found in `Bomb Busters/dist/` (`index 2.html`, `sw 2.js`,
`manifest 2.webmanifest`) and in `Traitors and Allies/docs/`. A sync service writing into
`.git` is also a known route to repository corruption.

`~/Developer` is the right destination: macOS treats it as a developer folder and it is not
synced.

## What the survey found — don't re-derive this, but do re-verify

- 20 top-level directories, 11 git repos, 4.2 GB.
- **15 files inside the tree** contain the literal string `Documents/Professional/AI`.
  The important ones are the `CLAUDE.md` / `claude.md` files, which `@`-import the shared
  conventions by absolute path:
  `@/Users/aaronferguson/Documents/Professional/AI/AI_CODING_CONVENTIONS/CONVENTIONS_CORE.md`
  Every project with that import silently loses its conventions if the path is not updated.
  Known: Mandata, JerryLee, Traitors and Allies, LifeBook, TrueNorth, Bomb Busters, Justice,
  plus `Mandata/.claude/settings.local.json`, `Engine/workspace-config.md`,
  `house_hunt/SHEET_README.md`, `Mandata/specs/001-sprint-0/tasks.md`, `Mandata/README.md`,
  `JerryLee/DEVELOPMENT.md`, and two files under `skill-workspaces/`.
- **Claude Code state outside the tree, keyed by absolute path — this is the part a naive
  `mv` loses silently:**
  - `~/.claude.json` has **12 `projects` entries** keyed by the absolute path. These carry
    local-scope MCP servers, permissions and history. A moved project gets a fresh, empty
    entry and the old one is orphaned.
  - `~/.claude/projects/` has **11 directories** whose names encode the path, e.g.
    `-Users-aaronferguson-Documents-Professional-AI-Traitors-and-Allies`. **These hold the
    per-project memory** (`memory/MEMORY.md` and its files). Moving the repo orphans all of
    it unless the directories are renamed to match the new path.
- Clean, so don't spend time here: no references in `~/.zshrc` / `~/.zprofile` /
  `~/.bash_profile`, no symlinks into the tree, no LaunchAgents, no `.code-workspace` files,
  no Python venvs. `node_modules/.bin` symlinks are relative and survive a move.

## Rules

- **Nothing is deleted until verification passes.** Keep the original in place until the
  final step, and keep a written rollback command at every stage.
- **Commit all outstanding work first**, in every repo, before anything moves. A move with a
  dirty tree makes "did the move break this or was it already broken?" unanswerable.
- Work in phases and **stop at each gate** and report. Do not run the whole thing unattended.
- Absolute paths get replaced with the new absolute path; do not opportunistically convert
  them to `~` or relative paths in the same pass. One kind of change at a time.

## Phases

**Phase 1 — Inventory and make safe.**
Re-run the survey and reconcile against the numbers above. Then, in every one of the 11
repos: report `git status`, and confirm each has a remote and is pushed, or tell me which are
not (a local-only repo has no safety net if the move goes wrong). List anything untracked and
large that a move would carry along. Stop and report.

**Phase 2 — Force iCloud to materialise everything.**
Evicted files exist only as `.icloud` placeholders and will not survive a move intact. Find
any with `find ~/Documents/Professional/AI -name "*.icloud"`, force download, and confirm
zero remain. Also sweep the existing ` 2` duplicates and report them — do not delete any that
differ from their sibling; check each is byte-identical first. Stop and report.

**Phase 3 — Move.**
`mkdir -p ~/Developer` then move the tree. Same volume, so this is fast and reversible;
record the exact inverse command before running it. Verify the destination file count and
total size match the source. Stop and report.

**Phase 4 — Fix references inside the tree.**
Update the 15 files. The `CLAUDE.md` conventions imports are the highest-value ones — after
updating, verify at least one project actually resolves its import rather than assuming.
Commit per repo, one commit each, message explaining the move. Stop and report.

**Phase 5 — Migrate Claude Code state.**
Back up `~/.claude.json` first. Re-key the 12 `projects` entries to the new paths, and rename
the 11 `~/.claude/projects/` directories to the new mangled form (same scheme:
`/` → `-`, so `-Users-aaronferguson-Developer-AI-Traitors-and-Allies`). Confirm memory
survives by checking a known file — `Traitors and Allies` should still have its
`memory/MEMORY.md` with entries about security waves and the testing workflow. Stop and
report.

**Phase 6 — Verify, then clean up.**
Pick the 3 repos with the most active test suites and actually run them — `npm run test:all`
or equivalent — rather than assuming a move is inert. For Traitors and Allies specifically:
`npm run db:start`, `npm run test:all`, then `npm run db:stop`; note its Supabase CLI project
name is derived from the directory name, so confirm the local stack still comes up. Only once
that passes, remove any leftover source directory and report what changed.

**Do not push anything** without asking. In at least one of these repos a push to `main`
deploys to production.

---

## After the move

Update this file's own path references, and check whether any project's CLAUDE.md documents
its location. Consider whether `~/Developer` should be excluded from Time Machine or added to
a backup that is not iCloud — moving out of a sync service also moves out of its versioning,
which was the one thing iCloud was providing.
