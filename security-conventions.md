# Security Conventions

This file defines security expectations for all projects. It is loaded into AI context when a task touches auth, credentials, user input, or data visibility.

---

## Secrets Never Touch the Repo

- No token, key, password, or connection string appears in source, config, commit history, or AI conversation context — ever. Not "temporarily," not in a comment, not in an example.
- Secrets live in a secure OS secret store (macOS Keychain, Windows Credential Manager, Linux Secret Service, or a dedicated secrets manager) and reach processes as environment variables — see `mcp-conventions.md` for the pattern.
- `.env` and `.env.*` are gitignored in every project (see `git-conventions.md`). Provide a committed `.env.example` with variable names only.
- Before any commit that touched config: scan the staged diff for anything that looks like a credential.
- If a secret leaks: rotate at the source first, then clean up. Removing it from the code does not un-leak it — and **preserve the evidence of scope before tidying anything**, because a leaked credential is a security incident with its own path (`incident-conventions.md`).

## Validate at Trust Boundaries

- All external input is hostile until validated: user input, URL params, request bodies, webhook payloads, file uploads, LLM output.
- Validation happens **server-side**. Client-side validation is UX, not security — anything the client enforces, the server must enforce again.
- Validate at the boundary, then trust internally. Don't re-validate the same value at every layer; validate once where it enters.

## The Server Is the Authority

- The client is a rendering surface, not a decision-maker. Permissions, prices, scores, game state, and data visibility are computed and enforced server-side.
- Never send client data shouldn't be seen and rely on the UI to hide it. If it's sent, it's exposed.
- Authorization is checked on every request, not just at login. Default deny.

## Production Access Is Least-Privilege

`data-privacy-conventions.md` covers least-privilege access to *data*. This is the same principle applied to the *systems* — the hosting account, the production database, the deploy pipeline, the secret store.

- **Nobody and nothing has standing production access it doesn't currently need.** Not a service, not a CI job, not a teammate, not an AI agent, not your everyday shell (`environment-conventions.md` — an agent's default target is local, without production credentials in reach).
- **Human production access is temporary and reasoned.** Grant it for a task, remove it when the task ends. Permanent admin "because it's easier" is the state every incident report describes in hindsight.
- **MFA on every account that can reach production** — hosting, DNS, database, secret store, source host. DNS and the source host are the ones people forget, and both are complete takeovers.
- **No shared credentials.** Access is attributable to one person or one service, so the audit trail means something and revoking one person doesn't require rotating everyone.
- **Machine identities get their own scoped credentials**, one per service and environment, with the narrowest permission set that works. A deploy token that can also read the database is two breaches for the price of one (`environment-conventions.md` — config and secrets are per-environment).
- **Production actions leave a trail you didn't have to remember to write** — provider audit logs on and retained, deploys recorded, and console access logged. If the only record of who changed production is someone's memory, you cannot investigate anything.

### Break-Glass Access

Some emergencies genuinely need more privilege than anyone holds day to day. That path is designed in advance, not improvised:

- **Define it before you need it** — what qualifies as an emergency, who may invoke it, how they authenticate, and where the credential lives.
- **Least privilege still applies.** Break-glass means "enough to fix this," not "root on everything."
- **It's time-boxed and revoked** when the emergency ends, not left active because things are calm now.
- **It's loud.** Invoking it notifies someone and is logged. Emergency access that nobody notices is just a backdoor with a polite name.
- **The credential is rotated after every use**, and the session is reviewed afterward — what was done, why, and what needs reconciling back into the infrastructure definition (`infrastructure-conventions.md` — drift is debt with a deadline). Rotation and revocation are close-out items on the incident, not optional cleanup (`incident-conventions.md`).

### By Project Scale

Solo, you *are* every role, so most of this collapses — but not to nothing. The floor: MFA on every account that can reach production, no production credentials on the machine or in the AI session you develop in, provider audit logging left on, and the recovery path for losing access to your own accounts written down somewhere you'd still have it. That last one is the solo equivalent of break-glass, and losing the only admin account is a genuinely common way a small project dies.

Team-scale controls — role-based grants, just-in-time elevation, approval workflows, formal access reviews — arrive with `collaboration: collaborative`, real users, or a company profile that mandates them (`companies/<name>/`).

## No Injection Paths

- Database queries are parameterized — never built by string concatenation.
- Shell commands never interpolate untrusted input. Prefer APIs over shelling out.
- Output is encoded for its context (HTML, URL, SQL). Frameworks do this by default — don't opt out (`dangerouslySetInnerHTML`, raw templates) without a documented reason.

## Don't Roll Your Own

- Auth, crypto, session management, and password handling come from the platform or a well-established library — never hand-written.
- Use the framework's CSRF/session defaults unless you can explain precisely why not.

## AI-Specific Rules

- LLM output is untrusted input. Never pipe it into a shell, query, or `eval` without the same validation any user input gets.
- Prompt injection is real: content retrieved from users or the web and fed to a model can contain instructions. Design so that injected instructions can't trigger privileged actions.
- Never paste secrets into an AI conversation to "help it debug." Redact first.

## When to Do a Security Pass

Run a deliberate security review (e.g. Claude Code's `/security-review`) — not just the normal review checklist — when a change touches:

- Auth flows, session handling, or credentials
- What data is visible to which user
- Anything that executes, evaluates, or renders external input
- Payment or PII handling
