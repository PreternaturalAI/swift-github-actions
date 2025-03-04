//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge

public extension _GHA {
    final class Configuration {
        
        // MARK: - Properties

        public static var configurations: [ConfigurationType] = []
        
        // MARK: - Public Interface
        
        /// Configure workflows and actions with their output URL
        public static func set(configurations: [ConfigurationType]) {
            Self.configurations = configurations
        }
    }
}
