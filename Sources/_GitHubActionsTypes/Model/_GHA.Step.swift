//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Step: Equatable {
        public let name: FormattedValue?
        public let `if`: FormattedValue?
        public let continueOnError: Bool?
        public let id: FormattedValue?
        public let uses: FormattedValue?
        public let shell: FormattedValue?
        public let with: OrderedDictionary<String, FormattedValue>?
        public let workingDirectory: FormattedValue?
        public let env: OrderedDictionary<String, FormattedValue>?
        public let run: FormattedValue?
        
        public init(
            name: FormattedValue? = nil,
            if: FormattedValue? = nil,
            continueOnError: Bool? = nil,
            id: FormattedValue? = nil,
            uses: FormattedValue? = nil,
            shell: FormattedValue? = nil,
            with: OrderedDictionary<String, FormattedValue>? = nil,
            workingDirectory: FormattedValue? = nil,
            env: OrderedDictionary<String, FormattedValue>? = nil,
            run: FormattedValue? = nil
        ) {
            self.name = name
            self.if = `if`
            self.continueOnError = continueOnError
            self.id = id
            self.uses = uses
            self.shell = shell
            self.with = with
            self.workingDirectory = workingDirectory
            self.env = env
            self.run = run
        }
    }
}
