# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2026-04-29]

### Fixed
- Hardened the Termux local secret setup flow so API keys are prompted with hidden input and Shell-GPT config writes now warn instead of reporting false success when the file cannot be written.

### Security
- Serialized Termux local secrets and generated Shell-GPT config with shell-safe escaping and `0600` file permissions to avoid quote breakage and accidental local exposure.
