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
