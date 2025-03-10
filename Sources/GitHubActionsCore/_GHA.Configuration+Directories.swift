//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge

extension _GHA.Configuration {
    private static var packageRootDirectory: URL {
        if let packageRootURL = findPackageRoot(from: mainCommandFileURL) {
            return packageRootURL
        } else {
            return mainCommandFileURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        }
    }
    
    public static var repositoryRootDirectory: URL {
        packageRootDirectory
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
    
    public static var workflowOutputDirectory: URL {
        return packageRootDirectory.deletingLastPathComponent()
    }
    
    public static var actionOutputDirectory: URL {
        return packageRootDirectory
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(.directory("generated-actions"))
    }
    
    public static var packageName: String {
        return packageRootDirectory.lastPathComponent.replacingOccurrences(of: " ", with: "-")
    }
    
    private static func findPackageRoot(from fileURL: URL) -> URL? {
        var currentURL = fileURL.deletingLastPathComponent()
        while !FileManager.default.fileExists(atPath: currentURL.appendingPathComponent("Package.swift").path) {
            let parentURL = currentURL.deletingLastPathComponent()
            if parentURL.pathComponents.count <= 1 {
                return nil
            }
            currentURL = parentURL
        }
        return currentURL
    }
}
