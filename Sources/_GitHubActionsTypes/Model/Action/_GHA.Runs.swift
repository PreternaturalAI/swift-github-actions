//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Action {
    struct Runs: Equatable {
        public let using: _GHA.YAMLString
        public let steps: [_GHA.Step]?
        public let main: String?
        public let pre: String?
        public let post: String?

        public init(
            using: _GHA.YAMLString,
            steps: [_GHA.Step]? = nil,
            main: String? = nil,
            pre: String? = nil,
            post: String? = nil
        ) {
            self.using = using
            self.steps = steps
            self.main = main
            self.pre = pre
            self.post = post
        }
    }
}

extension _GHA.Action.Runs: Encodable {}
