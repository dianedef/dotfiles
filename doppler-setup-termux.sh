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

# Fonction pour ajouter/mettre à jour une variable
update_env() {
    local key=$1
    local value=$2
    
    if grep -q "^export $key=" "$ENV_FILE" 2>/dev/null; then
        # Mettre à jour la ligne existante (portable pour Termux)
        grep -v "^export $key=" "$ENV_FILE" > "$ENV_FILE.tmp" || true
        echo "export $key=\"$value\"" >> "$ENV_FILE.tmp"
        mv "$ENV_FILE.tmp" "$ENV_FILE"
    else
        # Ajouter la nouvelle ligne
        echo "export $key=\"$value\"" >> "$ENV_FILE"
    fi
}

echo "🔑 Ajout des API keys..."
echo ""

# OpenAI
read -p "OpenAI API Key (laissez vide pour skip): " OPENAI_KEY
if [ ! -z "$OPENAI_KEY" ]; then
    update_env "OPENAI_API_KEY" "$OPENAI_KEY"
    echo "✓ OPENAI_API_KEY configuré"
fi

# Anthropic (Claude)
read -p "Anthropic API Key (laissez vide pour skip): " ANTHROPIC_KEY
if [ ! -z "$ANTHROPIC_KEY" ]; then
    update_env "ANTHROPIC_API_KEY" "$ANTHROPIC_KEY"
    echo "✓ ANTHROPIC_API_KEY configuré"
fi

# GitHub
read -p "GitHub Token (laissez vide pour skip): " GITHUB_TOKEN
if [ ! -z "$GITHUB_TOKEN" ]; then
    update_env "GITHUB_TOKEN" "$GITHUB_TOKEN"
    echo "✓ GITHUB_TOKEN configuré"
fi

# Google AI (Gemini)
read -p "Google AI API Key (laissez vide pour skip): " GOOGLE_AI_KEY
if [ ! -z "$GOOGLE_AI_KEY" ]; then
    update_env "GOOGLE_AI_API_KEY" "$GOOGLE_AI_KEY"
    echo "✓ GOOGLE_AI_API_KEY configuré"
fi

# Groq
read -p "Groq API Key (laissez vide pour skip): " GROQ_KEY
if [ ! -z "$GROQ_KEY" ]; then
    update_env "GROQ_API_KEY" "$GROQ_KEY"
    echo "✓ GROQ_API_KEY configuré"
fi

# Deepseek
read -p "Deepseek API Key (laissez vide pour skip): " DEEPSEEK_KEY
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
