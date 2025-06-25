// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SoundCloudClient",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SoundCloudClient", targets: ["SoundCloudClient"])
    ],
    dependencies: [
        // Dependencies will be added as needed
    ],
    targets: [
        .executableTarget(
            name: "SoundCloudClient",
            dependencies: []
        ),
        .testTarget(
            name: "SoundCloudClientTests",
            dependencies: ["SoundCloudClient"]
        )
    ]
)
