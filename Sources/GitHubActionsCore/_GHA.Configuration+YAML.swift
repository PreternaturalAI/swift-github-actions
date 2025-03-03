//
// Copyright (c) Vatsal Manot
//

import Foundation
import Yams

extension _GHA.Configuration {
    // MARK: - YAML Generation
    
    internal func generateYAML() throws {
        guard !configurations.isEmpty else {
            throw _GHA.ConfigurationError.noConfigurationSet
        }
        
        do {
            for configuration in configurations {
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
    
    private func generateWorkflowYAML(_ workflow: _GHA.Workflow, at outputURL: URL) throws {
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(workflow)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw _GHA.ConfigurationError.unsupportedConfigurationType
        }
        
        guard let yaml = try? Yams.dump(object: json) else {
            throw _GHA.ConfigurationError.yamlSerializationFailed
        }
        
        let finalOutputURL: URL
        if outputURL.pathExtension.lowercased() == "yml" || outputURL.pathExtension.lowercased() == "yaml" {
            finalOutputURL = outputURL
        } else {
            finalOutputURL = outputURL.appendingPathComponent("\(sanitizeFileName(workflow.name)).yml")
        }
        try yaml.write(to: finalOutputURL, atomically: true, encoding: .utf8)
    }
    
    private func generateActionYAML(_ action: _GHA.Action, at outputURL: URL) throws {
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(action)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw _GHA.ConfigurationError.unsupportedConfigurationType
        }
        
        guard let yaml = try? Yams.dump(object: json) else {
            throw _GHA.ConfigurationError.yamlSerializationFailed
        }
        
        let finalOutputURL: URL
        if outputURL.pathExtension.lowercased() == "yml" || outputURL.pathExtension.lowercased() == "yaml" {
            finalOutputURL = outputURL
        } else {
            finalOutputURL = outputURL.appendingPathComponent("action.yml")
        }
        try yaml.write(to: finalOutputURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Helper Methods
    
    private func sanitizeFileName(_ name: String) -> String {
        return name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
    }
}
