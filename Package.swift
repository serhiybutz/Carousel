// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Carousel",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "Carousel",
            targets: ["Carousel"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Carousel",
            dependencies: []),
    ]
)
