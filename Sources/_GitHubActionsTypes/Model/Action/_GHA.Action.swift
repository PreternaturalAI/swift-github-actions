//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Action: Equatable {
        public let name: YAMLString
        public let description: YAMLString?
        public let inputs: OrderedDictionary<String, Input>?
        public let runs: Runs
        
        public init(
            name: YAMLString,
            description: YAMLString? = nil,
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

extension _GHA.Action: Encodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case inputs
        case runs
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        if let inputs = inputs, !inputs.isEmpty {
            try container.encode(OrderedDictionaryWrapper(inputs), forKey: .inputs)
        }
        try container.encode(runs, forKey: .runs)
    }
}
