// Copyright (c) Vatsal Manot
//

import Foundation
import OrderedCollections
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to restore the Derived Data cache
    /// - Parameters:
    ///   - provider: Cache provider ("actions" or "cirruslabs")
    ///   - key: Primary cache key
    ///   - restoreKeys: Additional keys to try for restoration
    /// - Returns: A step that restores the Derived Data cache
    static func restoreDerivedDataCache(
        provider: String = "cirruslabs",
        key: String = "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}",
        restoreKeys: String = "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data"
    ) -> Self {
        let providerAction = provider == "cirruslabs" 
            ? "cirruslabs/cache/restore@v4"
            : "actions/cache/restore@v4"
        
        return .init(
            name: "Restore DerivedData Cache",
            uses: .plain(providerAction),
            with: [
                "path": .doubleQuoted("~/Library/Developer/Xcode/DerivedData"),
                "key": .plain(key),
                "restore-keys": .multiline(restoreKeys)
            ]
        )
    }
    
    /// Creates a step to save the Derived Data cache
    /// - Parameters:
    ///   - ifCondition: Optional condition to determine if the step should run
    ///   - provider: Cache provider ("actions" or "cirruslabs")
    ///   - key: Cache key
    /// - Returns: A step that saves the Derived Data cache
    static func saveDerivedDataCache(
        ifCondition: String? = nil,
        provider: String = "cirruslabs",
        key: String = "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}"
    ) -> Self {
        let providerAction = provider == "cirruslabs" 
            ? "cirruslabs/cache/save@v4"
            : "actions/cache/save@v4"
        
        return .init(
            name: "Save DerivedData Cache",
            if: ifCondition != nil ? .plain(ifCondition!) : nil,
            uses: .plain(providerAction),
            with: [
                "path": .doubleQuoted("~/Library/Developer/Xcode/DerivedData"),
                "key": .plain(key)
            ]
        )
    }
    
    /// Creates a step to check build status and fail if necessary
    /// - Parameter ifCondition: Condition to determine if the step should run
    /// - Returns: A step that checks the build status
    static func checkBuildStatusAndFail(
        ifCondition: String
    ) -> Self {
        .init(
            name: "Check build status and fail if necessary",
            if: .plain(ifCondition),
            shell: "bash",
            run: .multiline("""
            echo "::error::Build failed earlier in the workflow"
            exit 1
            """)
        )
    }
} 
