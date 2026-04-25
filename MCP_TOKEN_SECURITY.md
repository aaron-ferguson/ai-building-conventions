# MCP Token Security: Using macOS Keychain for Personal Access Tokens

Any MCP server that requires a Personal Access Token (PAT) should follow this pattern. It keeps the secret encrypted at rest in macOS Keychain rather than stored in plaintext in your shell profile.

---

## The Pattern

`.mcp.json` (committed to git) references an environment variable — never the token value directly:

```json
{
  "mcpServers": {
    "some-service": {
      "command": "npx",
      "args": ["-y", "@some/mcp-server@latest"],
      "env": {
        "SERVICE_ACCESS_TOKEN": "${SERVICE_PAT}"
      }
    }
  }
}
```

The token lives in Keychain. Your shell retrieves it at startup and exports it as the env var.

---

## One-Time Setup (per token)

**Step 1 — Store the token in Keychain** (run once in Terminal):

```bash
security add-generic-password -a "$USER" -s "SERVICE_PAT" -w "your_token_value_here"
```

Replace `SERVICE_PAT` with a descriptive name for the token (e.g. `SUPABASE_PAT`, `GITHUB_PAT`).

**Step 2 — Retrieve it in `~/.zshrc`**:

```bash
export SERVICE_PAT=$(security find-generic-password -a "$USER" -s "SERVICE_PAT" -w 2>/dev/null)
```

**Step 3 — Reload your shell**:

```bash
source ~/.zshrc
```

---

## Updating a Token

When a token expires or is rotated, update Keychain (do not add a duplicate):

```bash
# Delete the old entry
security delete-generic-password -a "$USER" -s "SERVICE_PAT"

# Add the new one
security add-generic-password -a "$USER" -s "SERVICE_PAT" -w "your_new_token_here"

# Reload shell
source ~/.zshrc
```

No changes needed to `.mcp.json` or `.zshrc` — only the Keychain entry changes.

---

## Why This Is Better Than Plaintext in `~/.zshrc`

| Approach | Secret at rest | Visible to `env`? |
|---|---|---|
| Plaintext in `~/.zshrc` | Unencrypted on disk | Yes |
| Keychain + `~/.zshrc` lookup | Encrypted in Keychain | Yes (in session) |

The Keychain approach means the token value is never stored in a plaintext file. The remaining exposure is that the env var is visible to any process in your shell session — this is unavoidable when you need it as an env var, and is an acceptable tradeoff for local development.

---

## Verifying It Works

```bash
# Confirm the env var is set (shows the value — only run in a trusted terminal)
echo $SERVICE_PAT

# Confirm Keychain has the entry (does not print the value)
security find-generic-password -a "$USER" -s "SERVICE_PAT" > /dev/null && echo "Found"
```

---

## Established Tokens in This Setup

| Env Var | Keychain Service Name | MCP Server | Used In |
|---|---|---|---|
| `SUPABASE_PAT` | `SUPABASE_PAT` | `@supabase/mcp-server-supabase` | Traitors and Allies |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | `GITHUB_PAT` | GitHub MCP | All projects |

Update this table as new tokens are added.

---

## Security Rules

- Never hardcode token values in `.mcp.json` — always use `${VAR}` substitution
- The `${VAR}` form is safe to commit; the value never touches git
- Never store token values in Claude memory — they are credentials, not context
- If a token is compromised, rotate it at the source first, then update Keychain
