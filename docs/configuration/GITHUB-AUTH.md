# GitHub CLI Authentication

Guide to automate GitHub CLI (`gh`) authentication using Doppler across all platforms.

## 🎯 Overview

The installation scripts (`install.sh`, `windows.ps1`, `termux.sh`) automatically authenticate the GitHub CLI using a token stored in Doppler.

**Flow:**
1. Check if Doppler is configured and has `GH_TOKEN`
2. If yes → Auto-authenticate silently ✅
3. If no → Prompt for manual authentication or skip

## 🔑 Creating a GitHub Token

### 1. Go to GitHub Settings

Visit: https://github.com/settings/tokens/new

### 2. Configure Token

**Note (Name):** `Dotfiles CLI Access`

**Expiration:** 
- No expiration (recommended for personal use)
- Or 90 days (if you prefer rotation)

**Scopes (Required):**
- ✅ `repo` - Full control of private repositories
- ✅ `read:org` - Read org and team membership  
- ✅ `gist` - Create gists

**Optional Scopes:**
- `workflow` - If you want to manage GitHub Actions
- `admin:public_key` - If you want gh to manage SSH keys

### 3. Generate Token

Click **"Generate token"** and **copy the token** (starts with `ghp_`).

⚠️ **Important:** Save it immediately - you won't see it again!

## 💾 Storing Token in Doppler

### Quick Setup

```bash
# 1. Install Doppler (if not done)
curl -sS https://cli.doppler.com/install.sh | sh

# 2. Login
doppler login

# 3. Setup project
cd ~/dotfiles
doppler setup --project dotfiles --config dev

# 4. Store token
doppler secrets set GH_TOKEN="ghp_your_token_here"
```

### Verify Storage

```bash
# Check token is stored (value hidden)
doppler secrets

# Get token value (for testing)
doppler secrets get GH_TOKEN --plain
```

## 🚀 Platform-Specific Behavior

### GitHub Codespaces (`install.sh`)

**First Run (Automatic):**
```bash
# Runs automatically on Codespace creation
# Output:
🤖 Running in non-interactive mode (Codespaces auto-run)
⚠️ GitHub not authenticated
💡 Quick setup: run 'ds' (doppler-setup.sh) then re-run ./install.sh
```

**Setup Doppler (One Command):**
```bash
# Just run this - it does everything!
ds

# This interactive script will:
# 1. Login to Doppler (browser auth)
# 2. Setup project (dotfiles/dev)
# 3. Prompt for all API keys (GitHub, OpenAI, etc.)
# 4. Save everything securely
```

**Re-run Installation:**
```bash
cd ~/dotfiles
./install.sh

# Output:
👤 Running in interactive mode
✅ GitHub authenticated via Doppler
```

### Termux (`termux.sh`)

**With Doppler:**
```bash
cd ~/dotfiles
./termux.sh

# Output:
✅ GitHub authenticated via Doppler
```

**Without Doppler:**
```bash
# Prompts:
⚠️ GitHub not authenticated
📝 Run: gh auth login (or setup Doppler with GH_TOKEN)
Authenticate now? (y/N):
```

### Windows (`windows.ps1`)

**With Doppler:**
```powershell
.\windows.ps1

# Output:
✅ GitHub authenticated via Doppler
```

**Without Doppler:**
```powershell
# Prompts:
⚠️ GitHub not authenticated
Authenticate now? (y/N):
```

## 🔄 Manual Authentication (Fallback)

If Doppler is not available or you prefer manual auth:

### Option 1: Interactive Web Flow

```bash
gh auth login
```

Follow the prompts:
1. Choose: **GitHub.com**
2. Choose: **HTTPS** (or SSH if you prefer)
3. Choose: **Login with a web browser**
4. Copy the one-time code
5. Open browser and paste code
6. Authorize GitHub CLI

### Option 2: Token via stdin

```bash
# Paste your token, then Ctrl+D
gh auth login --with-token
ghp_your_token_here
```

### Option 3: Environment Variable

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export GH_TOKEN="ghp_your_token_here"
```

**Note:** This is less secure than Doppler but works for testing.

## ✅ Verifying Authentication

### Check Status

```bash
gh auth status
```

**Successful Output:**
```
github.com
  ✓ Logged in to github.com as YOUR_USERNAME (oauth_token)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: ghp_************************************
  ✓ Token scopes: gist, read:org, repo
```

### Test API Access

```bash
# View your profile
gh api user

# List your repositories
gh repo list

# View current repository
gh repo view
```

## 🔒 Security Best Practices

### ✅ DO
- Store token in Doppler (encrypted, synced)
- Use fine-grained tokens when possible
- Set expiration dates for tokens
- Rotate tokens regularly (every 90 days)
- Revoke tokens when no longer needed

### ❌ DON'T
- Commit tokens to git repositories
- Share tokens in plain text
- Use tokens with excessive scopes
- Store tokens in shell history
- Hardcode tokens in scripts

## 🔄 Token Rotation

### When to Rotate
- Every 90 days (recommended)
- If token is compromised
- When changing organizations
- After leaving a project

### How to Rotate

1. **Create new token** (same scopes)
2. **Update Doppler:**
   ```bash
   doppler secrets set GH_TOKEN="ghp_new_token"
   ```
3. **Verify:**
   ```bash
   doppler run -- gh auth status
   ```
4. **Revoke old token:** https://github.com/settings/tokens

## 🐛 Troubleshooting

### Token Validation Failed

**Problem:** `error validating token: invalid token`

**Solution:**
```bash
# Check token in Doppler
doppler secrets get GH_TOKEN --plain

# Verify token format (should start with ghp_)
# Re-create token with correct scopes
# Update Doppler
doppler secrets set GH_TOKEN="ghp_new_token"
```

### Doppler Not Working

**Problem:** `Doppler Error: you must provide a token`

**Solution:**
```bash
# Re-login
doppler login

# Re-setup project
cd ~/dotfiles
doppler setup --project dotfiles --config dev

# Verify
doppler me
```

### Script Skips Authentication

**Problem:** Script says "GitHub not authenticated" but doesn't prompt

**Check:**
```bash
# Is Doppler configured?
doppler me

# Does token exist?
doppler secrets get GH_TOKEN

# Is gh cli installed?
which gh
gh --version
```

### GitHub CLI Not Found

**Problem:** `gh: command not found`

**Solution:**

**Linux/Codespaces:**
```bash
# Install gh cli
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**Termux:**
```bash
pkg install gh
```

**Windows:**
```powershell
winget install --id GitHub.cli
# or
scoop install gh
```

## 🔗 Related Documentation

- [Doppler Setup](DOPPLER.md) - Complete secrets management guide
- [Termux Installation](../installation/TERMUX.md) - Android setup
- [Codespaces Setup](../installation/LINUX.md) - Linux/Codespaces

## 💡 Tips

1. **Test before storing:** Verify token works before adding to Doppler
   ```bash
   echo "ghp_test" | gh auth login --with-token
   gh auth status
   ```

2. **Multiple tokens:** Use different tokens for different machines
   ```bash
   doppler secrets set GH_TOKEN_PERSONAL="ghp_..."
   doppler secrets set GH_TOKEN_WORK="ghp_..."
   ```

3. **Token scope check:** Verify your token has required scopes
   ```bash
   gh auth status | grep "Token scopes"
   ```

4. **Revoke old tokens:** Clean up unused tokens at https://github.com/settings/tokens

---

*Last Updated: December 2024*
