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
import OrderedCollections

@Suite("High Level Workflow Conversion Tests", .serialized)
@MainActor
struct HighLevelWorkflowConversionTests {

    @Test("Test Workflow 1 Conversion")
    func testWorkflow1Conversion() throws {
        let workflow = _GHA.Workflow(
            name: "build-swallow",
            on: _GHA.Triggers(
                push: _GHA.Triggers.PushTrigger(
                    branches: ["build-swallow"]
                ),
                workflowDispatch: true
            ),
            jobs: [
                "build-swallow": _GHA.Job(
                    strategy: _GHA.Job.Strategy(matrix: [
                        "xcode_version": [
                            .doubleQuoted("15.4"),
                            .doubleQuoted("16.1_beta"),
                        ]
                    ]),
                    environment: [
                        "DEVELOPER_DIR": .doubleQuoted("/Applications/Xcode_${{ matrix.xcode_version }}.app/Contents/Developer")
                    ],
                    runner: "ghcr.io/cirruslabs/macos-runner:sequoia",
                    steps: [
                        _GHA.Step(
                            name: "Xcode Select ${{ matrix.xcode_version }}",
                            run: "sudo xcode-select -s /Applications/Xcode_${{ matrix.xcode_version }}.app"
                        ),
                        .checkSwiftVersion(),
                        .checkoutRepository(version: "v2"),
                        _GHA.Step(
                            name: "Clone Swallow",
                            environment: [
                                "COMMIT": "2ac7c7f06110bc3b397677e82d3a232980c20617"
                            ],
                            run: .multiline("""
                            git clone https://github.com/vmanot/Swallow
                            cd Swallow
                            git checkout $COMMIT
                            """)
                        ),
                        _GHA.Step(
                            name: "Build Scipio",
                            run: .multiline("""
                            swift build -c release
                            """)
                        ),
                        _GHA.Step(
                            name: "Build XCFrameworks",
                            run: .multiline("""
                            swift run -c release scipio prepare Swallow
                            """)
                        ),
                        _GHA.Step(
                            name: "List XCFrameworks",
                            run: .multiline("""
                            ls -l Swallow/XCFrameworks
                            """)
                        )
                    ]
                )
            ]
        )
        
        try test(workflow: workflow, with: "workflow-1")
    }
    
