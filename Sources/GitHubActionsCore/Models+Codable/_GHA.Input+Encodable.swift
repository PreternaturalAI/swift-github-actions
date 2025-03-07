//
// Copyright (c) Vatsal Manot
//

import Foundation

extension _GHA.Action.Input: Encodable {
    private enum CodingKeys: String, CodingKey {
        case description
        case required
        case defaultValue = "default"
        case type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(required, forKey: .required)
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
