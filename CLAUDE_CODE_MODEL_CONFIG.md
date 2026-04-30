# Claude Code Model Configuration

## Model Selection Precedence

Claude Code determines which model to use based on this precedence order (highest to lowest):

1. **Managed settings** - Server-managed policies (cannot be overridden)
2. **Command-line flag** - `--model <model>` (session-specific)
3. **Environment variable** - `ANTHROPIC_MODEL` (user-configured)
4. **Local settings** - `.claude/settings.local.json` (project-specific personal overrides)
5. **Project settings** - `.claude/settings.json` (shared team settings)
6. **User settings** - `~/.claude/settings.json` (global personal settings)
7. **Default** - System default based on account tier

## Common Issue: Settings Not Being Respected

If you set a model in `~/.claude/settings.json` but sessions still use a different model, check for:

1. **Environment variables** - Run `env | grep ANTHROPIC` to check
2. **VS Code terminal inheritance** - VS Code inherits environment from its parent process
3. **Shell config** - Check `.zshrc`, `.zshenv`, `.bash_profile`

## Use Alias Names, Not Pinned Versions

Refer to models by their tier alias (`sonnet`, `opus`, `haiku`) rather than pinning to specific version strings. Claude Code resolves aliases to the current recommended version for that tier automatically — no manual updates needed when models are upgraded.

```json
// Good — in settings.json
{ "model": "sonnet" }

// Bad — pins to a specific version that will go stale
{ "model": "claude-sonnet-4-6" }
```

If you are setting model env vars in `~/.zshrc` to work around VS Code inheritance issues, use the alias mapping variables rather than `ANTHROPIC_MODEL` (which overrides all settings):

```bash
# Maps the alias to whatever the current default is — no version pinning
export ANTHROPIC_DEFAULT_SONNET_MODEL=sonnet
export ANTHROPIC_DEFAULT_OPUS_MODEL=opus
export ANTHROPIC_DEFAULT_HAIKU_MODEL=haiku
```

## Related Documentation

- Model configuration: https://docs.anthropic.com/en/docs/claude-code/settings
- Claude API models: https://docs.anthropic.com/en/docs/about-claude/models/overview
