// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MiniMD",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MiniMD",
            path: "Sources/MiniMD"
        )
    ]
)
