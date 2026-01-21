# al-smart-compile

[![CI](https://github.com/StefanMaron/al-smart-compile/actions/workflows/ci.yml/badge.svg)](https://github.com/StefanMaron/al-smart-compile/actions/workflows/ci.yml)
[![GitHub release](https://img.shields.io/github/v/release/StefanMaron/al-smart-compile)](https://github.com/StefanMaron/al-smart-compile/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A smart wrapper for the AL Language compiler (Business Central development) that auto-detects workspace structure, analyzers, and package paths.

## Table of Contents

- [Why use this?](#why-use-this)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Analyzer Modes](#analyzer-modes)
- [Requirements](#requirements)
- [Workspace Detection](#workspace-detection)
- [Error Reporting](#error-reporting)
- [Options](#options)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Why use this?

If you're developing for Microsoft Dynamics 365 Business Central using AL, you typically have to:

1. Find the AL extension path manually
2. Locate the compiler binary for your platform
3. Specify analyzer DLL paths one by one
4. Hunt down all `.alpackages` directories in multi-app workspaces
5. Remember complex compiler flags and syntax

**al-smart-compile does all of this automatically.**

Instead of this:
```bash
~/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/linux/alc \
  /project:/path/to/project \
  /packagecachepath:/path/to/.alpackages \
  /analyzer:~/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll \
  /analyzer:~/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/Analyzers/Microsoft.Dynamics.Nav.UICop.dll \
  # ... more flags ...
```

You just type:
```bash
al-compile
```

## Features

- **Cross-platform**: Works on Linux, Windows (Git Bash/WSL), and macOS
- **Auto-detection**: Automatically finds AL extension, analyzers, and package directories
- **Multi-app workspace support**: Detects `.code-workspace` files and includes all `.alpackages` paths
- **Flexible analyzer configuration**: Choose default, all, none, or custom analyzer combinations
- **Smart ruleset detection**: Finds and applies rulesets from workspace or project
- **Clean error reporting**: Structured output with colored messages and error summaries
- **Parallel compilation**: Enabled by default for faster builds

## Installation

### Linux / macOS

```bash
# Copy to your local bin directory
cp al-compile ~/.local/bin/
chmod +x ~/.local/bin/al-compile

# Make sure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

Or use the install script:

```bash
./install.sh
```

### Windows

#### PowerShell (Recommended)

**Easy installation:**
```powershell
# Run the installer script
.\install.ps1

# Restart your terminal, then use:
al-compile.ps1
```

**Manual installation:**
```powershell
# Copy to your PowerShell profile directory
$installDir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $installDir
Copy-Item al-compile.ps1 $installDir\

# Add to PATH (if not already added)
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "User")
}

# Restart your terminal, then run:
al-compile.ps1
```

#### Alternative: WSL (Windows Subsystem for Linux)

If you prefer using WSL, follow the Linux installation instructions above. WSL is fully supported and uses the Linux AL compiler.

#### Alternative: Git Bash

If you have Git Bash installed:

```bash
mkdir -p ~/.local/bin
cp al-compile ~/.local/bin/
chmod +x ~/.local/bin/al-compile
export PATH="$HOME/.local/bin:$PATH"  # Add to ~/.bashrc
```

## Quick Start

**Linux / macOS / Git Bash:**
```bash
# Navigate to your AL project directory
cd /path/to/your/al-project

# Run compilation with default settings
al-compile
```

**Windows PowerShell:**
```powershell
# Navigate to your AL project directory
cd C:\path\to\your\al-project

# Run compilation with default settings
al-compile.ps1
```

## Usage Examples

### Basic Compilation

```bash
al-compile
```

**Output:**
```
ℹ Detected AL extension: /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234
ℹ Compiler version: 14.2.1234.5678
ℹ Using default analyzers: CodeCop, UICop, PerTenantExtensionCop, LinterCop
ℹ Compiling...
✓ Compilation successful!
✓ Output: MyExtension_1.0.0.0.app
```

### Compilation with Errors

When compilation fails, you get a structured error summary:

```bash
al-compile
```

**Output:**
```
ℹ Detected AL extension: /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234
ℹ Compiler version: 14.2.1234.5678
ℹ Using default analyzers: CodeCop, UICop, PerTenantExtensionCop, LinterCop
ℹ Compiling...
✗ Compilation failed!

Error Summary:
  Total errors: 3
  Total warnings: 7

First 5 errors:
  1. [AL0118] src/HelloWorld.al:15:9
     The name 'CustomerRec' does not exist in the current context

  2. [AL0132] src/Tables/Customer.al:42:5
     Field 'Email' must have a value

  3. [CodeCop AA0001] src/Codeunit/MyCodeunit.al:28:1
     There must be exactly one space character on each side of a binary operator

Error log saved to: .dev/compile-errors.log
```

### Verbose Mode

See exactly what the tool detects and the full compiler command:

```bash
al-compile --verbose
```

**Output:**
```
ℹ Detected AL extension: /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234
ℹ Compiler: /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/linux/alc
ℹ Compiler version: 14.2.1234.5678
ℹ Project directory: /home/user/projects/my-bc-app
ℹ Package cache paths:
    /home/user/projects/my-bc-app/.alpackages
ℹ Using default analyzers: CodeCop, UICop, PerTenantExtensionCop, LinterCop
ℹ Analyzer paths:
    /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/Analyzers/Microsoft.Dynamics.Nav.CodeCop.dll
    /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/Analyzers/Microsoft.Dynamics.Nav.UICop.dll
    /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/Analyzers/Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll
    /home/user/.vscode/extensions/ms-dynamics-smb.al-14.2.1234/bin/Analyzers/LinterCop.dll
ℹ Compiling...
✓ Compilation successful!
✓ Output: MyExtension_1.0.0.0.app
```

### Common Workflows

```bash
# Clean and compile
al-compile --clean

# Compile with all analyzers
al-compile --analyzers all

# Compile with specific analyzers
al-compile --analyzers CodeCop,UICop

# Compile without analyzers (fastest)
al-compile --analyzers none

# Custom error log location
al-compile --output errors.json

# Disable parallel compilation (useful for debugging)
al-compile --no-parallel
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

- **Platform**: Linux, macOS, or Windows (Git Bash/WSL)
- **AL Language extension** for VS Code installed
- **Symbols downloaded**: Run "AL: Download Symbols" in VS Code
- **jq**: For error log parsing (optional but recommended)
  - Linux: `sudo apt install jq` or `sudo dnf install jq`
  - macOS: `brew install jq`
  - Windows: `choco install jq` (Git Bash) or install in WSL

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

## Troubleshooting

### "AL extension not found"

Make sure you have the AL Language extension installed in VS Code:
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "AL Language"
4. Install the extension by Microsoft

The extension should be in:
- **Linux/macOS**: `~/.vscode/extensions/ms-dynamics-smb.al-*`
- **Windows**: `%USERPROFILE%\.vscode\extensions\ms-dynamics-smb.al-*`
- **WSL**: `~/.vscode/extensions/ms-dynamics-smb.al-*`

### "No symbols found" or "Cannot resolve type" errors

Download symbols first:
1. Open your AL project in VS Code
2. Press Ctrl+Shift+P
3. Run "AL: Download Symbols"
4. Wait for download to complete
5. Try `al-compile` again

### Compilation succeeds but no .app file

Check your `app.json` file:
- Ensure `version` field is set
- Ensure `name` and `publisher` fields are set
- The output file will be named `{name}_{version}.app`

### "Permission denied" when running al-compile

Make the script executable:
```bash
chmod +x ~/.local/bin/al-compile
```

### AppSourceCop warnings about missing configuration

Either:
- Create an `AppSourceCop.json` in your project root with required fields
- Use `--analyzers` without AppSourceCop: `al-compile --analyzers CodeCop,UICop`

Example `AppSourceCop.json`:
```json
{
  "mandatoryAffixes": ["YourPrefix"],
  "supportedCountries": ["US"]
}
```

### Slow compilation in large workspaces

Try:
- `al-compile --no-parallel` to see if parallel compilation is causing issues
- `al-compile --analyzers none` to disable analyzers temporarily
- Check if your `.alpackages` directories contain unnecessary old symbols

### Windows: "AL extension not found" error

Make sure you're using the correct VS Code installation:
- Check `%USERPROFILE%\.vscode\extensions` for the AL extension
- If using VS Code Insiders, the path might be `%USERPROFILE%\.vscode-insiders\extensions`
- For PowerShell: Use `al-compile.ps1`
- For Git Bash/WSL: Use `al-compile` (requires Bash)

### Windows: Script runs but uses wrong compiler

The script automatically detects your environment and uses the correct compiler:
- **PowerShell**: Uses Windows compiler (`bin/win32/alc.exe`)
- **Git Bash**: Uses Windows compiler (`bin/win32/alc.exe`)
- **WSL**: Uses Linux compiler (`bin/linux/alc`)

To verify which platform is detected, run:
```powershell
# PowerShell
al-compile.ps1 -Verbose

# Git Bash/WSL
al-compile --verbose
```

Look for the "Platform: windows/wsl/linux" line in the output.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on GitHub.

See [TODO.md](TODO.md) for planned features and roadmap.

## License

MIT
