import SwiftUI

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

public extension Image {
    init?(icon iconName: String, bundle: Bundle = .main) {
        guard let parsed = IconNameParser.parse(iconName) else {
            return nil
        }
        self.init(parsed.assetName, bundle: bundle)
    }
}
