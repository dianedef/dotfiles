# Doppler Secrets Management

Guide to using Doppler for secure API key management across dotfiles.

## 📖 What is Doppler?

**Doppler** is a secrets management platform that:
- 🔐 Stores API keys securely (encrypted)
- 🔄 Syncs secrets across devices (Codespaces, Termux, local)
- 🚀 Automates authentication in installation scripts
- 🌐 Provides web dashboard for management

## 🎯 Why Use Doppler?

Without Doppler, you'd need to:
- ❌ Manually enter API keys on each device
- ❌ Store keys in plain text files (security risk)
- ❌ Re-authenticate tools after each installation

With Doppler:
- ✅ One-time key setup
- ✅ Automated authentication
- ✅ Secure encrypted storage
- ✅ Easy key rotation

## 🚀 Quick Setup

### 1. Install Doppler

#### On Codespaces/Linux
```bash
curl -sS https://cli.doppler.com/install.sh | sh
```

#### On Termux
```bash
pkg install curl
curl -sS https://cli.doppler.com/install.sh | sh
```

#### On Windows
```powershell
# Install via Scoop
scoop install doppler
```

### 2. Login to Doppler

```bash
doppler login
```

This opens a browser for authentication.

### 3. Setup Project

```bash
cd ~/dotfiles
doppler setup --project dotfiles --config dev
```

This creates `.doppler.yaml` in your dotfiles directory.

## 🔑 Adding API Keys

### Using `doppler-setup.sh` (Recommended)

```bash
cd ~/dotfiles
./doppler-setup.sh
```

This interactive script will prompt you for:
- OpenAI API Key
- Anthropic (Claude) API Key
- GitHub Token
- Google AI (Gemini) API Key
- Groq API Key
- Deepseek API Key
- OpenCode API Key (if installed)

### Manual Setup

```bash
# GitHub (for gh cli authentication)
doppler secrets set GH_TOKEN="ghp_your_token_here"

# OpenAI (GPT models)
doppler secrets set OPENAI_API_KEY="sk-..."

# Anthropic (Claude models)
doppler secrets set ANTHROPIC_API_KEY="sk-ant-..."

# Google Gemini
doppler secrets set GEMINI_AI="your_key_here"

# Groq (fast inference)
doppler secrets set GROQ="your_key_here"

# OpenCode service key
doppler secrets set OPENCODE_API_KEY="your_opencode_key"
```

## 📋 Required API Keys

### GitHub Token (GH_TOKEN)

**Purpose**: Authenticate `gh` CLI automatically

**Create at**: https://github.com/settings/tokens

**Scopes needed**:
- `repo` - Full control of private repositories
- `read:org` - Read org and team membership
- `gist` - Create gists

```bash
doppler secrets set GH_TOKEN="ghp_xxxxxxxxxxxx"
```

### OpenAI API Key (OPENAI_API_KEY)

**Purpose**: GPT models (ChatGPT, GPT-4, etc.)

**Create at**: https://platform.openai.com/api-keys

```bash
doppler secrets set OPENAI_API_KEY="sk-proj-xxxx"
```

### Anthropic API Key (ANTHROPIC_API_KEY)

**Purpose**: Claude models (Claude 3, etc.)

**Create at**: https://console.anthropic.com/settings/keys

```bash
doppler secrets set ANTHROPIC_API_KEY="sk-ant-xxxx"
```

### Google Gemini (GEMINI_AI)

**Purpose**: Gemini models

**Create at**: https://aistudio.google.com/apikey

```bash
doppler secrets set GEMINI_AI="AIzaSyxxxx"
```

### Groq (GROQ)

**Purpose**: Fast LLM inference

**Create at**: https://console.groq.com/keys

```bash
doppler secrets set GROQ="gsk_xxxx"
```

### OpenCode API Key (OPENCODE_API_KEY)

**Purpose**: OpenCode service authentication

**Create at**: OpenCode dashboard (after signup)

```bash
doppler secrets set OPENCODE_API_KEY="oc_xxxx"
```

## 🔄 How Scripts Use Doppler

### During `termux.sh` Installation

The script automatically:

1. **Checks if Doppler is authenticated**
   ```bash
   if command -v doppler &>/dev/null && doppler me &>/dev/null; then
   ```

2. **Retrieves secrets**
   ```bash
   GH_TOKEN=$(doppler secrets get GH_TOKEN --plain)
   ```

3. **Configures tools**
   - GitHub CLI: `echo "$GH_TOKEN" | gh auth login --with-token`
   - OpenCode: Creates `~/.opencode/config.json`
   - AI Providers: Exports to Alpine environment variables

