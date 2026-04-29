#!/data/data/com.termux/files/usr/bin/bash

# Doppler Setup Script - Version Termux (sans binaire Doppler)
# Gestion locale des API keys via fichier .env

set -e

ENV_FILE="$HOME/.dotfiles-secrets.env"

echo "🔐 Configuration des API keys (Termux - mode local)"
echo "===================================================="
echo ""
echo "⚠️  Note: Doppler CLI n'est pas compatible avec Termux"
echo "📝 Les secrets seront stockés dans: $ENV_FILE"
echo ""

# Créer le fichier s'il n'existe pas
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"

# Prompt helper for secret inputs (hidden, no echo)
read_secret() {
    local prompt="$1"
    local value=""
    read -r -s -p "$prompt" value
    echo ""
    printf '%s' "$value"
}

# Fonction pour ajouter/mettre à jour une variable
update_env() {
    local key=$1
    local value=$2
    local tmp_file="${ENV_FILE}.tmp"
    
    if grep -q "^export $key=" "$ENV_FILE" 2>/dev/null; then
        # Mettre à jour la ligne existante (portable pour Termux)
        grep -v "^export $key=" "$ENV_FILE" > "$tmp_file" || true
    else
        cp "$ENV_FILE" "$tmp_file"
    fi

    # Bash-safe serialization prevents quote/injection breakage in sourced env files.
    printf 'export %s=%q\n' "$key" "$value" >> "$tmp_file"
    chmod 600 "$tmp_file"
    mv "$tmp_file" "$ENV_FILE"
    chmod 600 "$ENV_FILE"
}

echo "🔑 Ajout des API keys..."
echo ""

# OpenAI
OPENAI_KEY="$(read_secret "OpenAI API Key (laissez vide pour skip): ")"
if [ ! -z "$OPENAI_KEY" ]; then
    update_env "OPENAI_API_KEY" "$OPENAI_KEY"
    echo "✓ OPENAI_API_KEY configuré"
fi

# Anthropic (Claude)
ANTHROPIC_KEY="$(read_secret "Anthropic API Key (laissez vide pour skip): ")"
if [ ! -z "$ANTHROPIC_KEY" ]; then
    update_env "ANTHROPIC_API_KEY" "$ANTHROPIC_KEY"
    echo "✓ ANTHROPIC_API_KEY configuré"
fi

# GitHub - Auto-authenticate using token from Doppler (if available) or local .env
GITHUB_TOKEN=""
GITHUB_FROM_DOPPLER=""

# Try Doppler first (if available)
if command -v doppler &>/dev/null && doppler me &>/dev/null; then
    GITHUB_FROM_DOPPLER=$(doppler secrets get GH_TOKEN --plain 2>/dev/null || doppler secrets get GITHUB_TOKEN --plain 2>/dev/null)
    if [ ! -z "$GITHUB_FROM_DOPPLER" ]; then
        GITHUB_TOKEN="$GITHUB_FROM_DOPPLER"
        echo "✅ GITHUB_TOKEN trouvé dans Doppler"
    fi
fi

# Fallback to local .env if Doppler not available
if [ -z "$GITHUB_TOKEN" ] && [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    if [ ! -z "$GITHUB_TOKEN" ]; then
        echo "✅ GITHUB_TOKEN trouvé dans le fichier local"
    fi
fi

if [ ! -z "$GITHUB_TOKEN" ]; then
    # Auto-authenticate with GitHub CLI
    if command -v gh &> /dev/null; then
        if ! gh auth status &>/dev/null; then
            echo "🔑 Authentication automatique avec GitHub CLI..."
            echo "$GITHUB_TOKEN" | gh auth login --with-token >/dev/null 2>&1
            
            if gh auth status &>/dev/null; then
                echo "✅ GitHub CLI authentifié automatiquement!"
            else
                echo "⚠️ L'authentification GitHub a échoué - vous devrez la faire manuellement"
            fi
        else
            echo "✅ GitHub CLI déjà authentifié"
        fi
    else
        echo "⚠️ GitHub CLI non installé (pkg install gh) - installez-le puis ré-authentifiez"
    fi
else
    echo "⚠️ Aucun GITHUB_TOKEN trouvé"
    echo "💡 Ajoutez-le avec: doppler secrets set GITHUB_TOKEN=\"ghp_votre_token\""
    echo "   Ou configurez-le localement avec la section API keys ci-dessus"
fi

# Google AI (Gemini)
GOOGLE_AI_KEY="$(read_secret "Google AI API Key (laissez vide pour skip): ")"
if [ ! -z "$GOOGLE_AI_KEY" ]; then
    update_env "GOOGLE_AI_API_KEY" "$GOOGLE_AI_KEY"
    echo "✓ GOOGLE_AI_API_KEY configuré"
fi

# Groq
GROQ_KEY="$(read_secret "Groq API Key (laissez vide pour skip): ")"
if [ ! -z "$GROQ_KEY" ]; then
    update_env "GROQ_API_KEY" "$GROQ_KEY"
    echo "✓ GROQ_API_KEY configuré"
fi

# Deepseek
DEEPSEEK_KEY="$(read_secret "Deepseek API Key (laissez vide pour skip): ")"
if [ ! -z "$DEEPSEEK_KEY" ]; then
    update_env "DEEPSEEK_API_KEY" "$DEEPSEEK_KEY"
    echo "✓ DEEPSEEK_API_KEY configuré"
fi

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📋 Pour voir vos secrets configurés:"
echo "   cat $ENV_FILE"
echo ""
echo "🔄 Pour charger les secrets dans votre shell:"
echo "   source $ENV_FILE"
echo ""
echo "💡 Pour charger automatiquement au démarrage, ajoutez à ~/.bashrc:"
echo "   [ -f $ENV_FILE ] && source $ENV_FILE"
echo ""

# Demander si on veut ajouter à .bashrc
read -p "Ajouter le chargement automatique à ~/.bashrc ? (y/N): " ADD_BASHRC
if [ "$ADD_BASHRC" = "y" ] || [ "$ADD_BASHRC" = "Y" ]; then
    BASHRC_LINE="[ -f $ENV_FILE ] && source $ENV_FILE"
    if ! grep -qF "$BASHRC_LINE" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# Auto-load API keys" >> ~/.bashrc
        echo "$BASHRC_LINE" >> ~/.bashrc
        echo "✅ Ajouté à ~/.bashrc"
        echo "🔄 Rechargez votre shell: source ~/.bashrc"
    else
        echo "✓ Déjà présent dans ~/.bashrc"
    fi
fi

echo ""
echo "🔒 Sécurité: N'oubliez pas d'ajouter .dotfiles-secrets.env à .gitignore"
