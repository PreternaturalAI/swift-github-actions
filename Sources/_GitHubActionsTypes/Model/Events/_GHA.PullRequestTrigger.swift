//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Triggers {
    struct PullRequestTrigger: Equatable {
        public let branches: [_GHA.YAMLString]?

        public init(branches: [_GHA.YAMLString]? = nil) {
            self.branches = branches
        }
    }
}

extension _GHA.Triggers.PullRequestTrigger: Encodable {}
