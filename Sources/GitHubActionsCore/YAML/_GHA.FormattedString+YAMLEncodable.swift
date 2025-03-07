//
// Copyright (c) Vatsal Manot
//

import Foundation
import Yams

extension _GHA.FormattedValue: YAMLEncodable {
    public func box() -> Node {
        var node = Node(stringLiteral: self.rawValue)
        
        switch self {
        case .plain, .boolean, .float, .integer:
            node.scalar?.style = .plain
        case .multiline:
            node.scalar?.style = .literal
        case .doubleQuoted:
            node.scalar?.style = .doubleQuoted
        case .singleQuoted:
            node.scalar?.style = .singleQuoted
        }
        
        return node
    }
}
