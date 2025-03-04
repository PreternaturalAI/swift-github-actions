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
    public func run(workflowURL: URL, sudoPassword: String) async throws -> Process.RunResult {
        return try await withUnsafeSystemShell { shell in
            let command = "echo \"\(sudoPassword)\" | sudo -S act -P macos-latest=-self-hosted -W '\(workflowURL.path(percentEncoded: false))'"
            return try await shell.run(command: command)
        }
    }
}

#endif
