//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension TriggerEvents {
    struct PushTrigger: Encodable {
        public let branches: [String]?
        public let tags: [String]?

        public init(branches: [String]? = nil, tags: [String]? = nil) {
            self.branches = branches
            self.tags = tags
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let branches = branches {
                try container.encode(branches, forKey: .branches)
            }
            if let tags = tags {
                try container.encode(tags, forKey: .tags)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case branches
            case tags
        }
    }
}
