// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to archive with Preternatural
    /// - Parameters:
    ///   - teamId: Optional team ID for notarization
    ///   - fuckSwiftSyntax: Whether to use the --fuck-swift-syntax flag
    ///   - notarizationUsername: Username for notarization (will use environment variables if nil)
    ///   - notarizationPassword: Password for notarization (will use environment variables if nil)
    /// - Returns: An archive step for Preternatural
    static func archiveWithPreternatural(
        teamId: String? = nil,
        fuckSwiftSyntax: Bool = true,
        notarizationUsername: String? = nil,
        notarizationPassword: String? = nil
    ) -> Self {
        var environment: OrderedDictionary<String, _GHA.FormattedValue>? = nil
        
        if let username = notarizationUsername, let password = notarizationPassword {
            environment = [
                "NOTARIZATION_APP_STORE_CONNECT_USERNAME": .doubleQuoted(username),
                "NOTARIZATION_APP_STORE_CONNECT_PASSWORD": .doubleQuoted(password)
            ]
        }
        
        var script = "# Construct the command as a string\nPRETERNATURAL_CMD=\"script -q /dev/null preternatural archive"
        
        if let teamId = teamId {
            script += " --team-id \"\(teamId)\""
        }
        
        if fuckSwiftSyntax {
            script += " --fuck-swift-syntax"
        }
        
        script += "\"\n\necho \"Running preternatural archive command:\"\necho \"${PRETERNATURAL_CMD}\"\neval ${PRETERNATURAL_CMD} 2>&1"
        
        return .init(
            name: "Run preternatural archive command",
            shell: "bash",
            environment: environment,
            run: .multiline(script)
        )
    }
    
    /// Creates a step to export a macOS app
    /// - Parameters:
    ///   - workingDirectory: Optional working directory
    ///   - configuration: Build configuration (Debug or Release)
    ///   - fuckSwiftSyntax: Whether to use the --fuck-swift-syntax flag
    /// - Returns: An export step for a macOS app
    static func exportMacOSApp(
        workingDirectory: String? = nil,
        configuration: String = "Release",
        fuckSwiftSyntax: Bool = true
    ) -> Self {
        var script = "echo -e \"Build Archive\"\n\n"
        
        if let workingDirectory = workingDirectory {
            script += """
            # Change directory if working-directory is provided
            if [ ! -z "\(workingDirectory)" ]; then
              cd "\(workingDirectory)"
              echo "Changed working directory to: \(workingDirectory)"
            fi

            """
        }
        
        script += "# Build command with optional debug flag\nCMD=\"script -q /dev/null preternatural archive --team-id $TEAM_ID\"\n\nif [ -n \"\(configuration)\" ]; then\n  CMD=\"$CMD --configuration \"\(configuration)\"\"\nfi\n"
        
        if fuckSwiftSyntax {
            script += "if [ \"true\" == \"true\" ]; then\n  CMD=\"$CMD --fuck-swift-syntax\"\nfi\n"
        }
        
        script += "\n# Execute the command\neval \"$CMD\" 2>&1\n\nif [ $? -eq 0 ]; then\n  echo \"archive_succeeded=true\" >> $GITHUB_OUTPUT\nfi\n\nset +x  # Disable command echo\necho -e \"Archive Step completed\""
        
        return .init(
            name: "Build Archive",
            continueOnError: true,
            id: "archive",
            shell: "bash",
            run: .multiline(script)
        )
    }
    
    /// Creates a step to find an archive file
    /// - Returns: A step that finds an archive file
    static func findArchiveFile() -> Self {
        .init(
            name: "Find archive file",
            shell: "bash",
            run: .multiline("""
            ARCHIVE_FILE=$(find . -name "*Notarized*.zip" -print -quit)
            if [ -z "$ARCHIVE_FILE" ]; then
              echo "Error: No notarized ZIP file found"
              exit 1
            fi
            echo "ARCHIVE_FILE=$ARCHIVE_FILE" >> $GITHUB_ENV
            echo "Found archive file: $ARCHIVE_FILE"
            """)
        )
    }
} 