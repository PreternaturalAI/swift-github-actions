//
//  ActionConversionTests.swift
//  swift-github-actions
//
//  Created by Akshat Patel on 03/03/25.
//

import Testing
import Foundation
import GitHubActionsCLT
import _GitHubActionsTypes
import GitHubActionsCore
import Yams

@Suite("Action Conversion Tests")
struct ActionConversionTests {
    
    @MainActor @Test("Test Action 1 Conversion")
    func testAction1Conversion() throws {
        // Get the URL to the original action YAML file
        let testBundle = Bundle.module
        guard let originalActionURL = testBundle.url(forResource: "action-1", withExtension: "yml", subdirectory: "Resources/actions") else {
            #expect(false, "Could not find action-1.yml")
            return
        }
        
        // Define the output URL for the generated YAML
        let outputDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("ActionConversionTests", isDirectory: true)
            .appendingPathComponent("Resources/actions", isDirectory: true)
        
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        let outputURL = outputDir.appendingPathComponent("action-1-output.yml")
        
        // Create the Swift Action model that corresponds to action-1.yml
        let action = _GHA.Action(
            name: "Authorize GitHub",
            description: "Authorizes GitHub so that further commands can access all internal Preternatural repositories.",
            runs: _GHA.Action.Runs(
                using: "composite",
                steps: [
                    _GHA.Step(
                        name: "Load Secrets from 1Password",
                        uses: "1password/load-secrets-action@v2",
                        with: [
                            "export-env": "true"
                        ],
                        env: [
                            "OP_SERVICE_ACCOUNT_TOKEN": "sample_token",
                            "GITHUB_PAT": "op://Services/github-pat-internal-export-action/credential"
                        ]
                    ),
                    _GHA.Step(
                        name: "Setup PAT for Private Repos",
                        shell: "bash",
                        run: """
                        {
                          git config --global url."https://$GITHUB_PAT@github.com/".insteadOf "https://github.com/"
                        } > /dev/null 2>&1
                        """,
                        env: nil
                    )
                ]
            )
        )
        
        // Configure with the Swift model
        _GHA.Configuration.set(configurations: [
            .action(action, outputURL: outputURL)
        ])
        
        // Generate the YAML file
        try _GHA.Configuration.generateYAML()
        
        // Check if the output file exists
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Generated YAML file doesn't exist")
        
        // Read both YAML files
        let originalYAML = try String(contentsOf: originalActionURL, encoding: .utf8)
        let generatedYAML = try String(contentsOf: outputURL, encoding: .utf8)
        
        // Parse both YAMLs to compare their structure (not just string equality)
        let originalDict = try Yams.load(yaml: originalYAML) as? [String: Any]
        let generatedDict = try Yams.load(yaml: generatedYAML) as? [String: Any]
        
        // Compare the parsed dictionaries
        #expect(originalDict != nil, "Failed to parse original YAML")
        #expect(generatedDict != nil, "Failed to parse generated YAML")
        
        // Compare specific values
        #expect(originalDict?["name"] as? String == generatedDict?["name"] as? String)
        #expect(originalDict?["description"] as? String == generatedDict?["description"] as? String)
        
        // Compare runs section
        let originalRuns = originalDict?["runs"] as? [String: Any]
        let generatedRuns = generatedDict?["runs"] as? [String: Any]
        
        #expect(originalRuns?["using"] as? String == generatedRuns?["using"] as? String)
        
        // Compare steps array
        let originalSteps = originalRuns?["steps"] as? [[String: Any]]
        let generatedSteps = generatedRuns?["steps"] as? [[String: Any]]
        
        #expect(originalSteps?.count == generatedSteps?.count)
        
        // Print the YAMLs for debugging
        print("Original YAML:\n\(originalYAML)")
        print("Generated YAML:\n\(generatedYAML)")
        
        // Clean up
        try? FileManager.default.removeItem(at: outputDir)
    }
}

