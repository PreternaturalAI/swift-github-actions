//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Action {
    enum InputType: String, Encodable {
        case boolean
        case string
        case number
    }
    
    struct Input: Equatable {
        public let description: _GHA.YAMLString?
        public let required: Bool?
        public let defaultValue: _GHA.YAMLString?
        public let type: InputType?

        public init(
            description: _GHA.YAMLString? = nil,
            required: Bool? = nil,
            defaultValue: _GHA.YAMLString? = nil,
            type: InputType? = nil
        ) {
            self.description = description
            self.required = required
            self.defaultValue = defaultValue
            self.type = type
        }
    }
}

extension _GHA.Action.Input: Encodable {
    private enum CodingKeys: String, CodingKey {
        case description
        case required
        case defaultValue = "default"
        case type
    }
}
