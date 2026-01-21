# TODO / Roadmap

## Pre-Release (v1.0.0)
- [ ] Add LICENSE file (MIT suggested)
- [ ] Add CHANGELOG.md
- [ ] Add usage examples/screenshots to README
- [ ] Create GitHub repository
- [ ] Tag v1.0.0 release

## Cross-Platform Support (v1.1)

### Windows Support
- [ ] Detect Windows platform (`uname` or check for PowerShell)
- [ ] Use correct extension path: `%USERPROFILE%\.vscode\extensions`
- [ ] Use correct compiler binary: `bin/win32/alc.exe`
- [ ] Handle path separators (already uses `;` for package paths)
- [ ] Test color output in cmd.exe vs PowerShell
- [ ] Consider separate PowerShell script or make bash script work in Git Bash/WSL
- [ ] Update README with Windows installation instructions

### macOS Support
- [ ] Detect macOS platform
- [ ] Use correct compiler binary: `bin/darwin/alc`
- [ ] Test with macOS AL extension paths
- [ ] Verify homebrew compatibility for installation
- [ ] Update README with macOS installation instructions

## Auto-Installation Features (v1.2)

### VS Code Extension Auto-Download
- [ ] Add `--install-dependencies` or `--auto-install-extension` flag
- [ ] Fetch latest AL extension from VS Code marketplace API
  - API endpoint: `https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery`
  - Extension ID: `ms-dynamics-smb.al`
- [ ] Download `.vsix` file
- [ ] Extract to `~/.vscode/extensions/` (unzip .vsix, rename folder)
- [ ] Set correct permissions on extracted files
- [ ] Verify installation and version
- [ ] Handle version upgrades vs clean installs
- [ ] Add `--extension-version <version>` flag for specific versions
- [ ] Offline mode: Use cached extension if available

### Symbol Management
- [ ] Add `--download-symbols` flag to trigger symbol download
- [ ] Integrate with AL compiler's symbol download functionality
- [ ] Auto-detect missing symbols and prompt for download

## Compiler Flags (v1.3)

### Additional Flags
- [ ] `/assemblyprobingpaths:<paths>` - Additional assembly search paths
- [ ] `/nowarn:<codes>` - Suppress specific warning codes (comma-separated)
- [ ] `/warn:<level>` - Warning level (0-4)
- [ ] `/features:<features>` - Enable experimental compiler features
- [ ] `/generatecrossreferences` - Generate cross-reference information
- [ ] `/reportSuppressedDiagnostics` - Already implemented, verify it works correctly

### Pass-Through Support
- [ ] Add `--compiler-flags "<flags>"` for arbitrary compiler flags
- [ ] Validate and pass through unknown flags to compiler
- [ ] Document all supported flags in README

## Custom Analyzer Support (v1.4)

### Custom Analyzer Loading
- [ ] Add `--custom-analyzer <path>` flag (repeatable)
- [ ] Support individual `.dll` files
- [ ] Support directories containing multiple analyzers
- [ ] Auto-detect analyzers in project `.analyzers/` directory
- [ ] Auto-detect analyzers in workspace root `.analyzers/` directory
- [ ] Validate analyzer DLLs before loading
- [ ] Show loaded custom analyzers in verbose output
- [ ] Document custom analyzer usage in README

### Analyzer Management
- [ ] Add `--list-analyzers` to show all available analyzers
- [ ] Show analyzer versions in verbose output
- [ ] Support analyzer-specific configurations
- [ ] Handle analyzer conflicts/dependencies

## Configuration File Support (v1.5)

### Project/Workspace Config
- [ ] Support `.al-compile.json` or `.al-compile.yaml` in project root
- [ ] Support workspace-level configuration
- [ ] Configuration hierarchy: CLI args > project config > workspace config > defaults
- [ ] Config options:
  - Default analyzers
  - Custom analyzer paths
  - Compiler flags
  - Error log location
  - Ruleset preferences

