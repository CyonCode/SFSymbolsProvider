import Foundation
import SFSymbolsProvider

struct Config: Codable {
    let phosphorPath: String?
    let ioniconsPath: String?
}

enum SFSymbolsProviderTool {
    static func run() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        
        guard let command = arguments.first else {
            printUsage()
            exit(1)
        }
        
        switch command {
        case "build":
            runBuild(arguments: Array(arguments.dropFirst()))
        case "scan":
            runScan(arguments: Array(arguments.dropFirst()))
        case "generate":
            runGenerate(arguments: Array(arguments.dropFirst()))
        case "--help", "-h":
            printUsage()
        default:
            fputs("Unknown command: \(command)\n", stderr)
            printUsage()
            exit(1)
        }
    }
    
    static func printUsage() {
        print("""
        SFSymbolsProviderTool - Generate icon assets from source code
        
        USAGE:
            SFSymbolsProviderTool build --source <dir> --output <dir> [--config <path>]
            SFSymbolsProviderTool scan --source <dir> --output <manifest.json>
            SFSymbolsProviderTool generate --manifest <json> --output <dir> --config <path>
        
        COMMANDS:
            build       Scan sources and generate assets in one step
            scan        Scan source files for icon references
            generate    Generate xcassets from manifest
        """)
    }
    
    static func parseArguments(_ args: [String]) -> [String: String] {
        var result: [String: String] = [:]
        var i = 0
        while i < args.count {
            let arg = args[i]
            if arg.hasPrefix("--") && i + 1 < args.count {
                let key = String(arg.dropFirst(2))
                result[key] = args[i + 1]
                i += 2
            } else {
                i += 1
            }
        }
        return result
    }
    
    static func runBuild(arguments: [String]) {
        let args = parseArguments(arguments)
        
        guard let sourceDir = args["source"],
              let outputDir = args["output"] else {
            fputs("Error: --source and --output are required\n", stderr)
            exit(1)
        }
        
        let sourceURL = URL(fileURLWithPath: sourceDir)
        let outputURL = URL(fileURLWithPath: outputDir)
        
        let icons = SourceScanner.scanDirectory(at: sourceURL)
        
        if icons.isEmpty {
            return
        }
        
        var phosphorPath = ""
        var ioniconsPath = ""
        
        if let resourcesDir = args["resources"] {
            phosphorPath = resourcesDir + "/Phosphor"
            ioniconsPath = resourcesDir + "/Ionicons"
        }
        
        if let configPath = args["config"] {
            let configURL = URL(fileURLWithPath: configPath)
            if let data = try? Data(contentsOf: configURL),
               let decoded = try? JSONDecoder().decode(Config.self, from: data) {
                if let p = decoded.phosphorPath { phosphorPath = p }
                if let i = decoded.ioniconsPath { ioniconsPath = i }
            }
        }
        
        let generatorConfig = AssetGeneratorConfig(
            phosphorPath: phosphorPath,
            ioniconsPath: ioniconsPath
        )
        
        let validation = AssetGenerator.validateIcons(icons, config: generatorConfig)
        
        for invalidIcon in validation.invalid {
            fputs("warning: Invalid icon name or missing source file: \(invalidIcon)\n", stderr)
        }
        
        if validation.valid.isEmpty {
            return
        }
        
        generateXcassets(
            icons: validation.valid,
            config: generatorConfig,
            outputDir: outputURL,
            platform: args["platform"],
            deploymentTarget: args["deployment-target"]
        )
    }
    
    static func runScan(arguments: [String]) {
        let args = parseArguments(arguments)
        
        guard let sourceDir = args["source"],
              let outputPath = args["output"] else {
            fputs("Error: --source and --output are required\n", stderr)
            exit(1)
        }
        
        let sourceURL = URL(fileURLWithPath: sourceDir)
        let icons = SourceScanner.scanDirectory(at: sourceURL)
        let manifest = SourceScanner.generateManifest(icons: icons)
        
        let outputURL = URL(fileURLWithPath: outputPath)
        try? manifest.write(to: outputURL)
    }
    
    static func runGenerate(arguments: [String]) {
        let args = parseArguments(arguments)
        
        guard let manifestPath = args["manifest"],
              let outputDir = args["output"],
              let configPath = args["config"] else {
            fputs("Error: --manifest, --output, and --config are required\n", stderr)
            exit(1)
        }
        
        let manifestURL = URL(fileURLWithPath: manifestPath)
        let outputURL = URL(fileURLWithPath: outputDir)
        let configURL = URL(fileURLWithPath: configPath)
        
        guard let manifestData = try? Data(contentsOf: manifestURL),
              let manifestJson = try? JSONSerialization.jsonObject(with: manifestData) as? [String: Any],
              let icons = manifestJson["icons"] as? [String] else {
            fputs("Error: Failed to read manifest\n", stderr)
            exit(1)
        }
        
        guard let configData = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(Config.self, from: configData) else {
            fputs("Error: Failed to read config\n", stderr)
            exit(1)
        }
        
        let generatorConfig = AssetGeneratorConfig(
            phosphorPath: config.phosphorPath ?? "",
            ioniconsPath: config.ioniconsPath ?? ""
        )
        
        let validation = AssetGenerator.validateIcons(icons, config: generatorConfig)
        
        for invalidIcon in validation.invalid {
            fputs("warning: Invalid icon name or missing source file: \(invalidIcon)\n", stderr)
        }
        
        if validation.valid.isEmpty {
            return
        }
        
        generateXcassets(
            icons: validation.valid,
            config: generatorConfig,
            outputDir: outputURL,
            platform: args["platform"],
            deploymentTarget: args["deployment-target"]
        )
    }
    
    static func generateXcassets(
        icons: [String],
        config: AssetGeneratorConfig,
        outputDir: URL,
        platform: String? = nil,
        deploymentTarget: String? = nil
    ) {
        let xcassetsDir = outputDir.appendingPathComponent("GeneratedIcons.xcassets")
        let fileManager = FileManager.default
        
        try? fileManager.createDirectory(at: xcassetsDir, withIntermediateDirectories: true)
        
        let rootContents = AssetGenerator.generateXcassetsRootContents()
        let rootContentsURL = xcassetsDir.appendingPathComponent("Contents.json")
        try? rootContents.write(to: rootContentsURL, atomically: true, encoding: .utf8)
        
        for icon in icons {
            guard let sourcePath = AssetGenerator.mapIconPath(icon, config: config) else {
                continue
            }
            
            let sourceURL = URL(fileURLWithPath: sourcePath)
            guard fileManager.fileExists(atPath: sourcePath) else {
                continue
            }
            
            let assetName = AssetGenerator.assetName(for: icon)
            let imagesetDir = xcassetsDir.appendingPathComponent("\(assetName).imageset")
            
            try? fileManager.createDirectory(at: imagesetDir, withIntermediateDirectories: true)
            
            let svgFilename = sourceURL.lastPathComponent
            let destURL = imagesetDir.appendingPathComponent(svgFilename)
            
            if var svgContent = try? String(contentsOf: sourceURL, encoding: .utf8) {
                if icon.contains(".outline") {
                    svgContent = AssetGenerator.processIoniconsOutlineSVG(svgContent)
                }
                try? svgContent.write(to: destURL, atomically: true, encoding: .utf8)
            } else {
                try? fileManager.copyItem(at: sourceURL, to: destURL)
            }
            
            let contentsJson = AssetGenerator.generateContentsJson(filename: svgFilename)
            let contentsURL = imagesetDir.appendingPathComponent("Contents.json")
            try? contentsJson.write(to: contentsURL, atomically: true, encoding: .utf8)
        }
        
        compileAssetCatalog(xcassetsDir: xcassetsDir, outputDir: outputDir, platform: platform, deploymentTarget: deploymentTarget)
    }
    
    static func compileAssetCatalog(xcassetsDir: URL, outputDir: URL, platform: String?, deploymentTarget: String?) {
        let targetPlatform = platform 
            ?? ProcessInfo.processInfo.environment["PLATFORM_NAME"]
            ?? detectPlatformFromSDK()
            ?? detectPlatformFromSystem()
        
        let minDeploymentTarget = deploymentTarget
            ?? getDeploymentTargetFromEnvironment(platform: targetPlatform)
            ?? defaultDeploymentTarget(for: targetPlatform)
        
        let bundleDir = outputDir.appendingPathComponent("SFSymbolsProviderIcons.bundle")
        let fileManager = FileManager.default
        
        try? fileManager.removeItem(at: bundleDir)
        try? fileManager.createDirectory(at: bundleDir, withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        
        let arguments = [
            "actool",
            xcassetsDir.path,
            "--compile", bundleDir.path,
            "--platform", targetPlatform,
            "--minimum-deployment-target", minDeploymentTarget,
            "--output-format", "human-readable-text"
        ]
        
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                fputs("warning: actool compilation failed (status \(process.terminationStatus)): \(output)\n", stderr)
                fputs("warning: Falling back to uncompiled xcassets\n", stderr)
            }
        } catch {
            fputs("warning: Failed to run actool: \(error.localizedDescription)\n", stderr)
            fputs("warning: Falling back to uncompiled xcassets\n", stderr)
        }
    }
    
    static func detectPlatformFromSDK() -> String? {
        if let sdkName = ProcessInfo.processInfo.environment["SDK_NAME"] {
            if sdkName.contains("iphoneos") { return "iphoneos" }
            if sdkName.contains("iphonesimulator") { return "iphonesimulator" }
            if sdkName.contains("macosx") { return "macosx" }
            if sdkName.contains("watchos") { return "watchos" }
            if sdkName.contains("watchsimulator") { return "watchsimulator" }
            if sdkName.contains("appletvos") { return "appletvos" }
            if sdkName.contains("appletvsimulator") { return "appletvsimulator" }
            if sdkName.contains("xros") { return "xros" }
            if sdkName.contains("xrsimulator") { return "xrsimulator" }
        }
        return nil
    }
    
    static func defaultDeploymentTarget(for platform: String) -> String {
        switch platform {
        case "macosx": return "12.0"
        case "iphoneos", "iphonesimulator": return "15.0"
        case "watchos", "watchsimulator": return "8.0"
        case "appletvos", "appletvsimulator": return "15.0"
        case "xros", "xrsimulator": return "1.0"
        default: return "15.0"
        }
    }
    
    static func detectPlatformFromSystem() -> String {
        #if os(macOS)
        return "macosx"
        #elseif os(iOS)
        #if targetEnvironment(simulator)
        return "iphonesimulator"
        #else
        return "iphoneos"
        #endif
        #elseif os(watchOS)
        #if targetEnvironment(simulator)
        return "watchsimulator"
        #else
        return "watchos"
        #endif
        #elseif os(tvOS)
        #if targetEnvironment(simulator)
        return "appletvsimulator"
        #else
        return "appletvos"
        #endif
        #elseif os(visionOS)
        #if targetEnvironment(simulator)
        return "xrsimulator"
        #else
        return "xros"
        #endif
        #else
        return "macosx"
        #endif
    }
    
    static func getDeploymentTargetFromEnvironment(platform: String) -> String? {
        let envVars: [String: String] = [
            "iphoneos": "IPHONEOS_DEPLOYMENT_TARGET",
            "iphonesimulator": "IPHONEOS_DEPLOYMENT_TARGET",
            "macosx": "MACOSX_DEPLOYMENT_TARGET",
            "watchos": "WATCHOS_DEPLOYMENT_TARGET",
            "watchsimulator": "WATCHOS_DEPLOYMENT_TARGET",
            "appletvos": "TVOS_DEPLOYMENT_TARGET",
            "appletvsimulator": "TVOS_DEPLOYMENT_TARGET",
            "xros": "XROS_DEPLOYMENT_TARGET",
            "xrsimulator": "XROS_DEPLOYMENT_TARGET"
        ]
        
        if let envVar = envVars[platform] {
            return ProcessInfo.processInfo.environment[envVar]
        }
        return nil
    }
}

SFSymbolsProviderTool.run()
