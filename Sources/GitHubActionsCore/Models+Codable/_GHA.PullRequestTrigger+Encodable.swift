//
// Copyright (c) Vatsal Manot
//

import Foundation

extension _GHA.Triggers.PullRequestTrigger: Encodable {
    private enum CodingKeys: String, CodingKey {
        case branches
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(branches, forKey: .branches)
    }
}
