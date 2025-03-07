//
// Copyright (c) Vatsal Manot
//

import Foundation

extension _GHA.Triggers: Encodable {
    private enum CodingKeys: String, CodingKey {
        case push
        case pullRequest = "pull_request"
        case workflowDispatch = "workflow_dispatch"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(push, forKey: .push)
        try container.encodeIfPresent(pullRequest, forKey: .pullRequest)
        if let _ = workflowDispatch {
            try container.encode(_GHA.FormattedValue.plain(""), forKey: .workflowDispatch)
        }
    }
}
