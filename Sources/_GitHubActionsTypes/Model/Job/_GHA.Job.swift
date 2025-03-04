//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Job: Equatable {
        public let strategy: _GHA.Job.Strategy?
        public let env: OrderedDictionary<String, YAMLString>?
        public let runsOn: YAMLString?
        public let steps: [Step]
        public let needs: [YAMLString]?
        
        public init(
            strategy: _GHA.Job.Strategy? = nil,
            env: OrderedDictionary<String, YAMLString>? = nil,
            runsOn: YAMLString? = nil,
            steps: [Step],
            needs: [YAMLString]? = nil
        ) {
            self.strategy = strategy
            self.env = env
            self.runsOn = runsOn
            self.steps = steps
            self.needs = needs
        }
    }
}

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
