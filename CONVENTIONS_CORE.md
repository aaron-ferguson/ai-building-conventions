# Conventions — Core Reference

Essential rules for every session. No exceptions. Read the full files listed at the bottom when a task requires deeper guidance.

---

## Code

- Name things exactly what they are. Functions are verbs. Files are named for what they do.
- Each file does one thing. Each function does one thing.
- Validate inputs at the top. Throw descriptive errors. Never swallow failures silently.
- No magic numbers or strings — use a constants file. No clever one-liners.
- Use types: TypeScript over JavaScript; Python with full type hints.
- Max 2 levels of nesting. Extract early-return guards or named functions instead.
- YAGNI: only build what the current task requires. No speculative code.
- Comments explain why, not what. If you need to explain what, rename instead.
- Functions either return a value or cause a side effect — not both.
- Don't mutate inputs. Return new values.

## Testing

- TDD always: write the test first → confirm red → implement → confirm green → commit. No exceptions.
- Never auto-run tests — prompt the user to run them.

## Git

- Atomic commits. Imperative mood, sentence case: `Add`, `Fix`, `Update`, `Remove`.
- Stage specific files. Never `git add .` or `git add -A`.
- Never push without explicit user approval.

## AI Workflow

- Review every AI-generated diff like a junior engineer's PR — read it before shipping.
- Don't delegate to AI: architectural decisions, security design, product judgment.

---

## Load for More Detail

Read these when the current task warrants it:

- **Coding rules + Review Checklist** → `ai-coding-conventions/CODING_CONVENTIONS.md`
- **Testing** (TDD cycle, isolation, what to test) → `ai-coding-conventions/TESTING_CONVENTIONS.md`
- **Architecture** (modular monolith, vertical slices) → `ai-coding-conventions/ARCHITECTURE_CONVENTIONS.md`
- **Git** (destructive commands, branch management) → `ai-coding-conventions/GIT_CONVENTIONS.md`
- **Building AI features** (evals, RAG, observability) → `ai-coding-conventions/AI_PRODUCT_CONVENTIONS.md`
- **MCP setup** (token security, Keychain pattern) → `ai-coding-conventions/MCP_CONVENTIONS.md`
- **Model config** (alias mapping, settings precedence) → `ai-coding-conventions/CLAUDE_CODE_MODEL_CONFIG.md`
