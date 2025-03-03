// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-github-actions",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
    ],
    targets: [
        .executableTarget(
            name: "swift-github-actions",
            dependencies: [
                "CorePersistence",
                "Merge"
            ]
        ),
        .target(
            name: "CLT_act",
            dependencies: [
                "CorePersistence",
                "Merge"
            ]
        ),
        .target(
            name: "_GitHubActionsTypes"
        ),
        .target(
            name: "GitHubActionsCore",
            dependencies: [
                "_GitHubActionsTypes",
                "Yams"
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
                "_GitHubActionsTypes",
                "GitHubActionsCore"
            ]
        ),
        .target(
            name: "GitHubActionsCLT",
            dependencies: [
                "_GitHubActionsTypes",
                "GitHubActionsCore",
                "GitHubActionsRunner"
            ]
        )
    ]
)
