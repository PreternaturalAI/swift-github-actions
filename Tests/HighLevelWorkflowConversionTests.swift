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
                        .installAppleCertificate(
                            certificateBase64: "base",
                            password: "123"
                        ),
                        .archiveWithPreternatural(
                            teamId: "asdbv",
                            notarizationUsername: "username", 
                            notarizationPassword: "password"
                        ),
                        .findArchiveFile(),
                        .uploadArtifact(
                            name: "notarized-app",
                            path: "${{ env.ARCHIVE_FILE }}"
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
                        .releasePlugin(
                            pluginPackageRepository: "PreternaturalAI/command-line-tool-plugin",
                            toolName: "preternatural"
                        ),
                        .releasePlugin(
                            pluginPackageRepository: "PreternaturalAI/lint-my-swift-plugin",
                            toolName: "lint-my-swift"
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
                        .testWithPreternatural(
                            buildBeforeTesting: true,
                            suppressWarnings: true
                        ),
                        .uploadLogs(),
                        .saveDerivedDataCache(ifCondition: "steps.test.outputs.test_failed != 'true'"),
                        .failWithMessage(
                            message: "Tests failed",
                            ifCondition: "steps.test.outputs.test_failed == 'true'"
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
            .appendingPathComponent("\(file)-output.yml")
        
        try _GHA.Configuration.generateYaml(for: workflow, at: outputURL)
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Generated YAML file doesn't exist")
        
        let originalYAML = try String(contentsOf: originalFileURL, encoding: .utf8)
        let generatedYAML = try String(contentsOf: outputURL, encoding: .utf8)
        #expect(originalYAML == generatedYAML)
    }
}
