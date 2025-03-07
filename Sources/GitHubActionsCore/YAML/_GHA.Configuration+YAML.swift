//
// Copyright (c) Vatsal Manot
//

import Foundation
import Yams

extension _GHA.Configuration {
    
    // MARK: - YAML Generation
    
    public static func generateYAML() throws {
        guard !Self.configurations.isEmpty else {
            throw _GHA.ConfigurationError.noConfigurationSet
        }
        
        do {
            for configuration in Self.configurations {
                switch configuration {
                case .workflow(let workflow, let outputURL):
                    try generateWorkflowYAML(workflow, at: outputURL)
                case .action(let action, let outputURL):
                    try generateActionYAML(action, at: outputURL)
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
    
    private static func generateWorkflowYAML(_ workflow: _GHA.Workflow, at outputURL: URL) throws {
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let yaml = try yamlEncoder.encode(workflow)
        
        let finalOutputURL: URL
        if outputURL.pathExtension.lowercased() == "yml" || outputURL.pathExtension.lowercased() == "yaml" {
            finalOutputURL = outputURL
        } else {
            finalOutputURL = outputURL.appendingPathComponent("workflow.yml")
        }
        try yaml.write(to: finalOutputURL, atomically: true, encoding: .utf8)
        print("Generated GitHub Workflow file at:\n\(finalOutputURL.path(percentEncoded: false))\n")
    }
    
    private static func generateActionYAML(_ action: _GHA.Action, at outputURL: URL) throws {
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let yaml = try yamlEncoder.encode(action)
        
        let finalOutputURL: URL
        if outputURL.pathExtension.lowercased() == "yml" || outputURL.pathExtension.lowercased() == "yaml" {
            finalOutputURL = outputURL
        } else {
            finalOutputURL = outputURL.appendingPathComponent("action.yml")
        }
        try yaml.write(to: finalOutputURL, atomically: true, encoding: .utf8)
        print("Generated GitHub Action file at:\n\(finalOutputURL.path(percentEncoded: false))\n")
    }
}
