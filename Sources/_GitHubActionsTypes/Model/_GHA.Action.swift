//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Action: Equatable {
        public let name: FormattedValue
        public let description: FormattedValue?
        public let inputs: OrderedDictionary<String, Input>?
        public let runs: Runs
        
        public init(
            name: FormattedValue,
            description: FormattedValue? = nil,
            inputs: OrderedDictionary<String, Input>? = nil,
            runs: Runs
        ) {
            self.name = name
            self.description = description
            self.inputs = inputs
            self.runs = runs
        }
    }
}
