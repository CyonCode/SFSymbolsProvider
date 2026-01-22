# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Run a single test
swift test --filter SFSymbolsProviderTests.SourceScannerTests/testScanSimple

# Build and run the example app
cd Example && swift build
```

## Architecture Overview

SFSymbolsProvider is an SPM Build Tool Plugin that provides an SF Symbols-like API for third-party icon libraries (Phosphor Icons and Ionicons). The system works by scanning source code at build time and generating only the icons that are actually used.

### Core Components

**Runtime Library** (`Sources/SFSymbolsProvider/`):
- `Image+Extensions.swift` - SwiftUI `Image(icon:)` initializer that loads icons from asset catalogs. Handles bundle discovery across platforms (UIKit/AppKit differences).
- `SourceScanner.swift` - Regex-based scanner that extracts `Image(icon: "ph.*")` and `Image(icon: "ion.*")` calls from Swift source files. Also contains `IconName` parser for decomposing icon strings into provider/name/weight/variant.

**Build Tool** (`Sources/SFSymbolsProviderTool/`):
- `main.swift` - CLI with three commands: `build` (combined scan+generate), `scan` (extract icons to manifest), `generate` (create xcassets from manifest). Handles platform detection and calls `actool` for asset compilation.
- `AssetGenerator.swift` - Maps icon names to SVG file paths, generates Contents.json for imagesets with template rendering.

**SPM Plugin** (`Plugins/SFSymbolsProviderPlugin/`):
- `Plugin.swift` - BuildToolPlugin that wires the CLI tool into SPM builds. Passes source directories and bundled resources to the tool.

### Data Flow

1. Plugin invokes `SFSymbolsProviderTool build --source <target-sources> --output <plugin-work-dir> --resources <bundled-icons>`
2. `SourceScanner.scanDirectory()` finds all `Image(icon: "...")` calls via regex
3. `AssetGenerator.validateIcons()` checks which icons have corresponding SVG source files
4. Tool generates `.xcassets` with one `.imageset` per icon, configured for template rendering
5. Tool compiles xcassets to `.bundle` using `xcrun actool`
6. At runtime, `Image(icon:)` looks up the asset by name from the compiled bundle

### Icon Name Format

- Phosphor: `ph.{name}[.{weight}]` where weight is thin/light/regular/bold/fill
- Ionicons: `ion.{name}[.{variant}]` where variant is outline/sharp

### Platform-Specific Notes

- macOS builds with `swift build` work out of the box
- iOS/watchOS/tvOS Xcode projects need a Run Script phase to copy plugin outputs (SPM limitation)
- The tool auto-detects platform from `PLATFORM_NAME` and `SDK_NAME` environment variables
