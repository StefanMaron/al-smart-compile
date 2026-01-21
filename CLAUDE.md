# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

al-smart-compile is a cross-platform smart wrapper for the AL Language compiler (Microsoft Dynamics 365 Business Central development). It's available as both a Bash script (`al-compile`) and PowerShell script (`al-compile.ps1`) that auto-detects workspace structure, analyzers, package paths, and provides clean compilation output.

## Architecture

### Single-File Design
The tool is implemented in two single-file scripts with feature parity:
- **`al-compile`**: Bash script for Linux, macOS, Git Bash, and WSL
- **`al-compile.ps1`**: PowerShell script for native Windows PowerShell/cmd.exe

No external dependencies except:
- AL Language extension for VS Code (required for compiler/analyzers)
- `jq` (Bash) or `ConvertFrom-Json` (PowerShell) for error log parsing (optional but recommended)

### Key Components (in al-compile script)

**Platform Detection (lines 11-52)**
- Detects platform: Linux, macOS, Windows (Git Bash), or WSL
- Sets platform-specific paths for VS Code extensions:
  - Linux/macOS/WSL: `~/.vscode/extensions`
  - Windows (Git Bash): `$USERPROFILE/.vscode/extensions`
  - Windows (PowerShell): `$env:USERPROFILE\.vscode\extensions`
- Selects correct compiler binary:
  - Linux/WSL: `bin/linux/alc`
  - macOS: `bin/darwin/alc`
  - Windows: `bin/win32/alc.exe`

**Environment Detection (lines 170-240)**
- Verifies AL project by checking for `app.json`
- Auto-discovers AL extension directory in platform-specific extensions path
- Detects multi-app workspace via `*.code-workspace` files in parent directories
- Builds package cache paths from all `.alpackages` directories in workspace
- Uses the platform-appropriate compiler from the detected extension

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

**Bash (Linux/macOS/Git Bash/WSL):**
```bash
# Basic compilation with default analyzers
al-compile

# Clean package cache and recompile
al-compile --clean

# Verbose output (shows detected paths, compiler version, full command)
al-compile --verbose
```

**PowerShell (Windows):**
```powershell
# Basic compilation with default analyzers
al-compile.ps1

# Clean package cache and recompile
al-compile.ps1 -Clean

# Verbose output (shows detected paths, compiler version, full command)
al-compile.ps1 -Verbose
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
Current version: 1.1.0 (see VERSION variable in al-compile:8 and al-compile.ps1:13)

## Platform Support

### Bash Script (`al-compile`)
- **Linux**: Full support with native `bin/linux/alc` compiler
- **macOS**: Full support with native `bin/darwin/alc` compiler
- **Windows (Git Bash)**: Full support using `bin/win32/alc.exe` compiler
- **Windows (WSL)**: Full support using `bin/linux/alc` compiler (Linux mode)

### PowerShell Script (`al-compile.ps1`)
- **Windows (PowerShell)**: Full support with native `bin/win32/alc.exe` compiler
- **Windows (cmd.exe)**: Works via `powershell -File al-compile.ps1`

Both scripts have complete feature parity and automatically detect the correct platform and compiler to use.
