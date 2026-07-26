# Deployment Conventions

This file defines expectations for deploying and releasing. Deploys are where reversibility ends — they get more ceremony than anything else.

---

## Document the Topology Before the First Deploy

Every project's CLAUDE.md records, from day one:

- **What hosts what** — platform, service names, URLs for each environment.
- **Which account owns each piece** — hosting, DNS, database, and any third-party services. Account ambiguity is a real failure mode: two similar project names on different accounts will eventually cause a deploy to the wrong place.
- **What triggers a deploy** — a push to a branch? A manual command? If pushing deploys, then the never-push-without-approval rule in `GIT_CONVENTIONS.md` is also the deploy gate.

If you can't answer "if I push this, what happens and where?", stop and find out before pushing.

## Deploys Are Explicit

- A deploy is a decision, never a side effect. AI tools never deploy on their own initiative — same rule as pushing.
- Use preview/staging deploys when the platform offers them (Cloudflare Pages previews, Vercel previews). Look at the preview before promoting.
- One change per deploy when practical. Deploying five commits at once means five suspects when something breaks.

## Know the Rollback Move First

Before deploying, know — not "figure out under pressure" — how to get back:

- The platform's rollback mechanism (redeploy previous build, revert commit + push, version pinning).
- Whether the change is *actually* reversible: schema migrations, data writes, and cache changes may not roll back with the code. If not, plan the forward fix before deploying.
- Prefer backward-compatible sequencing for risky changes: deploy the code that handles both shapes, then migrate, then remove the old path.

## Production Readiness

Before an app has real users, it has:

- **Error tracking** — production errors reach you without a user reporting them.
- **Meaningful logs** — enough server-side logging to reconstruct what happened. Never log secrets or PII.
- **A smoke check** — one fast manual or scripted pass ("can I load the app and do the core action?") run after every production deploy.

For AI features, observability requirements are stricter — see `AI_PRODUCT_CONVENTIONS.md`.

## Versioning

- Tag releases when a deploy is meaningful enough that you might need to reference or return to it. For continuously-deployed small apps, the git history plus the platform's deploy list is usually enough — don't add ceremony without a consumer for it.
