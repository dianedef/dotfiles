#!/bin/bash

# Workspace Logging System
# Centralized logging script for dotfiles workspace

# Configuration
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_DIR}/workspace.log"
ERROR_LOG_FILE="${LOG_DIR}/errors.log"
DEBUG_LOG_FILE="${LOG_DIR}/debug.log"
MAX_LOG_SIZE=$((1024 * 1024)) # 1MB
MAX_LOGS=5

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Initialize log files if they don't exist
touch "$LOG_FILE"
touch "$ERROR_LOG_FILE"
touch "$DEBUG_LOG_FILE"

# Log levels
LOG_LEVEL_INFO="INFO"
LOG_LEVEL_WARN="WARN"
LOG_LEVEL_ERROR="ERROR"
LOG_LEVEL_DEBUG="DEBUG"

# Log rotation function
rotate_logs() {
    local log_file=$1
    local base_name=$(basename "$log_file")
    local dir_name=$(dirname "$log_file")

    # Check if rotation is needed
    if [ -f "$log_file" ] && [ $(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null) -ge $MAX_LOG_SIZE ]; then
        # Rotate existing logs
        for i in $(seq $((MAX_LOGS-1)) -1 1); do
            local rotated_file="${dir_name}/${base_name}.${i}"
            if [ -f "$rotated_file" ]; then
                mv "$rotated_file" "${dir_name}/${base_name}. $((i+1))"
            fi
        done

        # Rotate current log
        if [ -f "$log_file" ]; then
            mv "$log_file" "${dir_name}/${base_name}.1"
        fi
    fi
}

# Main logging function
log() {
    local level=$1
    local source=$2
    local message=$3
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [$level] [$source] $message"

    # Rotate logs before writing
    rotate_logs "$LOG_FILE"

    # Write to main log
    echo "$log_entry" >> "$LOG_FILE"

    # Write to specific log files based on level
    case "$level" in
        "$LOG_LEVEL_ERROR")
            rotate_logs "$ERROR_LOG_FILE"
            echo "$log_entry" >> "$ERROR_LOG_FILE"
            ;;
        "$LOG_LEVEL_DEBUG")
            rotate_logs "$DEBUG_LOG_FILE"
            echo "$log_entry" >> "$DEBUG_LOG_FILE"
            ;;
    esac

    # Output to console based on level
    case "$level" in
        "$LOG_LEVEL_ERROR")
            echo -e "\033[31m[ERROR] $message\033[0m" >&2
            ;;
        "$LOG_LEVEL_WARN")
            echo -e "\033[33m[WARN] $message\033[0m" >&2
            ;;
        "$LOG_LEVEL_INFO")
            echo "[INFO] $message"
            ;;
        "$LOG_LEVEL_DEBUG")
            echo -e "\033[36m[DEBUG] $message\033[0m"
            ;;
    esac
}

# Convenience functions
log_info() {
    log "$LOG_LEVEL_INFO" "$1" "$2"
}

log_warn() {
    log "$LOG_LEVEL_WARN" "$1" "$2"
}

log_error() {
    log "$LOG_LEVEL_ERROR" "$1" "$2"
}

log_debug() {
    log "$LOG_LEVEL_DEBUG" "$1" "$2"
}

# Initialize logs
log_info "LOGGING_SYSTEM" "Logging system initialized"
log_info "LOGGING_SYSTEM" "Log directory: $LOG_DIR"