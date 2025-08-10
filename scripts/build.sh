#!/bin/bash

# Puchi App Build Script
# For consistent builds and testing before App Store releases

set -e  # Exit on any error

echo "🚀 Starting Puchi build process..."

# Configuration
PROJECT_NAME="Puchi"
SCHEME="Puchi" 
CONFIGURATION="Release"
SIMULATOR_DESTINATION="platform=iOS Simulator,name=iPhone 16,OS=18.5"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}"

# Build for simulator (quick validation)
echo "📱 Building for iOS Simulator..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -destination "${SIMULATOR_DESTINATION}" -configuration Debug build

# Build for device (App Store preparation)
echo "📦 Building for iOS Device (Release)..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -destination "generic/platform=iOS" -configuration "${CONFIGURATION}" build

echo "✅ Build completed successfully!"
echo ""
echo "Next steps for App Store release:"
echo "1. Archive: Product -> Archive in Xcode"
echo "2. Validate: Use Organizer to validate archive"
echo "3. Distribute: Upload to App Store Connect"