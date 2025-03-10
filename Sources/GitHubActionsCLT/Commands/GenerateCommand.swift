//
// Copyright (c) Vatsal Manot
//

import ArgumentParser

public struct GenerateCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generates YAML file(s) from the configured GitHub Workflows and Actions."
    )
    
    public init() {}

    public func run() async throws {
        try _GHA.Configuration.generateYamlForAllConfigurations()
    }
}
