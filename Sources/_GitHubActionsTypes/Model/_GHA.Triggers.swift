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

        public init(_ triggers: [Trigger]) {
            var push: PushTrigger?
            var pullRequest: PullRequestTrigger?
            var workflowDispatch: Bool?

            for trigger in triggers {
                switch trigger {
                case .push(let branches, let tags):
                    if let existing = push {
                        let newBranches = branches != nil ? (branches! + (existing.branches ?? [])) : nil
                        let newTags = tags != nil ? (tags! + (existing.tags ?? [])) : nil
                        push = PushTrigger(branches: newBranches, tags: newTags)
                    } else {
                        push = PushTrigger(branches: branches, tags: tags)
                    }
                case .pullRequest(let branches):
                    if let existing = pullRequest {
                        let newBranches = branches != nil ? (branches! + (existing.branches ?? [])) : nil
                        pullRequest = PullRequestTrigger(branches: newBranches)
                    } else {
                        pullRequest = PullRequestTrigger(branches: branches)
                    }
                case .workflowDispatch:
                    workflowDispatch = true
                }
            }

            self.init(push: push, pullRequest: pullRequest, workflowDispatch: workflowDispatch)
        }
    }
}

public extension _GHA {
    enum Trigger: Equatable {
        case push(branches: [_GHA.FormattedValue]? = nil, tags: [_GHA.FormattedValue]? = nil)
        case pullRequest(branches: [_GHA.FormattedValue]? = nil)
        case workflowDispatch
    }
}

extension _GHA.Triggers: ExpressibleByArrayLiteral {
    public init(arrayLiteral triggers: _GHA.Trigger...) {
        self.init(Array(triggers))
    }
}
