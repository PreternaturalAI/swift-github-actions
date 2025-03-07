//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    enum FormattedValue: RawRepresentable, Equatable {
        public typealias RawValue = String

        case plain(String)
        case singleQuoted(String)
        case doubleQuoted(String)
        case multiline(String)
        case boolean(Bool)
        case float(Float)
        case integer(Int)

        public init?(rawValue: String) {
            self = .plain(rawValue)
        }

        public var rawValue: String {
            switch self {
            case .plain(let string),
                 .singleQuoted(let string),
                 .doubleQuoted(let string),
                 .multiline(let string):
                return string
            case .boolean(let value):
                return "\(value)"
            case .float(let value):
                return "\(value)"
            case .integer(let value):
                return "\(value)"
            }
        }
    }
}

// MARK: - String Literal Support

extension _GHA.FormattedValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .plain(value)
    }
}

// MARK: - Boolean Literal Support

extension _GHA.FormattedValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

// MARK: - Float Literal Support

extension _GHA.FormattedValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Float) {
        self = .float(value)
    }
}

// MARK: - Integer Literal Support

extension _GHA.FormattedValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}
