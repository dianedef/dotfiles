# Dotfiles Documentation Index

Welcome to the comprehensive documentation for this dotfiles repository. This documentation is organized following the BMAD (Build More, Architect Dreams) methodology for clarity and maintainability.

## 📚 Quick Navigation

### Getting Started
- [Quick Start Guide](installation/QUICK-START.md) - Get up and running in 5 minutes
- [Platform-Specific Installation](#installation-guides)
- [What's Included](#whats-included)

### Installation Guides
- [Windows Installation](installation/WINDOWS.md)
- [Linux/Codespaces Installation](installation/LINUX.md)
- [Termux/Android Installation](installation/TERMUX.md)

### Configuration Guides
- [Neovim Configuration](configuration/NEOVIM.md)
- [Yazi File Manager](configuration/YAZI.md)
- [Starship Prompt](configuration/STARSHIP.md)
- [Shell Configuration](configuration/SHELL.md)
- [AI CLI Tools](configuration/AI-CLI-TOOLS.md) ⭐ **New!**

### Workflows & Usage
- [Daily Workflows](workflows/DAILY-USE.md)
- [Development Workflow](workflows/DEVELOPMENT.md)
- [Dotfiles Maintenance](workflows/MAINTENANCE.md)

### Troubleshooting
- [Nerd Fonts Issues](troubleshooting/NERD-FONTS.md) ⭐ **New!**
- [Common Issues](troubleshooting/COMMON-ISSUES.md)
- [Platform-Specific Issues](troubleshooting/PLATFORM-SPECIFIC.md)
- [FAQ](troubleshooting/FAQ.md)

### Reference
- [Tool Versions](reference/VERSIONS.md)
- [File Locations](reference/FILE-LOCATIONS.md)
- [Keybindings Reference](reference/KEYBINDINGS.md)
- [Glossary](reference/GLOSSARY.md)

## 📖 About This Repository

This repository contains personal dotfiles primarily used across multiple platforms:
- **Primary Use**: Termux (Android) → SSH → GitHub Codespaces (Linux)
- **Secondary**: Windows development environment
- **Focus**: Terminal-based workflow with Neovim, Yazi, and modern CLI tools

## 🎯 What's Included

### Core Tools
- **Neovim** - Modern Vim-based code editor with LSP support
- **Yazi** - Fast terminal file manager with preview support
- **Starship** - Cross-shell customizable prompt
- **FZF** - Fuzzy finder for files and command history
- **Ripgrep** - Fast recursive text search
- **Zoxide** - Smart directory navigation

### Additional Tools
- **Lazygit** - Terminal UI for git
- **Ranger** - Alternative file manager (backup)
- **Nushell** - Modern shell (experimental configs)

## 🚀 BMAD Method Integration

This documentation repository now uses the [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) for:
- Structured documentation organization
- Workflow-based maintenance processes
- AI-assisted development and documentation
- Quality assurance through specialized agents

### Using BMAD Agents

The BMAD agents are installed in `.github/agents/` and can be used with GitHub Copilot:

1. **BMad Master** - Project coordination and workflow guidance
2. **Developer** - Code implementation and debugging
3. **Tech Writer** - Documentation creation and improvement
4. **Architect** - System design and configuration planning
5. **Analyst** - Requirement analysis and planning
6. **PM (Product Manager)** - Feature planning and prioritization
7. **SM (Scrum Master)** - Sprint planning and task management
8. **Test Architect** - Testing strategy and quality assurance
9. **UX Designer** - User experience and interface design
10. **Quick Flow Solo Dev** - Fast development for small changes

### Quick BMAD Workflows

To use BMAD workflows in this repository:

```bash
# Initialize workflow (run once to analyze project)
@bmd-custom-core-bmad-master *workflow-init

# For quick bug fixes or small features
@bmd-custom-bmm-quick-flow-solo-dev *workflow-quick-flow

# For larger features or improvements
@bmd-custom-bmm-pm *workflow-planning-prd
```

See [BMAD Workflows Guide](workflows/BMAD-USAGE.md) for detailed instructions.

## 📝 Documentation Standards

All documentation in this repository follows these standards:

1. **Clear Headers** - Use descriptive section headers
2. **Code Examples** - Include working examples for all commands
3. **Platform Notes** - Specify platform-specific instructions clearly
4. **Prerequisites** - List requirements at the beginning
5. **Troubleshooting** - Include common issues and solutions
6. **Cross-References** - Link to related documentation

## 🤝 Contributing

When contributing to this documentation:

1. Follow the existing structure in `docs/`
2. Use the BMAD Tech Writer agent for documentation tasks
3. Keep documentation up-to-date with code changes
4. Test all installation instructions
5. Add screenshots for UI changes

## 📊 Documentation Structure

```
docs/
├── INDEX.md                    # This file - main navigation hub
├── installation/               # Platform-specific installation guides
│   ├── QUICK-START.md         # 5-minute quickstart
│   ├── WINDOWS.md             # Windows detailed guide
│   ├── LINUX.md               # Linux/Codespaces guide
│   └── TERMUX.md              # Android/Termux guide
├── configuration/              # Per-tool configuration guides
│   ├── NEOVIM.md              # Neovim setup and customization
│   ├── YAZI.md                # Yazi file manager
│   ├── STARSHIP.md            # Starship prompt
│   └── SHELL.md               # Shell configuration
├── workflows/                  # Usage and workflow guides
│   ├── DAILY-USE.md           # Daily operations
│   ├── DEVELOPMENT.md         # Development workflow
│   ├── MAINTENANCE.md         # Dotfiles maintenance
│   └── BMAD-USAGE.md          # Using BMAD agents
├── troubleshooting/            # Problem resolution
│   ├── COMMON-ISSUES.md       # Common problems
│   ├── PLATFORM-SPECIFIC.md   # Platform issues
│   └── FAQ.md                 # Frequently asked questions
└── reference/                  # Technical reference
    ├── VERSIONS.md            # Tool versions
    ├── FILE-LOCATIONS.md      # File path reference
    ├── KEYBINDINGS.md         # Keyboard shortcuts
    └── GLOSSARY.md            # Terms and definitions
```

## 🔍 Need Help?

- **Quick Issue?** → Check [Common Issues](troubleshooting/COMMON-ISSUES.md)
- **Installation Problem?** → See platform-specific guides
- **Want to Contribute?** → Use BMAD Tech Writer agent
- **Feature Request?** → Use BMAD PM agent for planning

## 📄 License

MIT License - See [LICENSE](../LICENSE) for details.

---

*Last Updated: December 2024*
*Documentation Structure: BMAD Method v6*
