//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    final class Configuration {
        
        // MARK: - Properties

        private static var shared = Configuration()
        internal var configurations: [ConfigurationType] = []
        
        // MARK: - Initialization
        
        private init() {}
        
        // MARK: - Public Interface
        
        /// Configure workflows and actions with their output URL
        public static func set(configurations: [ConfigurationType]) {
            shared.configurations = configurations
        }
        
        /// Clear all configurations
        public static func reset() {
            shared.configurations.removeAll()
        }
        
        /// Generate YAML files for all configured workflows and actions
        public static func generateYAML() throws {
            try shared.generateYAML()
        }
    }
}
