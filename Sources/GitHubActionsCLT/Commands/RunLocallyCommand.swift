//
// Copyright (c) Vatsal Manot
//

import ArgumentParser
import GitHubActionsRunner
import GitHubActionsCore
import Foundation

enum RunLocallyError: LocalizedError {
    case noWorkflowsConfigured
    case invalidWorkflowSelection
    case error(String)
    
    var errorDescription: String? {
        switch self {
        case .noWorkflowsConfigured:
            return "No workflows are configured. Please configure workflows first."
        case .invalidWorkflowSelection:
            return "Invalid workflow selection."
        case .error(let description):
            return description
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
                RunLocallyCommand.exit(withError: RunLocallyError.invalidWorkflowSelection)
            }
            
            selectedWorkflow = workflows[selection - 1]
        }
        
        // 3. Run the selected workflow
        let result = try await WorkflowLocalRunner.runWorkflow(at: selectedWorkflow.url)
        if let description = result.stderrString {
            RunLocallyCommand.exit(withError: RunLocallyError.error(description))
        }
        
        RunLocallyCommand.exit()
    }
}
