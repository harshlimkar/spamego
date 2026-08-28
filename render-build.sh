#!/usr/bin/env bash
# Exit on error
set -o errexit

# Download Flutter SDK if not present
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add flutter to path for the duration of the build
export PATH="$PATH:`pwd`/flutter/bin"

echo "Configuring Flutter..."
flutter config --enable-web

echo "Getting dependencies..."
cd flutter_app
flutter pub get

echo "Building for web..."
flutter build web --release

echo "Build complete."
