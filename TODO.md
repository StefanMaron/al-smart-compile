# TODO / Roadmap

## Pre-Release (v1.0.0) ✅ COMPLETED
- [x] Add LICENSE file (MIT suggested)
- [x] Add CHANGELOG.md
- [x] Add usage examples/screenshots to README
- [x] Create GitHub repository
- [x] Tag v1.0.0 release

## Cross-Platform Support (v1.1) ✅ COMPLETED

### Windows Support ✅ COMPLETED (v1.1.0)
- [x] Detect Windows platform (`uname` or check for PowerShell)
- [x] Use correct extension path: `%USERPROFILE%\.vscode\extensions`
- [x] Use correct compiler binary: `bin/win32/alc.exe`
- [x] Handle path separators (already uses `;` for package paths)
- [x] Test color output in cmd.exe vs PowerShell
- [x] Make bash script work in Git Bash/WSL (works in both)
- [x] Update README with Windows installation instructions
- [x] Add Windows CI/CD testing (GitHub Actions with windows-latest)

### macOS Support ✅ COMPLETED (v1.1.0)
- [x] Detect macOS platform
- [x] Use correct compiler binary: `bin/darwin/alc`
- [x] Test with macOS AL extension paths
- [x] Verify homebrew compatibility for installation
- [x] Update README with macOS installation instructions

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

## Configuration File Support (v1.5) - PARTIAL

### Project/Workspace Config ✅ COMPLETED
- [x] Support `.al-compile.json` in project root
- [x] Support workspace-level configuration
- [x] Configuration hierarchy: CLI args > project config > workspace config > defaults
- [x] Config options:
  - [x] Default analyzers
  - [ ] Custom analyzer paths (planned for v1.4)
  - [ ] Compiler flags (planned for v1.3)
  - [x] Error log location
  - [x] Ruleset preferences

### Config Schema (Current Implementation)
```json
{
  "analyzers": "default",
  "output": ".dev/compile-errors.log",
  "parallel": true,
  "rulesets": true
}
```

### Config Schema (Future - Full Implementation)
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
- [x] Add shellcheck to CI
- [ ] Add bats (Bash Automated Testing System) tests
- [ ] Test multi-app workspace scenarios
- [ ] Test single-app scenarios
- [ ] Test analyzer combinations
- [x] Test error handling and edge cases

### Error Handling
- [ ] Better error messages for common issues
- [x] Troubleshooting guide in README
- [ ] Validate dependencies before compilation
- [ ] Check for common misconfigurations

### Performance
- [ ] Benchmark compilation times
- [ ] Optimize package path scanning for large workspaces
- [ ] Cache extension/analyzer locations between runs
- [ ] Add progress indicators for long operations

## Documentation

### README Enhancements
- [x] Add "Why use this?" / comparison section
- [x] Add troubleshooting section
- [ ] Add FAQ section
- [x] Add screenshots/examples of output
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
- [x] GitHub Actions workflow for testing (shellcheck, basic install test)
- [x] Test install.sh on clean Ubuntu/Debian container
- [x] Test install.sh on clean Fedora/RHEL container
- [x] GitHub Actions workflow for releases
- [ ] Automated changelog generation
- [x] Automated GitHub release creation
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

- **v1.0.0** - Linux implementation (stable release) ✅
- **v1.1.0** - Cross-platform support (Windows + macOS) ✅
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
