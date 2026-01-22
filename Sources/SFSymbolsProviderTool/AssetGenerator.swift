import Foundation

public struct AssetGeneratorConfig {
    public let phosphorPath: String
    public let ioniconsPath: String
    
    public init(phosphorPath: String, ioniconsPath: String) {
        self.phosphorPath = phosphorPath
        self.ioniconsPath = ioniconsPath
    }
}

public struct ValidationResult {
    public let valid: [String]
    public let invalid: [String]
    
    public init(valid: [String], invalid: [String]) {
        self.valid = valid
        self.invalid = invalid
    }
}

public enum AssetGenerator {
    
    public static func mapIconPath(_ icon: String, config: AssetGeneratorConfig) -> String? {
        guard let parsed = parseIconName(icon) else { return nil }
        
        switch parsed.provider {
        case .phosphor:
            let weight = parsed.weight ?? "regular"
            if weight == "regular" {
                return "\(config.phosphorPath)/SVGs/\(weight)/\(parsed.name).svg"
            } else {
                return "\(config.phosphorPath)/SVGs/\(weight)/\(parsed.name)-\(weight).svg"
            }
        case .ionicons:
            let variant = parsed.variant
            switch variant {
            case "outline":
                return "\(config.ioniconsPath)/\(parsed.name)-outline.svg"
            case "sharp":
                return "\(config.ioniconsPath)/\(parsed.name)-sharp.svg"
            default:
                return "\(config.ioniconsPath)/\(parsed.name).svg"
            }
        }
    }
    
    public static func generateContentsJson(filename: String) -> String {
        return """
        {
          "images" : [
            {
              "filename" : "\(filename)",
              "idiom" : "universal"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          },
          "properties" : {
            "template-rendering-intent" : "template"
          }
        }
        """
    }
    
    public static func generateXcassetsRootContents() -> String {
        return """
        {
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
    }
    
    public static func assetName(for icon: String) -> String {
        return icon
    }
    
    public static func validateIcons(_ icons: [String], config: AssetGeneratorConfig) -> ValidationResult {
        var valid: [String] = []
        var invalid: [String] = []
        
        let fileManager = FileManager.default
        
        for icon in icons {
            if let path = mapIconPath(icon, config: config),
               fileManager.fileExists(atPath: path) {
                valid.append(icon)
            } else {
                invalid.append(icon)
            }
        }
        
        return ValidationResult(valid: valid, invalid: invalid)
    }
    
    public static func processIoniconsOutlineSVG(_ content: String) -> String {
        return content.replacingOccurrences(of: "stroke=\"#000\"", with: "stroke=\"currentColor\"")
    }
    
    private enum IconProvider {
        case phosphor
        case ionicons
    }
    
    private struct ParsedIcon {
        let provider: IconProvider
        let name: String
        let weight: String?
        let variant: String
    }
    
    private static let phosphorWeights = Set(["thin", "light", "regular", "bold", "fill"])
    private static let ioniconsVariants = Set(["outline", "sharp"])
    
    private static func parseIconName(_ icon: String) -> ParsedIcon? {
        let parts = icon.split(separator: ".").map(String.init)
        guard parts.count >= 2 else { return nil }
        
        let prefix = parts[0]
        
        switch prefix {
        case "ph":
            let lastPart = parts.last!
            if phosphorWeights.contains(lastPart) && parts.count >= 3 {
                let name = parts[1..<(parts.count - 1)].joined(separator: ".")
                return ParsedIcon(provider: .phosphor, name: name, weight: lastPart, variant: "default")
            } else {
                let name = parts[1...].joined(separator: ".")
                return ParsedIcon(provider: .phosphor, name: name, weight: "regular", variant: "default")
            }
            
        case "ion":
            let lastPart = parts.last!
            if ioniconsVariants.contains(lastPart) && parts.count >= 3 {
                let name = parts[1..<(parts.count - 1)].joined(separator: "-")
                return ParsedIcon(provider: .ionicons, name: name, weight: nil, variant: lastPart)
            } else {
                let name = parts[1...].joined(separator: "-")
                return ParsedIcon(provider: .ionicons, name: name, weight: nil, variant: "default")
            }
            
        default:
            return nil
        }
    }
}
