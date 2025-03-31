// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to setup Xcode
    /// - Parameter version: The version of Xcode to use
    /// - Returns: A step that sets up Xcode
    static func setupXcode(version: String = "latest-stable") -> Self {
        .init(
            name: "Setup Xcode",
            uses: "maxim-lobanov/setup-xcode@v1",
            with: [
                "xcode-version": .singleQuoted(version)
            ]
        )
    }
} 