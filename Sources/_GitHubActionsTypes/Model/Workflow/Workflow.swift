//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct Workflow: Encodable {
    public let name: String
    public let on: TriggerEvents
    public let jobs: [String: Job]
    public let env: [String: String]?

    public init(
        name: String,
        on: TriggerEvents,
        jobs: [String: Job],
        env: [String: String]? = nil
    ) {
        self.name = name
        self.on = on
        self.jobs = jobs
        self.env = env
    }
}
