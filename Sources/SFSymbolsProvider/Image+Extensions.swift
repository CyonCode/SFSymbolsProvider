import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public typealias IconNameParser = IconName

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
        
        if let resourceURL = parentBundle.resourceURL {
            let possiblePaths = [
                resourceURL.appendingPathComponent("SFSymbolsProviderIcons.bundle"),
                resourceURL.appendingPathComponent("Contents/Resources/SFSymbolsProviderIcons.bundle")
            ]
            for path in possiblePaths {
                if let bundle = Bundle(url: path) {
                    return bundle
                }
            }
        }
        
        return nil
    }
}

public extension Image {
    init?(icon iconName: String, bundle: Bundle? = nil) {
        guard let parsed = IconNameParser.parse(iconName) else {
            return nil
        }
        
        let assetName = parsed.assetName
        let parentBundle = bundle ?? SFSymbolsProviderConfig.resourceBundle
        
        #if canImport(UIKit)
        let bundlesToCheck: [Bundle] = [
            SFSymbolsProviderConfig.findIconsBundle(in: parentBundle),
            SFSymbolsProviderConfig.findIconsBundle(in: .main),
            parentBundle,
            .main
        ].compactMap { $0 }
        
        for checkBundle in bundlesToCheck {
            if UIImage(named: assetName, in: checkBundle, compatibleWith: nil) != nil {
                self.init(assetName, bundle: checkBundle)
                return
            }
        }
        
        return nil
        #elseif canImport(AppKit)
        let bundlesToCheck: [Bundle] = [
            SFSymbolsProviderConfig.findIconsBundle(in: parentBundle),
            SFSymbolsProviderConfig.findIconsBundle(in: .main),
            parentBundle,
            .main
        ].compactMap { $0 }
        
        for checkBundle in bundlesToCheck {
            if checkBundle.image(forResource: assetName) != nil {
                self.init(assetName, bundle: checkBundle)
                return
            }
        }
        
        return nil
        #else
        if let iconsBundle = SFSymbolsProviderConfig.findIconsBundle(in: parentBundle) {
            self.init(assetName, bundle: iconsBundle)
        } else {
            self.init(assetName, bundle: parentBundle)
        }
        #endif
    }
}
