# al-compile.ps1 - Smart wrapper for AL Language compiler (PowerShell version)
# Auto-detects workspace structure, analyzers, and package paths
# Version: 1.1.0

param(
    [switch]$Clean,
    [string]$Analyzers = "default",
    [string]$Output = ".dev/compile-errors.log",
    [switch]$NoParallel,
    [switch]$NoRulesets,
    [switch]$Verbose,
    [switch]$Version,
    [switch]$Help
)

$SCRIPT_VERSION = "1.1.0"

# Track CLI-provided options (to give them priority over config)
$CLI_Analyzers = $PSBoundParameters.ContainsKey('Analyzers') -and $Analyzers -ne "default"
$CLI_Output = $PSBoundParameters.ContainsKey('Output') -and $Output -ne ".dev/compile-errors.log"
$CLI_NoParallel = $PSBoundParameters.ContainsKey('NoParallel')
$CLI_NoRulesets = $PSBoundParameters.ContainsKey('NoRulesets')

# Load configuration from .al-compile.json file
function Load-Config {
    param([string]$ConfigPath)

    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

            # Apply analyzers if not set via CLI
            if (-not $script:CLI_Analyzers -and $config.PSObject.Properties['analyzers']) {
                $script:Analyzers = $config.analyzers
            }

            # Apply output if not set via CLI
            if (-not $script:CLI_Output -and $config.PSObject.Properties['output']) {
                $script:Output = $config.output
            }

            # Apply parallel if not set via CLI
            if (-not $script:CLI_NoParallel -and $config.PSObject.Properties['parallel']) {
                if ($config.parallel -eq $false) {
                    $script:NoParallel = $true
                }
            }

            # Apply rulesets if not set via CLI
            if (-not $script:CLI_NoRulesets -and $config.PSObject.Properties['rulesets']) {
                if ($config.rulesets -eq $false) {
                    $script:NoRulesets = $true
                }
            }

            return $true
        } catch {
            # Silently ignore parse errors
            return $false
        }
    }
    return $false
}

# Colors for output
function Write-Info { Write-Host "ℹ $args" -ForegroundColor Blue }
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-ErrorMsg { Write-Host "✗ $args" -ForegroundColor Red }

# Show usage
function Show-Usage {
    Write-Host @"
al-compile v$SCRIPT_VERSION - Smart AL compiler wrapper (PowerShell)

Usage: al-compile.ps1 [OPTIONS]

Auto-detects workspace structure, analyzers, and package paths.

OPTIONS:
    -Clean              Clean .alpackages before compiling
    -Analyzers <mode>   Analyzer mode: default, all, none, or comma-separated list
                        default: CodeCop, UICop, PerTenantExtensionCop, LinterCop
                                 (+ AppSourceCop if AppSourceCop.json exists)
                        all: All available analyzers including AppSourceCop
                        none: No analyzers
                        list: CodeCop,UICop,AppSourceCop (custom selection)
    -Output <file>      Error log output file (default: .dev/compile-errors.log)
    -NoParallel         Disable parallel compilation
    -NoRulesets         Disable external ruleset support
    -Verbose            Verbose output
    -Version            Show version information
    -Help               Show this help

CONFIGURATION FILE:
    Create .al-compile.json in project or workspace root to set defaults:
    {
      "analyzers": "default",
      "output": ".dev/compile-errors.log",
      "parallel": true,
      "rulesets": true
    }
    CLI arguments override config file settings.

EXAMPLES:
    al-compile.ps1                                # Basic compile with default analyzers
    al-compile.ps1 -Clean                         # Clean and compile
    al-compile.ps1 -Analyzers all                 # Compile with all analyzers
    al-compile.ps1 -Analyzers CodeCop,UICop       # Compile with specific analyzers
    al-compile.ps1 -Output errors.json            # Custom error log location

"@
    exit 0
}

# Handle flags
if ($Help) { Show-Usage }
if ($Version) {
    Write-Host "al-compile v$SCRIPT_VERSION (PowerShell)"
    exit 0
}

