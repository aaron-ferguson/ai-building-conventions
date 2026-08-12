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
- If a token is compromised, rotate at the source first, then update the secret store
- **One definition per server, in one scope.** Duplicates (`foo`, `foo-2`, `foo-3`, or the same
  name in both project and local scope) shadow each other and launch concurrently, and
  `npx`-launched duplicates race on one shared npx cache directory until it corrupts — after
  which *every* copy fails with `ENOTEMPTY`, including the correct one. Removing the duplicates
  does not fix it on its own; clear the cache entry under `~/.npm/_npx/` too.

---

## Token Security: OS Secret Store Pattern

Token values live in your operating system's secure secret store; your shell (or app startup) reads them into environment variables at launch. The token value is never written to a plaintext file — the remaining env-var exposure in the session is an acceptable tradeoff for local development.

Use whatever secure store your platform provides:

- **macOS** — Keychain, via the `security` command (worked example below).
- **Windows** — Credential Manager (`cmdkey`, or the PowerShell `CredentialManager` module).
- **Linux** — the Secret Service API / libsecret (`secret-tool store` / `secret-tool lookup`), backed by GNOME Keyring or KWallet.
- **Any platform, or a team** — a dedicated secrets manager (1Password CLI `op`, HashiCorp Vault, or a cloud provider's secret manager) is an equally valid backing store.

The pattern is identical everywhere: store the secret once, read it into an env var at shell/app startup, reference only the env var (`${VAR}`) in config.

### macOS example

Storing a token (once per token):

```bash
security add-generic-password -a "$USER" -s "SERVICE_PAT" -w "your_token_value_here"
```

Add to your shell profile (`~/.zshrc`, `~/.bashrc`, …), then reload it (`source` the file):

```bash
export SERVICE_PAT=$(security find-generic-password -a "$USER" -s "SERVICE_PAT" -w 2>/dev/null)
```

Updating a token:

```bash
security delete-generic-password -a "$USER" -s "SERVICE_PAT"
security add-generic-password -a "$USER" -s "SERVICE_PAT" -w "your_new_token_here"
source ~/.zshrc
```

No changes needed to `.mcp.json` or your shell profile — only the secret-store entry changes.

---

## Established Tokens

| Env Var | Secret Store Key | MCP Server | Used In |
|---|---|---|---|
| `SUPABASE_PAT` | `SUPABASE_PAT` | `@supabase/mcp-server-supabase` | Traitors and Allies |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | `GITHUB_PAT` | GitHub MCP | All projects |

Update this table as new tokens are added.

---

## MCP Servers

### GitHub

PAT scopes required: `repo`, `workflow`, `read:org`  
Env var: `GITHUB_PERSONAL_ACCESS_TOKEN` / Secret store key: `GITHUB_PAT`

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
