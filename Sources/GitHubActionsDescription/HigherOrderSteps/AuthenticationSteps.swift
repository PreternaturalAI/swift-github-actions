// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to setup PAT for private repositories
    /// - Returns: A step that configures Git to use PAT for private repositories
    static func setupPATForPrivateRepos() -> Self {
        .init(
            name: "Setup PAT for Private Repos",
            shell: "bash",
            run: .multiline("""
            {
              git config --global url."https://$GITHUB_PAT@github.com/".insteadOf "https://github.com/"
            } > /dev/null 2>&1
            """)
        )
    }
    
    /// Creates a step to load secrets from 1Password
    /// - Parameters:
    ///   - serviceAccountToken: The 1Password service account token
    ///   - secrets: Dictionary mapping environment variable names to 1Password references
    /// - Returns: A step that loads secrets from 1Password
    static func loadSecretsFrom1Password(
        serviceAccountToken: String = "token",
        secrets: OrderedDictionary<String, String>
    ) -> Self {
        var environment: OrderedDictionary<String, _GHA.FormattedValue> = [
            "OP_SERVICE_ACCOUNT_TOKEN": .doubleQuoted(serviceAccountToken)
        ]
        
        for (key, value) in secrets {
            environment[key] = .plain(value)
        }
        
        return .init(
            name: "Load Secrets From 1Password",
            uses: "1password/load-secrets-action@v2",
            with: [
                "export-env": true
            ],
            environment: environment
        )
    }
} 
