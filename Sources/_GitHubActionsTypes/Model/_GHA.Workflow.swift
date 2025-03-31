//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Workflow: Equatable {
        public let name: FormattedValue
        public let on: Triggers
        public let concurrency: OrderedDictionary<String, FormattedValue>?
        public let jobs: OrderedDictionary<String, Job>
        public let environment: OrderedDictionary<String, FormattedValue>?

        public init(
            name: FormattedValue,
            on: Triggers,
            concurrency: OrderedDictionary<String, FormattedValue>? = nil,
            jobs: OrderedDictionary<String, Job>,
            environment: OrderedDictionary<String, FormattedValue>? = nil
        ) {
            self.name = name
            self.on = on
            self.concurrency = concurrency
            self.jobs = jobs
            self.environment = environment
        }
    }
}
