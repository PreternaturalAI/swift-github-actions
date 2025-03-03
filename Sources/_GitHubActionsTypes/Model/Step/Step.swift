//
// Copyright (c) Vatsal Manot
//

import Foundation

public struct Step: Encodable {
    public let name: String?
    public let uses: String?
    public let run: String?
    public let with: [String: String]?
    public let env: [String: String]?

    public init(
        name: String? = nil,
        uses: String? = nil,
        run: String? = nil,
        with: [String: String]? = nil,
        env: [String: String]? = nil
    ) {
        self.name = name
        self.uses = uses
        self.run = run
        self.with = with
        self.env = env
    }
}
