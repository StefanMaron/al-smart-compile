# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-21

### Added
- Initial release of al-smart-compile for Linux
- Auto-detection of AL Language extension in `~/.vscode/extensions/`
- Auto-detection of AL compiler binary (`bin/linux/alc`)
- Multi-app workspace support via `*.code-workspace` file detection
- Automatic discovery of all `.alpackages` directories in workspace
- Flexible analyzer configuration with four modes:
  - `default`: CodeCop, UICop, PerTenantExtensionCop, LinterCop (+ AppSourceCop if config exists)
  - `all`: All available analyzers including AppSourceCop
  - `none`: No analyzers
  - Custom comma-separated list (e.g., `CodeCop,UICop`)
- Analyzer short name aliases: `PerTenant`, `AppSource`, `Linter`
- Smart ruleset detection from workspace or project directories
- Automatic `/enableexternalrulesets` flag when ruleset found
- Clean error reporting with structured JSON output
- Error summary display showing:
  - Total error and warning counts
  - First 5 errors with file locations and line numbers
- Colored terminal output for better readability
- Parallel compilation enabled by default (`/parallel` flag)
- `--clean` flag to clear package cache before compilation
- `--analyzers <mode>` flag for analyzer selection
- `--output <file>` flag for custom error log location (default: `.dev/compile-errors.log`)
- `--no-parallel` flag to disable parallel compilation
- `--no-rulesets` flag to disable external ruleset support
- `--verbose` flag for detailed output (paths, compiler version, full command)
- `--version` flag to show version information
- `--help` flag for usage information
- Error log parsing with `jq` for structured error reporting
- Installation script (`install.sh`) for easy setup

### Technical Details
- Single-file Bash script with no external dependencies (except AL extension)
- Optional `jq` dependency for enhanced error reporting
- Workspace detection searches parent and grandparent directories
- Package cache paths combined with semicolon separator
- Absolute path resolution for all compiler arguments
- Proper handling of AppSourceCop configuration requirements

[1.0.0]: https://github.com/StefanMaron/al-smart-compile/releases/tag/v1.0.0
