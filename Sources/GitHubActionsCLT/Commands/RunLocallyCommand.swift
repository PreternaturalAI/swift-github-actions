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
        let workflows = _GHA.Configuration.configurations.compactMap { config -> _GHA.Workflow? in
            if case let .workflow(workflow) = config {
                return workflow
            }
            return nil
        }
        
        guard !workflows.isEmpty else {
            RunLocallyCommand.exit(withError: RunLocallyError.noWorkflowsConfigured)
        }
        
        for workflow in workflows {
            print("\nRunning Workflow:\n - Name: \(workflow.name)\n - Location: \(workflow.tempYamlOutputURL.path())\n")
            let result = try await WorkflowLocalRunner.run(workflow: workflow)
            if let _ = result.terminationError, let description = result.stderrString {
                RunLocallyCommand.exit(withError: RunLocallyError.error(description))
            }
        }
        
        RunLocallyCommand.exit()
    }
}
