//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import CommandLineToolSupport
import Foundation
import Merge

public extension CommandLineTools {
    final class act: AnyCommandLineTool, CommandLineTool {
        override public init() {}
    }
}

public extension CommandLineTools.act {
    func run() async throws -> Process.RunResult {
        return try await withUnsafeSystemShell { shell in
            let command = "act"
            return try await shell.run(command: command)
        }
    }
}

#endif
