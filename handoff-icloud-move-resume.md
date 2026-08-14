# Handoff — Resume the iCloud move (Phases 5 verify + 6)

**Written:** 2026-08-13, end of session `fbcfdd8b`. Paste this file's path into a fresh
Claude Code session started from `~/AI` to continue.

Companion doc: `handoff-move-ai-dir-out-of-icloud.md` (the original plan). That file is a
**historical record and was deliberately left un-rewritten** — its old paths are correct in
context. Don't "fix" it.

---

## Where things stand

The tree moved from `~/Documents/Professional/AI` to **`~/AI`**. Phases 1–5 are done.
The **old tree still exists, fully intact, and is still iCloud-synced** — it is the rollback,
and it keeps generating conflict copies until Phase 6 removes it. Do not work in it.

| Phase | Status |
|---|---|
| 1 Inventory & make safe | done |
| 2 Materialise + duplicate sweep | done (see "dataless files" below) |
| 3 Move | done, verified 11,939 files, 0 missing, 0 extra |
| 4 Fix references | done, 8 commits |
| 5 Migrate Claude Code state | done — **verify first, see Task 0** |
| 6 Verify & clean up | **not started** |

### Decisions already made (do not re-litigate)

- **Destination is `~/AI`**, not `~/Developer`. The original plan said both; the user chose
  `~/AI`. State keys are therefore `-Users-aaronferguson-AI-*`, not the `-Developer-` form
  written in the original plan.
- **`node_modules` was deliberately not copied.** 267,257 of 275,251 remaining files, and
  where the ~6,681 iCloud conflict duplicates live (incl. the `playwright 2` that broke a
  build). Reinstall from lockfiles instead. All six repos have lockfiles.
- **`Cozy` entry dropped** from `~/.claude.json` — the directory no longer exists.
- **Stale UPPERCASE conventions filenames are known and intentional.** Six projects' CLAUDE.md
  files point at `CODING_CONVENTIONS.md`, `GIT_CONVENTIONS.md` etc., which no longer exist
  (the repo was renamed to kebab-case). They are plain markdown text, not `@`-imports, so
  nothing auto-loads them. The user will fix these per-project later. **Not this project's job.**
- **`AI-project-template` was left with 21 staged-but-uncommitted files and no remote**, at the
  user's explicit choice after the risk was flagged.
- **Two `skill-workspaces/.../outputs/response.txt` files were left un-rewritten** — they are
  recorded eval transcripts; editing them falsifies the baseline.

---

## Task 0 — Verify the Phase 5 state migration held (do this FIRST)

The previous session had `~/.claude.json` open and might have rewritten it from memory on
exit. Everything else (directory renames, file edits) is durable on disk; only this is at risk.
Failure is silent — a reverted key means a project comes up with no trust state and no memory.

Report pass/fail per check, fix nothing yet:

1. **`~/.claude.json`** — parses as valid JSON; **zero** project keys contain
   `Documents/Professional/AI`; these 11 keys exist:
   `/Users/aaronferguson/AI/` + `{AI_CODING_CONVENTIONS, Bomb Busters, Engine, JerryLee,
   Justice, LifeBook, Mandata, Monster Mysteries, TrueNorth, Traitors and Allies,
   Traitors and Allies/Among-Us-IRL}`.
   Confirm `.../Documents/Professional/AI/Cozy` is **absent** (deliberately dropped).
   Expected totals: 17 entries, 0 stale, 12 new-path keys (the 11 above + `/Users/aaronferguson/AI`).

2. **`~/.claude/projects/`** — no directory name contains `Documents-Professional-AI`; these
   11 exist: `-Users-aaronferguson-AI`, plus `-Users-aaronferguson-AI-` followed by
   `AI-CODING-CONVENTIONS, Bomb-Busters, Economy, Engine, JerryLee, LifeBook, Mandata,
   Traitors-and-Allies, TrueNorth, house-hunt`.
   ⚠️ These names **start with a dash** — prefix paths with `./` or `ls`/`find` parses them as flags.

3. **Memory survived** —
   `~/.claude/projects/-Users-aaronferguson-AI-Traitors-and-Allies/memory/MEMORY.md`
   exists with 6 entries, including the Wave 2/3 security audit backlog and a testing-workflow
   rule about running both `npm test` and `npm run test:integration`.

4. **Conventions import resolves** — `~/AI/Traitors and Allies/claude.md` line 4 is
   `@/Users/aaronferguson/AI/AI_CODING_CONVENTIONS/CONVENTIONS_CORE.md`, and that file exists
   (134 lines).

**If check 1 fails:** only the JSON re-key needs redoing — remap the key prefix
`/Users/aaronferguson/Documents/Professional/AI` → `/Users/aaronferguson/AI`, drop the `Cozy`
key, preserve every payload verbatim. Backups: `~/.claude.json.bak-premove` and timestamped
copies in the old session's scratchpad.

---

## Phase 6 — Verify, then clean up

**Gate: stop and report after step 3. Do not run step 4 without the user's explicit go.**

