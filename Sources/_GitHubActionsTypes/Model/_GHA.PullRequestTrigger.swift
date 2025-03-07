//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Triggers {
    struct PullRequestTrigger: Equatable {
        public let branches: [_GHA.FormattedValue]?

        public init(branches: [_GHA.FormattedValue]? = nil) {
            self.branches = branches
        }
    }
}
