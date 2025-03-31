//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

extension _GHA.Job: Encodable {
    private enum CodingKeys: String, CodingKey {
        case strategy
        case environment = "env"
        case runner = "runs-on"
        case steps
        case needs
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(strategy, forKey: .strategy)
        if let environment = environment, !environment.isEmpty {
            try container.encode(OrderedDictionaryWrapper(environment), forKey: .environment)
        }
        try container.encodeIfPresent(runner, forKey: .runner)
        try container.encode(steps, forKey: .steps)
        try container.encodeIfPresent(needs, forKey: .needs)
    }
}
