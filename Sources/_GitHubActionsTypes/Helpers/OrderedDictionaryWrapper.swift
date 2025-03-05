//
// Copyright (c) Vatsal Manot
//

import OrderedCollections

struct OrderedDictionaryWrapper<Value: Encodable>: Encodable {
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
            
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
            
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    let dictionary: OrderedDictionary<String, Value>
            
    init(_ dictionary: OrderedDictionary<String, Value>) {
        self.dictionary = dictionary
    }
            
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        
        for (key, value) in dictionary {
            if let dynamicKey = DynamicCodingKeys(stringValue: key) {
                try container.encode(value, forKey: dynamicKey)
            }
        }
    }
}
