#!/bin/bash
# ============================================================================
# One-Click Bootstrap for Fresh Ubuntu 24.04 LTS Servers
# ============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/dianedef/dotfiles/main/dotfiles/bootstrap.sh | bash
#
# What it does:
#   1. Installs minimal prerequisites (git, curl, jq)
#   2. Clones dotfiles repository
#   3. Runs the full installation (dotfiles + ShipGlowz + Claude Code + Codex)
#
# Environment variables:
#   DOTFILES_REPO   - Override repo URL (default: dianedef/dotfiles)
#   DOTFILES_DIR    - Override install directory (default: ~/dotfiles)
#   SKIP_SHIPGLOWZ   - Set to 1 to skip ShipGlowz installation
#   NON_INTERACTIVE - Set to 1 to skip all interactive prompts
# ============================================================================

# NO set -e here — we handle errors explicitly
set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/dianedef/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}       ${YELLOW}One-Click Dev Environment Setup${NC}        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="x86_64" ;;
    aarch64) ARCH="arm64" ;;
    arm64)   ARCH="arm64" ;;
    *)
        echo -e "${RED}Architecture non supportee: $ARCH${NC}"
        exit 1
        ;;
esac
export ARCH
echo -e "${BLUE}Architecture:${NC} $ARCH"

# Check we're on a supported OS
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}OS non supporte (pas de /etc/os-release)${NC}"
    exit 1
fi

# Step 1: Install prerequisites
echo ""
echo -e "${BLUE}[1/3]${NC} Installation des prerequis..."
if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    if [ "$(id -u)" -eq 0 ]; then
        apt-get update -qq 2>/dev/null || true
        apt-get install -y -qq git curl jq 2>/dev/null
    else
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y -qq git curl jq 2>/dev/null
    fi

    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}FATAL: Impossible d'installer git${NC}"
        exit 1
    fi
    echo -e "${GREEN}Prerequis installes${NC}"
else
    echo -e "${GREEN}Prerequis deja presents${NC}"
fi

# Step 2: Clone or update dotfiles
echo ""
echo -e "${BLUE}[2/3]${NC} Recuperation des dotfiles..."
if [ -d "$DOTFILES_DIR/.git" ]; then
    echo -e "${YELLOW}Dotfiles existants, mise a jour...${NC}"
    cd "$DOTFILES_DIR" && git pull --quiet 2>/dev/null || true
elif [ -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}Dossier $DOTFILES_DIR existe mais n'est pas un repo git${NC}"
    echo -e "${YELLOW}Suppression et re-clonage...${NC}"
    rm -rf "$DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

if [ ! -f "$DOTFILES_DIR/dotfiles/install.sh" ]; then
    echo -e "${RED}FATAL: dotfiles/install.sh introuvable dans $DOTFILES_DIR${NC}"
    exit 1
fi
echo -e "${GREEN}Dotfiles prets${NC}"

# Step 3: Run installation
echo ""
echo -e "${BLUE}[3/3]${NC} Lancement de l'installation..."
echo ""
chmod +x "$DOTFILES_DIR/dotfiles/install.sh"

# Pass through environment variables and arguments
cd "$DOTFILES_DIR" && exec ./dotfiles/install.sh "$@"
