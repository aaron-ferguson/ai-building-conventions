# MCP Conventions

Standards for configuring and securing Model Context Protocol servers across all projects.

---

## General Setup Pattern

`.mcp.json` references environment variables only — never token values directly. The `${VAR}` form is safe to commit.

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

Rules:
- Never hardcode token values in `.mcp.json`
- Never store token values in Claude memory — they are credentials, not context
- If a token is compromised, rotate at the source first, then update Keychain

---

## Token Security: macOS Keychain Pattern

Token values live in Keychain; your shell exports them as env vars at startup. The token value is never stored in a plaintext file — remaining env var exposure in the shell session is an acceptable tradeoff for local development.

### Storing a token (once per token)

```bash
security add-generic-password -a "$USER" -s "SERVICE_PAT" -w "your_token_value_here"
```

Add to `~/.zshrc`, then `source ~/.zshrc`:

```bash
export SERVICE_PAT=$(security find-generic-password -a "$USER" -s "SERVICE_PAT" -w 2>/dev/null)
```

### Updating a token

```bash
security delete-generic-password -a "$USER" -s "SERVICE_PAT"
security add-generic-password -a "$USER" -s "SERVICE_PAT" -w "your_new_token_here"
source ~/.zshrc
```

No changes needed to `.mcp.json` or `.zshrc` — only the Keychain entry changes.

---

## Established Tokens

| Env Var | Keychain Service Name | MCP Server | Used In |
|---|---|---|---|
| `SUPABASE_PAT` | `SUPABASE_PAT` | `@supabase/mcp-server-supabase` | Traitors and Allies |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | `GITHUB_PAT` | GitHub MCP | All projects |

Update this table as new tokens are added.

---

## MCP Servers

### GitHub

PAT scopes required: `repo`, `workflow`, `read:org`  
Env var: `GITHUB_PERSONAL_ACCESS_TOKEN` / Keychain key: `GITHUB_PAT`

**Option A — Direct `.mcp.json`:**

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

**Option B — Claude Code plugin** (plugin already installed at `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/github/`): activate by adding `"enabledMcpjsonServers": ["github"]` to `.claude/settings.local.json` — no `.mcp.json` needed.

Verify: run `/mcp` in Claude Code — `github` appears in the list; tools are prefixed `mcp__github__*`.  
If auth fails: check PAT hasn't expired and has the correct scopes; confirm env var is set (`echo $GITHUB_PERSONAL_ACCESS_TOKEN`).
