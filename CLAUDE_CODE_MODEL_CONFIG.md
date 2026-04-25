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

## Solution: Model Alias Mapping

Instead of setting `ANTHROPIC_MODEL` directly (which overrides all settings), use the alias mapping environment variables:

```bash
# In ~/.zshrc or ~/.bash_profile
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6
export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-6
export ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5-20251001
```

This maps the short aliases (`sonnet`, `opus`, `haiku`) to specific model versions while still respecting your settings.json for other configurations.

## Current Configuration

As of March 2026, the recommended default models are:
- **Sonnet**: `claude-sonnet-4-6` (latest)
- **Opus**: `claude-opus-4-6` (most capable)
- **Haiku**: `claude-haiku-4-5-20251001` (fastest)

## Related Documentation

- Model configuration: https://code.claude.com/docs/en/model-config.md
- Settings precedence: https://code.claude.com/docs/en/settings.md
- Claude API models: https://platform.claude.com/docs/en/about-claude/models/overview.md
