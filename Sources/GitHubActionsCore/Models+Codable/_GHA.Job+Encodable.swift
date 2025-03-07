//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

extension _GHA.Job: Encodable {
    private enum CodingKeys: String, CodingKey {
        case strategy
        case env
        case runsOn = "runs-on"
        case steps
        case needs
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(strategy, forKey: .strategy)
        if let env = env, !env.isEmpty {
            try container.encode(OrderedDictionaryWrapper(env), forKey: .env)
        }
        try container.encodeIfPresent(runsOn, forKey: .runsOn)
        try container.encode(steps, forKey: .steps)
        try container.encodeIfPresent(needs, forKey: .needs)
    }
}
