#!/bin/bash
# SFSymbolsProvider - iOS Build Script
# Add this to your Xcode Build Phases as a Run Script Phase
# Usage: "${BUILD_DIR}/../../SourcePackages/checkouts/SFSymbolsProvider/Scripts/ios-build-icons.sh"

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG="$(dirname "$SCRIPT_DIR")"

# Fallback: search in SourcePackages if script location doesn't have Resources
if [ ! -d "$PKG/Resources" ]; then
    PKG=$(find "${BUILD_DIR}/../../SourcePackages/checkouts" -maxdepth 1 -type d -name "*[Ss][Ff][Ss]ymbol*" 2>/dev/null | head -1)
fi
[ -z "$PKG" ] || [ ! -d "$PKG/Resources" ] && exit 0

# Build the tool (cached after first build)
TOOL="${DERIVED_FILE_DIR}/SFSymbolsProviderTool"
if [ ! -f "$TOOL" ]; then
    echo "Building SFSymbolsProviderTool..."
    env -i PATH="$PATH" HOME="$HOME" swift build --package-path "$PKG" --product SFSymbolsProviderTool -c release
    cp "$PKG/.build/release/SFSymbolsProviderTool" "$TOOL"
fi

# Generate icon assets from source code
echo "Generating icons..."
"$TOOL" build --source "${SRCROOT}" --output "${DERIVED_FILE_DIR}" --resources "$PKG/Resources"

# Compile assets with actool
BUNDLE="${DERIVED_FILE_DIR}/SFSymbolsProviderIcons.bundle"
mkdir -p "$BUNDLE"
xcrun actool "${DERIVED_FILE_DIR}/GeneratedIcons.xcassets" \
    --compile "$BUNDLE" \
    --platform "${PLATFORM_NAME}" \
    --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET:-15.0}" \
    --output-format human-readable-text

# Create bundle Info.plist (required for iOS to recognize the bundle)
cat > "$BUNDLE/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.sfsymbolsprovider.icons</string>
    <key>CFBundleName</key>
    <string>SFSymbolsProviderIcons</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF

# Copy bundle to app
if [ -f "$BUNDLE/Assets.car" ]; then
    cp -R "$BUNDLE" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
    echo "Icons bundle copied to app"
fi
