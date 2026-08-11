# Collaboration Modes

Every project declares a **collaboration mode** in its CLAUDE.md. This is the only axis on which these conventions flex — and it flexes narrowly. The bar for code quality, testing, security, architecture, and AI practice is identical in every mode. What changes is the **human process around merging and shipping a change**, which only earns its weight when more than one person shares the codebase.

One thing flexes on a *trigger* rather than on this axis: whether a project needs a staging environment, which depends on release stage (`environment-conventions.md`). Collaborative mode requires staging regardless; a solo project requires it as soon as it has real users. The distinction matters because a solo developer with public users should not have to declare themselves "collaborative" to get the environment discipline that protects those users.

The point of these conventions is building good habits that hold on every project — including the ones where you're the only developer. "Solo" is not a licence to lower the standard. It removes coordination overhead that has no second person to coordinate with; nothing else.

---

## Declaring the mode

In each project's CLAUDE.md:

```markdown
## Profile
- collaboration: solo        # or: collaborative
- company: none              # or: <name> → loads companies/<name>/ (gitignored)
- release: pre-release       # or: released → see environment-conventions.md
```

Default to `solo` unless a second person makes regular changes. Promote to `collaborative` the moment that changes — it's a one-line edit, and the "When to promote" trigger below tells you when.

---

## What is identical in every mode

These never relax. If anything, a solo project needs them *more*, because there's no second reviewer to catch what you miss.

- All of `coding-conventions.md` (naming, single responsibility, fail-loudly, types, YAGNI, immutability).
- TDD and the full `testing-conventions.md` cycle.
- Everything in `security-conventions.md` and `data-privacy-conventions.md`.
- Architecture defaults, dependency discipline, documentation baseline, observability.
- A working local environment, isolated from production, holding no production data or credentials (`environment-conventions.md`).
- Reproducible infrastructure and a restore you have actually tested (`infrastructure-conventions.md`) — a solo project's data loss is just as permanent.
- Migration discipline: additive schema changes, forward-only in production, seeds kept current (`migration-conventions.md`).
- All of `ai-product-conventions.md`.

---

## What flexes by mode

Only merge-and-ship ceremony. Three files carry a "By collaboration mode" note; this table is the summary.

| Area | Solo | Collaborative |
|---|---|---|
| **Merging** (`git-conventions.md`) | Commit directly to `main`; branch only for parallel work or risky spikes. | Feature branch → PR → at least one approval → merge. No direct pushes to `main`. |
| **Review** (`coding-conventions.md` review checklist) | Self-review against the checklist before committing. Treat your own AI-generated diffs as a junior's PR. | Checklist review by someone other than the author. AI-generated diffs get a human author-of-record who read them. |
| **CI gates** (`cicd-conventions.md`) | Tests run locally in the TDD cycle; CI optional but recommended once the project outlives a weekend. | CI required and enforced: tests + lint + typecheck must pass before merge. Branch protection on. |
| **Deploy approval** (`deployment-conventions.md`) | You approve your own deploy — but still explicitly, never as an automatic side effect of a push. | Deploy follows the team's release process; the never-push-without-approval rule is the gate. |
| **Staging** (`environment-conventions.md`) | Required once the project is `released`; before that it has no job. | Required regardless of release stage — two people's changes interact in ways neither tested locally. |

Everything not in this table is mode-independent.

---

## When to promote from solo to collaborative

Flip to `collaborative` when any of these becomes true — the same signals as `coding-conventions.md` Tier 3:

- A second person starts making regular changes.
- You need an audit trail of who approved what (often a company-profile requirement — see `companies/`).

Gaining real users is a *different* trigger: it flips `release: released`, which requires staging (`environment-conventions.md`) but does not by itself make a one-person project collaborative. Both can fire independently.

Promotion is deliberate and cheap: edit the one line in CLAUDE.md, turn on branch protection, and start opening PRs. Don't pre-adopt collaborative ceremony on a solo project "in case" — that's the same speculative-work mistake YAGNI warns against.
