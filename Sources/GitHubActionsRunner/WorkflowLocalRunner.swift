//
// Copyright (c) Vatsal Manot
//

import CLT_act
import CommandLineToolSupport
import Foundation
import GitHubActionsCore
import KeychainAccess
import Merge

public enum WorkflowLocalRunnerError: LocalizedError {
    case workflowFileNotFound(URL)
    case noGitRepositoryFound
    case invalidOrEmptyGitHubToken
    
    public var errorDescription: String? {
        switch self {
        case .workflowFileNotFound(let url):
            return "Workflow file not found at path: \(url.path)"
        case .noGitRepositoryFound:
            return "No Git repository found in the parent directories of the workflow file"
        case .invalidOrEmptyGitHubToken:
            return "GITHUB_TOKEN was either empty or invalid"
        }
    }
}

public enum WorkflowLocalRunner {
    private static let keychainService = "ai.preternatural.swift-github-actions"
    private static let githubTokenKey = "GitHubActionsRunner.GITHUB_TOKEN"
    
    @discardableResult
    public static func run(workflow: _GHA.Workflow) async throws -> Process.RunResult {
        /// When running the cli tool directly in Xcode, we do not have access to `PATH`.
        /// This function updates `PATH` with the most commonly used paths for commands such as `node`.
        try await updateEnvironmentPath()
        
        let artifactsURL = _GHA.Configuration.repositoryRootDirectory.appending(.directory(".act-artifacts"))
        
        // 1. Generate workflow temp file + cleanup after
        try _GHA.Configuration.generateYaml(for: workflow, at: workflow.tempYamlOutputURL)
        defer {
            try? FileManager.default.removeItem(atPath: workflow.tempYamlOutputURL.path(percentEncoded: false))
            try? FileManager.default.removeItem(atPath: artifactsURL.path(percentEncoded: false))
        }
        
        // 2. Get GitHub token from environment, keychain or prompt user
        let keychain = Keychain(service: keychainService)
        var githubToken = ""
        do {
            // First check if GITHUB_TOKEN is set in the environment
            if let envToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"], !envToken.isEmpty {
                githubToken = envToken
            }
            // If no environment token, try keychain
            else if let storedToken = try keychain.get(githubTokenKey) {
                githubToken = storedToken
            } else {
                print("\nGITHUB_TOKEN is required to run act locally.")
                print("If you are already logged in to the `gh` command, run `gh auth token` to get your current personal access token.")
                print("You can directly enter $(gh auth token) in the prompt below to automatically fetch the personal access token.")
                print("\nPlease enter your GitHub personal access token:")
                guard let token = readLine() else { throw WorkflowLocalRunnerError.invalidOrEmptyGitHubToken }
                try keychain.set(token, key: githubTokenKey)
                githubToken = token
            }
        } catch {
            print(error)
        }
        
        // 3. Create local copy with modified runner
        let originalContent = try String(contentsOf: workflow.tempYamlOutputURL, encoding: .utf8)
        let modifiedContent = originalContent.replacingOccurrences(
            of: "ghcr.io/cirruslabs/macos-runner[^\\n]*",
            with: "macos-latest",
            options: .regularExpression
        )
        try modifiedContent.write(to: workflow.tempYamlOutputURL, atomically: true, encoding: .utf8)
        
        // 4. Run with act
        let act = CLT.act()
        act.currentDirectoryURL = _GHA.Configuration.repositoryRootDirectory
        print("Running command in directory: \(act.currentDirectoryURL?.path(percentEncoded: false) ?? "-")")
        let result = try await act.run(workflowURL: workflow.tempYamlOutputURL, gitHubToken: githubToken)
        
        // 5. Move artifacts
        let workflowFileName = workflow.yamlOutputURL.deletingPathExtension().lastPathComponent
        let destinationDirectory = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Caches/swift-github-actions/\(workflowFileName)/\(UUID().uuidString)")
        if FileManager.default.fileExists(atPath: artifactsURL.path(percentEncoded: false)),
           let contents = try? FileManager.default.contentsOfDirectory(at: artifactsURL.appending(.directory("1")))
        {
            try? FileManager.default.copyFolders(
                from: contents,
                to: destinationDirectory,
                replaceExisting: true
            )
            try await SystemShell().run(command: "open \(destinationDirectory.path())")
        }
        
        return result
    }
}
