import PackagePlugin
import Foundation

@main
struct SFSymbolsProviderPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: any Target) async throws -> [Command] {
        guard let sourceModule = target.sourceModule else {
            return []
        }
        
        let tool = try context.tool(named: "SFSymbolsProviderTool")
        let sourceDir = sourceModule.directory
        let outputDir = context.pluginWorkDirectory
        
        let sfSymbolsProviderPackage = context.package.dependencies.first { dep in
            let name = dep.package.displayName.lowercased()
            return name == "sfsymbolsprovider" || name == "sf-symbols-provider"
        }?.package ?? context.package
        
        let resourcesDir = sfSymbolsProviderPackage.directory.appending("Resources")
        
        var arguments: [CustomStringConvertible] = [
            "build",
            "--source", sourceDir,
            "--output", outputDir,
            "--resources", resourcesDir
        ]
        
        let configPath = context.package.directory.appending("sfsymbols.json")
        if FileManager.default.fileExists(atPath: configPath.string) {
            arguments.append(contentsOf: ["--config", configPath] as [CustomStringConvertible])
        }
        
        let xcassetsPath = outputDir.appending("GeneratedIcons.xcassets")
        let compiledBundlePath = outputDir.appending("SFSymbolsProviderIcons.bundle")
        
        return [
            .buildCommand(
                displayName: "SFSymbolsProvider: Generating icon assets for \(target.name)",
                executable: tool.path,
                arguments: arguments,
                inputFiles: sourceModule.sourceFiles.map { $0.path },
                outputFiles: [xcassetsPath, compiledBundlePath]
            )
        ]
    }
}
