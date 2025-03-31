// Copyright (c) Vatsal Manot
//

import Foundation
import _GitHubActionsTypes

public extension _GHA.Step {
    /// Creates a step to check Swift version
    /// - Returns: A step that runs the Swift version command
    static func checkSwiftVersion() -> Self {
        .init(
            name: "Get swift version",
            run: "swift --version"
        )
    }
    
    /// Creates a step to check macOS version
    /// - Returns: A step that runs the macOS version command
    static func checkMacOSVersion() -> Self {
        .init(
            name: "Check macOS Version",
            shell: "bash",
            run: "sw_vers"
        )
    }
    
    /// Creates a step to check Xcode version
    /// - Returns: A step that runs the Xcode version command
    static func checkXcodeVersion() -> Self {
        .init(
            name: "Check Xcode Version",
            shell: "bash",
            run: "xcodebuild -version"
        )
    }
    
    /// Creates a step to check available SDKs
    /// - Returns: A step that lists available SDKs
    static func checkAvailableSDKs() -> Self {
        .init(
            name: "Check Available SDKs",
            shell: "bash",
            run: "xcodebuild -showsdks"
        )
    }
    
    /// Creates a step to fail with a custom message
    /// - Parameters:
    ///   - message: Error message
    ///   - ifCondition: Condition to determine if the step should run
    /// - Returns: A step that fails with a custom message
    static func failWithMessage(
        message: String,
        ifCondition: String? = nil
    ) -> Self {
        .init(
            name: "Fail with error",
            if: ifCondition != nil ? .plain(ifCondition!) : nil,
            shell: "bash",
            run: .multiline("""
            echo "::error::\(message)"
            exit 1
            """)
        )
    }
} 