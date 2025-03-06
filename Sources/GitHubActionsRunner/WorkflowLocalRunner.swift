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

public final class WorkflowLocalRunner {
    private static let keychainService = "ai.preternatural.swift-github-actions"
    private static let githubTokenKey = "GitHubActionsRunner.GITHUB_TOKEN"
    
    @discardableResult
    public static func runWorkflow(at url: URL) async throws -> Process.RunResult {
        // 1. Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw WorkflowLocalRunnerError.workflowFileNotFound(url)
        }
        
        // 2. Get GitHub token from keychain or prompt user
        let keychain = Keychain(service: keychainService)
        var githubToken = ""
        do {
            if let storedToken = try keychain.get(githubTokenKey) {
                githubToken = storedToken
            } else {
                print("GITHUB_TOKEN is required to run act locally. If you are already logged in to the `gh` command, run `gh auth token` to get your current personal access token.")
                print("Please enter your GitHub token:")
                guard let token = readLine() else { throw WorkflowLocalRunnerError.invalidOrEmptyGitHubToken }
                try keychain.set(token, key: githubTokenKey)
                githubToken = token
            }
        } catch {
            print(error)
        }
        
        // 3. Get sudo password securely
        print("Sudo access is required to run the workflow.")
        print("Please enter your sudo password:")
        let password = String(cString: getpass(""))
        
        // 4. Create local copy with modified runner
        let localWorkflowURL = url.deletingLastPathComponent()
            .appendingPathComponent(url.deletingPathExtension().lastPathComponent + "-local.yml")
        
        let originalContent = try String(contentsOf: url, encoding: .utf8)
        let modifiedContent = originalContent.replacingOccurrences(
            of: "ghcr.io/cirruslabs/macos-runner[^\\n]*",
            with: "macos-latest",
            options: .regularExpression
        )
        
        try modifiedContent.write(to: localWorkflowURL, atomically: true, encoding: .utf8)
        defer {
            try? FileManager.default.removeItem(at: localWorkflowURL)
        }
        
        // 5. Run with act
        let act = CLT.act()
        act.currentDirectoryURL = try findNearestParentGitRepoURL(for: localWorkflowURL)
        print("Running command in directory: \(act.currentDirectoryURL?.path(percentEncoded: false) ?? "-")")
        return try await act.run(workflowURL: localWorkflowURL, sudoPassword: password, gitHubToken: githubToken)
    }
    
    private static func findNearestParentGitRepoURL(for url: URL) throws -> URL {
        var currentURL = url.deletingLastPathComponent()
        
        while currentURL.pathComponents.count > 1 {
            let gitFolderURL = currentURL.appendingPathComponent(".git")
            if FileManager.default.fileExists(atPath: gitFolderURL.path) {
                return currentURL
            }
            currentURL = currentURL.deletingLastPathComponent()
        }
        
        throw WorkflowLocalRunnerError.noGitRepositoryFound
    }
}
