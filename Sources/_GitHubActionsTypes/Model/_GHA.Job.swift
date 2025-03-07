//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Job: Equatable {
        public let strategy: _GHA.Job.Strategy?
        public let env: OrderedDictionary<String, FormattedValue>?
        public let runsOn: FormattedValue?
        public let steps: [Step]
        public let needs: [FormattedValue]?
        
        public init(
            strategy: _GHA.Job.Strategy? = nil,
            env: OrderedDictionary<String, FormattedValue>? = nil,
            runsOn: FormattedValue? = nil,
            steps: [Step],
            needs: [FormattedValue]? = nil
        ) {
            self.strategy = strategy
            self.env = env
            self.runsOn = runsOn
            self.steps = steps
            self.needs = needs
        }
    }
}
