//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA {
    struct Step: Equatable {
        public let name: YAMLString?
        public let `if`: YAMLString?
        public let continueOnError: Bool?
        public let id: YAMLString?
        public let uses: YAMLString?
        public let shell: YAMLString?
        public let with: OrderedDictionary<String, YAMLString>?
        public let workingDirectory: YAMLString?
        public let env: OrderedDictionary<String, YAMLString>?
        public let run: YAMLString?
        
        public init(
            name: YAMLString? = nil,
            if: YAMLString? = nil,
            continueOnError: Bool? = nil,
            id: YAMLString? = nil,
            uses: YAMLString? = nil,
            shell: YAMLString? = nil,
            with: OrderedDictionary<String, YAMLString>? = nil,
            workingDirectory: YAMLString? = nil,
            env: OrderedDictionary<String, YAMLString>? = nil,
            run: YAMLString? = nil
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

extension _GHA.Step: Encodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case `if`
        case continueOnError = "continue-on-error"
        case id
        case uses
        case shell
        case with
        case workingDirectory = "working-directory"
        case env
        case run
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(`if`, forKey: .`if`)
        try container.encodeIfPresent(continueOnError, forKey: .continueOnError)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(uses, forKey: .uses)
        try container.encodeIfPresent(shell, forKey: .shell)
        if let with = with, !with.isEmpty {
            try container.encode(OrderedDictionaryWrapper(with), forKey: .with)
        }
        try container.encodeIfPresent(workingDirectory, forKey: .workingDirectory)
        if let env = env, !env.isEmpty {
            try container.encode(OrderedDictionaryWrapper(env), forKey: .env)
        }
        try container.encodeIfPresent(run, forKey: .run)
    }
}
