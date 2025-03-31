// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections
import _GitHubActionsTypes

public extension _GHA.Step {    
    /// Creates a step to upload logs
    /// - Parameter zipName: Optional name for the log zip file
    /// - Returns: A step that uploads logs
    static func uploadLogs(zipName: String? = nil) -> Self {
        var with: OrderedDictionary<String, _GHA.FormattedValue>? = nil
        
        if let zipName = zipName {
            with = [
                "zip-name": .singleQuoted(zipName)
            ]
        }
        
        return .init(
            name: "Upload logs",
            if: "success() || failure()",
            uses: "PreternaturalAI/preternatural-github-actions/preternatural-upload-logs@main",
            with: with
        )
    }
    
    /// Creates a step to upload notarized app
    /// - Returns: A step that uploads a notarized app
    static func uploadNotarizedApp() -> Self {
        .init(
            name: "Upload Notarized App as artifact",
            if: "steps.archive.outputs.archive_succeeded == 'true'",
            uses: "actions/upload-artifact@v4",
            with: [
                "name": "Notarized-App",
                "path": .singleQuoted("**/*Notarized.zip"),
                "if-no-files-found": "error"
            ]
        )
    }
} 