# Verify we're in an AL project
if (-not (Test-Path "app.json")) {
    Write-ErrorMsg "Not in an AL project directory (app.json not found)"
    exit 1
}

# Read project name from app.json
try {
    $appJson = Get-Content "app.json" -Raw | ConvertFrom-Json
    $projectName = $appJson.name
    if (-not $projectName) { $projectName = "Unknown" }
} catch {
    $projectName = "Unknown"
}
Write-Info "Project: $projectName"

# Find AL extension
if ($Verbose) {
    Write-Info "Searching for AL extension..."
}

$vscodeExtBase = "$env:USERPROFILE\.vscode\extensions"
$alExtDirs = Get-ChildItem -Path $vscodeExtBase -Filter "ms-dynamics-smb.al-*" -Directory -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1

if (-not $alExtDirs) {
    Write-ErrorMsg "AL extension not found in $vscodeExtBase"
    Write-ErrorMsg "Please install the AL Language extension for VS Code"
    exit 1
}

$alExtDir = $alExtDirs.FullName
$analyzerDir = Join-Path $alExtDir "bin\Analyzers"
$alVersion = $alExtDirs.Name -replace 'ms-dynamics-smb.al-', ''

if ($Verbose) {
    Write-Info "Platform: Windows (PowerShell)"
    Write-Info "AL Extension: $alVersion"
    Write-Info "Analyzers: $analyzerDir"
}

# Verify analyzers directory exists
if (-not (Test-Path $analyzerDir)) {
    Write-ErrorMsg "Analyzers directory not found: $analyzerDir"
    exit 1
}

# Use compiler from extension
$alCompiler = Join-Path $alExtDir "bin\win32\alc.exe"

# Verify compiler exists
if (-not (Test-Path $alCompiler)) {
    Write-ErrorMsg "AL compiler not found: $alCompiler"
    Write-ErrorMsg "Please ensure the AL extension is properly installed"
    exit 1
}

if ($Verbose) {
    try {
        $compilerVersion = & $alCompiler version 2>&1 | Select-String "version" | Select-Object -First 1
        Write-Info "Compiler: $compilerVersion"
    } catch {
        Write-Info "Compiler: (version check failed)"
    }
}

# Detect workspace structure
$workspaceFile = Get-ChildItem -Path "..\", "..\.." -Filter "*.code-workspace" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($workspaceFile) {
    Write-Info "Multi-app workspace detected: $($workspaceFile.Name)"
    $workspaceRoot = $workspaceFile.DirectoryName

    # Find all .alpackages directories in workspace
    $packageDirs = Get-ChildItem -Path $workspaceRoot -Filter ".alpackages" -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue

    if ($packageDirs.Count -eq 0) {
        Write-Warning "No .alpackages directories found in workspace"
        $packagePath = ".alpackages"
    } else {
        # Build semicolon-separated path list (AL compiler format)
        $packagePath = ($packageDirs | ForEach-Object { $_.FullName }) -join ';'

        if ($Verbose) {
            Write-Info "Package paths:"
            $packageDirs | ForEach-Object { Write-Host "  - $($_.FullName)" }
        }
    }
} else {
    Write-Info "Single-app project"
    $workspaceRoot = $null
    $packagePath = ".alpackages"
}

# Load configuration files (workspace config first, then project config overrides)
# CLI args have already been parsed and take highest priority
$configLoaded = $false
if ($workspaceRoot -and (Test-Path (Join-Path $workspaceRoot ".al-compile.json"))) {
    if (Load-Config (Join-Path $workspaceRoot ".al-compile.json")) {
        if ($Verbose) {
            Write-Info "Config: $workspaceRoot\.al-compile.json (workspace)"
        }
        $configLoaded = $true
    }
}

if (Test-Path ".al-compile.json") {
    if (Load-Config ".al-compile.json") {
        if ($Verbose) {
            Write-Info "Config: .al-compile.json (project)"
        }
        $configLoaded = $true
    }
}

# Verify package cache exists
if (-not (Test-Path ".alpackages")) {
    Write-Warning ".alpackages directory not found"
    Write-Warning "Run 'AL: Download Symbols' in VS Code first"
}

