//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation

extension WorkflowLocalRunner {
    static func updateEnvironmentPath() async throws {
        // Get current user's home directory
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        
        // Common Node.js installation paths
        let commonNodePaths = [
            "\(homeDirectory)/.asdf/shims",           // ASDF version manager
            "\(homeDirectory)/.nvm/versions/node",    // NVM version manager
            "\(homeDirectory)/.n",                    // N version manager
            "\(homeDirectory)/.local/bin",            // Local bin directory
            "/usr/local/bin",                         // System-wide local bin
            "/opt/homebrew/bin",                      // Homebrew on Apple Silicon
            "/usr/local/opt/node/bin",                // Homebrew Node.js
            "/opt/homebrew/opt/node/bin"              // Homebrew Node.js (Apple Silicon)
        ]
        
        // Filter to only include paths that exist
        let existingPaths = commonNodePaths.filter { path in
            FileManager.default.fileExists(atPath: path)
        }
        
        // If we found any existing paths, update the PATH environment variable
        if !existingPaths.isEmpty {
            if let originalPath = ProcessInfo.processInfo.environment["PATH"] {
                let newPath = originalPath + ":" + existingPaths.joined(separator: ":")
                setenv("PATH", newPath, 1)
            }
        }
    }
}

