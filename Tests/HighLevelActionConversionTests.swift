//
// Copyright (c) Vatsal Manot
//

import _GitHubActionsTypes
import Foundation
import GitHubActionsCLT
import GitHubActionsCore
import GitHubActionsDescription
import Testing
import Yams

@Suite("High Level Action Conversion Tests", .serialized)
@MainActor
struct HighLevelActionConversionTests {

    @Test("Test Action 1 Conversion")
    func testAction1Conversion() throws {
        let action = _GHA.Action(
            name: "Authorize GitHub",
            description: .multiline("Authorizes GitHub so that further commands can access all internal Preternatural repositories.\n"),
            runs: _GHA.Action.Runs(
                using: .singleQuoted("composite"),
                steps: [
                    .loadSecretsFrom1Password(
                        serviceAccountToken: "sample_token", 
                        secrets: ["GITHUB_PAT": "op://abc/abc/credential"]
                    ),
                    .setupPATForPrivateRepos()
                ]
            )
        )
        
        try test(action: action, with: "action-1")
    }
    
    @Test("Test Action 2 Conversion")
    func testAction2Conversion() throws {
        let action = _GHA.Action(
            name: .singleQuoted("Preternatural Upload Logs Action"),
            description: .singleQuoted("Processes and uploads logs from the default derived data path"),
            inputs: [
                "zip-name": _GHA.Action.Input(
                    description: .singleQuoted("Name of the final log zip file (without .zip extension)"),
                    required: false,
                    defaultValue: .singleQuoted("")
                )
            ],
            runs: _GHA.Action.Runs(
                using: .singleQuoted("composite"),
                steps: [
                    _GHA.Step(
                        name: "Cleanup previous runs",
                        shell: "bash",
                        run: .multiline("rm -rf ./logs\n")
                    ),
                    _GHA.Step(
                        name: "Find logs",
                        continueOnError: true,
                        shell: "bash",
                        run: .multiline("""
                        DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
                        echo "Searching for logs in: $DERIVED_DATA_PATH"
                        
                        mkdir -p ./logs
                        
                        # Find and copy xcresult bundles
                        find "$DERIVED_DATA_PATH" -name "*.xcresult" -type d -print0 | while IFS= read -r -d '' result; do
                          cp -R "$result" "./logs"
                          echo "Copied $result to ./logs"
                        done
                        
                        # Check if any logs were found and copied
                        if [ -z "$(ls -A ./logs)" ]; then
                          echo "No log files found in $DERIVED_DATA_PATH"
                          exit 1
                        fi
                        
                        # Create zip archive with dynamic name
                        cd ./logs
                        if [ -n "${{ inputs.zip-name }}" ]; then
                          ZIP_NAME="${{ inputs.zip-name }}.zip"
                        else
                          TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                          ZIP_NAME="logs-${TIMESTAMP}.zip"
                        fi
                        zip -r "../$ZIP_NAME" ./*
                        cd ..
                        
                        # Set output path for upload step
                        echo "ZIP_PATH=$ZIP_NAME" >> $GITHUB_ENV
                        # Set artifact name (zip name without extension) for upload step
                        echo "ARTIFACT_NAME=${ZIP_NAME%.zip}" >> $GITHUB_ENV
                        
                        # Clean up Logs and ResultBundle folders in DerivedData
                        echo "Cleaning up Logs and ResultBundle folders in DerivedData..."
                        find "$DERIVED_DATA_PATH" -type d -name "Logs" -exec rm -rf {} +
                        find "$DERIVED_DATA_PATH" -type d -name "ResultBundle" -exec rm -rf {} +
                        echo "Cleanup completed"
                        """)
                    ),
                    .uploadArtifact(
                        name: "${{ env.ARTIFACT_NAME }}",
                        path: "${{ env.ZIP_PATH }}"
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-2")
    }
    
    @Test("Test Action 3 Conversion")
    func testAction3Conversion() throws {
        let action = _GHA.Action(
            name: .singleQuoted("Preternatural Build Action"),
            description: .singleQuoted("Run Preternatural build command on repositories with a specified Xcode version"),
            inputs: [
                "xcode-version": _GHA.Action.Input(
                    description: .singleQuoted("Xcode version to use"),
                    required: false,
                    defaultValue: .singleQuoted("latest-stable")
                ),
                "platforms": _GHA.Action.Input(
                    description: .singleQuoted("Target platforms (array of: iOS, macOS, tvOS, watchOS, visionOS, all)"),
                    required: false,
                    defaultValue: .singleQuoted("[\"macOS\"]")
                ),
                "configurations": _GHA.Action.Input(
                    description: .singleQuoted("Build configurations (array of: debug, release)"),
                    required: false,
                    defaultValue: .singleQuoted("[\"debug\"]")
                ),
                "working-directory": _GHA.Action.Input(
                    description: .singleQuoted("Directory to run the preternatural command from"),
                    required: false,
                    defaultValue: .singleQuoted("")
                ),
                "fuck-swift-syntax": _GHA.Action.Input(
                    description: .singleQuoted("Enable the --fuck-swift-syntax flag for the build command"),
                    required: false,
                    defaultValue: true,
                    type: "boolean"
                )
            ],
            runs: _GHA.Action.Runs(
                using: .singleQuoted("composite"),
                steps: [
                    .setupXcode(version: "${{ inputs.xcode-version }}"),
                    .checkMacOSVersion(),
                    .checkXcodeVersion(),
                    .checkAvailableSDKs(),
                    .installPreternatural(ifCondition: "${{ !env.ACT }}"),
                    .restoreDerivedDataCache(),
                    .buildWithPreternatural(
                        id: "build",
                        workingDirectory: "${{ inputs.working-directory }}",
                        fuckSwiftSyntax: true
                    ),
                    .uploadLogs(),
                    .saveDerivedDataCache(ifCondition: "steps.build.outputs.build_succeeded == 'true'"),
                    .checkBuildStatusAndFail(ifCondition: "steps.build.outputs.build_succeeded != 'true'")
                ]
            )
        )
        
        try test(action: action, with: "action-3")
    }

    @Test("Test Action 4 Conversion")
    func testAction4Conversion() throws {
        let action = _GHA.Action(
            name: "Preternatural Release Plugin",
            description: .multiline("""
            Updates the url and SHA of the binary target in the given Plugin Package repository
            """),
            inputs: [
                "homebrew-repository": _GHA.Action.Input(
                    description: .singleQuoted("Homebrew Repository from which to lookup the command line tools"),
                    required: false,
                    defaultValue: .singleQuoted("PreternaturalAI/homebrew-preternatural")
                ),
                "plugin-package-repository": _GHA.Action.Input(
                    description: .singleQuoted("Plugin Package Repository to update"),
                    required: true
                ),
                "tool-name": _GHA.Action.Input(
                    description: .singleQuoted("Name of the command line tool"),
                    required: true
                )
            ],
            runs: _GHA.Action.Runs(
                using: .singleQuoted("composite"),
                steps: [
                    .loadSecretsFrom1Password(
                        serviceAccountToken: "token",
                        secrets: ["GITHUB_PAT": "op://abc/abc/abc"]
                    ),
                    .setupPATForPrivateRepos(),
                    _GHA.Step(
                        name: "Fetch URL and SHA",
                        shell: "bash",
                        run: .multiline("""
                        # Clone homebrew repository
                        git clone https://github.com/${{ inputs.homebrew-repository }}.git homebrew-repo
                        
                        # Check if tool file exists
                        if [ ! -f "homebrew-repo/${{ inputs.tool-name }}.rb" ]; then
                          echo "Error: ${{ inputs.tool-name }}.rb not found in ${{ inputs.homebrew-repository }}"
                          exit 1
                        fi
                        
                        # Extract URL and SHA
                        URL=$(grep "url" "homebrew-repo/${{ inputs.tool-name }}.rb" | cut -d '"' -f 2)
                        SHA=$(grep "sha256" "homebrew-repo/${{ inputs.tool-name }}.rb" | cut -d '"' -f 2)
                        
                        if [ -z "$URL" ] || [ -z "$SHA" ]; then
                          echo "Error: Could not extract URL and SHA from ${{ inputs.tool-name }}.rb"
                          exit 1
                        fi
                        
                        echo "Successfully extracted URL and SHA:"
                        echo "URL: $URL"
                        echo "SHA: $SHA"
                        
                        # Export for next steps
                        echo "TOOL_URL=$URL" >> $GITHUB_ENV
                        echo "TOOL_SHA=$SHA" >> $GITHUB_ENV
                        
                        # Cleanup: Remove the homebrew repository
                        rm -rf homebrew-repo
                        echo "Cleaned up homebrew repository"
                        """)
                    ),
                    _GHA.Step(
                        name: "Update Package.swift",
                        shell: "bash",
                        run: .multiline("""
                        # Clone plugin package repository
                        git clone https://github.com/${{ inputs.plugin-package-repository }}.git plugin-repo
                        cd plugin-repo
                        
                        # Check if Package.swift exists
                        if [ ! -f "Package.swift" ]; then
                          echo "Error: Package.swift not found in ${{ inputs.plugin-package-repository }}"
                          exit 1
                        fi
                        
                        # Check if binary target exists
                        if ! grep -A 3 "\\.binaryTarget(" Package.swift | grep -q "name: \\"${{ inputs.tool-name }}\\""; then
                          echo "Error: Binary target '${{ inputs.tool-name }}' not found in Package.swift"
                          exit 1
                        fi
                        
                        # Update binary target URL and checksum
                        awk -v name="${{ inputs.tool-name }}" -v url="$TOOL_URL" -v sha="$TOOL_SHA" '
                            /\\.binaryTarget\\(/ {
                                p = 1
                                print
                                next
                            }
                            p && /name:/ {
                                if ($0 ~ "\\"" name "\\"") {
                                    found = 1
                                }
                                print
                                next
                            }
                            p && found && /url:/ {
                                match($0, /^[[:space:]]*/)
                                spaces = substr($0, RSTART, RLENGTH)
                                print spaces "url: \\"" url "\\","
                                next
                            }
                            p && found && /checksum:/ {
                                match($0, /^[[:space:]]*/)
                                spaces = substr($0, RSTART, RLENGTH)
                                print spaces "checksum: \\"" sha "\\""
                                p = 0
                                found = 0
                                next
                            }
                            { print }
                        ' Package.swift > Package.swift.tmp && mv Package.swift.tmp Package.swift
                        
                        # Check if changes were made
                        if ! git diff --quiet Package.swift; then
                          git config user.name "GitHub Action"
                          git config user.email "action@github.com"
                          git add Package.swift
                          git commit -m "Update ${{ inputs.tool-name }} binary target URL and checksum"
                          git push
                          echo "Successfully updated and pushed changes to Package.swift in ${{ inputs.plugin-package-repository }}"
                        else
                          echo "No changes detected."
                        fi
                        
                        # Cleanup: Remove the plugin repository
                        cd ..
                        rm -rf plugin-repo
                        echo "Cleaned up plugin repository"
                        """)
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-4")
    }

    @Test("Test Action 5 Conversion")
    func testAction5Conversion() throws {
        let action = _GHA.Action(
            name: .singleQuoted("Preternatural Archive & Notarize Action"),
            description: .singleQuoted("Archive & notarize a MacOS application using Preternatural CLI"),
            inputs: [
                "xcode-version": _GHA.Action.Input(
                    description: .singleQuoted("Xcode version to use"),
                    required: true,
                    defaultValue: .singleQuoted("latest-stable")
                ),
                "notarization_username": _GHA.Action.Input(
                    description: .singleQuoted("App Store Connect Username for notarization"),
                    required: true
                ),
                "notarization_password": _GHA.Action.Input(
                    description: .singleQuoted("App Store Connect Password for notarization"),
                    required: true
                ),
                "notarization_team_id": _GHA.Action.Input(
                    description: .singleQuoted("App Store Connect Team ID for notarization"),
                    required: false
                ),
                "build_certificate_base64": _GHA.Action.Input(
                    description: .singleQuoted("Base64-encoded Apple certificate"),
                    required: true
                ),
                "p12_password": _GHA.Action.Input(
                    description: .singleQuoted("Password for the P12 certificate"),
                    required: true
                ),
                "fuck-swift-syntax": _GHA.Action.Input(
                    description: .singleQuoted("Enable the --fuck-swift-syntax flag for the archive command"),
                    required: false,
                    defaultValue: true,
                    type: "boolean"
                )
            ],
            runs: _GHA.Action.Runs(
                using: .singleQuoted("composite"),
                steps: [
                    .setupXcode(version: "${{ inputs.xcode-version }}"),
                    .installPreternatural(ifCondition: "${{ !env.ACT }}"),
                    .installAppleCertificate(
                        certificateBase64: "${{ inputs.build_certificate_base64 }}",
                        password: "${{ inputs.p12_password }}"
                    ),
                    .archiveWithPreternatural(
                        teamId: "${{ inputs.notarization_team_id }}",
                        fuckSwiftSyntax: true,
                        notarizationUsername: "${{ inputs.notarization_username }}",
                        notarizationPassword: "${{ inputs.notarization_password }}"
                    ),
                    .findArchiveFile(),
                    .uploadArtifact(
                        name: "notarized-app",
                        path: "${{ env.ARCHIVE_FILE }}"
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-5")
    }

    @Test("Test Action 6 Conversion")
    func testAction6Conversion() throws {
        let action = _GHA.Action(
            name: "Export macOS App",
            description: .multiline("""
            Signs, exports, packages and notarizes a macOS app in .zip or .dmg format using Preternatural CLI.
            """),
            inputs: [
                "xcode-version": _GHA.Action.Input(
                    description: .singleQuoted("Xcode version to use"),
                    required: false,
                    defaultValue: .singleQuoted("16.2")
                ),
                "working-directory": _GHA.Action.Input(
                    description: .singleQuoted("Directory to run the preternatural command from"),
                    required: false,
                    defaultValue: .singleQuoted("")
                ),
                "configuration": _GHA.Action.Input(
                    description: .singleQuoted("Build configuration (either `Debug` or `Release`; Release by default)"),
                    required: false,
                    defaultValue: .singleQuoted("Release")
                ),
                "fuck-swift-syntax": _GHA.Action.Input(
                    description: .singleQuoted("Enable the --fuck-swift-syntax flag"),
                    required: false,
                    defaultValue: true,
                    type: "boolean"
                )
            ],
            runs: _GHA.Action.Runs(
                using: .singleQuoted("composite"),
                steps: [
                    .loadSecretsFrom1Password(
                        serviceAccountToken: "token",
                        secrets: [
                            "NOTARIZATION_APP_STORE_CONNECT_USERNAME": "op://abc/abc/abc",
                            "NOTARIZATION_APP_STORE_CONNECT_PASSWORD": "op://abc/abc/abc",
                            "GITHUB_PAT": "op://abc/abc/abc",
                            "DEVELOPER_ID_APPLICATION_CERTIFICATE_DATA_BASE_64": "op://abc/abc/abc",
                            "DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD": "op://abc/abc/abc",
                            "TEAM_ID": "op://abc/abc/abc"
                        ]
                    ),
                    .setupXcode(version: "${{ inputs.xcode_version }}"),
                    .installPreternatural(),
                    .setupPATForPrivateRepos(),
                    .restoreDerivedDataCache(),
                    .exportMacOSApp(
                        workingDirectory: "${{ inputs.working-directory }}",
                        configuration: "${{ inputs.configuration }}",
                        fuckSwiftSyntax: true
                    ),
                    .uploadNotarizedApp(),
                    .uploadLogs(),
                    .saveDerivedDataCache(ifCondition: "steps.archive.outputs.archive_succeeded == 'true'"),
                    .checkBuildStatusAndFail(ifCondition: "steps.archive.outputs.archive_succeeded != 'true'")
                ]
            )
        )
        
        try test(action: action, with: "action-6")
    }
    
    @MainActor
    private func test(action: _GHA.Action, with file: String) throws {
        guard let originalFileURL = Bundle.module.url(forResource: file, withExtension: "yml", subdirectory: "Resources/actions") else {
            #expect(Bool(false), "Could not find \(file).yml")
            return
        }
        
        let outputURL = originalFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(file)-output.yml")
        
        try _GHA.Configuration.generateYaml(for: action, at: outputURL)
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Generated YAML file doesn't exist")
        
        let originalFormattedValue = try String(contentsOf: originalFileURL, encoding: .utf8)
        let generatedFormattedValue = try String(contentsOf: outputURL, encoding: .utf8)
        #expect(originalFormattedValue == generatedFormattedValue)
    }
}
