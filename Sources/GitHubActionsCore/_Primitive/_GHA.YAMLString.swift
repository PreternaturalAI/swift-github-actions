//
// Copyright (c) Vatsal Manot
//

import Foundation
import Yams

extension _GHA.YAMLString: YAMLEncodable {
    public func box() -> Node {
        var node = Node(stringLiteral: self.value)
        
        switch self.type {
        case .plain:
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

extension String {
    public var toYamlString: _GHA.YAMLString {
        return _GHA.YAMLString(self)
    }
    
    public func toYamlString(_ type: _GHA.YAMLStringType) -> _GHA.YAMLString {
        return _GHA.YAMLString(value: self, type: type)
    }
}
