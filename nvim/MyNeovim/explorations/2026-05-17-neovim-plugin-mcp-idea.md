---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "MyNeovim"
created: "2026-05-17"
updated: "2026-05-17"
status: draft
source_skill: sf-explore
scope: "Neovim plugin, script, or MCP decision space"
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: low
docs_impact: yes
linked_systems:
  - Neovim
  - LazyVim
  - Lua
  - MCP
  - Claude Code
  - Gemini CLI
evidence:
  - "lua/plugins/mcphub.lua"
  - "lua/plugins/claudecode.lua"
  - "lua/plugins/gemini-cli.lua"
  - "lua/shipglows/init.lua"
  - "lua/config/keymaps.lua"
  - "AI Plugins.md"
depends_on:
  - "README.md"
supersedes: []
next_step: "/sf-spec nvim workflow cockpit"
---

# Exploration Report: Neovim Plugin, Script, Or MCP Idea

## Starting Question

The user wants to create something for Neovim, but has not yet decided whether the right form is a plugin, a script, an MCP server, or another integration.

## Context Read

- `lua/plugins/mcphub.lua` - MCP integration exists but is disabled.
- `lua/plugins/claudecode.lua` - Claude Code is already available inside Neovim as an agent terminal.
- `lua/plugins/gemini-cli.lua` - Gemini CLI is already wired with file, diagnostic, and command-picker actions.
- `lua/shipglows/init.lua` - A local Lua module already groups custom commands and mappings.
- `lua/config/keymaps.lua` - Several personal workflow helpers are currently embedded directly in keymaps.
- `AI Plugins.md` - The current AI tool choice matrix is already documented.

## Internet Research

- None. This was an exploration of the local configuration shape only.

## Problem Framing

This setup already has many AI frontends. The interesting opportunity is probably not "add another chat UI". It is to make local workflow context easier to capture, route, and act on from Neovim.

## Option Space

### Option A: Local Neovim Workflow Plugin

- Summary: Extract existing custom helpers into a first-class local plugin, likely under `lua/shipglows/`.
- Pros: Low risk, fits the current config, immediately useful, no server process required.
- Cons: Only helps inside Neovim; does not expose capabilities to external agents.

### Option B: MCP Server For Dotfiles And Neovim Context

- Summary: Build an MCP server that exposes curated tools such as reading current project context, listing ShipGlows docs, or preparing prompts.
- Pros: Useful from Claude Code and other MCP clients; can make local context portable.
- Cons: More moving parts; requires deciding which client should consume it; security boundaries matter.

### Option C: Script/CLI First

- Summary: Build a small command-line utility first, then call it from Neovim and optionally expose it through MCP later.
- Pros: Easiest to test; reusable outside Neovim; avoids premature plugin or MCP design.
- Cons: Less native UX than Lua commands/keymaps at first.

### Option D: AI Router Inside Neovim

- Summary: A Neovim command that sends the current buffer/selection/diagnostic to the best installed AI tool: Copilot Chat, Gemini CLI, Claude Code, Avante.
- Pros: Matches the current plugin set; solves real choice friction.
- Cons: Coupled to several plugin APIs and keymaps; can become brittle.

## Comparison

The local plugin is the safest first move if the goal is personal workflow polish. The MCP server is strongest if the goal is agent interoperability. The CLI-first path is the most reversible. The AI router is attractive because this config already has several overlapping AI tools, but it needs careful scoping.

## Emerging Recommendation

Start with a local Neovim "workflow cockpit" plugin under `lua/shipglows/`, backed by small testable Lua functions and user commands. Keep the boundary clean enough that selected actions can later call a CLI or MCP server.

Confidence: medium.

## Non-Decisions

- Whether MCP should be enabled through `mcphub.nvim`.
- Whether the implementation should be published as an external plugin.
- Which AI provider should be preferred by default.

## Rejected Paths

- New generic chat plugin - the config already has enough chat and agent surfaces.
- Large external dependency - this dotfiles repo favors direct, local workflow improvements.

## Risks And Unknowns

- Plugin APIs for AI tools may change and make a router brittle.
- MCP may be overkill unless there is a concrete external client workflow.
- Current custom keymaps mix unrelated concerns; extracting them needs a small design pass to avoid simply moving clutter.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: No secrets or private logs were read.

## Decision Inputs For Spec

- User story seed: As a Neovim user with several AI tools, I want one workflow surface that captures context and routes actions so I do not think about which integration to use each time.
- Scope in seed: Lua module, user commands, keymaps, context capture, provider/action registry.
- Scope out seed: Publishing to GitHub, remote sync, auth handling, implementing a full chat UI.
- Invariants/constraints seed: Preserve LazyVim patterns; avoid breaking existing AI plugins; no secrets in persisted artifacts.
- Validation seed: Neovim loads without errors; commands exist; mappings show in which-key; provider actions fail gracefully when unavailable.

## Handoff

- Recommended next command: `/sf-spec nvim workflow cockpit`
- Why this next step: The idea is clear enough to specify once the user picks the preferred direction.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-05-17 00:00:00 UTC | Find whether plugin, script, or MCP fits | Read local Neovim AI/MCP/workflow files and compared shapes | Recommend a local workflow plugin with optional CLI/MCP boundary | Pick direction or write spec |