### Manual Usage

```bash
# Run any command with Doppler secrets injected
doppler run -- your-command

# Example: Run gh with secrets
doppler run -- gh api user

# Example: Run neovim with AI keys available
doppler run -- nvim
```

## 🌐 Doppler Dashboard

### View Secrets Online

```bash
doppler open
```

This opens the web dashboard where you can:
- View all secrets (values hidden by default)
- Add/edit/delete secrets
- Manage access across environments
- View audit logs

### List Secrets in Terminal

```bash
# List all secrets (values hidden)
doppler secrets

# Get specific secret value
doppler secrets get OPENAI_API_KEY --plain

# Download all secrets as env file
doppler secrets download --no-file --format env
```

## 🔐 Security Best Practices

### ✅ DO
- Store all API keys in Doppler
- Use different keys for dev/prod
- Rotate keys regularly
- Use the web dashboard to audit access

### ❌ DON'T
- Commit API keys to git
- Share keys in plain text
- Use the same key across all projects
- Store keys in shell history

## 🔄 Syncing Across Devices

Doppler automatically syncs secrets across:
- 📱 **Termux** (Android)
- ☁️ **GitHub Codespaces**
- 💻 **Local machines**

**Setup on new device:**
```bash
# 1. Install Doppler
curl -sS https://cli.doppler.com/install.sh | sh

# 2. Login (uses existing account)
doppler login

# 3. Setup project
cd ~/dotfiles
doppler setup --project dotfiles --config dev

# 4. Secrets are now available!
doppler secrets
```

## 🐛 Troubleshooting

### "You must provide a token"
**Problem**: Not logged in to Doppler

**Solution**:
```bash
doppler login
doppler setup --project dotfiles --config dev
```

### Secrets not found
**Problem**: Wrong project/config selected

**Solution**:
```bash
# Check current project
doppler configure get project

# List available projects
doppler projects

# Switch project
doppler setup --project dotfiles --config dev
```

### Script doesn't use Doppler secrets
**Problem**: Script runs before Doppler check passes

**Solution**:
```bash
# Verify Doppler works
doppler me
doppler secrets

# Re-run installation
cd ~/dotfiles && ./termux.sh
```

## 📊 Environment Variables

When using `doppler run`, secrets are available as environment variables:

```bash
# In Alpine (for OpenCode)
export OPENAI_API_KEY="..."
export ANTHROPIC_API_KEY="..."
export GOOGLE_GENERATIVE_AI_API_KEY="..."
export GROQ_API_KEY="..."
```

OpenCode automatically reads these standard variable names.

## 🔄 Updating Secrets

```bash
# Update existing secret
doppler secrets set OPENAI_API_KEY="new_key_here"

# Delete secret
doppler secrets delete OLD_KEY_NAME

# Rename (delete + create)
doppler secrets set NEW_NAME="$(doppler secrets get OLD_NAME --plain)"
doppler secrets delete OLD_NAME
```

## 🚀 Advanced Usage

### Load Secrets in Shell

Add to `~/.bashrc` (optional):
```bash
# Auto-load Doppler secrets when entering dotfiles directory
if [ -f ~/dotfiles/.doppler.yaml ]; then
    eval "$(doppler secrets download --no-file --format env-no-quotes 2>/dev/null || true)"
fi
```

### Use in Scripts

```bash
#!/bin/bash
# Get secret in script
API_KEY=$(doppler secrets get OPENAI_API_KEY --plain 2>/dev/null)

if [ -z "$API_KEY" ]; then
    echo "Error: API key not found in Doppler"
    exit 1
fi

# Use the key
curl -H "Authorization: Bearer $API_KEY" https://api.openai.com/...
```

## 🔗 Related Documentation

- [Termux Installation](../installation/TERMUX.md) - See Doppler automation in action
- [AI CLI Tools](AI-CLI-TOOLS.md) - Tools that use these secrets
- [GitHub Authentication](GITHUB-AUTH.md) - GitHub token setup

## 💡 Tips

1. **Keep backup**: Export secrets once and store securely offline
   ```bash
   doppler secrets download --no-file --format env > ~/backup-secrets.env
   ```

2. **Use different configs**: Separate `dev` and `prod` environments
   ```bash
   doppler setup --config prod
   ```

3. **Check sync status**: Verify secrets are up to date
   ```bash
   doppler secrets
   ```

## 📚 Official Documentation

- [Doppler CLI Docs](https://docs.doppler.com/docs/cli)
- [Doppler Dashboard](https://dashboard.doppler.com/)

---

*Last Updated: December 2024*
