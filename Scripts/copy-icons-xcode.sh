#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"

XCASSETS_PATH="${BUILD_DIR}/../../SourcePackages/plugins/sf-symbols-provider.output/${TARGETNAME}/SFSymbolsProviderPlugin/GeneratedIcons.xcassets"
BUNDLE_PATH="${BUILD_DIR}/../../SourcePackages/plugins/sf-symbols-provider.output/${TARGETNAME}/SFSymbolsProviderPlugin/SFSymbolsProviderIcons.bundle"

ALT_XCASSETS_PATH="${BUILD_DIR}/../../SourcePackages/plugins/sfsymbolsprovider.output/${TARGETNAME}/SFSymbolsProviderPlugin/GeneratedIcons.xcassets"
ALT_BUNDLE_PATH="${BUILD_DIR}/../../SourcePackages/plugins/sfsymbolsprovider.output/${TARGETNAME}/SFSymbolsProviderPlugin/SFSymbolsProviderIcons.bundle"

if [ -d "$BUNDLE_PATH" ] && [ -f "$BUNDLE_PATH/Assets.car" ]; then
    echo "Copying pre-compiled icons bundle..."
    mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    cp -R "$BUNDLE_PATH" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
    exit 0
fi

if [ -d "$ALT_BUNDLE_PATH" ] && [ -f "$ALT_BUNDLE_PATH/Assets.car" ]; then
    echo "Copying pre-compiled icons bundle (alt path)..."
    mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    cp -R "$ALT_BUNDLE_PATH" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
    exit 0
fi

FOUND_XCASSETS=""
if [ -d "$XCASSETS_PATH" ]; then
    FOUND_XCASSETS="$XCASSETS_PATH"
elif [ -d "$ALT_XCASSETS_PATH" ]; then
    FOUND_XCASSETS="$ALT_XCASSETS_PATH"
fi

if [ -n "$FOUND_XCASSETS" ]; then
    echo "Compiling xcassets for ${PLATFORM_NAME}..."
    TEMP_BUNDLE="${DERIVED_FILE_DIR}/SFSymbolsProviderIcons.bundle"
    mkdir -p "$TEMP_BUNDLE"
    
    xcrun actool "$FOUND_XCASSETS" \
        --compile "$TEMP_BUNDLE" \
        --platform "${PLATFORM_NAME}" \
        --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET:-15.0}" \
        --output-format human-readable-text
    
    if [ -f "$TEMP_BUNDLE/Assets.car" ]; then
        mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        cp -R "$TEMP_BUNDLE" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
        echo "Icons bundle copied successfully."
    else
        echo "warning: actool did not produce Assets.car"
    fi
else
    echo "warning: No generated xcassets found. Build the SPM package first."
fi
