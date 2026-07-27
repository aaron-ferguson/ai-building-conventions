# Security Conventions

This file defines security expectations for all projects. It is loaded into AI context when a task touches auth, credentials, user input, or data visibility.

---

## Secrets Never Touch the Repo

- No token, key, password, or connection string appears in source, config, commit history, or AI conversation context — ever. Not "temporarily," not in a comment, not in an example.
- Secrets live in the macOS Keychain and reach processes as environment variables — see `mcp-conventions.md` for the pattern.
- `.env` and `.env.*` are gitignored in every project (see `git-conventions.md`). Provide a committed `.env.example` with variable names only.
- Before any commit that touched config: scan the staged diff for anything that looks like a credential.
- If a secret leaks: rotate at the source first, then clean up. Removing it from the code does not un-leak it.

## Validate at Trust Boundaries

- All external input is hostile until validated: user input, URL params, request bodies, webhook payloads, file uploads, LLM output.
- Validation happens **server-side**. Client-side validation is UX, not security — anything the client enforces, the server must enforce again.
- Validate at the boundary, then trust internally. Don't re-validate the same value at every layer; validate once where it enters.

## The Server Is the Authority

- The client is a rendering surface, not a decision-maker. Permissions, prices, scores, game state, and data visibility are computed and enforced server-side.
- Never send the client data it isn't allowed to see and rely on the UI to hide it. If it crossed the wire, it's exposed. (Bomb Busters' `projectClientState()` hand-isolation invariant is this rule applied.)
- Authorization is checked on every request, not just at login. Default deny.

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
