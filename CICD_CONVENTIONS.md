# CI/CD & Code Review Conventions

This file defines continuous integration, automated checks, and the code-review process. It is loaded into AI context when a task touches pipeline config, branch protection, or review workflow.

**This is the most collaboration-mode-dependent file in the set.** Most of it describes the *collaborative* path. A solo project adopts the automatable parts (they're cheap and catch your own mistakes) and skips the human-coordination parts (there's no second human to coordinate with). Git branching strategy referenced here is a *preference*, not a principle — a company profile or project may override it (`CONVENTIONS_CORE.md` → "How overrides work").

---

## What CI Enforces (Both Modes, When CI Exists)

The value of CI is a consistent, un-skippable gate that runs the same way regardless of who (or what) made the change. When a project has CI, it runs, at minimum:

- **Tests** — the suite passes (`TESTING_CONVENTIONS.md`).
- **Lint + format check** — the linter and formatter agree the code is clean (these are the style authority, not the conventions files).
- **Typecheck** — typed code actually typechecks (`CODING_CONVENTIONS.md`).
- **A secret scan** — no credential slipped into the diff (`SECURITY_CONVENTIONS.md`). Cheap insurance, worth it even solo.

CI runs the same checks you're supposed to run locally. It exists because "supposed to" fails silently and CI doesn't.

## By Collaboration Mode

**Solo:**
- Tests run locally in the TDD cycle. CI is *optional but recommended* once a project outlives a weekend — a green-check gate catches the mistake you'd otherwise push.
- No PR or approval required. Commit to `main`, self-review against the `CODING_CONVENTIONS.md` checklist first.
- Branch protection is unnecessary overhead — you are the only writer.

**Collaborative:**
- CI is **required and enforced.** The checks above must pass before merge — no merging red, no exceptions negotiated per-PR.
- **Branch protection is on:** no direct pushes to `main`; changes land through pull requests.
- Every PR gets **at least one approving review from someone other than the author** before merge.
- `--no-verify` and force-pushes to shared branches stay off (`GIT_CONVENTIONS.md`).

## The Pull Request (Collaborative Mode)

- **One logical change per PR.** A reviewable PR is small enough to actually review; a 2,000-line PR gets rubber-stamped, which is the same as no review.
- The PR description says *what changed and why* — the reasoning that won't be obvious from the diff (mirrors the commit and comment rules).
- CI must be green before review is requested — don't spend a human's attention on something the machine would have rejected.

## Reviewing Code (Collaborative Mode)

The reviewer runs the `CODING_CONVENTIONS.md` review checklist against someone else's change, plus:

- Does it do what the PR says, and only that?
- Are there edge cases or failure modes the author missed?
- Does it match repo conventions, or introduce a divergent style?
- Does it touch auth, data visibility, or sensitive data? → trigger the `SECURITY_CONVENTIONS.md` / `DATA_PRIVACY_CONVENTIONS.md` pass.

**AI-generated diffs get a human author-of-record** who read and understood the change before requesting review (`CODING_CONVENTIONS.md` — "Review AI Output Like a Junior Engineer's PR"). "The AI wrote it" is never a reason a diff got less scrutiny — it's a reason it gets the same scrutiny a junior's PR would.

## Deploy Pipeline

CD specifics — what a merge triggers, environment promotion, rollback — live in `DEPLOYMENT_CONVENTIONS.md`. The one rule that spans both: **a deploy is an explicit decision, never an automatic side effect the pipeline makes for you** without the approval gate.

## Company Overrides

Required checks beyond this baseline, mandated branching strategy, and compliance sign-off gates are company-specific — record them in the company profile (`companies/<name>/`), where they override the preference-level defaults here.
