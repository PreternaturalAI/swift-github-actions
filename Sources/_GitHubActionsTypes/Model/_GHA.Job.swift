//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Job: Equatable {
        public let strategy: _GHA.Job.Strategy?
        public let environment: OrderedDictionary<String, FormattedValue>?
        public let runner: FormattedValue?
        public let steps: [Step]
        public let needs: [FormattedValue]?
        
        public init(
            strategy: _GHA.Job.Strategy? = nil,
            environment: OrderedDictionary<String, FormattedValue>? = nil,
            runner: FormattedValue? = nil,
            steps: [Step],
            needs: [FormattedValue]? = nil
        ) {
            self.strategy = strategy
            self.environment = environment
            self.runner = runner
            self.steps = steps
            self.needs = needs
        }
    }
}
