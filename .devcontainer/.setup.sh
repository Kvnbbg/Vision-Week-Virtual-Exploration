#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Flutter web support
flutter config --enable-web

# Install project dependencies
# cd /workspaces/your_project_name
flutter pub get

# Run Flutter web
flutter run -d chrome
