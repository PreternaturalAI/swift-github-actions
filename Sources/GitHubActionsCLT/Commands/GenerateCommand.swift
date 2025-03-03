//
// Copyright (c) Vatsal Manot
//

import ArgumentParser

struct GenerateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generates YAML file(s) from the configured GitHub Workflows and Actions."
    )

    func run() async throws {
        try await _GHA.Configuration.generateYAML()
    }
}
