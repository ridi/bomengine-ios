// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "RBBomReaderEngine",
    platforms: [
        .iOS("7.0")
    ],
    products: [
        .library(
            name: "RBBomReaderEngine",
            targets: ["RBBomReaderEngine"]),
    ],
    targets: [
        .target(
            name: "RBBomReaderEngine",
            dependencies: []),
    ]
)
