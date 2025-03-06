//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import CommandLineToolSupport
import Foundation
import Merge

extension CommandLineTools {
    public final class act: AnyCommandLineTool, CommandLineTool {
        override public init() {}
    }
}

extension CommandLineTools.act {
    
    @discardableResult
    public func run(workflowURL: URL, sudoPassword: String, gitHubToken: String) async throws -> Process.RunResult {
        return try await withUnsafeSystemShell { shell in
            let command = "echo \"\(sudoPassword)\" | sudo -S act "
            let arguments = [
                "-P",
                "macos-latest=-self-hosted",
                "-W",
                workflowURL.path(percentEncoded: false),
                "-s",
                "GITHUB_TOKEN=\"\(gitHubToken)\""
            ]
            let finalCommand = command + arguments.joined(separator: " ")
            return try await shell.run(command: finalCommand)
        }
    }
}

#endif
