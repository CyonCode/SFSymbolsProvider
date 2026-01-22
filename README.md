# SFSymbolsProvider

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20watchOS%208+%20|%20tvOS%2015+%20|%20visionOS%201+-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Swift library that provides an **SF Symbols-like API** for third-party icon libraries. Use familiar SwiftUI patterns like `Image(icon: "ph.house")` to access [Phosphor Icons](https://phosphoricons.com) and [Ionicons](https://ionic.io/ionicons) with on-demand packaging via SPM Build Tool Plugin.

## Features

- **Zero Configuration** - Icons are bundled with the package; just add the dependency and start using icons
- **SF Symbols-like API** - Use `Image(icon: "ph.house")` just like `Image(systemName: "house")`
- **On-demand packaging** - Only icons used in your code are bundled into your app
- **SPM Build Tool Plugin** - Automatic source scanning and asset generation at build time
- **Template rendering** - Full support for SwiftUI color modifiers like `.foregroundStyle()`
- **Multiple icon libraries** - Phosphor Icons (5 weights) and Ionicons (3 variants)
- **All Apple platforms** - iOS, macOS, watchOS, tvOS, and visionOS

## Requirements

- Swift 5.9+
- iOS 15+ / macOS 12+ / watchOS 8+ / tvOS 15+ / visionOS 1+
- Xcode 15+

## Installation

### Swift Package Manager

Add SFSymbolsProvider to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CyonCode/SFSymbolsProvider.git", from: "1.0.0")
]
```

Then add it to your target with the plugin:

```swift
.executableTarget(
    name: "YourApp",
    dependencies: ["SFSymbolsProvider"],
    plugins: [
        .plugin(name: "SFSymbolsProviderPlugin", package: "SFSymbolsProvider")
    ]
)
```

### For SPM Packages

Configure the resource bundle in your app's entry point:

```swift
import SFSymbolsProvider

@main
struct YourApp: App {
    init() {
        SFSymbolsProviderConfig.resourceBundle = .module
    }
    // ...
}
```

### For Xcode Projects (iOS/watchOS/tvOS)

Due to a limitation in how Xcode handles SPM build tool plugin outputs, iOS builds require an additional setup step:

1. Add the package via **File > Add Package Dependencies...**
2. In your target's **Build Phases**, add a new **Run Script Phase** (after "Compile Sources")
3. Add the following script:

```bash
XCASSETS_PATHS=(
    "${BUILD_DIR}/../../SourcePackages/plugins/sf-symbols-provider.output/${TARGETNAME}/SFSymbolsProviderPlugin/GeneratedIcons.xcassets"
    "${BUILD_DIR}/../../SourcePackages/plugins/sfsymbolsprovider.output/${TARGETNAME}/SFSymbolsProviderPlugin/GeneratedIcons.xcassets"
)

for XCASSETS_PATH in "${XCASSETS_PATHS[@]}"; do
    if [ -d "$XCASSETS_PATH" ]; then
        TEMP_BUNDLE="${DERIVED_FILE_DIR}/SFSymbolsProviderIcons.bundle"
        mkdir -p "$TEMP_BUNDLE"
        xcrun actool "$XCASSETS_PATH" --compile "$TEMP_BUNDLE" --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET:-15.0}" --output-format human-readable-text 2>/dev/null
        if [ -f "$TEMP_BUNDLE/Assets.car" ]; then
            mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
            cp -R "$TEMP_BUNDLE" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
        fi
        break
    fi
done
```

4. Set **"Based on dependency analysis"** to unchecked (run every build)

> **Note**: macOS targets built with `swift build` work without this extra step.

## Usage

### Basic Usage

```swift
import SwiftUI
import SFSymbolsProvider

