# Dotfiles — Pitch

> Pitch reviewed: 2026-09-02 · Project state: see canonical sources below

Dotfiles is a cross-platform terminal configuration system for reproducible Windows and Linux workstations. It installs and maintains a bounded set of shell and terminal tools while keeping ShipGlows developer provisioning and project toolchains outside its ownership.

## Current state

The repository provides previewable Windows and Linux installers, a shared component registry, conflict backups, managed-artifact journals, read-only checks, constrained updates, and recovery-aware uninstall behavior.

## Navigate

- Business truth: `shipglows_data/business/business.md`
- Product truth: `README.md`
- Current work: `shipglows_data/workflow/`
- Technical map: `docs/INDEX.md`
- Repository guide: `README.md`

## Boundaries

Dotfiles owns terminal tools and their configuration. ShipGlows separately owns developer provisioning, AI agents, skills, MCP configuration, Doppler, and project toolchains; secrets must remain outside version control.
