#!/bin/bash

# Doppler Setup Script - Configuration des API keys
# Ce script initialise Doppler avec vos secrets pour différents services

set -e

echo "🔐 Configuration de Doppler pour vos API keys"
echo "=============================================="
echo ""

# Vérifier si Doppler est connecté, sinon lancer le login
echo "🔑 Vérification de l'authentification Doppler..."
if ! doppler me &>/dev/null; then
    echo "⚠️  Vous n'êtes pas connecté à Doppler"
    echo "🌐 Lancement de l'authentification Doppler..."
    doppler login
    echo "✅ Authentification Doppler réussie!"
else
    echo "✅ Déjà authentifié sur Doppler ($(doppler me --json 2>/dev/null | grep -o '"email":"[^"]*"' | cut -d'"' -f4))"
fi

echo ""

# Créer le projet dotfiles
echo "📁 Création du projet 'dotfiles'..."
doppler projects create dotfiles --description "Configuration et secrets pour dotfiles" 2>/dev/null || echo "✓ Projet 'dotfiles' existe déjà"

# Setup du projet dans le répertoire actuel
echo "⚙️  Configuration du projet dans ce répertoire..."
doppler setup --project dotfiles --config dev --no-interactive

echo ""
echo "🔑 Vérification des API keys dans Doppler..."
echo ""

# Function to check and display API key status
check_api_key() {
    local key_name=$1
    local display_name=$2
    local secret_key=$3
    
    local value=$(doppler secrets get "$secret_key" --plain 2>/dev/null)
    if [ ! -z "$value" ]; then
        echo "✅ $display_name trouvé dans Doppler"
        return 0
    else
        echo "⚠️  $display_name non trouvé dans Doppler"
        return 1
    fi
}

# Check all API keys
check_api_key "OPENAI_API_KEY" "OpenAI" "OPENAI_API_KEY"
check_api_key "ANTHROPIC_API_KEY" "Anthropic (Claude)" "ANTHROPIC_API_KEY"

# GitHub - Auto-authenticate using token from Doppler
GITHUB_TOKEN=$(doppler secrets get GH_TOKEN --plain 2>/dev/null || doppler secrets get GITHUB_TOKEN --plain 2>/dev/null)
if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "✅ GITHUB_TOKEN trouvé dans Doppler"
    
    # Auto-authenticate with GitHub CLI using the token from Doppler
    if command -v gh &> /dev/null; then
        if ! gh auth status &>/dev/null 2>&1; then
            echo "🔑 Authentication automatique avec GitHub CLI..."
            echo "$GITHUB_TOKEN" | gh auth login --with-token >/dev/null 2>&1
            
            if gh auth status &>/dev/null 2>&1; then
                echo "✅ GitHub CLI authentifié automatiquement!"
            else
                echo "⚠️ L'authentification GitHub a échoué - vous devrez la faire manuellement"
            fi
        else
            echo "✅ GitHub CLI déjà authentifié"
        fi
    else
        echo "⚠️ GitHub CLI non installé - installez-le puis ré-authentifiez"
    fi
else
    echo "⚠️ Aucun GITHUB_TOKEN trouvé dans Doppler"
fi

check_api_key "GEMINI_AI" "Google AI (Gemini)" "GEMINI_AI"
check_api_key "GROQ" "Groq" "GROQ"
check_api_key "DEEPSEEK_API_KEY" "Deepseek" "DEEPSEEK_API_KEY"

echo ""
echo "💡 Pour ajouter une API key manuellement:"
echo "   doppler secrets set OPENAI_API_KEY=\"votre_key\""
echo "   doppler secrets set GITHUB_TOKEN=\"ghp_votre_token\""
echo "   etc."

echo ""
echo "🎨 Configuration d'OpenCode..."
if command -v opencode &> /dev/null; then
    read -p "Voulez-vous configurer OpenCode maintenant? (y/N): " SETUP_OPENCODE
    if [ "$SETUP_OPENCODE" = "y" ] || [ "$SETUP_OPENCODE" = "Y" ]; then
        echo "🌐 Lancement de l'authentification OpenCode..."
        opencode auth login
        
        # Récupérer le token configuré et le stocker dans Doppler
        if [ -f "$HOME/.opencode/config.json" ]; then
            OPENCODE_TOKEN=$(grep -o '"apiKey":"[^"]*"' "$HOME/.opencode/config.json" 2>/dev/null | cut -d'"' -f4)
            if [ ! -z "$OPENCODE_TOKEN" ]; then
                doppler secrets set OPENCODE_API_KEY="$OPENCODE_TOKEN" --silent
                echo "✓ OPENCODE_API_KEY configuré et synchronisé avec Doppler"
            fi
        fi
    else
        echo "⏭️  Configuration OpenCode skippée (lancez 'opencode auth login' plus tard)"
    fi
else
    echo "⚠️  OpenCode CLI non installé, installation via: npm install -g opencode-ai"
fi

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📋 Pour voir vos secrets configurés:"
echo "   doppler secrets"
echo ""
echo "🌐 Pour voir vos secrets sur le dashboard web:"
echo "   doppler open"
echo ""
echo "🔄 Pour utiliser vos secrets dans une commande:"
echo "   doppler run -- votre-commande"
echo ""
echo "🌍 Pour exporter les variables dans votre shell:"
echo "   eval \$(doppler secrets download --no-file --format env-no-quotes)"
echo ""
echo "💡 Astuce: Ajoutez à votre ~/.bashrc pour charger automatiquement:"
echo "   eval \$(doppler secrets download --no-file --format env-no-quotes 2>/dev/null || true)"
echo ""
