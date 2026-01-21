# al-smart-compile

A smart wrapper for the AL Language compiler (Business Central development) that auto-detects workspace structure, analyzers, and package paths.

## Features

- **Auto-detection**: Automatically finds AL extension, analyzers, and package directories
- **Multi-app workspace support**: Detects `.code-workspace` files and includes all `.alpackages` paths
- **Flexible analyzer configuration**: Choose default, all, none, or custom analyzer combinations
- **Smart ruleset detection**: Finds and applies rulesets from workspace or project
- **Clean error reporting**: Structured output with colored messages and error summaries
- **Parallel compilation**: Enabled by default for faster builds

## Installation

```bash
# Copy to your local bin directory
cp al-compile ~/.local/bin/
chmod +x ~/.local/bin/al-compile

# Make sure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
# Basic compile with default analyzers
al-compile

# Clean and compile
al-compile --clean

# Compile with all analyzers
al-compile --analyzers all

# Compile with specific analyzers
al-compile --analyzers CodeCop,UICop

# Compile without analyzers
al-compile --analyzers none

# Custom error log location
al-compile --output errors.json

# Verbose output
al-compile --verbose
```

## Analyzer Modes

### Default
Includes: CodeCop, UICop, PerTenantExtensionCop, LinterCop
- Automatically adds AppSourceCop if `AppSourceCop.json` exists in project

### All
Includes all available analyzers:
- CodeCop
- UICop
- PerTenantExtensionCop
- AppSourceCop
- LinterCop

### None
Disables all analyzers

### Custom
Comma-separated list of analyzers:
- `CodeCop`
- `UICop`
- `PerTenantExtensionCop` (or `PerTenant`)
- `AppSourceCop` (or `AppSource`)
- `LinterCop` (or `Linter`)

## Requirements

- AL Language extension for VS Code installed
- Symbols downloaded (run "AL: Download Symbols" in VS Code)
- `jq` for error log parsing (optional but recommended)

## Workspace Detection

The tool automatically detects:
1. **Multi-app workspaces**: Looks for `*.code-workspace` files in parent directories
2. **Package paths**: Finds all `.alpackages` directories in workspace
3. **Rulesets**: Searches for `custom.ruleset.json` or `AppSourceCop.json`

## Error Reporting

Compilation errors are saved to `.dev/compile-errors.log` (configurable) in JSON format.
Error summary is displayed on failure with:
- Total error and warning counts
- First 5 errors with file locations

## Options

```
--clean              Clean .alpackages before compiling
--analyzers <mode>   Analyzer mode (default/all/none/custom list)
--output <file>      Error log output file (default: .dev/compile-errors.log)
--no-parallel        Disable parallel compilation
--no-rulesets        Disable external ruleset support
--verbose, -v        Verbose output
--version            Show version information
--help, -h           Show this help
```

## License

MIT
