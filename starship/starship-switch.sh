#!/bin/bash
# Starship Configuration Switcher
# Automatically detects environment and applies appropriate config

set -e

STARSHIP_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_FILE="$HOME/.config/starship.toml"

# Detect current environment
detect_environment() {
    if [ "$CODESPACES" = "true" ]; then
        echo "codespace"
    elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        echo "ssh"
    elif [ -f /.dockerenv ]; then
        echo "docker"
    elif uname | grep -q "Android"; then
        echo "termux"
    else
        echo "local"
    fi
}

# Apply appropriate configuration
apply_config() {
    local env_type=$(detect_environment)
    local config_source
    
    case "$env_type" in
        "codespace")
            config_source="$STARSHIP_DIR/starship.toml"
            echo "🌐 Applying Codespace configuration..."
            ;;
        "ssh")
            config_source="$STARSHIP_DIR/starship-smart.toml"
            echo "🌐 Applying SSH configuration..."
            ;;
        "termux")
            config_source="$STARSHIP_DIR/starship-simple.toml"
            echo "📱 Applying Termux configuration..."
            ;;
        "docker")
            config_source="$STARSHIP_DIR/starship-smart.toml"
            echo "🐳 Applying Docker configuration..."
            ;;
        *)
            config_source="$STARSHIP_DIR/starship-local.toml"
            echo "💻 Applying Local configuration..."
            ;;
    esac
    
    # Create config directory if it doesn't exist
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    # Copy the appropriate configuration
    if [ -f "$config_source" ]; then
        cp "$config_source" "$CONFIG_FILE"
        echo "✅ Configuration applied: $config_source → $CONFIG_FILE"
        
        # Reload starship if it's running
        if command -v starship >/dev/null 2>&1; then
            echo "🔄 Reloading Starship..."
            export STARSHIP_CONFIG="$CONFIG_FILE"
        fi
    else
        echo "❌ Configuration file not found: $config_source"
        return 1
    fi
    
    echo "🎯 Environment detected: $env_type"
    echo "⚡ Active config: $(basename "$config_source")"
}

# Force specific configuration (optional)
force_config() {
    local config_name="$1"
    local config_source="$STARSHIP_DIR/starship-$config_name.toml"
    
    if [ -f "$config_source" ]; then
        cp "$config_source" "$CONFIG_FILE"
        echo "✅ Forced configuration applied: $config_name"
    else
        echo "❌ Configuration not found: $config_source"
            echo "Available configurations:"
            ls -1 "$STARSHIP_DIR"/starship*.toml 2>/dev/null | sed 's/.*starship-/ - /; s/\.toml$//' || echo "   No configuration files found in $STARSHIP_DIR"
        return 1
    fi
}

# Main script logic
main() {
    case "${1:-auto}" in
        "auto"|"detect")
            apply_config
            ;;
        "codespace"|"ssh"|"termux"|"docker"|"local"|"simple"|"smart")
            force_config "$1"
            ;;
        "status")
            echo "🔍 Current environment: $(detect_environment)"
            echo "📄 Active config: $(basename "$CONFIG_FILE")"
            if [ -f "$CONFIG_FILE" ]; then
                echo "📋 Config preview:"
                head -5 "$CONFIG_FILE" | sed 's/^/   /'
            fi
            ;;
        "help"|"-h"|"--help")
            echo "Starship Configuration Switcher"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  auto     Auto-detect environment (default)"
            echo "  codespace Force Codespace config"
            echo "  ssh      Force SSH config"  
            echo "  termux   Force Termux config"
            echo "  docker   Force Docker config"
            echo "  local    Force Local config"
            echo "  simple   Force Simple config"
            echo "  smart    Force Smart config"
            echo "  status   Show current status"
            echo "  help     Show this help"
            ;;
        *)
            echo "❌ Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"