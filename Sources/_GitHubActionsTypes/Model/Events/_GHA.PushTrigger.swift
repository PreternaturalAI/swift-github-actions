//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Triggers {
    struct PushTrigger: Equatable {
        public let branches: [_GHA.YAMLString]?
        public let tags: [_GHA.YAMLString]?

        public init(branches: [_GHA.YAMLString]? = nil, tags: [_GHA.YAMLString]? = nil) {
            self.branches = branches
            self.tags = tags
        }
    }
}

extension _GHA.Triggers.PushTrigger: Encodable {}
