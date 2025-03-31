// Copyright (c) Vatsal Manot
//

import Foundation
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to install Preternatural
    /// - Parameter ifCondition: Optional condition to determine if the step should run
    /// - Returns: A step that installs Preternatural
    static func installPreternatural(ifCondition: String? = nil) -> Self {
        .init(
            name: "Install Preternatural",
            if: ifCondition != nil ? .plain(ifCondition!) : nil,
            shell: "bash",
            run: .multiline("""
            brew tap PreternaturalAI/preternatural
            brew install preternatural
            """)
        )
    }
    
    /// Creates a step to authorize GitHub for Preternatural repositories
    /// - Returns: A step that authorizes GitHub
    static func authorizePreternaturalGitHub() -> Self {
        .init(
            name: "Authorize Preternatural GitHub",
            uses: "PreternaturalAI/internal-github-action/preternatural-authorize-github@main"
        )
    }
} 