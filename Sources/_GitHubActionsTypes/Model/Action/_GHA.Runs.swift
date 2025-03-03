//
// Copyright (c) Vatsal Manot
//

import Foundation

public extension _GHA.Action {
    typealias Step = _GHA.Step
    
    struct Runs: Encodable {
        public let using: String
        public let steps: [Step]?
        public let main: String?
        public let pre: String?
        public let post: String?
        
        public init(
            using: String,
            steps: [Step]? = nil,
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
        
        public static func composite(steps: [Step]) -> Self {
            Runs(using: "composite", steps: steps)
        }
    }
}
