# Deployment Conventions

This file defines expectations for deploying and releasing. Deploys are where reversibility ends — they get more ceremony than anything else.

Scope split: `environment-conventions.md` owns *where* code runs — which environments a project needs, parity, per-environment config, and the promotion path. `infrastructure-conventions.md` owns the substrate those environments are made of, and recovery. `migration-conventions.md` owns schema and stored-data changes, which are the least reversible part of most deploys. This file owns the *act* of deploying application code into an environment. Telling the outside world — support, users, anyone who sells or teaches the product — is a third decision again, and it is `launch-conventions.md`. The "Production Readiness" section below asks whether *this deploy* is safe; whether the *product* can carry customers for years is `product-readiness-conventions.md`.

---

## Document the Topology Before the First Deploy

Every project's CLAUDE.md records, from day one — as the Environments block in `environment-conventions.md`:

- **What hosts what** — platform, service names, URLs for each environment.
- **Which account owns each piece** — hosting, DNS, database, and any third-party services. Account ambiguity is a real failure mode: two similar project names on different accounts will eventually cause a deploy to the wrong place.
- **What triggers a deploy** — a push to a branch? A manual command? If pushing deploys, then the push-approval rule in `git-conventions.md` is also the deploy gate. This is why that field is recorded rather than remembered: it's what tells an agent whether a given push is a release decision or just a backup, and an undocumented trigger makes every push a question.

If you can't answer "if I push this, what happens and where?", stop and find out before pushing.

## Deploying Is Not Releasing

Putting code in production and exposing its behavior to users are two separate decisions, and on a released project they should be separately controllable. That separation is what makes a rollout gradual and a mitigation instant — otherwise every release decision is also a deploy decision and your only rollback is the slowest one you have. `progressive-delivery-conventions.md` owns the mechanics; the rules below are about the deploy half.

## Deploys Are Explicit

- A deploy is a decision, never a side effect. AI tools never deploy on their own initiative — same rule as pushing.
- **Production is reached by promotion, not by direct deploy.** Once a project is released or has a second contributor, a change goes to staging first and the *same commit* is promoted forward — including hotfixes. Which environments exist and how much verification happens on each: `environment-conventions.md`.
- Use preview/staging deploys when the platform offers them (Cloudflare Pages previews, Vercel previews). Look at the preview before promoting.
- One change per deploy when practical. Deploying five commits at once means five suspects when something breaks.

## Know the Rollback Move First

Before deploying, know — not "figure out under pressure" — how to get back. When you *are* under pressure, `incident-conventions.md` owns the sequence and tells you whether rollback, forward fix, or restore is the right move:

- The platform's rollback mechanism (redeploy previous build, revert commit + push, version pinning).
- Whether the change is *actually* reversible: schema migrations, data writes, and cache changes may not roll back with the code. If not, plan the forward fix before deploying — and rehearse the migration on staging against a production-shaped dataset first (`environment-conventions.md`). An irreversible change is the case where staging earns its cost outright.
- Prefer backward-compatible sequencing for risky changes: deploy the code that handles both shapes, then migrate, then remove the old path. The full sequence and its rules are in `migration-conventions.md`.
- That a **restore** works, for anything a deploy could corrupt. Rollback recovers code; only a tested backup recovers data (`infrastructure-conventions.md`).

## Production Readiness

Before an app has real users, it has:

- **Error tracking** — production errors reach you without a user reporting them.
- **Meaningful logs** — enough server-side logging to reconstruct what happened. Never log secrets or PII.
- **A smoke check** — one fast manual or scripted pass ("can I load the app and do the core action?") run after every production deploy.

For AI features, observability requirements are stricter — see `ai-product-conventions.md`.

## Versioning

- Tag releases when a deploy is meaningful enough that you might need to reference or return to it. For continuously-deployed small apps, the git history plus the platform's deploy list is usually enough — don't add ceremony without a consumer for it.
