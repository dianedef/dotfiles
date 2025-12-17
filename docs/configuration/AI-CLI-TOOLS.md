# AI-Powered CLI Tools

## Installed Tools

These AI-powered CLI tools are automatically installed in Codespaces via `install.sh`:

### 1. GitHub Copilot CLI

**Command**: `copilot`

GitHub's AI assistant directly in your terminal.

```bash
# Get suggestions for shell commands
copilot "how do I find large files?"

# Explain shell commands
copilot --explain "tar -xzf file.tar.gz"

# Get help
copilot --help
```

**Features**:
- Natural language to shell commands
- Explain complex commands
- Git command assistance
- Context-aware suggestions

**Documentation**: [GitHub Copilot CLI Docs](https://githubnext.com/projects/copilot-cli/)

---

### 2. Kilocode CLI

**Commands**: `kilocode` or `kilo`

AI-powered code generation and refactoring tool.

```bash
# Generate code
kilocode generate "create a REST API endpoint"

# Refactor code
kilocode refactor file.js

# Get help
kilocode --help
```

**Features**:
- Code generation from descriptions
- Intelligent refactoring
- Multi-language support
- Context-aware suggestions

**Documentation**: [Kilocode Docs](https://kilocode.com)

---

### 3. OpenCode AI

**Command**: `opencode`

Open-source AI coding assistant with multiple model support.

```bash
# Ask coding questions
opencode "how to implement binary search in Python?"

# Generate code snippets
opencode generate "fibonacci function in JavaScript"

# Get help
opencode --help
```

**Features**:
- Open-source alternative
- Multiple AI model support
- Code generation and explanation
- Free to use

**Documentation**: [OpenCode AI Docs](https://opencode.ai)

---

## Installation

These tools are **automatically installed** when you run `install.sh`:

```bash
cd ~/dotfiles
./install.sh
```

### Manual Installation

If you need to install or update manually:

```bash
npm install -g @github/copilot
npm install -g @kilocode/cli
npm install -g opencode-ai
```

### Update All Tools

```bash
npm update -g
```

---

## Platform Support

| Tool | Windows | Linux/Codespaces | Termux |
|------|---------|------------------|--------|
| GitHub Copilot CLI | ✅ | ✅ | ❌ |
| Kilocode | ✅ | ✅ | ❌ |
| OpenCode AI | ✅ | ✅ | ❌ |

**Note**: These tools require Node.js and are not installed on Termux due to resource constraints.

---

## Troubleshooting

### Commands not found after installation

```bash
# Refresh shell's command cache
hash -r

# Or restart your shell
source ~/.bashrc
```

### Check installations

```bash
# List installed npm global packages
npm list -g --depth=0

# Check individual tools
copilot --version
kilocode --version
opencode --version
```

### Reinstall

```bash
npm uninstall -g @github/copilot @kilocode/cli opencode-ai
npm install -g @github/copilot @kilocode/cli opencode-ai
```

---

## Tips & Best Practices

### GitHub Copilot CLI

- **Be specific**: "Find all .log files larger than 100MB in current directory"
- **Use natural language**: Describe what you want, not how to do it
- **Iterate**: If first suggestion isn't perfect, refine your prompt

### Kilocode

- **Provide context**: "In a React component, add error handling to API call"
- **Use type hints**: "TypeScript function that sorts array of objects"
- **Review generated code**: Always review and test AI-generated code

### OpenCode AI

- **Ask for explanations**: "Explain this regex pattern: `^[a-z0-9]+$`"
- **Request multiple solutions**: "Show me 3 ways to handle async errors"
- **Learn from output**: Use it as a learning tool, not just code generator

---

## Integration with BMAD Method

These AI CLI tools complement the BMAD Method agents:

- Use **GitHub Copilot CLI** for quick shell command help
- Use **Kilocode** for rapid code generation (then review with Developer agent)
- Use **OpenCode AI** for alternative perspectives (combine with Architect agent)
- Document generated code with **Tech Writer agent**

**Example workflow**:
1. Generate code with Kilocode: `kilocode generate "authentication middleware"`
2. Review with Developer agent: `@bmd-custom-bmm-dev "Review this auth middleware"`
3. Document with Tech Writer: `@bmd-custom-bmm-tech-writer "Document this middleware"`

---

## Related Documentation

- [BMAD Usage Guide](../workflows/BMAD-USAGE.md)
- [Quick Start Guide](../installation/QUICK-START.md)
- [Documentation Index](../INDEX.md)
