//
// Copyright (c) Vatsal Manot
//

import Foundation

extension _GHA.Action.Runs: Encodable {
    private enum CodingKeys: String, CodingKey {
        case using
        case steps
        case main
        case pre
        case post
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(using, forKey: .using)
        try container.encodeIfPresent(steps, forKey: .steps)
        try container.encodeIfPresent(main, forKey: .main)
        try container.encodeIfPresent(pre, forKey: .pre)
        try container.encodeIfPresent(post, forKey: .post)
    }
}
