#!/bin/bash

# Exit on error
set -e

# Configuration
SCHEME="JoblogicQRScanner"
FRAMEWORK_NAME="JoblogicQRScanner"
CONFIGURATION="Release"
OUTPUT_DIR="build"

# Clean build directory
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen generate --spec project.yml

# Verify project exists
if [ ! -d "${FRAMEWORK_NAME}.xcodeproj" ]; then
    echo "Error: Xcode project was not generated successfully"
    exit 1
fi

# Build for iOS devices
echo "Building iOS framework..."
xcodebuild archive \
    -project "${FRAMEWORK_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -destination "generic/platform=iOS" \
    -archivePath "${OUTPUT_DIR}/${FRAMEWORK_NAME}-iOS" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS Simulator
echo "Building simulator framework..."
xcodebuild archive \
    -project "${FRAMEWORK_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "${OUTPUT_DIR}/${FRAMEWORK_NAME}-iOS-Simulator" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "${OUTPUT_DIR}/${FRAMEWORK_NAME}-iOS.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${OUTPUT_DIR}/${FRAMEWORK_NAME}-iOS-Simulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"

# Copy headers to both frameworks
echo "Copying headers to frameworks..."
mkdir -p "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64/${FRAMEWORK_NAME}.framework/Headers"
mkdir -p "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64_x86_64-simulator/${FRAMEWORK_NAME}.framework/Headers"

# Copy all public headers
cp -R "Sources/Library/include/"* "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64/${FRAMEWORK_NAME}.framework/Headers/"
cp -R "Sources/Library/include/"* "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64_x86_64-simulator/${FRAMEWORK_NAME}.framework/Headers/"

# Verify headers
echo "Verifying headers..."
ls -la "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64/${FRAMEWORK_NAME}.framework/Headers/"
ls -la "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64_x86_64-simulator/${FRAMEWORK_NAME}.framework/Headers/"

# Create modulemap for each framework
echo "Creating modulemap for frameworks..."
cat > "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64/${FRAMEWORK_NAME}.framework/Modules/module.modulemap" << EOF
framework module JoblogicQRScanner {
    umbrella "."
    
     explicit module QRCodeReaderViewController {
        header "QRCodeReaderViewController.h"
        export *
    }
    
    export *
    module * { export * }
}
EOF

cat > "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework/ios-arm64_x86_64-simulator/${FRAMEWORK_NAME}.framework/Modules/module.modulemap" << EOF
framework module JoblogicQRScanner {
    umbrella "."
    
     explicit module QRCodeReaderViewController {
        header "QRCodeReaderViewController.h"
        export *
    }
    
    export *
    module * { export * }
}
EOF

echo "Build completed successfully!"
echo "XCFramework is available at: ${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework" 