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
        secrets: [String: String]
    ) -> Self {
        var environment: OrderedDictionary<String, _GHA.FormattedValue> = [
            "OP_SERVICE_ACCOUNT_TOKEN": .doubleQuoted(serviceAccountToken)
        ]
        
        for (key, value) in secrets {
            environment[key] = .plain(value)
        }
        
        return .init(
            name: "Load Secrets from 1Password",
            uses: "1password/load-secrets-action@v2",
            with: [
                "export-env": true
            ],
            environment: environment
        )
    }
    
    /// Creates a step to install an Apple certificate for code signing
    /// - Parameters:
    ///   - certificateBase64: The base64-encoded certificate
    ///   - password: The certificate password
    /// - Returns: A step that installs the certificate
    static func installAppleCertificate(
        certificateBase64: String,
        password: String
    ) -> Self {
        .init(
            name: "Install the Apple certificate and provisioning profile",
            shell: "bash",
            environment: [
                "BUILD_CERTIFICATE_BASE64": .doubleQuoted(certificateBase64),
                "P12_PASSWORD": .doubleQuoted(password)
            ],
            run: .multiline("""
            # Generate a random keychain password
            KEYCHAIN_PASSWORD=$(openssl rand -base64 15)
            
            # Create variables
            CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
            KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
            
            # Import certificate from inputs
            echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
            
            # Create temporary keychain
            security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
            security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
            security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
            
            # Import certificate to keychain
            security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
            security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
            security list-keychain -d user -s $KEYCHAIN_PATH
            """)
        )
    }
} 