### Config Schema
```json
{
  "analyzers": {
    "mode": "default",
    "custom": ["/path/to/analyzer.dll"]
  },
  "compiler": {
    "parallel": true,
    "warnLevel": 4,
    "nowarn": ["AL0432", "AL0254"]
  },
  "output": {
    "errorLog": ".dev/compile-errors.log"
  },
  "rulesets": {
    "enable": true,
    "path": "./custom.ruleset.json"
  }
}
```

## Quality Improvements

### Testing
- [ ] Add shellcheck to CI
- [ ] Add bats (Bash Automated Testing System) tests
- [ ] Test multi-app workspace scenarios
- [ ] Test single-app scenarios
- [ ] Test analyzer combinations
- [ ] Test error handling and edge cases

### Error Handling
- [ ] Better error messages for common issues
- [ ] Troubleshooting guide in README
- [ ] Validate dependencies before compilation
- [ ] Check for common misconfigurations

### Performance
- [ ] Benchmark compilation times
- [ ] Optimize package path scanning for large workspaces
- [ ] Cache extension/analyzer locations between runs
- [ ] Add progress indicators for long operations

## Documentation

### README Enhancements
- [ ] Add "Why use this?" / comparison section
- [ ] Add troubleshooting section
- [ ] Add FAQ section
- [ ] Add screenshots/examples of output
- [ ] Add architecture/how it works diagram
- [ ] Document all environment variables
- [ ] Add video demo/asciinema recording

### Additional Docs
- [ ] Create CONTRIBUTING.md
- [ ] Create detailed architecture documentation
- [ ] Create migration guide from raw `alc` usage
- [ ] Create integration guide (CI/CD, VS Code tasks, etc.)

## Distribution

### Package Managers
- [ ] Create Homebrew formula (macOS/Linux)
- [ ] Create AUR package (Arch Linux)
- [ ] Consider snap package (Linux)
- [ ] Consider chocolatey package (Windows)

### CI/CD
- [ ] GitHub Actions workflow for testing (shellcheck, basic install test)
- [ ] Test install.sh on clean Ubuntu/Debian container
- [ ] Test install.sh on clean Fedora/RHEL container
- [ ] GitHub Actions workflow for releases
- [ ] Automated changelog generation
- [ ] Automated GitHub release creation
- [ ] Version bump automation

## Nice-to-Have Features

### Interactive Mode
- [ ] `--interactive` or `-i` flag for guided compilation
- [ ] Prompt for analyzer selection
- [ ] Prompt for cleanup before compile
- [ ] Prompt for symbol download if missing

### Watch Mode
- [ ] Add `--watch` flag to recompile on file changes
- [ ] Use `inotifywait` (Linux), `fswatch` (macOS), or similar
- [ ] Debounce file changes to avoid excessive recompilation

### Integration Features
- [ ] VS Code task.json generator
- [ ] Pre-commit hook generator for git
- [ ] Integration with popular BC DevOps tools

### Reporting
- [ ] Generate HTML error reports
- [ ] Generate markdown summary reports
- [ ] Statistics (compilation time, error trends, etc.)
- [ ] Compare error counts between compilations

## Version Plan

- **v1.0.0** - Current Linux implementation (stable release)
- **v1.1.0** - Cross-platform support (Windows + macOS)
- **v1.2.0** - Auto-installation features
- **v1.3.0** - Additional compiler flags
- **v1.4.0** - Custom analyzer support
- **v1.5.0** - Configuration file support
- **v2.0.0** - Major refactor if needed (config system, plugin architecture, etc.)

## Ideas / Maybe Later

- Plugin system for extensibility
- Language server integration
- Dependency graph visualization
- Automatic refactoring suggestions
- Integration with BC performance profiler
- Cloud compilation support (for CI/CD)
- Multi-project parallel compilation
- Incremental compilation support
