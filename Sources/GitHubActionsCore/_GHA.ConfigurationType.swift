//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    /// Represents the type of configuration to be generated
    enum ConfigurationType {
        /// A GitHub Actions workflow configuration
        case workflow(Workflow, outputURL: URL)
        
        /// A GitHub Actions action configuration
        case action(Action, outputURL: URL)
    }
} 
