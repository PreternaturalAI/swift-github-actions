//
// Copyright (c) Vatsal Manot
//

import Foundation

extension _GHA.Triggers.PushTrigger: Encodable {
    private enum CodingKeys: String, CodingKey {
        case branches
        case tags
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(branches, forKey: .branches)
        try container.encodeIfPresent(tags, forKey: .tags)
    }
}
