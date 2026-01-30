# MCP (Model Context Protocol) Configuration

Single source of truth for MCP server configurations across all AI tools.

## What is MCP?

[Model Context Protocol](https://modelcontextprotocol.io/) is an open standard for connecting AI assistants to external tools and data sources. MCP servers provide:
- **Tools** - Functions the AI can call (e.g., web search, file operations)
- **Resources** - Data the AI can read (e.g., databases, APIs)
- **Prompts** - Pre-defined conversation starters

## Files

| File | Purpose |
|------|---------|
| `mcp-servers.json` | Main MCP server definitions (edit this!) |
| `README.md` | This documentation |

## Configuration

Edit `mcp-servers.json` to add your MCP servers:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### Server Types

**stdio servers** (subprocess):
```json
{
  "command": "node",
  "args": ["path/to/server.js"],
  "env": { "KEY": "value" }
}
```

**HTTP servers** (remote):
```json
{
  "url": "https://mcp.example.com/sse",
  "headers": { "Authorization": "Bearer ${TOKEN}" }
}
```

## Environment Variables

Use `${VAR_NAME}` syntax for secrets. These are resolved from:
1. Shell environment
2. Doppler (if configured)
3. `.env` file

Example: `"API_KEY": "${OPENAI_API_KEY}"`

## Supported Tools

After running `install.sh`, configs are synced to:

| Tool | Config Location |
|------|-----------------|
| Claude Code | `~/.claude/settings.json` |
| Kilocode | `~/.kilocode/cli/global/settings/mcp_settings.json` |
| Claude Desktop | `~/.config/claude/claude_desktop_config.json` |

## Using mcpc CLI

The `mcpc` CLI lets you interact with MCP servers from the terminal:

```bash
# List available servers
mcpc servers

# Connect to a server
mcpc connect my-server

# List tools from connected server
mcpc tools

# Call a tool
mcpc call my-server tool-name '{"param": "value"}'

# JSON output for scripting
mcpc --code tools | jq '.[] | .name'
```

## Popular MCP Servers

Add these to your `mcp-servers.json`:

### Apify (Web Scraping)
```json
"apify": {
  "command": "npx",
  "args": ["-y", "@apify/mcp-server-rag-web-browser"],
  "env": { "APIFY_TOKEN": "${APIFY_TOKEN}" }
}
```

### Brave Search
```json
"brave-search": {
  "command": "npx",
  "args": ["-y", "@anthropic/mcp-server-brave-search"],
  "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" }
}
```

### GitHub
```json
"github": {
  "command": "npx",
  "args": ["-y", "@anthropic/mcp-server-github"],
  "env": { "GITHUB_TOKEN": "${GH_TOKEN}" }
}
```

### Filesystem
```json
"filesystem": {
  "command": "npx",
  "args": ["-y", "@anthropic/mcp-server-filesystem", "/home/user/projects"]
}
```

### Memory (Persistent)
```json
"memory": {
  "command": "npx",
  "args": ["-y", "@anthropic/mcp-server-memory"]
}
```

## Troubleshooting

### Server not connecting
```bash
# Test server directly
mcpc connect server-name --verbose

# Check if command exists
which npx
```

### Credentials not working
```bash
# Verify env var is set
echo $API_KEY

# Check Doppler
doppler secrets get API_KEY
```

### Re-sync configs
```bash
# Re-run install script
cd ~/dotfiles && ./install.sh
```

## Resources

- [MCP Documentation](https://modelcontextprotocol.io/docs)
- [MCP Server Registry](https://github.com/modelcontextprotocol/servers)
- [mcpc CLI](https://github.com/apify/mcp-cli)
- [Claude Code MCP Guide](https://docs.anthropic.com/en/docs/claude-code/mcp)
