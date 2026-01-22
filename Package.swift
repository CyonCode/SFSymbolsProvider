// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SFSymbolsProvider",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SFSymbolsProvider",
            targets: ["SFSymbolsProvider"]
        ),
        .plugin(
            name: "SFSymbolsProviderPlugin",
            targets: ["SFSymbolsProviderPlugin"]
        )
    ],
    targets: [
        .target(
            name: "SFSymbolsProvider",
            dependencies: []
        ),
        .executableTarget(
            name: "SFSymbolsProviderTool",
            dependencies: ["SFSymbolsProvider"]
        ),
        .plugin(
            name: "SFSymbolsProviderPlugin",
            capability: .buildTool(),
            dependencies: ["SFSymbolsProviderTool"]
        ),
        .testTarget(
            name: "SFSymbolsProviderTests",
            dependencies: ["SFSymbolsProvider", "SFSymbolsProviderTool"]
        )
    ]
)