# Clean if requested
if ($Clean) {
    Write-Info "Cleaning .alpackages..."
    if (Test-Path ".alpackages") {
        Remove-Item ".alpackages\*" -Recurse -Force
        Write-Success "Cleaned package cache"
    }
}

# Build analyzer arguments based on mode
$analyzerArgs = @()

# Available analyzers
$codecop = Join-Path $analyzerDir "Microsoft.Dynamics.Nav.CodeCop.dll"
$uicop = Join-Path $analyzerDir "Microsoft.Dynamics.Nav.UICop.dll"
$pertenant = Join-Path $analyzerDir "Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll"
$appsource = Join-Path $analyzerDir "Microsoft.Dynamics.Nav.AppSourceCop.dll"
$lintercop = Join-Path $analyzerDir "BusinessCentral.LinterCop.dll"

switch ($Analyzers) {
    "none" {
        Write-Info "Analyzers: None"
    }
    "all" {
        Write-Info "Analyzers: All"
        if (Test-Path $codecop) { $analyzerArgs += "/analyzer:$codecop" }
        if (Test-Path $uicop) { $analyzerArgs += "/analyzer:$uicop" }
        if (Test-Path $pertenant) { $analyzerArgs += "/analyzer:$pertenant" }
        if (Test-Path $appsource) { $analyzerArgs += "/analyzer:$appsource" }
        if (Test-Path $lintercop) { $analyzerArgs += "/analyzer:$lintercop" }
    }
    "default" {
        # Auto-include AppSourceCop if config exists
        if (Test-Path "AppSourceCop.json") {
            Write-Info "Analyzers: Default (CodeCop, UICop, PerTenantExtensionCop, LinterCop, AppSourceCop)"
            if (Test-Path $codecop) { $analyzerArgs += "/analyzer:$codecop" }
            if (Test-Path $uicop) { $analyzerArgs += "/analyzer:$uicop" }
            if (Test-Path $pertenant) { $analyzerArgs += "/analyzer:$pertenant" }
            if (Test-Path $lintercop) { $analyzerArgs += "/analyzer:$lintercop" }
            if (Test-Path $appsource) { $analyzerArgs += "/analyzer:$appsource" }
        } else {
            Write-Info "Analyzers: Default (CodeCop, UICop, PerTenantExtensionCop, LinterCop)"
            if (Test-Path $codecop) { $analyzerArgs += "/analyzer:$codecop" }
            if (Test-Path $uicop) { $analyzerArgs += "/analyzer:$uicop" }
            if (Test-Path $pertenant) { $analyzerArgs += "/analyzer:$pertenant" }
            if (Test-Path $lintercop) { $analyzerArgs += "/analyzer:$lintercop" }
        }
    }
    default {
        # Custom comma-separated list
        Write-Info "Analyzers: Custom ($Analyzers)"
        $analyzerList = $Analyzers -split ',' | ForEach-Object { $_.Trim() }
        foreach ($analyzer in $analyzerList) {
            switch ($analyzer) {
                "CodeCop" { if (Test-Path $codecop) { $analyzerArgs += "/analyzer:$codecop" } }
                "UICop" { if (Test-Path $uicop) { $analyzerArgs += "/analyzer:$uicop" } }
                { $_ -in "PerTenantExtensionCop", "PerTenant" } { if (Test-Path $pertenant) { $analyzerArgs += "/analyzer:$pertenant" } }
                { $_ -in "AppSourceCop", "AppSource" } { if (Test-Path $appsource) { $analyzerArgs += "/analyzer:$appsource" } }
                { $_ -in "LinterCop", "Linter" } { if (Test-Path $lintercop) { $analyzerArgs += "/analyzer:$lintercop" } }
                default { Write-Warning "Unknown analyzer: $analyzer" }
            }
        }
    }
}

