// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ExampleApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                .product(name: "SFSymbolsProvider", package: "SF-Symbols-Provider")
            ]
        )
    ]
)
