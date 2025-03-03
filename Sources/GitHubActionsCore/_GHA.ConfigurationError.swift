//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    /// Errors that can occur during configuration operations
    enum ConfigurationError: Error {
        /// No configuration has been set
        case noConfigurationSet
        
        /// The configuration type is not supported for serialization
        case unsupportedConfigurationType
        
        /// Failed to serialize the configuration to YAML
        case yamlSerializationFailed
    }
} 
