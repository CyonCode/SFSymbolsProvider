import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension IconName {
    public var assetName: String {
        switch provider {
        case .phosphor:
            if let weight = weight, weight != .regular {
                return "ph.\(name).\(weight.rawValue)"
            }
            return "ph.\(name)"
        case .ionicons:
            if let variant = variant, variant != .default {
                return "ion.\(name).\(variant.rawValue)"
            }
            return "ion.\(name)"
        }
    }
}

public enum SFSymbolsProviderConfig {
    public static var resourceBundle: Bundle = .main

    static func findIconsBundle(in parentBundle: Bundle) -> Bundle? {
        if let bundleURL = parentBundle.url(forResource: "SFSymbolsProviderIcons", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL) {
            return bundle
        }

        guard let resourceURL = parentBundle.resourceURL else { return nil }

        let possiblePaths = [
            resourceURL.appendingPathComponent("SFSymbolsProviderIcons.bundle"),
            resourceURL.appendingPathComponent("Contents/Resources/SFSymbolsProviderIcons.bundle")
        ]

        for path in possiblePaths {
            if let bundle = Bundle(url: path) {
                return bundle
            }
        }

        return nil
    }

    static func bundlesToSearch(from parentBundle: Bundle) -> [Bundle] {
        [
            findIconsBundle(in: parentBundle),
            findIconsBundle(in: .main),
            parentBundle,
            .main
        ].compactMap { $0 }
    }
}

public extension Image {
    init?(icon iconName: String, bundle: Bundle? = nil) {
        guard let parsed = IconName.parse(iconName) else {
            return nil
        }

        let assetName = parsed.assetName
        let parentBundle = bundle ?? SFSymbolsProviderConfig.resourceBundle
        let bundlesToCheck = SFSymbolsProviderConfig.bundlesToSearch(from: parentBundle)

        #if canImport(UIKit)
        for checkBundle in bundlesToCheck {
            if UIImage(named: assetName, in: checkBundle, compatibleWith: nil) != nil {
                self.init(assetName, bundle: checkBundle)
                return
            }
        }
        return nil
        #elseif canImport(AppKit)
        for checkBundle in bundlesToCheck {
            if checkBundle.image(forResource: assetName) != nil {
                self.init(assetName, bundle: checkBundle)
                return
            }
        }
        return nil
        #else
        let targetBundle = SFSymbolsProviderConfig.findIconsBundle(in: parentBundle) ?? parentBundle
        self.init(assetName, bundle: targetBundle)
        #endif
    }
}
