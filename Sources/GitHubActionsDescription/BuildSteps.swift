// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to build with Preternatural
    /// - Parameters:
    ///   - id: Optional ID for the step
    ///   - workingDirectory: Optional working directory
    ///   - platforms: Target platforms to build for
    ///   - configurations: Build configurations
    ///   - fuckSwiftSyntax: Whether to use the --fuck-swift-syntax flag
    ///   - updateDeveloperTeam: Whether to update the developer team
    /// - Returns: A build step for Preternatural
    static func buildWithPreternatural(
        id: String = "build",
        workingDirectory: String? = nil,
        platforms: [String] = ["macOS"],
        configurations: [String] = ["debug"],
        fuckSwiftSyntax: Bool = true,
        updateDeveloperTeam: Bool = true
    ) -> Self {
        let platformsString = platforms.joined(separator: ",")
        let configurationsString = configurations.joined(separator: ",")
        
        let platformsCode = "PLATFORMS=$(echo '\(platformsString)' | tr -d '[]' | sed 's/, /,/g')"
        let configurationsCode = "CONFIGURATIONS=$(echo '\(configurationsString)' | tr -d '[]' | sed 's/, /,/g')"
        
        var script = """
        echo "::group::Preparing Build Command"
        \(platformsCode)
        \(configurationsCode)

        """
        
        if let workingDirectory = workingDirectory {
            script += """
            # Change directory if working-directory is provided
            if [ ! -z "\(workingDirectory)" ]; then
              cd "\(workingDirectory)"
              echo "Changed working directory to: \(workingDirectory)"
            fi

            """
        }
        
        script += """
        # Construct the command as a string
        PRETERNATURAL_CMD="script -q /dev/null preternatural build --platforms $PLATFORMS --configurations $CONFIGURATIONS
        """
        
        if updateDeveloperTeam {
            script += " --update-developer-team"
        }
        
        if fuckSwiftSyntax {
            script += " --fuck-swift-syntax"
        }
        
        script += """
        "

        echo "Prepared command: ${PRETERNATURAL_CMD}"
        echo "::endgroup::"

        echo "::group::First Build Attempt"
        # First attempt
        set +e  # Don't exit on error
        eval ${PRETERNATURAL_CMD} 2>&1
        BUILD_STATUS=$?
        set -e  # Return to exit on error
        echo "::endgroup::"

        if [ $BUILD_STATUS -ne 0 ]; then
          echo "::group::Cleaning DerivedData and Retrying"
          echo "First build attempt failed (status: $BUILD_STATUS). Cleaning derived data and retrying..."
          rm -rf "$DERIVED_DATA_PATH"
          echo "Cleaned derived data"
          echo "::endgroup::"

          echo "::group::Second Build Attempt"
          # Second attempt
          eval ${PRETERNATURAL_CMD} 2>&1
          RETRY_STATUS=$?
          echo "::endgroup::"

          if [ $RETRY_STATUS -ne 0 ]; then
            echo "::error::Second build attempt failed (status: $RETRY_STATUS) after cleaning derived data. Failing the workflow."
            exit 1
          fi
        fi

        echo "build_succeeded=true" >> $GITHUB_OUTPUT
        """
        
        return .init(
            name: "Execute preternatural build command",
            continueOnError: true,
            id: .plain(id),
            shell: "bash",
            workingDirectory: workingDirectory != nil ? .singleQuoted(workingDirectory!) : nil,
            run: .multiline(script)
        )
    }
    
    /// Creates a step to test with Preternatural
    /// - Parameters:
    ///   - id: Optional ID for the step
    ///   - buildBeforeTesting: Whether to build before testing
    ///   - suppressWarnings: Whether to suppress warnings
    ///   - fuckSwiftSyntax: Whether to use the --fuck-swift-syntax flag
    /// - Returns: A test step for Preternatural
    static func testWithPreternatural(
        id: String = "test",
        buildBeforeTesting: Bool = true,
        suppressWarnings: Bool = true,
        fuckSwiftSyntax: Bool = false
    ) -> Self {
        var script = "PRETERNATURAL_CMD=\"script -q /dev/null preternatural test"
        
        if buildBeforeTesting {
            script += " --build-before-testing"
        }
        
        if suppressWarnings {
            script += " --suppress-warnings"
        }
        
        if fuckSwiftSyntax {
            script += " --fuck-swift-syntax"
        }
        
        script += "\"\n\nset +e  # Don't exit on error\neval ${PRETERNATURAL_CMD} 2>&1\nTEST_STATUS=$?\necho \"Test command exited with status: $TEST_STATUS\"\nif [ $TEST_STATUS -ne 0 ]; then\n  echo \"::error::Test failed (status: $TEST_STATUS). Failing the workflow after uploading logs.\"\n  echo \"test_failed=true\" >> $GITHUB_OUTPUT\nelse\n  echo \"test_failed=false\" >> $GITHUB_OUTPUT\nfi\nexit 0"
        
        return .init(
            name: "Run Preternatural Test Command",
            id: .plain(id),
            shell: "bash",
            run: .multiline(script)
        )
    }
} 
