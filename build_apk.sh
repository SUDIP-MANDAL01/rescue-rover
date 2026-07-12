#!/bin/bash
# Script to build APK for Rescue Rover
echo "Building APK for Rescue Rover..."

cd frontend

if ! command -v flutter &> /dev/null
then
    echo "Flutter is not installed or not in PATH."
    exit 1
fi

# In case android platform isn't generated
if [ ! -d "android" ]; then
    echo "Android platform directory not found. Running flutter create . to generate it..."
    flutter create .
fi

flutter clean
flutter pub get
flutter build apk --release

echo "Build complete. Check frontend/build/app/outputs/flutter-apk/app-release.apk"
