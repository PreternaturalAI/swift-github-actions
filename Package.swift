// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-github-actions",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "swift-github-actions",
            targets: [
                "GitHubActionsCLT"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/preternatural-fork/Yams", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    ],
    targets: [
        .target(
            name: "CLT_act",
            dependencies: [
                "CorePersistence",
                "Merge"
            ]
        ),
        .target(
            name: "_GitHubActionsTypes",
            dependencies: [
                "Merge"
            ]
        ),
        .target(
            name: "GitHubActionsCore",
            dependencies: [
                "_GitHubActionsTypes",
                "CorePersistence",
                "Merge",
                "Yams",
            ]
        ),
        .target(
            name: "GitHubActionsDescription",
            dependencies: [
                "_GitHubActionsTypes",
                "GitHubActionsCore"
            ]
        ),
        .target(
            name: "GitHubActionsRunner",
            dependencies: [
                "CLT_act",
                "_GitHubActionsTypes",
                "GitHubActionsCore",
                "KeychainAccess"
            ]
        ),
        .target(
            name: "GitHubActionsCLT",
            dependencies: [
                "_GitHubActionsTypes",
                "GitHubActionsCore",
                "GitHubActionsRunner",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "GitHubActionsTests",
            dependencies: [
                "GitHubActionsCLT",
            ],
            path: "Tests",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
