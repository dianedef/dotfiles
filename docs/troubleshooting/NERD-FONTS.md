# Nerd Fonts - Installation & Troubleshooting

## Overview

Nerd Fonts are patched fonts that include icons and glyphs from popular icon sets. They're essential for displaying icons in Neovim, Starship, Yazi, and other modern terminal tools.

---

## Installation

### Linux/Codespaces (Automatic)

Nerd Fonts are **automatically installed** by `install.sh`:

```bash
cd ~/dotfiles
./install.sh
```

The script installs **JetBrainsMono Nerd Font** to `~/.local/share/fonts/`.

### Termux/Android (Automatic)

Nerd Fonts are **automatically installed** by `termux.sh`:

```bash
cd ~/dotfiles
./termux.sh
```

The script installs the font to `~/.termux/font.ttf`.

**Important**: You must **completely restart Termux** (not just close the session) for the font to take effect.

### Manual Installation

#### Linux/Codespaces

```bash
# Create fonts directory
mkdir -p ~/.local/share/fonts

# Download JetBrainsMono Nerd Font
cd /tmp
curl -sLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip

# Extract and install
unzip -q JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/

# Update font cache
fc-cache -fv ~/.local/share/fonts

# Clean up
rm JetBrainsMono.zip
```

#### Termux/Android

```bash
# Create termux config directory
mkdir -p ~/.termux

# Download font
cd /tmp
curl -sLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
unzip -q JetBrainsMono.zip

# Install as Termux font (use Regular variant)
cp JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf

# Clean up
rm -rf JetBrainsMono* *.ttf *.otf

# IMPORTANT: Completely restart Termux!
```

#### Windows

1. Download from [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases/latest)
2. Download `JetBrainsMono.zip`
3. Extract the zip file
4. Select all `.ttf` files → Right-click → "Install for all users"
5. Configure your terminal to use "JetBrainsMono Nerd Font"

---

## Verification

### Check if Nerd Fonts are installed

**Linux/Codespaces:**
```bash
# List installed Nerd Fonts
fc-list | grep -i nerd

# Count JetBrains variants
fc-list | grep -i jetbrains | wc -l
```

**Termux:**
```bash
# Check if font file exists
ls -lh ~/.termux/font.ttf
```

### Test icon display

Run this in your terminal:
```bash
echo -e "\uf179 \uf17a \uf17b \uf17c \uf17d"
```

You should see Git-related icons. If you see boxes or question marks, the font is not active.

### Test with Neovim

Open Neovim and check the file tree:
```bash
nvim
```

Press `<Space>e` to open the file explorer. You should see folder and file icons.

---

## Troubleshooting

### Icons show as boxes or question marks

#### Codespaces/Linux

**Problem**: Terminal doesn't recognize the font.

**Solution 1** - Refresh font cache:
```bash
fc-cache -fv ~/.local/share/fonts
```

**Solution 2** - Check if fonts are in the right location:
```bash
ls ~/.local/share/fonts/JetBrainsMono/
```

**Solution 3** - Reinstall fonts:
```bash
rm -rf ~/.local/share/fonts/JetBrainsMono
# Then run install.sh again
```

#### Termux

**Problem**: Font not applied after installation.

**Solution**: You must **completely restart Termux**:
1. Don't just exit the session
2. Swipe away Termux from recent apps (Android task switcher)
3. Reopen Termux

**Still not working?**

Check if font file exists:
```bash
ls -lh ~/.termux/font.ttf
```

If missing, reinstall:
```bash
cd ~/dotfiles
./termux.sh
```

#### Windows

**Problem**: Terminal not using Nerd Font.

**Solution**: Configure your terminal:

**Windows Terminal:**
1. Open Settings (Ctrl+,)
2. Go to Profiles → Defaults (or your specific profile)
3. Appearance → Font face → Select "JetBrainsMono Nerd Font"
4. Save

**VS Code:**
1. Open Settings (Ctrl+,)
2. Search: "terminal font"
3. Set to: `JetBrainsMono Nerd Font`

---

### Icons are too small/large

**Adjust terminal font size:**

**Linux/Codespaces:**
- VS Code: Ctrl+, → Search "terminal font size"
- Or use Ctrl++ and Ctrl+- to zoom

**Termux:**
- Volume Down + '+' to increase size
- Volume Down + '-' to decrease size

**Windows Terminal:**
- Settings → Font size

---

### Different fonts for different tools

Some tools can use different fonts:

**Neovim** - Uses terminal font (can't override)

**Starship** - Uses terminal font, but you can disable icons:
```toml
# In ~/.config/starship.toml
[character]
success_symbol = "[>](bold green)"
error_symbol = "[>](bold red)"
```

**Yazi** - Uses terminal font, but you can disable icons in config:
```toml
# In ~/.config/yazi/yazi.toml
[manager]
show_hidden = true
show_symlink = true
```

---

## Recommended Nerd Fonts

We use **JetBrainsMono Nerd Font** because:
- ✅ Excellent code readability
- ✅ Complete icon coverage
- ✅ Professional appearance
- ✅ Works great on all platforms

**Alternatives** (if you want to try others):

| Font | Best For | Size |
|------|----------|------|
| **FiraCode Nerd Font** | Ligatures, modern look | Medium |
| **Hack Nerd Font** | Clean, simple | Small |
| **Meslo Nerd Font** | Classic, readable | Medium |
| **CascadiaCode Nerd Font** | Microsoft, modern | Medium |

To install a different font, replace `JetBrainsMono` with the font name in installation commands.

---

## Platform Support

| Platform | Installation Method | Configuration |
|----------|-------------------|---------------|
| Linux/Codespaces | `~/.local/share/fonts/` | Automatic via fc-cache |
| Termux/Android | `~/.termux/font.ttf` | Requires full restart |
| Windows | System fonts | Configure in terminal |

---

## Advanced: Custom Font Configuration

### Linux - System-wide installation (optional)

```bash
# Install for all users (requires sudo)
sudo cp ~/.local/share/fonts/JetBrainsMono/*.ttf /usr/local/share/fonts/
sudo fc-cache -fv
```

### Termux - Custom font size in .termux/termux.properties

```bash
# Edit Termux settings
nano ~/.termux/termux.properties

# Add or modify:
font-size = 12
```

After changing, restart Termux.

---

## FAQ

### Q: Do I need Nerd Fonts?

**A:** Yes, if you want icons in Neovim, Starship, Yazi, etc. Without Nerd Fonts, you'll see boxes (□) or question marks (?).

### Q: Can I use multiple Nerd Fonts?

**A:** You can install multiple, but your terminal will use only one at a time.

### Q: Does this affect performance?

**A:** No. Font rendering is handled by your terminal, not by the applications.

### Q: What if I prefer no icons?

**A:** You can disable icons in each tool's configuration. But installing Nerd Fonts doesn't hurt.

### Q: Are Nerd Fonts free?

**A:** Yes! They're open-source and free to use.

---

## Related Documentation

- [Neovim Configuration](../configuration/NEOVIM.md)
- [Starship Configuration](../configuration/STARSHIP.md)
- [Termux Installation Guide](../installation/TERMUX.md)
- [Common Issues](COMMON-ISSUES.md)

---

## External Resources

- [Nerd Fonts Official Site](https://www.nerdfonts.com/)
- [Nerd Fonts GitHub](https://github.com/ryanoasis/nerd-fonts)
- [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet) - Browse all icons
