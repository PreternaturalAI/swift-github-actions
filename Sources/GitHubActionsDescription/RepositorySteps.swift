// Copyright (c) Vatsal Manot
//

import Foundation
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to checkout a repository
    /// - Parameter version: The version of the checkout action to use (defaults to v4)
    /// - Returns: A step that checks out the repository
    static func checkoutRepository(version: String = "v4") -> Self {
        .init(
            name: "Checkout repository",
            uses: .plain("actions/checkout@\(version)")
        )
    }
} 
