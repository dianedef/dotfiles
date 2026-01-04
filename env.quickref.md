# .env Quick Reference

## TL;DR - Common Scenarios

### 1. Default (Fast Boot, No Tokens)
```bash
# Use existing .env - no changes needed
# Boots in ~1 min, setup auth later
./install.sh
```

### 2. Add GitHub Token (Auto-Auth)
```bash
# Edit .env
echo 'GH_TOKEN=ghp_YOUR_TOKEN_HERE' >> .env

# Reinstall
./install.sh
```

### 3. Full Auto-Install (Slow Boot)
```bash
# Edit .env
sed -i 's/AUTO_INSTALL_NVIM_PLUGINS=false/AUTO_INSTALL_NVIM_PLUGINS=true/' .env

# Boots in ~5 min, everything ready
./install.sh
```

### 4. Minimal/Fast Testing
```bash
# Edit .env
cat >> .env << EOF
SKIP_NERD_FONTS=true
SKIP_YAZI_INSTALL=true
SKIP_NPM_TOOLS=true
EOF

# Boots in ~30 sec
./install.sh
```

## Key Variables

| Variable | Default | Options | Effect |
|----------|---------|---------|--------|
| `AUTO_INSTALL_NVIM_PLUGINS` | `false` | `true`/`false` | Plugins install during setup vs first launch |
| `GH_TOKEN` | _(empty)_ | `ghp_...` | Auto-authenticate GitHub CLI |
| `SKIP_NEOVIM_INSTALL` | `false` | `true`/`false` | Skip Neovim download |
| `SKIP_NERD_FONTS` | `false` | `true`/`false` | Skip font install (saves ~100MB) |
| `SKIP_YAZI_INSTALL` | `false` | `true`/`false` | Skip file manager |
| `SKIP_NPM_TOOLS` | `false` | `true`/`false` | Skip Copilot CLI, etc. |
| `LOG_LEVEL` | `INFO` | `DEBUG`/`INFO`/`WARN`/`ERROR` | Verbosity |

## Commands

```bash
# View current config
cat .env

# Edit config
nvim .env

# Copy example
cp .env.example .env

# Test without installing
bash -n install.sh

# Run with overrides
AUTO_INSTALL_NVIM_PLUGINS=true ./install.sh

# View logs
tail -f install.log
```

## Priority Order

1. `.env` file (highest)
2. Doppler secrets
3. Existing authentication
4. Manual prompt

## Troubleshooting

**Problem**: Changes not applied
```bash
# Verify .env exists in script directory
ls -la .env

# Check it's being loaded
./install.sh | head -5
# Should show: "📋 Loading configuration from .env file..."
```

**Problem**: Token not working
```bash
# Check format (no quotes, no spaces)
grep GH_TOKEN .env
# Should be: GH_TOKEN=ghp_abc123

# Test manually
export $(grep -v '^#' .env | xargs)
echo $GH_TOKEN
```

**Problem**: Still prompts for input
```bash
# Non-interactive mode only applies when:
# 1. Script detects no TTY (Codespace auto-run)
# 2. OR no tokens configured

# Add token to skip prompts
echo "GH_TOKEN=ghp_YOUR_TOKEN" >> .env
```

## See Also

- Full documentation: [docs/ENV_CONFIGURATION.md](docs/ENV_CONFIGURATION.md)
- Installation guide: [README.md](README.md)
- Doppler setup: [docs/configuration/DOPPLER.md](docs/configuration/DOPPLER.md)
