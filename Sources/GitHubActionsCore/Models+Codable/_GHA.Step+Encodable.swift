//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

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
        case environment = "env"
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
        if let environment = environment, !environment.isEmpty {
            try container.encode(OrderedDictionaryWrapper(environment), forKey: .environment)
        }
        try container.encodeIfPresent(run, forKey: .run)
    }
}
