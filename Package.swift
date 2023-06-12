// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "firmy-cz-scraper",
    platforms: [.macOS(.v12)],
    products: [.executable(name: "firmy-cz-scraper", targets: ["firmy-cz-scraper"])],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/dominicegginton/Spinner", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "firmy-cz-scraper",
            dependencies: [
                "SwiftSoup",
                "Spinner",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources"),
    ]
)
