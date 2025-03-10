//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge

public extension _GHA {
    final class Configuration {
        
        // MARK: - Properties

        public static var configurations: [ConfigurationType] = []
        public static var mainCommandFileURL: URL!
        // MARK: - Public Interface
        
        /// Configure workflows and actions with their output URL
        public static func set(configurations: [ConfigurationType], mainCommandFileURL: URL) {
            Self.configurations = configurations
            Self.mainCommandFileURL = mainCommandFileURL
        }
    }
}
