# Collaboration Modes

Every project declares a **collaboration mode** in its CLAUDE.md. This is the *only* axis on which these conventions flex — and it flexes narrowly. The bar for code quality, testing, security, architecture, and AI practice is identical in every mode. What changes is the **human process around merging and shipping a change**, which only earns its weight when more than one person shares the codebase.

The point of these conventions is building good habits that hold on every project — including the ones where you're the only developer. "Solo" is not a licence to lower the standard. It removes coordination overhead that has no second person to coordinate with; nothing else.

---

## Declaring the mode

In each project's CLAUDE.md:

```markdown
## Profile
- collaboration: solo        # or: collaborative
- company: none              # or: <name> → loads companies/<name>/ (gitignored)
```

Default to `solo` unless a second person makes regular changes. Promote to `collaborative` the moment that changes — it's a one-line edit, and the "When to promote" trigger below tells you when.

---

## What is identical in every mode

These never relax. If anything, a solo project needs them *more*, because there's no second reviewer to catch what you miss.

- All of `CODING_CONVENTIONS.md` (naming, single responsibility, fail-loudly, types, YAGNI, immutability).
- TDD and the full `TESTING_CONVENTIONS.md` cycle.
- Everything in `SECURITY_CONVENTIONS.md` and `DATA_PRIVACY_CONVENTIONS.md`.
- Architecture defaults, dependency discipline, documentation baseline, observability.
- All of `AI_PRODUCT_CONVENTIONS.md`.

---

## What flexes by mode

Only merge-and-ship ceremony. Three files carry a "By collaboration mode" note; this table is the summary.

| Area | Solo | Collaborative |
|---|---|---|
| **Merging** (`GIT_CONVENTIONS.md`) | Commit directly to `main`; branch only for parallel work or risky spikes. | Feature branch → PR → at least one approval → merge. No direct pushes to `main`. |
| **Review** (`CODING_CONVENTIONS.md` review checklist) | Self-review against the checklist before committing. Treat your own AI-generated diffs as a junior's PR. | Checklist review by someone other than the author. AI-generated diffs get a human author-of-record who read them. |
| **CI gates** (`CICD_CONVENTIONS.md`) | Tests run locally in the TDD cycle; CI optional but recommended once the project outlives a weekend. | CI required and enforced: tests + lint + typecheck must pass before merge. Branch protection on. |
| **Deploy approval** (`DEPLOYMENT_CONVENTIONS.md`) | You approve your own deploy — but still explicitly, never as an automatic side effect of a push. | Deploy follows the team's release process; the never-push-without-approval rule is the gate. |

Everything not in this table is mode-independent.

---

## When to promote from solo to collaborative

Flip to `collaborative` when any of these becomes true — the same signals as `CODING_CONVENTIONS.md` Tier 3:

- A second person starts making regular changes.
- The project gains real users and an outage would matter to someone other than you.
- You need an audit trail of who approved what (often a company-profile requirement — see `companies/`).

Promotion is deliberate and cheap: edit the one line in CLAUDE.md, turn on branch protection, and start opening PRs. Don't pre-adopt collaborative ceremony on a solo project "in case" — that's the same speculative-work mistake YAGNI warns against.
