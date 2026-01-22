# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-22

### Added
- Initial release of SFSymbolsProvider.
- Phosphor Icons support with 5 weights: regular, thin, light, bold, and fill.
- Ionicons support with 3 variants: default, outline, and sharp.
- SPM Build Tool Plugin for on-demand icon packaging, ensuring only used icons are included in the app bundle.
- SwiftUI `Image` extension: `Image(icon:bundle:)` for seamless integration.
- Regex-based source code scanning for automatic icon detection.
- Asset catalog generation for optimized resource management.
- Support for iOS 15+, macOS 12+, watchOS 8+, tvOS 15+, and visionOS 1+.
