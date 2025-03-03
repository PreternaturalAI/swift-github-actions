//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct Job: Encodable {
    private enum CodingKeys: String, CodingKey {
        case runsOn = "runs-on"
        case steps
        case needs
        case env
    }

    public let runsOn: String?
    public let steps: [Step]
    public let needs: [String]?
    public let env: [String: String]?

    public init(
        runsOn: String? = nil,
        steps: [Step],
        needs: [String]? = nil,
        env: [String: String]? = nil
    ) {
        self.runsOn = runsOn
        self.steps = steps
        self.needs = needs
        self.env = env
    }
}
