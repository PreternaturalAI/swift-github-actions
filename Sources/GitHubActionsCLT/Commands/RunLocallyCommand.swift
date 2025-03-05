//
// Copyright (c) Vatsal Manot
//

import ArgumentParser
import Foundation
import GitHubActionsCore
import CLT_act
import CommandLineToolSupport

enum RunLocallyError: LocalizedError {
    case noWorkflowsConfigured
    case workflowFileNotFound(URL)
    
    var errorDescription: String? {
        switch self {
        case .noWorkflowsConfigured:
            return "No workflows are configured. Please configure workflows first."
        case .workflowFileNotFound(let url):
            return "Workflow file not found at path: \(url.path)"
        }
    }
}

public struct RunLocallyCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "run-locally",
        abstract: "Runs the selected workflow file locally."
    )

    public init() {}
    
    public func run() async throws {
        // 1. Check configurations for workflows
        let workflows = _GHA.Configuration.configurations.compactMap { config -> (workflow: _GHA.Workflow, url: URL)? in
            if case let .workflow(workflow, outputURL) = config {
                return (workflow, outputURL)
            }
            return nil
        }
        
        guard !workflows.isEmpty else {
            RunLocallyCommand.exit(withError: RunLocallyError.noWorkflowsConfigured)
        }
        
        // 2. Handle workflow selection
        let selectedWorkflow: (workflow: _GHA.Workflow, url: URL)
        if workflows.count == 1 {
            selectedWorkflow = workflows[0]
            print("Using the workflow at: \(selectedWorkflow.url.path)")
        } else {
            print("Available workflows:")
            for (index, workflow) in workflows.enumerated() {
                print("[\(index + 1)] \(workflow.url.path)")
            }
            
            print("\nEnter the number of the workflow to run (1-\(workflows.count)): ", terminator: "")
            guard let input = readLine(),
                  let selection = Int(input),
                  selection > 0 && selection <= workflows.count else {
                RunLocallyCommand.exit(withError: ValidationError("Invalid selection. Exiting."))
            }
            
            selectedWorkflow = workflows[selection - 1]
        }
        
        // 3. Check if file exists
        guard FileManager.default.fileExists(atPath: selectedWorkflow.url.path) else {
            RunLocallyCommand.exit(withError: RunLocallyError.workflowFileNotFound(selectedWorkflow.url))
        }
        
        // 4. Create local copy with modified runner
        let localWorkflowURL = selectedWorkflow.url.deletingLastPathComponent()
            .appendingPathComponent(selectedWorkflow.url.deletingPathExtension().lastPathComponent + "-local.yml")
        
        let originalContent = try String(contentsOf: selectedWorkflow.url, encoding: .utf8)
        let modifiedContent = originalContent.replacingOccurrences(
            of: "ghcr.io/cirruslabs/macos-runner[^\\n]*",
            with: "macos-latest",
            options: .regularExpression
        )
        
        try modifiedContent.write(to: localWorkflowURL, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: localWorkflowURL)
        }
        
        // 5. Get sudo password securely
        print("Sudo access is required to run the workflow.")
        print("Please enter your sudo password:")
        let password = String(cString: getpass(""))
        
        // 6. Run with act
        let act = CLT.act()
        act.currentDirectoryURL = localWorkflowURL.deletingLastPathComponent().deletingLastPathComponent()
        let result = try await act.run(workflowURL: localWorkflowURL, sudoPassword: password)
        print("Result: \(result)")
    }
}
