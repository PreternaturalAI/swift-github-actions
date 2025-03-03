//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Action {
    struct Input: Encodable {
        public let description: String?
        public let required: Bool?
        public let defaultValue: String?
        public let type: InputType?

        private enum CodingKeys: String, CodingKey {
            case description
            case required
            case defaultValue = "default"
            case type
        }

        public init(
            description: String? = nil,
            required: Bool? = nil,
            defaultValue: String? = nil,
            type: InputType? = nil
        ) {
            self.description = description
            self.required = required
            self.defaultValue = defaultValue
            self.type = type
        }
    }

    enum InputType: String, Encodable {
        case boolean
        case string
        case number
    }
}
