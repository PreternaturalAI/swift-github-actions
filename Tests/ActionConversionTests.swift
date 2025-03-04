//
// Copyright (c) Vatsal Manot
//

import _GitHubActionsTypes
import Foundation
import GitHubActionsCLT
import GitHubActionsCore
import Testing
import Yams

@Suite("Action Conversion Tests", .serialized)
@MainActor
struct ActionConversionTests {

    @Test("Test Action 1 Conversion")
    func testAction1Conversion() throws {
        let action = _GHA.Action(
            name: "Authorize GitHub".toYamlString,
            description: "Authorizes GitHub so that further commands can access all internal Preternatural repositories.\n".toYamlString(.multiline),
            runs: _GHA.Action.Runs(
                using: "composite".toYamlString(.singleQuoted),
                steps: [
                    _GHA.Step(
                        name: "Load Secrets from 1Password".toYamlString,
                        uses: "1password/load-secrets-action@v2".toYamlString,
                        with: [
                            "export-env": "true".toYamlString
                        ],
                        env: [
                            "OP_SERVICE_ACCOUNT_TOKEN": "sample_token".toYamlString(.doubleQuoted),
                            "GITHUB_PAT": "op://abc/abc/credential".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Setup PAT for Private Repos".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        {
                          git config --global url."https://$GITHUB_PAT@github.com/".insteadOf "https://github.com/"
                        } > /dev/null 2>&1
                        """.toYamlString(.multiline)
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-1")
    }
    
    @Test("Test Action 2 Conversion")
    func testAction2Conversion() throws {
        let action = _GHA.Action(
            name: "Preternatural Upload Logs Action".toYamlString(.singleQuoted),
            description: "Processes and uploads logs from the default derived data path".toYamlString(.singleQuoted),
            inputs: [
                "zip-name": _GHA.Action.Input(
                    description: "Name of the final log zip file (without .zip extension)".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "".toYamlString(.singleQuoted)
                )
            ],
            runs: _GHA.Action.Runs(
                using: "composite".toYamlString(.singleQuoted),
                steps: [
                    _GHA.Step(
                        name: "Cleanup previous runs".toYamlString,
                        shell: "bash".toYamlString,
                        run: "rm -rf ./logs\n".toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Find logs".toYamlString,
                        continueOnError: true,
                        shell: "bash".toYamlString,
                        run: """
                        DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
                        echo "Searching for logs in: $DERIVED_DATA_PATH"
                        
                        mkdir -p ./logs
                        
                        # Find and copy xcresult bundles
                        find "$DERIVED_DATA_PATH" -name "*.xcresult" -type d -print0 | while IFS= read -r -d '' result; do
                          cp -R "$result" "./logs"
                          echo "Copied $result to ./logs"
                        done
                        
                        # Check if any logs were found and copied
                        if [ -z "$(ls -A ./logs)" ]; then
                          echo "No log files found in $DERIVED_DATA_PATH"
                          exit 1
                        fi
                        
                        # Create zip archive with dynamic name
                        cd ./logs
                        if [ -n "${{ inputs.zip-name }}" ]; then
                          ZIP_NAME="${{ inputs.zip-name }}.zip"
                        else
                          TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                          ZIP_NAME="logs-${TIMESTAMP}.zip"
                        fi
                        zip -r "../$ZIP_NAME" ./*
                        cd ..
                        
                        # Set output path for upload step
                        echo "ZIP_PATH=$ZIP_NAME" >> $GITHUB_ENV
                        # Set artifact name (zip name without extension) for upload step
                        echo "ARTIFACT_NAME=${ZIP_NAME%.zip}" >> $GITHUB_ENV
                        
                        # Clean up Logs and ResultBundle folders in DerivedData
                        echo "Cleaning up Logs and ResultBundle folders in DerivedData..."
                        find "$DERIVED_DATA_PATH" -type d -name "Logs" -exec rm -rf {} +
                        find "$DERIVED_DATA_PATH" -type d -name "ResultBundle" -exec rm -rf {} +
                        echo "Cleanup completed"
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Upload logs".toYamlString,
                        continueOnError: true,
                        uses: "actions/upload-artifact@v4".toYamlString,
                        with: [
                            "name": "${{ env.ARTIFACT_NAME }}".toYamlString,
                            "path": "${{ env.ZIP_PATH }}".toYamlString
                        ]
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-2")
    }
    
    @Test("Test Action 3 Conversion")
    func testAction3Conversion() throws {
        let action = _GHA.Action(
            name: "Preternatural Build Action".toYamlString(.singleQuoted),
            description: "Run Preternatural build command on repositories with a specified Xcode version".toYamlString(.singleQuoted),
            inputs: [
                "xcode-version": _GHA.Action.Input(
                    description: "Xcode version to use".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "latest-stable".toYamlString(.singleQuoted)
                ),
                "platforms": _GHA.Action.Input(
                    description: "Target platforms (array of: iOS, macOS, tvOS, watchOS, visionOS, all)".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: """
                    ["macOS"]
                    """.toYamlString(.singleQuoted)
                ),
                "configurations": _GHA.Action.Input(
                    description: "Build configurations (array of: debug, release)".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: """
                    ["debug"]
                    """.toYamlString(.singleQuoted)
                ),
                "working-directory": _GHA.Action.Input(
                    description: "Directory to run the preternatural command from".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "".toYamlString(.singleQuoted)
                ),
                "fuck-swift-syntax": _GHA.Action.Input(
                    description: "Enable the --fuck-swift-syntax flag for the build command".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "true".toYamlString,
                    type: .boolean
                )
            ],
            runs: _GHA.Action.Runs(
                using: "composite".toYamlString(.singleQuoted),
                steps: [
                    _GHA.Step(
                        name: "Setup Xcode".toYamlString,
                        uses: "maxim-lobanov/setup-xcode@v1".toYamlString,
                        with: [
                            "xcode-version": "${{ inputs.xcode-version }}".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Check macOS Version".toYamlString,
                        shell: "bash".toYamlString,
                        run: "sw_vers".toYamlString
                    ),
                    _GHA.Step(
                        name: "Check Xcode Version".toYamlString,
                        shell: "bash".toYamlString,
                        run: "xcodebuild -version".toYamlString
                    ),
                    _GHA.Step(
                        name: "Check Available SDKs".toYamlString,
                        shell: "bash".toYamlString,
                        run: "xcodebuild -showsdks".toYamlString
                    ),
                    _GHA.Step(
                        name: "Install Preternatural".toYamlString,
                        if: "${{ !env.ACT }}".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        echo "::group::Installing Preternatural via Homebrew"
                        brew tap PreternaturalAI/preternatural
                        brew install preternatural
                        echo "::endgroup::"
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Restore DerivedData Cache".toYamlString,
                        uses: "cirruslabs/cache/restore@v4".toYamlString,
                        with: [
                            "path": "~/Library/Developer/Xcode/DerivedData".toYamlString(.doubleQuoted),
                            "key": "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}".toYamlString,
                            "restore-keys": """
                            ${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data
                            """.toYamlString(.multiline)
                        ]
                    ),
                    _GHA.Step(
                        name: "Execute preternatural build command".toYamlString,
                        continueOnError: true,
                        id: "build".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        echo "::group::Preparing Build Command"
                        PLATFORMS=$(echo '${{ inputs.platforms }}' | tr -d '[]' | sed 's/, /,/g')
                        CONFIGURATIONS=$(echo '${{ inputs.configurations }}' | tr -d '[]' | sed 's/, /,/g')

                        # Change directory if working-directory is provided
                        if [ ! -z "${{ inputs.working-directory }}" ]; then
                          cd "${{ inputs.working-directory }}"
                          echo "Changed working directory to: ${{ inputs.working-directory }}"
                        fi

                        # Construct the command as a string
                        PRETERNATURAL_CMD="script -q /dev/null preternatural build --platforms $PLATFORMS --configurations $CONFIGURATIONS --update-developer-team"
                        if [ "${{ inputs.fuck-swift-syntax }}" == "true" ]; then
                          PRETERNATURAL_CMD="$PRETERNATURAL_CMD --fuck-swift-syntax"
                        fi

                        echo "Prepared command: ${PRETERNATURAL_CMD}"
                        echo "::endgroup::"

                        echo "::group::First Build Attempt"
                        # First attempt
                        set +e  # Don't exit on error
                        eval ${PRETERNATURAL_CMD} 2>&1
                        BUILD_STATUS=$?
                        set -e  # Return to exit on error
                        echo "::endgroup::"

                        if [ $BUILD_STATUS -ne 0 ]; then
                          echo "::group::Cleaning DerivedData and Retrying"
                          echo "First build attempt failed (status: $BUILD_STATUS). Cleaning derived data and retrying..."
                          rm -rf "$DERIVED_DATA_PATH"
                          echo "Cleaned derived data"
                          echo "::endgroup::"

                          echo "::group::Second Build Attempt"
                          # Second attempt
                          eval ${PRETERNATURAL_CMD} 2>&1
                          RETRY_STATUS=$?
                          echo "::endgroup::"

                          if [ $RETRY_STATUS -ne 0 ]; then
                            echo "::error::Second build attempt failed (status: $RETRY_STATUS) after cleaning derived data. Failing the workflow."
                            exit 1
                          fi
                        fi

                        echo "build_succeeded=true" >> $GITHUB_OUTPUT
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Upload logs".toYamlString,
                        uses: "PreternaturalAI/preternatural-github-actions/preternatural-upload-logs@main".toYamlString
                    ),
                    _GHA.Step(
                        name: "Save DerivedData Cache".toYamlString,
                        if: "steps.build.outputs.build_succeeded == 'true'".toYamlString,
                        uses: "cirruslabs/cache/save@v4".toYamlString,
                        with: [
                            "path": "~/Library/Developer/Xcode/DerivedData".toYamlString(.doubleQuoted),
                            "key": "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Check build status and fail if necessary".toYamlString,
                        if: "steps.build.outputs.build_succeeded != 'true'".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        echo "::error::Build failed earlier in the workflow"
                        exit 1
                        """.toYamlString(.multiline)
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-3")
    }

    @Test("Test Action 4 Conversion")
    func testAction4Conversion() throws {
        let action = _GHA.Action(
            name: "Preternatural Release Plugin".toYamlString,
            description: """
            Updates the url and SHA of the binary target in the given Plugin Package repository
            """.toYamlString(.multiline),
            inputs: [
                "homebrew-repository": _GHA.Action.Input(
                    description: "Homebrew Repository from which to lookup the command line tools".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "PreternaturalAI/homebrew-preternatural".toYamlString(.singleQuoted)
                ),
                "plugin-package-repository": _GHA.Action.Input(
                    description: "Plugin Package Repository to update".toYamlString(.singleQuoted),
                    required: true
                ),
                "tool-name": _GHA.Action.Input(
                    description: "Name of the command line tool".toYamlString(.singleQuoted),
                    required: true
                )
            ],
            runs: _GHA.Action.Runs(
                using: "composite".toYamlString(.singleQuoted),
                steps: [
                    _GHA.Step(
                        name: "Load Secrets From 1Password and Export Environment Variables".toYamlString,
                        uses: "1password/load-secrets-action@v2".toYamlString,
                        with: [
                            "export-env": "true".toYamlString
                        ],
                        env: [
                            "OP_SERVICE_ACCOUNT_TOKEN": "token".toYamlString(.doubleQuoted),
                            "GITHUB_PAT": "op://abc/abc/abc".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Setup PAT for Private Repos".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        {
                          git config --global url."https://$GITHUB_PAT@github.com/".insteadOf "https://github.com/"
                        } > /dev/null 2>&1
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Fetch URL and SHA".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        # Clone homebrew repository
                        git clone https://github.com/${{ inputs.homebrew-repository }}.git homebrew-repo
                        
                        # Check if tool file exists
                        if [ ! -f "homebrew-repo/${{ inputs.tool-name }}.rb" ]; then
                          echo "Error: ${{ inputs.tool-name }}.rb not found in ${{ inputs.homebrew-repository }}"
                          exit 1
                        fi
                        
                        # Extract URL and SHA
                        URL=$(grep "url" "homebrew-repo/${{ inputs.tool-name }}.rb" | cut -d '"' -f 2)
                        SHA=$(grep "sha256" "homebrew-repo/${{ inputs.tool-name }}.rb" | cut -d '"' -f 2)
                        
                        if [ -z "$URL" ] || [ -z "$SHA" ]; then
                          echo "Error: Could not extract URL and SHA from ${{ inputs.tool-name }}.rb"
                          exit 1
                        fi
                        
                        echo "Successfully extracted URL and SHA:"
                        echo "URL: $URL"
                        echo "SHA: $SHA"
                        
                        # Export for next steps
                        echo "TOOL_URL=$URL" >> $GITHUB_ENV
                        echo "TOOL_SHA=$SHA" >> $GITHUB_ENV
                        
                        # Cleanup: Remove the homebrew repository
                        rm -rf homebrew-repo
                        echo "Cleaned up homebrew repository"
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Update Package.swift".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        # Clone plugin package repository
                        git clone https://github.com/${{ inputs.plugin-package-repository }}.git plugin-repo
                        cd plugin-repo
                        
                        # Check if Package.swift exists
                        if [ ! -f "Package.swift" ]; then
                          echo "Error: Package.swift not found in ${{ inputs.plugin-package-repository }}"
                          exit 1
                        fi
                        
                        # Check if binary target exists
                        if ! grep -A 3 "\\.binaryTarget(" Package.swift | grep -q "name: \\"${{ inputs.tool-name }}\\""; then
                          echo "Error: Binary target '${{ inputs.tool-name }}' not found in Package.swift"
                          exit 1
                        fi
                        
                        # Update binary target URL and checksum
                        awk -v name="${{ inputs.tool-name }}" -v url="$TOOL_URL" -v sha="$TOOL_SHA" '
                            /\\.binaryTarget\\(/ {
                                p = 1
                                print
                                next
                            }
                            p && /name:/ {
                                if ($0 ~ "\\"" name "\\"") {
                                    found = 1
                                }
                                print
                                next
                            }
                            p && found && /url:/ {
                                match($0, /^[[:space:]]*/)
                                spaces = substr($0, RSTART, RLENGTH)
                                print spaces "url: \\"" url "\\","
                                next
                            }
                            p && found && /checksum:/ {
                                match($0, /^[[:space:]]*/)
                                spaces = substr($0, RSTART, RLENGTH)
                                print spaces "checksum: \\"" sha "\\""
                                p = 0
                                found = 0
                                next
                            }
                            { print }
                        ' Package.swift > Package.swift.tmp && mv Package.swift.tmp Package.swift
                        
                        # Check if changes were made
                        if ! git diff --quiet Package.swift; then
                          git config user.name "GitHub Action"
                          git config user.email "action@github.com"
                          git add Package.swift
                          git commit -m "Update ${{ inputs.tool-name }} binary target URL and checksum"
                          git push
                          echo "Successfully updated and pushed changes to Package.swift in ${{ inputs.plugin-package-repository }}"
                        else
                          echo "No changes detected."
                        fi
                        
                        # Cleanup: Remove the plugin repository
                        cd ..
                        rm -rf plugin-repo
                        echo "Cleaned up plugin repository"
                        """.toYamlString(.multiline)
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-4")
    }

    @Test("Test Action 5 Conversion")
    func testAction5Conversion() throws {
        let action = _GHA.Action(
            name: "Preternatural Archive & Notarize Action".toYamlString(.singleQuoted),
            description: "Archive & notarize a MacOS application using Preternatural CLI".toYamlString(.singleQuoted),
            inputs: [
                "xcode-version": _GHA.Action.Input(
                    description: "Xcode version to use".toYamlString(.singleQuoted),
                    required: true,
                    defaultValue: "latest-stable".toYamlString(.singleQuoted)
                ),
                "notarization_username": _GHA.Action.Input(
                    description: "App Store Connect Username for notarization".toYamlString(.singleQuoted),
                    required: true
                ),
                "notarization_password": _GHA.Action.Input(
                    description: "App Store Connect Password for notarization".toYamlString(.singleQuoted),
                    required: true
                ),
                "notarization_team_id": _GHA.Action.Input(
                    description: "App Store Connect Team ID for notarization".toYamlString(.singleQuoted),
                    required: false
                ),
                "build_certificate_base64": _GHA.Action.Input(
                    description: "Base64-encoded Apple certificate".toYamlString(.singleQuoted),
                    required: true
                ),
                "p12_password": _GHA.Action.Input(
                    description: "Password for the P12 certificate".toYamlString(.singleQuoted),
                    required: true
                ),
                "fuck-swift-syntax": _GHA.Action.Input(
                    description: "Enable the --fuck-swift-syntax flag for the archive command".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "true".toYamlString,
                    type: .boolean
                )
            ],
            runs: _GHA.Action.Runs(
                using: "composite".toYamlString(.singleQuoted),
                steps: [
                    _GHA.Step(
                        name: "Setup Xcode".toYamlString,
                        uses: "maxim-lobanov/setup-xcode@v1".toYamlString,
                        with: [
                            "xcode-version": "${{ inputs.xcode-version }}".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Install Preternatural".toYamlString,
                        if: "${{ !env.ACT }}".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        brew tap PreternaturalAI/preternatural
                        brew install preternatural
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Install the Apple certificate and provisioning profile".toYamlString,
                        if: "${{ !env.ACT }}".toYamlString,
                        shell: "bash".toYamlString,
                        env: [
                            "BUILD_CERTIFICATE_BASE64": "${{ inputs.build_certificate_base64 }}".toYamlString,
                            "P12_PASSWORD": "${{ inputs.p12_password }}".toYamlString
                        ],
                        run: """
                        # Generate a random keychain password
                        KEYCHAIN_PASSWORD=$(openssl rand -base64 15)
                        
                        # Create variables
                        CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
                        KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
                        
                        # Import certificate from inputs
                        echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
                        
                        # Create temporary keychain
                        security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
                        security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
                        security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
                        
                        # Import certificate to keychain
                        security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
                        security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
                        security list-keychain -d user -s $KEYCHAIN_PATH
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Run preternatural archive command".toYamlString,
                        shell: "bash".toYamlString,
                        env: [
                            "NOTARIZATION_APP_STORE_CONNECT_USERNAME": "${{ inputs.notarization_username }}".toYamlString,
                            "NOTARIZATION_APP_STORE_CONNECT_PASSWORD": "${{ inputs.notarization_password }}".toYamlString
                        ],
                        run: """
                        # Construct the command as a string
                        PRETERNATURAL_CMD="script -q /dev/null preternatural archive"
                        
                        if [ -n "${{ inputs.notarization_team_id }}" ]; then
                          PRETERNATURAL_CMD="$PRETERNATURAL_CMD --team-id "${{ inputs.notarization_team_id }}"
                        fi
                        
                        if [ "${{ inputs.fuck-swift-syntax }}" == "true" ]; then
                          PRETERNATURAL_CMD="$PRETERNATURAL_CMD --fuck-swift-syntax"
                        fi
                        
                        echo "Running preternatural archive command:"
                        echo "${PRETERNATURAL_CMD}"
                        eval ${PRETERNATURAL_CMD} 2>&1
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Find archive file".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        ARCHIVE_FILE=$(find . -name "*Notarized*.zip" -print -quit)
                        if [ -z "$ARCHIVE_FILE" ]; then
                          echo "Error: No notarized ZIP file found"
                          exit 1
                        fi
                        echo "ARCHIVE_FILE=$ARCHIVE_FILE" >> $GITHUB_ENV
                        echo "Found archive file: $ARCHIVE_FILE"
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Upload archive as artifact".toYamlString,
                        uses: "actions/upload-artifact@v4".toYamlString,
                        with: [
                            "name": "notarized-app".toYamlString,
                            "path": "${{ env.ARCHIVE_FILE }}".toYamlString,
                            "if-no-files-found": "error".toYamlString
                        ]
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-5")
    }

    @Test("Test Action 6 Conversion")
    func testAction6Conversion() throws {
        let action = _GHA.Action(
            name: "Export macOS App".toYamlString,
            description: """
            Signs, exports, packages and notarizes a macOS app in .zip or .dmg format using Preternatural CLI.
            """.toYamlString(.multiline),
            inputs: [
                "xcode-version": _GHA.Action.Input(
                    description: "Xcode version to use".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "16.2".toYamlString(.singleQuoted)
                ),
                "working-directory": _GHA.Action.Input(
                    description: "Directory to run the preternatural command from".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "".toYamlString(.singleQuoted)
                ),
                "configuration": _GHA.Action.Input(
                    description: "Build configuration (either `Debug` or `Release`; Release by default)".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "Release".toYamlString(.singleQuoted)
                ),
                "fuck-swift-syntax": _GHA.Action.Input(
                    description: "Enable the --fuck-swift-syntax flag".toYamlString(.singleQuoted),
                    required: false,
                    defaultValue: "true".toYamlString,
                    type: .boolean
                )
            ],
            runs: _GHA.Action.Runs(
                using: "composite".toYamlString(.singleQuoted),
                steps: [
                    _GHA.Step(
                        name: "Load Secrets from 1Password".toYamlString,
                        uses: "1password/load-secrets-action@v2".toYamlString,
                        with: [
                            "export-env": "true".toYamlString
                        ],
                        env: [
                            "OP_SERVICE_ACCOUNT_TOKEN": "token".toYamlString(.doubleQuoted),
                            "NOTARIZATION_APP_STORE_CONNECT_USERNAME": "op://abc/abc/abc".toYamlString,
                            "NOTARIZATION_APP_STORE_CONNECT_PASSWORD": "op://abc/abc/abc".toYamlString,
                            "GITHUB_PAT": "op://abc/abc/abc".toYamlString,
                            "DEVELOPER_ID_APPLICATION_CERTIFICATE_DATA_BASE_64": "op://abc/abc/abc".toYamlString,
                            "DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD": "op://abc/abc/abc".toYamlString,
                            "TEAM_ID": "op://abc/abc/abc".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Setup Xcode".toYamlString,
                        uses: "maxim-lobanov/setup-xcode@v1".toYamlString,
                        with: [
                            "xcode-version": "${{ inputs.xcode_version }}".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Install Preternatural".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        set -x  # Enable verbose output
                        brew tap PreternaturalAI/preternatural
                        brew install preternatural
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Setup PAT for Private Repos".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        echo -e "Setup PAT for Private Repos"
                        {
                          git config --global url."https://$GITHUB_PAT@github.com/".insteadOf "https://github.com/"
                        } > /dev/null 2>&1
                        echo -e "PAT Setup Complete"
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Restore DerivedData Cache".toYamlString,
                        uses: "actions/cache/restore@v4".toYamlString,
                        with: [
                            "path": "~/Library/Developer/Xcode/DerivedData".toYamlString(.doubleQuoted),
                            "key": "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}".toYamlString,
                            "restore-keys": """
                            ${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data
                            """.toYamlString(.multiline)
                        ]
                    ),
                    _GHA.Step(
                        name: "Build Archive".toYamlString,
                        continueOnError: true,
                        id: "archive".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        echo -e "Build Archive"

                        # Change directory if working-directory is provided
                        if [ ! -z "${{ inputs.working-directory }}" ]; then
                          cd "${{ inputs.working-directory }}"
                          echo "Changed working directory to: ${{ inputs.working-directory }}"
                        fi

                        # Build command with optional debug flag
                        CMD="script -q /dev/null preternatural archive --team-id $TEAM_ID"

                        if [ -n "${{ inputs.configuration }}" ]; then
                          CMD="$CMD --configuration "${{ inputs.configuration }}""
                        fi

                        if [ "${{ inputs.fuck-swift-syntax }}" == "true" ]; then
                          CMD="$CMD --fuck-swift-syntax"
                        fi

                        # Execute the command
                        eval "$CMD" 2>&1

                        if [ $? -eq 0 ]; then
                          echo "archive_succeeded=true" >> $GITHUB_OUTPUT
                        fi

                        set +x  # Disable command echo
                        echo -e "Archive Step completed"
                        """.toYamlString(.multiline)
                    ),
                    _GHA.Step(
                        name: "Upload Notarized App as artifact".toYamlString,
                        if: "steps.archive.outputs.archive_succeeded == 'true'".toYamlString,
                        uses: "actions/upload-artifact@v4".toYamlString,
                        with: [
                            "name": "Notarized-App".toYamlString,
                            "path": "**/*Notarized.zip".toYamlString(.singleQuoted),
                            "if-no-files-found": "error".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Upload logs".toYamlString,
                        uses: "PreternaturalAI/preternatural-github-actions/preternatural-upload-logs@main".toYamlString
                    ),
                    _GHA.Step(
                        name: "Save DerivedData Cache".toYamlString,
                        if: "steps.archive.outputs.archive_succeeded == 'true'".toYamlString,
                        uses: "actions/cache/save@v4".toYamlString,
                        with: [
                            "path": "~/Library/Developer/Xcode/DerivedData".toYamlString(.doubleQuoted),
                            "key": "${{ runner.os }}-${{ github.repository }}-${{ github.workflow }}-${{ github.ref_name }}-derived-data-${{ hashFiles('**/*') }}".toYamlString
                        ]
                    ),
                    _GHA.Step(
                        name: "Check archive status and fail if necessary".toYamlString,
                        if: "steps.archive.outputs.archive_succeeded != 'true'".toYamlString,
                        shell: "bash".toYamlString,
                        run: """
                        echo "Archive failed earlier in the workflow"
                        exit 1
                        """.toYamlString(.multiline)
                    )
                ]
            )
        )
        
        try test(action: action, with: "action-6")
    }
    
    @MainActor
    private func test(action: _GHA.Action, with file: String) throws {
        guard let originalFileURL = Bundle.module.url(forResource: file, withExtension: "yml", subdirectory: "Resources/actions") else {
            #expect(Bool(false), "Could not find \(file).yml")
            return
        }
        
        let outputURL = originalFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(file)-output.yml")
        
        _GHA.Configuration.set(configurations: [
            .action(action, outputURL: outputURL)
        ])
        
        try _GHA.Configuration.generateYAML()
        #expect(FileManager.default.fileExists(atPath: outputURL.path), "Generated YAML file doesn't exist")
        
        let originalYAMLString = try String(contentsOf: originalFileURL, encoding: .utf8)
        let generatedYAMLString = try String(contentsOf: outputURL, encoding: .utf8)
        #expect(originalYAMLString == generatedYAMLString)
    }
}
