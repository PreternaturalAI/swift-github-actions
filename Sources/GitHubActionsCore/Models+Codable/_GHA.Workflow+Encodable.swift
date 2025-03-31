//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

extension _GHA.Workflow: Encodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case on
        case concurrency
        case jobs
        case environment = "env"
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
        if let environment = environment, !environment.isEmpty {
            try container.encode(OrderedDictionaryWrapper(environment), forKey: .environment)
        }
    }
}
