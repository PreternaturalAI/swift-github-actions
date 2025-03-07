//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

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
