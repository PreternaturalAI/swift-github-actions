//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA.Job {
    struct Strategy: Equatable {
        public let matrix: OrderedDictionary<String, [_GHA.YAMLString]>?

        public init(matrix: OrderedDictionary<String, [_GHA.YAMLString]>? = nil) {
            self.matrix = matrix
        }
    }
}

extension _GHA.Job.Strategy: Encodable {
    private enum CodingKeys: String, CodingKey {
        case matrix
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let matrix = matrix, !matrix.isEmpty {
            try container.encode(OrderedDictionaryWrapper(matrix), forKey: .matrix)
        }
    }
}
