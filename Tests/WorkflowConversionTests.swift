//
// Copyright (c) Vatsal Manot
//

import _GitHubActionsTypes
import Foundation
import GitHubActionsCLT
import GitHubActionsCore
import Testing
import Yams
import OrderedCollections

@Suite("Workflow Conversion Tests", .serialized)
@MainActor
struct WorkflowConversionTests {

    @Test("Test Workflow 1 Conversion")
    func testWorkflow1Conversion() throws {
        let workflow = _GHA.Workflow(
            name: "build-swallow".toYamlString,
            on: _GHA.Triggers(
                push: _GHA.Triggers.PushTrigger(
                    branches: ["build-swallow".toYamlString]
                ),
                workflowDispatch: true
            ),
            jobs: [
                "build-swallow": _GHA.Job(
                    strategy: _GHA.Job.Strategy(matrix: [
                        "xcode_version": [
                            "15.4".toYamlString(.doubleQuoted),
                            "16.1_beta".toYamlString(.doubleQuoted),
                        ]
                    ]),
                    env: [
                        "DEVELOPER_DIR": "/Applications/Xcode_${{ matrix.xcode_version }}.app/Contents/Developer".toYamlString(.doubleQuoted)
                    ],
                    runsOn: "ghcr.io/cirruslabs/macos-runner:sequoia".toYamlString,
                    steps: [
                        _GHA.Step(
                            name: "Xcode Select ${{ matrix.xcode_version }}".toYamlString,
                            run: "sudo xcode-select -s /Applications/Xcode_${{ matrix.xcode_version }}.app".toYamlString
                        ),
                        _GHA.Step(
                            name: "Get swift version".toYamlString,
                            run: "swift --version".toYamlString
                        ),
                        _GHA.Step(
                            uses: "actions/checkout@v2".toYamlString
                        ),
                        _GHA.Step(
                            name: "Clone Swallow".toYamlString,
                            env: [
                                "COMMIT": "2ac7c7f06110bc3b397677e82d3a232980c20617".toYamlString
                            ],
                            run: """
                            git clone https://github.com/vmanot/Swallow
                            cd Swallow
                            git checkout $COMMIT
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Build Scipio".toYamlString,
                            run: """
                            swift build -c release
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Build XCFrameworks".toYamlString,
                            run: """
                            swift run -c release scipio prepare Swallow
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "List XCFrameworks".toYamlString,
                            run: """
                            ls -l Swallow/XCFrameworks
                            """.toYamlString(.multiline)
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
            name: "Preternatural Archive Test (Test-Project)".toYamlString,
            on: _GHA.Triggers(
                workflowDispatch: true
            ),
            jobs: [
                "build": _GHA.Job(
                    runsOn: "ghcr.io/cirruslabs/macos-runner:sequoia".toYamlString,
                    steps: [
                        _GHA.Step(
                            name: "Checkout repository".toYamlString,
                            uses: "actions/checkout@v3".toYamlString
                        ),
                        _GHA.Step(
                            name: "Install Preternatural".toYamlString,
                            run: """
                            set -x  # Enable verbose output
                            brew tap PreternaturalAI/preternatural
                            brew install preternatural
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Test Preternatural Installation".toYamlString,
                            run: """
                            echo "Preternatural version:"
                            preternatural help

                            echo "Preternatural location:"
                            which preternatural

                            echo "Brew info:"
                            brew info preternatural
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Setup Xcode".toYamlString,
                            uses: "maxim-lobanov/setup-xcode@v1".toYamlString,
                            with: [
                                "xcode-version": "${{ inputs.xcode_version }}".toYamlString
                            ]
                        ),
                        _GHA.Step(
                            name: "Install the Apple certificate and provisioning profile".toYamlString,
                            shell: "bash".toYamlString,
                            workingDirectory: "Test-Project".toYamlString(.singleQuoted),
                            env: [
                                "BUILD_CERTIFICATE_BASE64": "base".toYamlString(.doubleQuoted),
                                "P12_PASSWORD": "123".toYamlString(.doubleQuoted)
                            ],
                            run: """
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
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Run preternatural archive command".toYamlString,
                            shell: "bash".toYamlString,
                            workingDirectory: "Test-Project".toYamlString(.singleQuoted),
                            env: [
                                "NOTARIZATION_APP_STORE_CONNECT_USERNAME": "username".toYamlString(.doubleQuoted),
                                "NOTARIZATION_APP_STORE_CONNECT_PASSWORD": "password".toYamlString(.doubleQuoted)
                            ],
                            run: """
                            TEAM_ID="asdbv"

                            if [ -n "${TEAM_ID}" ]; then
                              script -q /dev/null preternatural archive --team-id "${TEAM_ID}"
                            else
                              script -q /dev/null preternatural archive
                            fi
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Find archive file".toYamlString,
                            shell: "bash".toYamlString,
                            run: """
                            ARCHIVE_FILE=$(find . -name "*Notarized*.zip" -print -quit)
                            if [ -z "$ARCHIVE_FILE" ]; then
                              echo "Error: No notarized ZIP file found"
                              exit 1
                            fi
                            echo "ARCHIVE_FILE=$ARCHIVE_FILE" >> $GITHUB_ENV
                            echo "Found archive file: $ARCHIVE_FILE"
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Upload archive as artifact".toYamlString,
                            uses: "actions/upload-artifact@v4".toYamlString,
                            with: [
                                "name": "notarized-app".toYamlString,
                                "path": "${{ env.ARCHIVE_FILE }}".toYamlString,
                                "if-no-files-found": "error".toYamlString
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
            name: "Preternatural Internal Release Plugin GitHub Action".toYamlString,
            on: _GHA.Triggers(
                workflowDispatch: true
            ),
            jobs: [
                "build": _GHA.Job(
                    runsOn: "ghcr.io/cirruslabs/macos-runner:sequoia".toYamlString,
                    steps: [
                        _GHA.Step(
                            name: "Run Update Plugin Action (preternatural)".toYamlString,
                            uses: "PreternaturalAI/internal-github-action/preternatural-release-plugin@aksh1t/ENG-1792".toYamlString,
                            with: [
                                "plugin-package-repository": "PreternaturalAI/command-line-tool-plugin".toYamlString(.singleQuoted),
                                "tool-name": "preternatural".toYamlString(.singleQuoted)
                            ]
                        ),
                        _GHA.Step(
                            name: "Run Update Plugin Action (lint-my-swift)".toYamlString,
                            uses: "PreternaturalAI/internal-github-action/preternatural-release-plugin@aksh1t/ENG-1792".toYamlString,
                            with: [
                                "plugin-package-repository": "PreternaturalAI/lint-my-swift-plugin".toYamlString(.singleQuoted),
                                "tool-name": "lint-my-swift".toYamlString(.singleQuoted)
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
            name: "Build and Test".toYamlString,
            on: _GHA.Triggers(
                push: _GHA.Triggers.PushTrigger(
                    branches: ["main".toYamlString]
                ),
                pullRequest: _GHA.Triggers.PullRequestTrigger(
                    branches: ["*".toYamlString]
                )
            ),
            jobs: [
                "Tests": _GHA.Job(
                    runsOn: "ghcr.io/cirruslabs/macos-runner:sequoia".toYamlString,
                    steps: [
                        _GHA.Step(
                            name: "Setup Xcode".toYamlString,
                            uses: "maxim-lobanov/setup-xcode@v1".toYamlString,
                            with: [
                                "xcode-version": "16.2".toYamlString(.singleQuoted)
                            ]
                        ),
                        _GHA.Step(
                            name: "Authorize Preternatural GitHub".toYamlString,
                            uses: "PreternaturalAI/internal-github-action/preternatural-authorize-github@main".toYamlString
                        ),
                        _GHA.Step(
                            name: "Get swift version".toYamlString,
                            run: "swift --version".toYamlString
                        ),
                        _GHA.Step(
                            uses: "actions/checkout@v4".toYamlString
                        ),
                        _GHA.Step(
                            name: "Install Preternatural".toYamlString,
                            shell: "bash".toYamlString,
                            run: """
                            brew tap PreternaturalAI/preternatural
                            brew install preternatural
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Restore DerivedData Cache".toYamlString,
                            uses: "cirruslabs/cache/restore@v4".toYamlString,
                            with: [
                                "path": "~/Library/Developer/Xcode/DerivedData".toYamlString(.doubleQuoted),
                                "key": "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}".toYamlString,
                                "restore-keys": """
                                ${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data
                                """.toYamlString(.multiline)
                            ]
                        ),
                        _GHA.Step(
                            name: "Run Preternatural Test Command".toYamlString,
                            id: "test".toYamlString,
                            shell: "bash".toYamlString,
                            run: """
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
                            """.toYamlString(.multiline)
                        ),
                        _GHA.Step(
                            name: "Upload logs".toYamlString,
                            if: "success() || failure()".toYamlString,
                            uses: "PreternaturalAI/preternatural-github-actions/preternatural-upload-logs@main".toYamlString
                        ),
                        _GHA.Step(
                            name: "Save DerivedData Cache".toYamlString,
                            if: "steps.test.outputs.test_failed != 'true'".toYamlString,
                            uses: "cirruslabs/cache/save@v4".toYamlString,
                            with: [
                                "path": "~/Library/Developer/Xcode/DerivedData".toYamlString(.doubleQuoted),
                                "key": "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}".toYamlString
                            ]
                        ),
                        _GHA.Step(
                            name: "Fail if tests failed".toYamlString,
                            if: "steps.test.outputs.test_failed == 'true'".toYamlString,
                            shell: "bash".toYamlString,
                            run: "exit 1".toYamlString
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
            runsOn: "ghcr.io/cirruslabs/macos-runner:sequoia".toYamlString,
            steps: [
                _GHA.Step(
                    name: "Checkout repository".toYamlString,
                    uses: "actions/checkout@v4".toYamlString
                ),
                _GHA.Step(
                    uses: "oven-sh/setup-bun@v2".toYamlString,
                    with: [
                        "bun-version": "latest".toYamlString
                    ]
                ),
                _GHA.Step(
                    name: "Run Internal Preternatural Export".toYamlString,
                    uses: "PreternaturalAI/internal-github-action/preternatural-export@main".toYamlString,
                    with: [
                        "working-directory": "BrowserExtensionContainer".toYamlString(.singleQuoted)
                    ]
                )
            ]
        )
        
        let workflow = _GHA.Workflow(
            name: "Preternatural Archive & Notarize".toYamlString,
            on: _GHA.Triggers(
                push: _GHA.Triggers.PushTrigger(
                    branches: ["main".toYamlString]
                ),
                workflowDispatch: true
            ),
            concurrency: [
                "group": "${{ github.workflow }}-${{ github.ref }}".toYamlString,
                "cancel-in-progress": "true".toYamlString
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
            .appendingPathComponent("\(file)-output.yml")
        
        _GHA.Configuration.set(configurations: [
            .workflow(workflow, outputURL: outputURL)
        ])
        
        try _GHA.Configuration.generateYAML()
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Generated YAML file doesn't exist")
        
        let originalYAML = try String(contentsOf: originalFileURL, encoding: .utf8)
        let generatedYAML = try String(contentsOf: outputURL, encoding: .utf8)
        #expect(originalYAML == generatedYAML)
    }
}
