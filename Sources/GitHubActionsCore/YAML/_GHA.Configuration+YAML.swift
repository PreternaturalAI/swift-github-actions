//
// Copyright (c) Vatsal Manot
//

import Foundation
import Yams

extension _GHA.Configuration {
    
    // MARK: - YAML Generation
    
    public static func generateYamlForAllConfigurations() throws {
        guard !Self.configurations.isEmpty else {
            throw _GHA.ConfigurationError.noConfigurationSet
        }
        
        do {
            for configuration in Self.configurations {
                switch configuration {
                case .workflow(let workflow):
                    try generateYaml(for: workflow, at: workflow.yamlOutputURL)
                case .action(let action):
                    try generateYaml(for: action, at: action.yamlOutputURL)
                }
            }
        } catch {
            throw error
        }
    }
    
    private static var yamlEncoder: YAMLEncoder {
        let encoder = YAMLEncoder()
        encoder.options.sortKeys = false
        encoder.options.width = -1
        return encoder
    }
    
    public static func generateYaml(for encodable: Encodable, at url: URL) throws {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let yaml = try yamlEncoder.encode(encodable)
        try yaml.write(to: url, atomically: true, encoding: .utf8)
        print("Generated YAML file at:\n\(url.path(percentEncoded: false))\n")
    }
}
