# Install script for al-compile (PowerShell version)
# This script copies al-compile.ps1 to your local bin directory and adds it to PATH

$ErrorActionPreference = "Stop"

Write-Host "Installing al-compile (PowerShell version)..." -ForegroundColor Blue

# Create installation directory
$installDir = "$env:USERPROFILE\.local\bin"
Write-Host "Creating directory: $installDir" -ForegroundColor Gray

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
}

# Copy script
Write-Host "Copying al-compile.ps1 to $installDir" -ForegroundColor Gray

if (-not (Test-Path "al-compile.ps1")) {
    Write-Host "Error: al-compile.ps1 not found in current directory" -ForegroundColor Red
    Write-Host "Please run this script from the al-smart-compile repository root" -ForegroundColor Red
    exit 1
}

Copy-Item "al-compile.ps1" "$installDir\al-compile.ps1" -Force

Write-Host "✓ Copied al-compile.ps1" -ForegroundColor Green

# Check if directory is in PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -like "*$installDir*") {
    Write-Host "✓ $installDir is already in PATH" -ForegroundColor Green
} else {
    Write-Host "Adding $installDir to PATH..." -ForegroundColor Gray

    # Add to user PATH
    $newPath = "$currentPath;$installDir"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    Write-Host "✓ Added to PATH (restart your terminal to use)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  al-compile.ps1              # Run in your AL project directory" -ForegroundColor Gray
Write-Host "  al-compile.ps1 -Clean       # Clean and compile" -ForegroundColor Gray
Write-Host "  al-compile.ps1 -Verbose     # Verbose output" -ForegroundColor Gray
Write-Host "  al-compile.ps1 -Help        # Show help" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
