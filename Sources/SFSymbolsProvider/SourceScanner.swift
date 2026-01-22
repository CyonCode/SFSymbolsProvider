import Foundation

public struct IconName: Equatable {
    public enum Provider: Equatable {
        case phosphor
        case ionicons
    }
    
    public enum PhosphorWeight: String, CaseIterable, Equatable {
        case regular
        case thin
        case light
        case bold
        case fill
    }
    
    public enum IoniconsVariant: String, CaseIterable, Equatable {
        case `default`
        case outline
        case sharp
    }
    
    public let provider: Provider
    public let name: String
    public let weight: PhosphorWeight?
    public let variant: IoniconsVariant?
    
    public static func parse(_ raw: String) -> IconName? {
        let components = raw.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard components.count >= 2 else { return nil }
        
        let prefix = components[0]
        
        switch prefix {
        case "ph":
            return parsePhosphor(components: Array(components.dropFirst()))
        case "ion":
            return parseIonicons(components: Array(components.dropFirst()))
        default:
            return nil
        }
    }
    
    private static func parsePhosphor(components: [String]) -> IconName? {
        guard !components.isEmpty else { return nil }
        
        let lastComponent = components.last ?? ""
        let weight = PhosphorWeight(rawValue: lastComponent)
        
        let nameComponents: [String]
        let finalWeight: PhosphorWeight
        
        if weight != nil && components.count > 1 {
            nameComponents = Array(components.dropLast())
            finalWeight = weight!
        } else {
            nameComponents = components
            finalWeight = .regular
        }
        
        let name = nameComponents.joined(separator: ".")
        guard !name.isEmpty else { return nil }
        
        return IconName(provider: .phosphor, name: name, weight: finalWeight, variant: nil)
    }
    
    private static func parseIonicons(components: [String]) -> IconName? {
        guard !components.isEmpty else { return nil }
        
        let lastComponent = components.last ?? ""
        let variant = IoniconsVariant(rawValue: lastComponent)
        
        let nameComponents: [String]
        let finalVariant: IoniconsVariant
        
        if variant != nil && variant != .default && components.count > 1 {
            nameComponents = Array(components.dropLast())
            finalVariant = variant!
        } else {
            nameComponents = components
            finalVariant = .default
        }
        
        let name = nameComponents.joined(separator: ".")
        guard !name.isEmpty else { return nil }
        
        return IconName(provider: .ionicons, name: name, weight: nil, variant: finalVariant)
    }
}

public enum SourceScanner {
    
    private static let imagePattern = #"Image\s*\(\s*(?:icon\s*:\s*)?"((?:ph|ion)\.[a-z0-9\-\.]+)"\s*\)"#
    private static let lineCommentPattern = #"//.*$"#
    private static let blockCommentPattern = #"/\*[\s\S]*?\*/"#
    
    public static func scan(source: String) -> [String] {
        var cleanedSource = source
        
        if let blockRegex = try? NSRegularExpression(pattern: blockCommentPattern, options: []) {
            cleanedSource = blockRegex.stringByReplacingMatches(
                in: cleanedSource,
                options: [],
                range: NSRange(cleanedSource.startIndex..., in: cleanedSource),
                withTemplate: ""
            )
        }
        
        let lines = cleanedSource.components(separatedBy: .newlines)
        var icons: [String] = []
        
        guard let imageRegex = try? NSRegularExpression(pattern: imagePattern, options: [.caseInsensitive]) else {
            return []
        }
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.hasPrefix("//") {
                continue
            }
            
            var processedLine = line
            if let commentRange = line.range(of: "//") {
                processedLine = String(line[..<commentRange.lowerBound])
            }
            
            let range = NSRange(processedLine.startIndex..., in: processedLine)
            let matches = imageRegex.matches(in: processedLine, options: [], range: range)
            
            for match in matches {
                if let iconRange = Range(match.range(at: 1), in: processedLine) {
                    let iconName = String(processedLine[iconRange])
                    if !icons.contains(iconName) {
                        icons.append(iconName)
                    }
                }
            }
        }
        
        return icons
    }
    
    public static func scanDirectory(at url: URL) -> [String] {
        var allIcons: [String] = []
        
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        while let fileURL = enumerator.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }
            
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
            
            let icons = scan(source: content)
            for icon in icons {
                if !allIcons.contains(icon) {
                    allIcons.append(icon)
                }
            }
        }
        
        return allIcons
    }
    
    public static func generateManifest(icons: [String]) -> Data {
        let manifest: [String: Any] = ["icons": icons]
        return (try? JSONSerialization.data(withJSONObject: manifest, options: [.sortedKeys])) ?? Data()
    }
}
