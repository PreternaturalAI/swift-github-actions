//
// Copyright (c) Vatsal Manot
//

import CorePersistence

extension _GHA.Workflow {
    private var yamlSHA: String {
        let sha256Hash = _PersistentTextHash.compute(for: self.name.rawValue).rawValue
        return String(sha256Hash.suffix(7))
    }
    
    public var yamlFileName: String {
        _GHA.Configuration.packageName + "-" + yamlSHA + ".yml"
    }
    
    public var yamlOutputURL: URL {
        _GHA.Configuration.workflowOutputDirectory.appending(.file(yamlFileName))
    }

    public var tempYamlFileName: String {
        _GHA.Configuration.packageName + "-temp-" + yamlSHA + ".yml"
    }
    
    public var tempYamlOutputURL: URL {
        _GHA.Configuration.workflowOutputDirectory.appending(.file(tempYamlFileName))
    }
}
