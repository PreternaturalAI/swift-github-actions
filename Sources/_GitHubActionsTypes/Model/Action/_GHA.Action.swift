//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    struct Action: Encodable {
        public let name: String
        public let description: String?
        public let inputs: [String: Input]?
        public let runs: Runs
        
        public init(
            name: String,
            description: String? = nil,
            inputs: [String: Input]? = nil,
            runs: Runs
        ) {
            self.name = name
            self.description = description
            self.inputs = inputs
            self.runs = runs
        }
    }
}
