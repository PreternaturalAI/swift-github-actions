//
// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections

public extension _GHA.Job {
    struct Strategy: Equatable {
        public let matrix: OrderedDictionary<String, [_GHA.FormattedValue]>?

        public init(matrix: OrderedDictionary<String, [_GHA.FormattedValue]>? = nil) {
            self.matrix = matrix
        }
    }
}
