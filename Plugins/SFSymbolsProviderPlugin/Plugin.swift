import PackagePlugin
import Foundation

@main
struct SFSymbolsProviderPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: any Target) async throws -> [Command] {
        guard let sourceModule = target.sourceModule else {
            return []
        }
        
        let tool = try context.tool(named: "SFSymbolsProviderTool")
        let configPath = context.package.directory.appending("sfsymbols.json")
        let sourceDir = sourceModule.directory
        let outputDir = context.pluginWorkDirectory
        
        var arguments: [CustomStringConvertible] = [
            "build",
            "--source", sourceDir,
            "--output", outputDir
        ]
        
        if FileManager.default.fileExists(atPath: configPath.string) {
            arguments.append(contentsOf: ["--config", configPath] as [CustomStringConvertible])
        }
        
        // Use buildCommand instead of prebuildCommand to allow using source-based tools
        // We specify the xcassets directory as the output
        let xcassetsPath = outputDir.appending("GeneratedIcons.xcassets")
        
        return [
            .buildCommand(
                displayName: "SFSymbolsProvider: Generating icon assets for \(target.name)",
                executable: tool.path,
                arguments: arguments,
                inputFiles: sourceModule.sourceFiles.map { $0.path },
                outputFiles: [xcassetsPath]
            )
        ]
    }
}
