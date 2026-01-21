# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

al-smart-compile is a Bash-based smart wrapper for the AL Language compiler (Microsoft Dynamics 365 Business Central development). It's a single-file shell script that auto-detects workspace structure, analyzers, package paths, and provides clean compilation output.

## Architecture

### Single-File Design
The entire tool is implemented in a single executable Bash script (`al-compile`) with no external dependencies except:
- AL Language extension for VS Code (required for compiler/analyzers)
- `jq` for JSON parsing (optional but recommended for error reporting)

### Key Components (in al-compile script)

**Environment Detection (lines 104-195)**
- Verifies AL project by checking for `app.json`
- Auto-discovers AL extension directory in `~/.vscode/extensions/ms-dynamics-smb.al-*`
- Detects multi-app workspace via `*.code-workspace` files in parent directories
- Builds package cache paths from all `.alpackages` directories in workspace
- Uses the compiler (`bin/linux/alc`) from the detected extension

**Analyzer Management (lines 206-295)**
- Supports 5 analyzers: CodeCop, UICop, PerTenantExtensionCop, AppSourceCop, LinterCop
- Four modes: `default` (auto-includes AppSourceCop if config exists), `all`, `none`, or custom comma-separated list
- Analyzer DLLs loaded from `$AL_EXT_DIR/bin/Analyzers/`
- Warns if AppSourceCop is enabled without `AppSourceCop.json` config

**Ruleset Detection (lines 297-323)**
- Searches for rulesets in order: workspace root `custom.ruleset.json`, project `AppSourceCop.json`, parent/project `custom.ruleset.json`
- Automatically applies `/enableexternalrulesets` flag when ruleset found (unless `--no-rulesets` specified)

**Compilation & Error Reporting (lines 328-403)**
- Builds command array with all detected paths and flags
- Runs compiler with `/parallel` (default), `/reportsuppresseddiagnostics`, and `/errorlog`
- On failure, parses error log with `jq` to show summary: error count, warning count, and first 5 errors
- Error log saved to `.dev/compile-errors.log` by default

## Common Commands

### Development
```bash
# Basic compilation with default analyzers
al-compile

# Clean package cache and recompile
al-compile --clean

# Verbose output (shows detected paths, compiler version, full command)
al-compile --verbose
```

### Testing Different Analyzer Configurations
```bash
# All analyzers (includes AppSourceCop even without config)
al-compile --analyzers all

# No analyzers (fastest compilation)
al-compile --analyzers none

# Custom analyzer combination
al-compile --analyzers CodeCop,UICop
al-compile --analyzers AppSource,Linter
```

### Debugging Compilation Issues
```bash
# Custom error log location
al-compile --output my-errors.json

# Disable parallel compilation (useful for debugging race conditions)
al-compile --no-parallel

# Disable external rulesets
al-compile --no-rulesets
```

### Installation/Update
```bash
# Install to user bin directory
./install.sh

# Manual installation
cp al-compile ~/.local/bin/
chmod +x ~/.local/bin/al-compile
```

## Workspace Structure Assumptions

### Single-App Projects
- Must have `app.json` in current directory
- Symbols in `./.alpackages/`

### Multi-App Workspaces
- Detects `*.code-workspace` file in parent or grandparent directory
- Searches for all `.alpackages` directories within workspace (max depth 2)
- Combines them with semicolon separator for AL compiler's `/packagecachepath`
- Example workspace structure:
  ```
  workspace-root/
  ├── workspace.code-workspace
  ├── app1/
  │   ├── app.json
  │   └── .alpackages/
  └── app2/
      ├── app.json
      └── .alpackages/
  ```

## Analyzer Short Names

When using `--analyzers` with comma-separated list, these aliases work:
- `PerTenant` → PerTenantExtensionCop
- `AppSource` → AppSourceCop
- `Linter` → LinterCop

## Important Implementation Details

### AppSourceCop Configuration
- If `AppSourceCop.json` exists, default mode automatically includes AppSourceCop analyzer
- Without `AppSourceCop.json`, AppSourceCop diagnostics are silently suppressed by the AL compiler
- Required config structure:
  ```json
  {
    "mandatoryAffixes": ["YourPrefix"],
    "supportedCountries": ["US"]
  }
  ```

### Error Log Format
- Output is JSON with structure: `{ "diagnostics": [ { "severity": "Error|Warning", "code": "...", "message": "...", "source": "filename", "range": { "start": { "line": N, "character": N } } } ] }`
- Used for structured error reporting and IDE integration

### Path Resolution
- All paths are resolved to absolute paths before passing to compiler
- Package cache paths use semicolon separator (AL compiler convention)
- Ruleset paths passed as absolute paths via `/ruleset:` flag

## Version Information
Current version: 1.0.0 (see VERSION variable in al-compile:8)
