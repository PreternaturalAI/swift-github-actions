//
// Copyright (c) Vatsal Manot
//

import CorePersistence

extension _GHA.Action {
    private var yamlSHA: String {
        let sha256Hash = _PersistentTextHash.compute(for: self.name.rawValue).rawValue
        return String(sha256Hash.suffix(7))
    }
    
    public var yamlFileName: String {
        _GHA.Configuration.packageName + "-" + yamlSHA + ".yml"
    }
    
    public var yamlOutputURL: URL {
        _GHA.Configuration.actionOutputDirectory.appending(.file(yamlFileName))
    }
}
