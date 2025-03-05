//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    struct Triggers: Equatable {
        public let push: PushTrigger?
        public let pullRequest: PullRequestTrigger?
        public let workflowDispatch: Bool?
        
        public init(
            push: PushTrigger? = nil,
            pullRequest: PullRequestTrigger? = nil,
            workflowDispatch: Bool? = nil
        ) {
            self.push = push
            self.pullRequest = pullRequest
            self.workflowDispatch = workflowDispatch
        }
    }
}

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
            let emptyString = _GHA.YAMLString("", .plain)
            try container.encode(emptyString, forKey: .workflowDispatch)
        }
    }
}
