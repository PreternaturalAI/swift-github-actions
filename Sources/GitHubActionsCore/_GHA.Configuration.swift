//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge

public extension _GHA {
    
    @MainActor
    @Singleton
    final class Configuration {
        
        // MARK: - Properties

        internal var configurations: [ConfigurationType] = []
        
        // MARK: - Public Interface
        
        /// Configure workflows and actions with their output URL
        public static func set(configurations: [ConfigurationType]) {
            shared.configurations = configurations
        }
        
        /// Generate YAML files for all configured workflows and actions
        public static func generateYAML() throws {
            try shared.generateYAML()
        }
    }
}
