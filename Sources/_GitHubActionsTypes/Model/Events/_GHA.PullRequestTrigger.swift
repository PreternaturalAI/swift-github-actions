//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Triggers {
    struct PullRequestTrigger: Encodable {
        public let branches: [String]?

        public init(branches: [String]? = nil) {
            self.branches = branches
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let branches = branches {
                try container.encode(branches, forKey: .branches)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case branches
        }
    }
}