struct ContentView: View {
    var body: some View {
        VStack {
            // Phosphor Icons
            Image(icon: "ph.house")           // Regular weight
            Image(icon: "ph.house.fill")      // Fill weight
            Image(icon: "ph.gear.bold")       // Bold weight
            
            // Ionicons
            Image(icon: "ion.home")           // Default variant
            Image(icon: "ion.home.outline")   // Outline variant
            Image(icon: "ion.settings.sharp") // Sharp variant
        }
    }
}
```

### Styling with SwiftUI Modifiers

Icons use template rendering, so standard SwiftUI modifiers work seamlessly:

```swift
Image(icon: "ph.heart.fill")
    .foregroundStyle(.red)
    .font(.system(size: 24))

Image(icon: "ion.star")
    .foregroundStyle(.yellow)
    .frame(width: 32, height: 32)
```

### Handling Missing Icons

The initializer returns `nil` for invalid icon names, so use optional binding or provide a fallback:

```swift
// Optional binding
if let icon = Image(icon: "ph.house") {
    icon
}

// With fallback
Image(icon: "ph.house") ?? Image(systemName: "house")
```

## API Reference

### Image Extension

```swift
public extension Image {
    /// Creates an image from a Phosphor or Ionicons icon name.
    /// - Parameters:
    ///   - iconName: The icon name in format "ph.name[.weight]" or "ion.name[.variant]"
    ///   - bundle: The bundle containing the generated assets (default: .main)
    /// - Returns: An Image if the icon name is valid, nil otherwise
    init?(icon iconName: String, bundle: Bundle = .main)
}
```

### Icon Name Format

| Provider | Format | Examples |
|----------|--------|----------|
| Phosphor | `ph.{name}` | `ph.house`, `ph.gear`, `ph.user` |
| Phosphor | `ph.{name}.{weight}` | `ph.house.fill`, `ph.gear.bold`, `ph.user.thin` |
| Ionicons | `ion.{name}` | `ion.home`, `ion.settings`, `ion.person` |
| Ionicons | `ion.{name}.{variant}` | `ion.home.outline`, `ion.settings.sharp` |

### Supported Weights (Phosphor)

| Weight | Description |
|--------|-------------|
| `regular` | Default weight (no suffix needed) |
| `thin` | Thinnest stroke |
| `light` | Light stroke |
| `bold` | Bold stroke |
| `fill` | Filled/solid icons |

### Supported Variants (Ionicons)

| Variant | Description |
|---------|-------------|
| `default` | Default style (no suffix needed) |
| `outline` | Outline/stroke style |
| `sharp` | Sharp corners variant |

## How It Works

1. **Build Time Scanning**: The SPM Build Tool Plugin scans your Swift source files for `Image(icon: "...")` calls
2. **Icon Detection**: Regex-based detection identifies all Phosphor (`ph.*`) and Ionicons (`ion.*`) references
3. **Asset Generation**: Only the icons you use are copied to a generated `.xcassets` catalog
4. **Template Rendering**: Icons are configured with `template-rendering-intent` for color customization

## Advanced Configuration

By default, SFSymbolsProvider uses bundled icons. To use custom icon paths (e.g., for newer icon versions), create a `sfsymbols.json` file in your package/project root:

```json
{
    "phosphorPath": "/path/to/phosphor-icons",
    "ioniconsPath": "/path/to/ionicons.designerpack"
}
```

## Known Limitations

- **Xcode iOS builds require setup** - SPM plugin outputs aren't automatically bundled for iOS. See [Xcode Projects setup](#for-xcode-projects-ioswatchostvos) above.
- **No Duotone support** - Phosphor Duotone icons require special two-color rendering (planned for v2.0)
- **String literals only** - Dynamic icon names like `Image(icon: variable)` are not detected at build time
- **SwiftUI only** - No UIKit/AppKit API provided
- **No Symbol Effects** - iOS 17+ symbol animations are not supported

## Example App

See the `Example/` directory for a complete iOS app demonstrating all features:

```bash
cd Example
swift build
```

## License

SFSymbolsProvider is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Acknowledgments

- [Phosphor Icons](https://phosphoricons.com) - Beautiful open-source icons
- [Ionicons](https://ionic.io/ionicons) - Premium icons for Ionic Framework
- [phosphor-swift](https://github.com/phosphor-icons/swift) - Inspiration for the implementation approach
