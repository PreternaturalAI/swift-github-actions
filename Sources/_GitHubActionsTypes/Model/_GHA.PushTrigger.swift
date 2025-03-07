//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Triggers {
    struct PushTrigger: Equatable {
        public let branches: [_GHA.FormattedValue]?
        public let tags: [_GHA.FormattedValue]?

        public init(branches: [_GHA.FormattedValue]? = nil, tags: [_GHA.FormattedValue]? = nil) {
            self.branches = branches
            self.tags = tags
        }
    }
}
