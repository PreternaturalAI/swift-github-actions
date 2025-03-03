//
// Copyright (c) Vatsal Manot
//

import ArgumentParser

struct RunLocallyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run-locally",
        abstract: "Runs the selected workflow file locally."
    )

    func run() async throws {
        print("TODO: GitHubActionsRunner")
    }
}