    @Test("Test Workflow 2 Conversion")
    func testWorkflow2Conversion() throws {
        let workflow = _GHA.Workflow(
            name: "Preternatural Archive Test (Test-Project)",
            on: _GHA.Triggers(
                workflowDispatch: true
            ),
            jobs: [
                "build": _GHA.Job(
                    runner: "ghcr.io/cirruslabs/macos-runner:sequoia",
                    steps: [
                        .checkoutRepository(version: "v3"),
                        .installPreternatural(),
                        _GHA.Step(
                            name: "Test Preternatural Installation",
                            run: .multiline("""
                            echo "Preternatural version:"
                            preternatural help

                            echo "Preternatural location:"
                            which preternatural

                            echo "Brew info:"
                            brew info preternatural
                            """)
                        ),
                        .setupXcode(version: "${{ inputs.xcode_version }}"),
                        _GHA.Step(
                            name: "Install the Apple certificate and provisioning profile",
                            shell: "bash",
                            workingDirectory: .singleQuoted("Test-Project"),
                            environment: [
                                "BUILD_CERTIFICATE_BASE64": .doubleQuoted("base"),
                                "P12_PASSWORD": .doubleQuoted("123")
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

                            # Make the custom keychain the default and add it to the keychain list
                            security default-keychain -s $KEYCHAIN_PATH
                            security list-keychains -d user -s $KEYCHAIN_PATH $(security list-keychains -d user | xargs)
                            """)
                        ),
                        _GHA.Step(
                            name: "Run preternatural archive command",
                            shell: "bash",
                            workingDirectory: .singleQuoted("Test-Project"),
                            environment: [
                                "NOTARIZATION_APP_STORE_CONNECT_USERNAME": .doubleQuoted("username"),
                                "NOTARIZATION_APP_STORE_CONNECT_PASSWORD": .doubleQuoted("password")
                            ],
                            run: .multiline("""
                            TEAM_ID="asdbv"

                            if [ -n "${TEAM_ID}" ]; then
                              script -q /dev/null preternatural archive --team-id "${TEAM_ID}"
                            else
                              script -q /dev/null preternatural archive
                            fi
                            """)
                        ),
                        _GHA.Step(
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
                        ),
                        _GHA.Step(
                            name: "Upload archive as artifact",
                            uses: "actions/upload-artifact@v4",
                            with: [
                                "name": "notarized-app",
                                "path": "${{ env.ARCHIVE_FILE }}",
                                "if-no-files-found": "error"
                            ]
                        )
                    ]
                )
            ]
        )
        
        try test(workflow: workflow, with: "workflow-2")
    }
    
    @Test("Test Workflow 3 Conversion")
    func testWorkflow3Conversion() throws {
        let workflow = _GHA.Workflow(
            name: "Preternatural Internal Release Plugin GitHub Action",
            on: _GHA.Triggers(
                workflowDispatch: true
            ),
            jobs: [
                "build": _GHA.Job(
                    runner: "ghcr.io/cirruslabs/macos-runner:sequoia",
                    steps: [
                        _GHA.Step(
                            name: "Run Update Plugin Action (preternatural)",
                            uses: "PreternaturalAI/internal-github-action/preternatural-release-plugin@aksh1t/ENG-1792",
                            with: [
                                "plugin-package-repository": .singleQuoted("PreternaturalAI/command-line-tool-plugin"),
                                "tool-name": .singleQuoted("preternatural")
                            ]
                        ),
                        _GHA.Step(
                            name: "Run Update Plugin Action (lint-my-swift)",
                            uses: "PreternaturalAI/internal-github-action/preternatural-release-plugin@aksh1t/ENG-1792",
                            with: [
                                "plugin-package-repository": .singleQuoted("PreternaturalAI/lint-my-swift-plugin"),
                                "tool-name": .singleQuoted("lint-my-swift")
                            ]
                        )
                    ]
                )
            ]
        )
        
        try test(workflow: workflow, with: "workflow-3")
    }
    
    @Test("Test Workflow 4 Conversion")
    func testWorkflow4Conversion() throws {
        let workflow = _GHA.Workflow(
            name: "Build and Test",
            on: _GHA.Triggers(
                push: _GHA.Triggers.PushTrigger(
                    branches: ["main"]
                ),
                pullRequest: _GHA.Triggers.PullRequestTrigger(
                    branches: ["*"]
                )
            ),
            jobs: [
                "Tests": _GHA.Job(
                    runner: "ghcr.io/cirruslabs/macos-runner:sequoia",
                    steps: [
                        .setupXcode(version: "16.2"),
                        .authorizePreternaturalGitHub(),
                        .checkSwiftVersion(),
                        .checkoutRepository(version: "v4"),
                        .installPreternatural(),
                        .restoreDerivedDataCache(),
                        _GHA.Step(
                            name: "Run Preternatural Test Command",
                            id: "test",
                            shell: "bash",
                            run: .multiline("""
                            PRETERNATURAL_CMD="script -q /dev/null preternatural test --build-before-testing --suppress-warnings"

                            set +e  # Don't exit on error
                            eval ${PRETERNATURAL_CMD} 2>&1
                            TEST_STATUS=$?
                            echo "Test command exited with status: $TEST_STATUS"
                            if [ $TEST_STATUS -ne 0 ]; then
                              echo "::error::Test failed (status: $TEST_STATUS). Failing the workflow after uploading logs."
                              echo "test_failed=true" >> $GITHUB_OUTPUT
                            else
                              echo "test_failed=false" >> $GITHUB_OUTPUT
                            fi
                            exit 0
                            """)
                        ),
                        .uploadLogs(),
                        .saveDerivedDataCache(ifCondition: "steps.test.outputs.test_failed != 'true'"),
                        _GHA.Step(
                            name: "Fail if tests failed",
                            if: "steps.test.outputs.test_failed == 'true'",
                            shell: "bash",
                            run: "exit 1"
                        )
                    ]
                )
            ]
        )
        
        try test(workflow: workflow, with: "workflow-4")
    }
    
    @Test("Test Workflow 5 Conversion")
    func testWorkflow5Conversion() throws {
        var jobs: OrderedDictionary<String, _GHA.Job> = [:]
        jobs["archive-and-notarize"] = _GHA.Job(
            runner: "ghcr.io/cirruslabs/macos-runner:sequoia",
            steps: [
                .checkoutRepository(version: "v4"),
                _GHA.Step(
                    uses: "oven-sh/setup-bun@v2",
                    with: [
                        "bun-version": "latest"
                    ]
                ),
                _GHA.Step(
                    name: "Run Internal Preternatural Export",
                    uses: "PreternaturalAI/internal-github-action/preternatural-export@main",
                    with: [
                        "working-directory": .singleQuoted("BrowserExtensionContainer")
                    ]
                )
            ]
        )
        
        let workflow = _GHA.Workflow(
            name: "Preternatural Archive & Notarize",
            on: _GHA.Triggers(
                push: _GHA.Triggers.PushTrigger(
                    branches: ["main"]
                ),
                workflowDispatch: true
            ),
            concurrency: [
                "group": "${{ github.workflow }}-${{ github.ref }}",
                "cancel-in-progress": true
            ],
            jobs: jobs
        )
        
        try test(workflow: workflow, with: "workflow-5")
    }
    
    @MainActor
    private func test(workflow: _GHA.Workflow, with file: String) throws {
        guard let originalFileURL = Bundle.module.url(forResource: file, withExtension: "yml", subdirectory: "Resources/workflows") else {
            #expect(Bool(false), "Could not find \(file).yml")
            return
        }
        
        let outputURL = originalFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(file)-higher-level-output.yml")
        
        try _GHA.Configuration.generateYaml(for: workflow, at: outputURL)
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Generated YAML file doesn't exist")
        
        let originalYAML = try String(contentsOf: originalFileURL, encoding: .utf8)
        let generatedYAML = try String(contentsOf: outputURL, encoding: .utf8)
        #expect(originalYAML == generatedYAML)
    }
}
