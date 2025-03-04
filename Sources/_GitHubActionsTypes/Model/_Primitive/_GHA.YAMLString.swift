//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    enum YAMLStringType: Equatable {
        case plain
        case multiline
        case doubleQuoted
        case singleQuoted
    }
}

public extension _GHA {
    struct YAMLString: Equatable {
        public let value: String
        public let type: YAMLStringType

        public init(
            value: String,
            type: YAMLStringType = .plain
        ) {
            self.value = value
            self.type = type
        }

        public init(
            _ value: String,
            _ type: YAMLStringType = .plain
        ) {
            self.value = value
            self.type = type
        }
    }
}

extension _GHA.YAMLStringType: Encodable {}

extension _GHA.YAMLString: Encodable {}
