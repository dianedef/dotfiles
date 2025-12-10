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
echo "🔑 Ajout des API keys..."
echo ""

# OpenAI
read -p "OpenAI API Key (laissez vide pour skip): " OPENAI_KEY
if [ ! -z "$OPENAI_KEY" ]; then
    doppler secrets set OPENAI_API_KEY="$OPENAI_KEY" --silent
    echo "✓ OPENAI_API_KEY configuré"
fi

# Anthropic (Claude)
read -p "Anthropic API Key (laissez vide pour skip): " ANTHROPIC_KEY
if [ ! -z "$ANTHROPIC_KEY" ]; then
    doppler secrets set ANTHROPIC_API_KEY="$ANTHROPIC_KEY" --silent
    echo "✓ ANTHROPIC_API_KEY configuré"
fi

# GitHub
read -p "GitHub Token (laissez vide pour skip): " GITHUB_TOKEN
if [ ! -z "$GITHUB_TOKEN" ]; then
    doppler secrets set GITHUB_TOKEN="$GITHUB_TOKEN" --silent
    echo "✓ GITHUB_TOKEN configuré"
fi

# Google AI (Gemini)
read -p "Google AI API Key (laissez vide pour skip): " GOOGLE_AI_KEY
if [ ! -z "$GOOGLE_AI_KEY" ]; then
    doppler secrets set GOOGLE_AI_API_KEY="$GOOGLE_AI_KEY" --silent
    echo "✓ GOOGLE_AI_API_KEY configuré"
fi

# Groq
read -p "Groq API Key (laissez vide pour skip): " GROQ_KEY
if [ ! -z "$GROQ_KEY" ]; then
    doppler secrets set GROQ_API_KEY="$GROQ_KEY" --silent
    echo "✓ GROQ_API_KEY configuré"
fi

# Deepseek
read -p "Deepseek API Key (laissez vide pour skip): " DEEPSEEK_KEY
if [ ! -z "$DEEPSEEK_KEY" ]; then
    doppler secrets set DEEPSEEK_API_KEY="$DEEPSEEK_KEY" --silent
    echo "✓ DEEPSEEK_API_KEY configuré"
fi

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
