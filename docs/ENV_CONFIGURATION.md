# Environment Configuration (.env)

## Overview

The `install.sh` script now supports pre-configuration via a `.env` file. This is especially useful for **GitHub Codespaces** where the script runs automatically on boot and you don't have interactive access during installation.

## Why Use .env?

1. **Non-interactive Codespace Boot**: When a Codespace starts, `install.sh` runs automatically without user input
2. **No Doppler Access**: Initial boot happens before you can authenticate with Doppler
3. **Automated Authentication**: Pre-populate GitHub tokens and API keys for hands-free setup
4. **Customized Installation**: Skip or enable specific components without editing the script

## Quick Start

### Option 1: Use Pre-configured Defaults (Recommended)
The repository includes a pre-configured `.env` file with safe defaults:

```bash
# Already exists in the repo - no action needed
cat .env
```

**What's included:**
- ✅ Deferred plugin installation (fast boot)
- ✅ All essential tools enabled
- ⏭️ No tokens (user sets up manually after boot)

### Option 2: Customize for Your Needs

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit with your tokens:**
   ```bash
   nvim .env
   ```

3. **Add your GitHub token:**
   ```bash
   # Get token from: https://github.com/settings/tokens
   GH_TOKEN=ghp_your_token_here
   ```

4. **Commit (optional):**
   ```bash
   # If you trust the Codespace environment
   git add .env
   git commit -m "Add personalized .env config"
   ```

   ⚠️ **Security Warning**: Don't commit real tokens to public repos!

## Configuration Options

### Authentication Tokens

```bash
# === Doppler Service Token (Recommended) ===
# Non-interactive authentication - no browser login required
# Get from: https://dashboard.doppler.com → Project → Access → Service Tokens
DOPPLER_TOKEN=dp.st.dev.your_token_here

# === Direct Tokens (Alternative) ===
# Use these if not using Doppler

# GitHub CLI (for gh commands, Copilot authentication)
GH_TOKEN=ghp_your_github_token_here
# OR
GITHUB_TOKEN=ghp_your_github_token_here

# OpenAI (for AI coding assistants)
OPENAI_API_KEY=sk-your_openai_key_here

# Anthropic Claude
ANTHROPIC_API_KEY=sk-ant-your_anthropic_key_here
```

### Installation Flags

```bash
# Skip specific components (set to "true")
SKIP_NEOVIM_INSTALL=false
SKIP_NERD_FONTS=false       # Large download (~100MB)
SKIP_YAZI_INSTALL=false
SKIP_DOPPLER_INSTALL=false
SKIP_NPM_TOOLS=false        # Copilot CLI, Kilocode, OpenCode

# Auto-install Neovim plugins during setup
# "false" = faster boot (plugins install on first nvim launch)
# "true" = longer boot (~3-5 min) but nvim is immediately ready
AUTO_INSTALL_NVIM_PLUGINS=false
```

### Shell Integration

```bash
# Automatically configure shell (usually leave enabled)
AUTO_SETUP_BASHRC=true
AUTO_SETUP_STARSHIP=true    # Fancy prompt
AUTO_SETUP_ZOXIDE=true      # Smart cd
AUTO_SETUP_ALIASES=true     # Git shortcuts, etc.
```

### Logging

```bash
LOG_LEVEL=INFO              # DEBUG, INFO, WARN, ERROR
DEBUG_MODE=false            # Verbose output
```

## Authentication Priority

The script checks for authentication in this order:

1. **`.env` file** (this file)
2. **Doppler** (if configured and authenticated)
3. **Existing auth** (already logged in)
4. **Manual prompt** (interactive mode only)

## Common Use Cases

### Scenario 1: Fast Boot, Manual Setup Later
**Use case**: Quick Codespace startup, setup auth after boot

```bash
# .env (default configuration)
AUTO_INSTALL_NVIM_PLUGINS=false
GH_TOKEN=
# Leave tokens empty
```

**After boot:**
```bash
# Authenticate manually
gh auth login
doppler login
# OR run setup script
ds  # Alias for doppler-setup.sh
```

---

### Scenario 2: Fully Automated Setup
**Use case**: Zero-touch Codespace, everything ready immediately

```bash
# .env
AUTO_INSTALL_NVIM_PLUGINS=true
GH_TOKEN=ghp_your_secure_token_here
OPENAI_API_KEY=sk-your_key_here
```

**Result**: Codespace fully configured on first boot (~5 min)

---

### Scenario 3: Minimal Install (Testing)
**Use case**: Fast iteration, testing dotfiles changes

```bash
# .env
SKIP_NERD_FONTS=true
SKIP_YAZI_INSTALL=true
SKIP_NPM_TOOLS=true
AUTO_INSTALL_NVIM_PLUGINS=false
```

**Result**: Only core tools installed (~30 seconds)

---

### Scenario 4: Use Doppler for Everything
**Use case**: Enterprise secrets management

```bash
# .env (minimal config)
DOPPLER_TOKEN=dp.st.your_token_here
DOPPLER_PROJECT=dotfiles
DOPPLER_CONFIG=dev
# Leave other tokens empty - Doppler will provide them
```

**Result**: All secrets fetched from Doppler

## Security Best Practices

### ✅ DO:
- Use `.env` for **Codespaces** (ephemeral environments)
- Use **Doppler** for production secrets
- Keep `.env.example` in version control (no secrets)
- Add `.env` to `.gitignore` for local development

### ❌ DON'T:
- Commit `.env` with real tokens to **public repos**
- Share your `.env` file
- Store production secrets in `.env` files
- Reuse tokens across environments

## Troubleshooting

### Problem: Tokens not working
```bash
# Check if .env is being loaded
grep "Loading configuration" install.log

# Verify env vars are set
echo $GH_TOKEN
echo $DOPPLER_TOKEN
```

### Problem: Doppler authentication fails
```bash
# Check if DOPPLER_TOKEN is set
echo $DOPPLER_TOKEN

# Test authentication
doppler whoami

# If fails, generate service token:
# 1. Go to https://dashboard.doppler.com
# 2. Select project → config
# 3. Access → Service Tokens → Generate
# 4. Add to .env: DOPPLER_TOKEN=dp.st.dev.your_token
```

### Problem: Installation still prompts for input
```bash
# Ensure you're in non-interactive mode (Codespaces auto-run)
# OR add tokens to skip prompts:
echo "GH_TOKEN=ghp_your_token" >> .env
```

### Problem: Script ignores .env changes
```bash
# Re-run installation
./install.sh

# OR restart Codespace
gh codespace rebuild
```

## Files

- **`.env`**: Active configuration (gitignored by default, **included in repo**)
- **`.env.example`**: Template with all options documented
- **`install.sh`**: Auto-loads `.env` on startup
- **`.gitignore`**: Excludes `.env` (but current repo includes it)

## Migration from Doppler-Only

If you previously used only Doppler:

1. **.env now runs first**: No changes needed, Doppler is still fallback
2. **Add tokens to .env**: For faster boot without Doppler login
3. **Keep Doppler**: Use for sensitive production secrets

## Next Steps

- **View current config**: `cat .env`
- **Edit config**: `nvim .env`
- **Test installation**: `./install.sh`
- **Monitor logs**: `tail -f install.log`
- **Setup Doppler**: `ds` (doppler-setup.sh)

## Related Documentation

- [Doppler Setup Guide](./DOPPLER.md)
- [Installation Guide](../README.md)
- [Troubleshooting](./TROUBLESHOOTING.md) (if exists)
