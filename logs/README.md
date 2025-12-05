# Workspace Logging System

This directory contains logs for the dotfiles workspace. The logging system is designed to track various activities and operations within the workspace.

## Log Structure

- `workspace.log` - Main workspace operations log
- `install.log` - Installation and setup operations
- `errors.log` - Error and exception logging
- `debug.log` - Debug and development logging

## Log Format

All logs follow this format:
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] [SOURCE] MESSAGE
```

Where:
- LEVEL: INFO, WARN, ERROR, DEBUG
- SOURCE: Component or script generating the log
- MESSAGE: Log message content

## Usage

To view logs:
```bash
# View main log
tail -f logs/workspace.log

# View errors only
grep "ERROR" logs/*.log

# View recent logs
tail -n 50 logs/workspace.log
```

## Log Rotation

Logs are rotated automatically when they reach 1MB in size, with a maximum of 5 rotated logs kept.