//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA {
    struct Triggers: Encodable {
        public let push: PushTrigger?
        public let pullRequest: PullRequestTrigger?
        public let workflowDispatch: Bool?
        
        private enum CodingKeys: String, CodingKey {
            case push
            case pullRequest = "pull_request"
            case workflowDispatch = "workflow_dispatch"
        }
        
        public init(
            push: PushTrigger? = nil,
            pullRequest: PullRequestTrigger? = nil,
            workflowDispatch: Bool? = nil
        ) {
            self.push = push
            self.pullRequest = pullRequest
            self.workflowDispatch = workflowDispatch
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Encode push if present
            if let push = push {
                try container.encode(push, forKey: .push)
            }
            
            // Encode pull_request if present
            if let pullRequest = pullRequest {
                try container.encode(pullRequest, forKey: .pullRequest)
            }
            
            // Encode workflow_dispatch as empty object {} if true
            if let workflowDispatch = workflowDispatch, workflowDispatch {
                try container.encode([String: String](), forKey: .workflowDispatch)
            }
        }
    }
}
