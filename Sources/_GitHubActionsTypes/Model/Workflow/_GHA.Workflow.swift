//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    struct Workflow: Encodable {
        public let name: String
        public let on: Triggers
        public let jobs: [String: Job]
        public let env: [String: String]?

        public init(
            name: String,
            on: Triggers,
            jobs: [String: Job],
            env: [String: String]? = nil
        ) {
            self.name = name
            self.on = on
            self.jobs = jobs
            self.env = env
        }
    }
}