### 1. Purge the contaminated `node_modules`

`Bomb Busters` moved via `mv` *before* the strategy switched to rsync, so **its `node_modules`
came across with the iCloud conflict duplicates intact** — the one tree that carries the
corruption forward. The user approved removing it.

```bash
rm -rf "/Users/aaronferguson/AI/Bomb Busters/node_modules"
```

No other project has `node_modules` at the destination except `mcp-servers`, which was copied
deliberately (485 files, 11 MB, no lockfile — **do not delete it**).

### 2. Reinstall from lockfiles

`npm ci` for: `Bomb Busters`, `JerryLee`, `Justice`, `LifeBook`, `TrueNorth`,
`Traitors and Allies`. **`Mandata` uses pnpm** — `pnpm install --frozen-lockfile`.

This doubles as proof the lockfiles are good. If one fails, that is a real finding: report it,
don't paper over it with a plain `npm install`.

### 3. Run the test suites

Pick the 3 repos with the most active suites. **Traitors and Allies is mandatory:**

```bash
cd "/Users/aaronferguson/AI/Traitors and Allies"
npm run db:start
npm run test:all
npm run db:stop      # stop what you started — same turn, per conventions
```

⚠️ **The Supabase trap.** The CLI derives its project name from the directory name
(previously `supabase_db_Traitors_and_Allies`). The directory name did not change, but its
**path** did, and the CLI may key state on either. Explicitly confirm the local stack comes up
and the container name is what you expect — `docker ps` — rather than assuming.

Then run two more suites (Bomb Busters and Mandata are the next most active by state-dir size).
A passing suite after a move is the only thing that makes the move inert.

**Stop and report results here.**

### 4. Only after step 3 passes — remove the source

```bash
# verify one last time that destination still matches, then:
rm -rf /Users/aaronferguson/Documents/Professional/AI
```

Removing this is what finally stops iCloud generating conflict copies. Until then the old tree
is the rollback. **Get explicit approval before running it.**

---

## Rollback

- **The 14 rsync'd entries** need no rollback — the source copy is retained until step 4.
- **The 9 entries moved by `mv`** exist only at the destination:
  ```bash
  mv ~/AI/{AI-project-template,AI_CODING_CONVENTIONS,"Bomb Busters","Candy Quest",Coach,Economy,Engine,Family,"Family Economy"} ~/Documents/Professional/AI/
  ```
- **Phase 4 commits** (one per repo, revert individually if needed):
  Mandata `7f7e5b8` · JerryLee `02d5cb6` · Traitors and Allies `88847f7` · LifeBook `c754fdd` ·
  TrueNorth `0a1cfe2` · Bomb Busters `2d489a4` · Justice `e5ff194` · Engine `db07a52`
- **Bomb Busters WIP commit** `88a5104` (made to clean the tree pre-move):
  `git -C ~/AI/"Bomb Busters" reset --mixed HEAD~1`
- **`~/.claude.json`**: `~/.claude.json.bak-premove`

---

## Gotchas learned the hard way

- **`find -name "*.icloud"` is NOT a materialisation check on current macOS.** It returned zero
  while the tree still held many **dataless** files — normal-looking to `ls`, `find`, and `du`,
  but with no local content until read. `mcp-servers` reported 456 KB and was actually 11 MB.
- **`mv` out of an iCloud-synced directory can wedge indefinitely.** It blocked 32+ minutes on a
  531 MB directory with zero bytes transferred, parked on a single `rename` syscall while
  `fileproviderd` spun at 125% CPU. **Use rsync (copy), verify, then delete.** Reading a dataless
  file triggers a normal on-demand download; renaming one can hang.
- **`~/.claude/projects/` names begin with `-`** and will be parsed as command-line flags.
- **`-Users-aaronferguson-AI` already existed** before migration — created by a session whose cwd
  was `~/AI`. A blind rename would have clobbered or nested it. Merge, don't overwrite.
- **`.claude.json` project keys can include nested sub-paths**
  (`Traitors and Allies/Among-Us-IRL`). Re-key by **prefix substitution**, not by matching a list
  of known top-level project names.
- **`Mandata/.claude/settings.local.json` is gitignored** — updated on disk, correctly not
  committed. It contains embedded heredocs; re-validate it parses as JSON after any edit.

---

## Rules that still apply

- **Do not push anything without asking.** In at least one of these repos, a push to `main`
  deploys to production.
- Nothing is deleted until verification passes; keep a written rollback at every stage.
- Work in phases, stop at each gate and report. Do not run unattended.
- Commit per repo, one logical commit each. Stage specific files — never `git add .` / `-A`.

---

## Open decision, not yet made

**What backs up `~/AI`?** Moving out of iCloud also moved out of iCloud's versioning. That sync
was doing something, badly — but it was doing something. Time Machine, a cloned repo remote, or
something else is a real decision the user has not yet made. Two repos have no safety net today:
`AI-project-template` (no remote, no commits at all) and `Justice` (`main` has no upstream).
Raise this once Phase 6 is complete; don't let it block Phase 6.
