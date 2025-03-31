// Copyright (c) Vatsal Manot
//

import Foundation
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to release a plugin
    /// - Parameters:
    ///   - pluginPackageRepository: Plugin package repository to update
    ///   - toolName: Name of the command line tool
    ///   - homebrewRepository: Homebrew repository from which to lookup the command line tools
    /// - Returns: A step that updates a plugin package
    static func releasePlugin(
        pluginPackageRepository: String,
        toolName: String,
        homebrewRepository: String = "PreternaturalAI/homebrew-preternatural"
    ) -> Self {
        .init(
            name: .doubleQuoted("Run Update Plugin Action (\(toolName))"),
            uses: "PreternaturalAI/internal-github-action/preternatural-release-plugin@main",
            with: [
                "plugin-package-repository": .singleQuoted(pluginPackageRepository),
                "tool-name": .singleQuoted(toolName),
                "homebrew-repository": .singleQuoted(homebrewRepository)
            ]
        )
    }
} 
