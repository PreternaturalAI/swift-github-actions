//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Workflow: Equatable {
        public let name: YAMLString
        public let on: Triggers
        public let concurrency: OrderedDictionary<String, YAMLString>?
        public let jobs: OrderedDictionary<String, Job>
        public let env: OrderedDictionary<String, YAMLString>?

        public init(
            name: YAMLString,
            on: Triggers,
            concurrency: OrderedDictionary<String, YAMLString>? = nil,
            jobs: OrderedDictionary<String, Job>,
            env: OrderedDictionary<String, YAMLString>? = nil
        ) {
            self.name = name
            self.on = on
            self.concurrency = concurrency
            self.jobs = jobs
            self.env = env
        }
    }
}

extension _GHA.Workflow: Encodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case on
        case concurrency
        case jobs
        case env
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(on, forKey: .on)
        if let concurrency = concurrency, !concurrency.isEmpty {
            try container.encode(OrderedDictionaryWrapper(concurrency), forKey: .concurrency)
        }
        if !jobs.isEmpty {
            try container.encode(OrderedDictionaryWrapper(jobs), forKey: .jobs)
        }
        if let env = env, !env.isEmpty {
            try container.encode(OrderedDictionaryWrapper(env), forKey: .env)
        }
    }
}