# Check if AppSourceCop is enabled and warn if config is missing
$usingAppSourceCop = $analyzerArgs | Where-Object { $_ -like "*AppSourceCop*" }
if ($usingAppSourceCop -and -not (Test-Path "AppSourceCop.json")) {
    Write-Host ""
    Write-Warning "AppSourceCop is enabled but AppSourceCop.json not found"
    Write-Warning "AppSourceCop diagnostics will be silently hidden without this config file"
    Write-Warning "Create AppSourceCop.json next to app.json with mandatory properties:"
    Write-Host '  {'
    Write-Host '    "mandatoryAffixes": ["YourPrefix"],'
    Write-Host '    "supportedCountries": ["US"]'
    Write-Host '  }'
    Write-Host ""
}

# Find ruleset file
$ruleset = $null
if ($workspaceFile) {
    $workspaceRuleset = Join-Path $workspaceRoot "custom.ruleset.json"
    if (Test-Path $workspaceRuleset) {
        $ruleset = $workspaceRuleset
    }
}

# Fallback to local rulesets
if (-not $ruleset) {
    if (Test-Path "AppSourceCop.json") {
        $ruleset = (Get-Item "AppSourceCop.json").FullName
    } elseif (Test-Path "..\custom.ruleset.json") {
        $ruleset = (Get-Item "..\custom.ruleset.json").FullName
    } elseif (Test-Path "custom.ruleset.json") {
        $ruleset = (Get-Item "custom.ruleset.json").FullName
    }
}

if ($ruleset) {
    Write-Info "Ruleset: $(Split-Path -Leaf $ruleset)"
} else {
    if ($Verbose) {
        Write-Info "Ruleset: None"
    }
}

# Create .dev directory if needed
$outputDir = Split-Path -Parent $Output
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Build compilation command
$compileCmd = @(
    $alCompiler
    "/project:."
    "/packagecachepath:$packagePath"
)
$compileCmd += $analyzerArgs

# Add ruleset if found
if ($ruleset) {
    $compileCmd += "/ruleset:$ruleset"
    if (-not $NoRulesets) {
        $compileCmd += "/enableexternalrulesets"
    }
}

# Add optional flags
if (-not $NoParallel) {
    $compileCmd += "/parallel"
}

$compileCmd += @(
    "/reportsuppresseddiagnostics"
    "/errorlog:$Output"
)

# Show command if verbose
if ($Verbose) {
    Write-Info "Command:"
    $compileCmd | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
}

# Run compilation
Write-Info "Compiling..."
Write-Host ""

$process = Start-Process -FilePath $alCompiler -ArgumentList $compileCmd[1..($compileCmd.Length-1)] -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host ""
    Write-Success "Compilation succeeded!"

    # Show summary if error log exists
    if (Test-Path $Output) {
        try {
            $errorLog = Get-Content $Output -Raw | ConvertFrom-Json
            $diagnosticCount = $errorLog.diagnostics.Count
            if ($diagnosticCount -gt 0) {
                Write-Info "Diagnostics: $diagnosticCount (see $Output)"
            }
        } catch {
            # Ignore parse errors
        }
    }

    exit 0
} else {
    Write-Host ""
    Write-ErrorMsg "Compilation failed"

    if (Test-Path $Output) {
        Write-Info "Error log: $Output"

        # Try to parse and show error summary
        try {
            $errorLog = Get-Content $Output -Raw | ConvertFrom-Json
            $errors = $errorLog.diagnostics | Where-Object { $_.severity -eq "Error" }
            $warnings = $errorLog.diagnostics | Where-Object { $_.severity -eq "Warning" }

            Write-Host ""
            Write-ErrorMsg "Errors: $($errors.Count)"
            Write-Warning "Warnings: $($warnings.Count)"

            # Show first few errors
            Write-Host ""
            Write-Info "First errors:"
            $errors | Select-Object -First 5 | ForEach-Object {
                $line = $_.range.start.line
                $char = $_.range.start.character
                Write-Host "$($_.code): $($_.message) in $($_.source)($line,$char)"
            }
        } catch {
            Write-Warning "Could not parse error log (ConvertFrom-Json failed)"
        }
    }

    exit 1
}
