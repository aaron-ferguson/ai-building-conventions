# GitHub MCP Setup Guide

## What is GitHub MCP?

GitHub's Model Context Protocol (MCP) server lets Claude interact with GitHub directly — creating/viewing issues, reviewing PRs, checking workflow runs, managing releases, and more.

---

## Prerequisites

Create a GitHub Personal Access Token (PAT):
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Create a token with scopes: `repo`, `workflow`, `read:org`
3. Store it securely using macOS Keychain — see `MCP_TOKEN_SECURITY.md` for the standard pattern

Quick version:
```bash
security add-generic-password -a "$USER" -s "GITHUB_PAT" -w "ghp_your_token_here"
echo 'export GITHUB_PERSONAL_ACCESS_TOKEN=$(security find-generic-password -a "$USER" -s "GITHUB_PAT" -w 2>/dev/null)' >> ~/.zshrc
source ~/.zshrc
```

---

## Setup Options

### Option A: Direct `.mcp.json` (simplest)

Create a `.mcp.json` file at your project root:

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

> Note: The top-level key is `mcpServers` when used in `.mcp.json` directly.

### Option B: Enable via Claude Code plugin (recommended if you use other plugins)

This is how the Mandata project does it. The GitHub plugin is already installed globally at:
`~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/github/`

To activate it for a project, add this to `.claude/settings.local.json`:

```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["github"]
}
```

No `.mcp.json` needed — Claude Code reads the plugin's config automatically.

---

## Verifying It Works

Run `/mcp` in Claude Code — `github` should appear in the list of connected servers.

Tools will be prefixed: `mcp__github__*`

---

## Refreshing Your Token

When your PAT expires, update Keychain and reload your shell (see `MCP_TOKEN_SECURITY.md` for the full pattern):

```bash
security delete-generic-password -a "$USER" -s "GITHUB_PAT"
security add-generic-password -a "$USER" -s "GITHUB_PAT" -w "your_new_token_here"
source ~/.zshrc
```

> Note: Claude Code's file permissions block writes to files outside the project directory, so you must run this in Terminal directly — not via Claude.

---

## Troubleshooting

- **Server not appearing**: Make sure `GITHUB_PERSONAL_ACCESS_TOKEN` is set in your shell and restart Claude Code
- **Auth errors**: Check your PAT hasn't expired and has the right scopes
- **Option B not working**: Confirm the plugin exists at `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/github/.mcp.json`

---

## Security Notes

- Never hardcode tokens in `.mcp.json` — always use `${VAR}` substitution
- The `${VAR}` form is safe to commit; add `.mcp.json` to `.gitignore` only if it contains values directly
- Store all credentials in macOS Keychain, not plaintext in `~/.zshrc` — see `MCP_TOKEN_SECURITY.md`
