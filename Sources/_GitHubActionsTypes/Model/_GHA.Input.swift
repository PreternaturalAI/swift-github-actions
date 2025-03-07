//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Action {
    struct Input: Equatable {
        public let description: _GHA.FormattedValue?
        public let required: Bool?
        public let defaultValue: _GHA.FormattedValue?
        public let type: _GHA.FormattedValue?

        public init(
            description: _GHA.FormattedValue? = nil,
            required: Bool? = nil,
            defaultValue: _GHA.FormattedValue? = nil,
            type: _GHA.FormattedValue? = nil
        ) {
            self.description = description
            self.required = required
            self.defaultValue = defaultValue
            self.type = type
        }
    }
}
