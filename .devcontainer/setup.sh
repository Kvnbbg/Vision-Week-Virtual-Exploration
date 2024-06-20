#!/bin/bash

# Install Flutter if not already installed
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to the PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Flutter web support
flutter config --enable-web
flutter upgrade

# Install Xcode Command Line Tools and set Xcode path if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  xcode-select --install
  sudo xcode-select --switch /Applications/Xcode.app
fi

# Install Android SDK and tools if not already installed
if [ ! -d "$ANDROID_HOME" ]; then
  mkdir -p "$HOME/Android/Sdk"
  export ANDROID_HOME="$HOME/Android/Sdk"
  export PATH="$PATH:$ANDROID_HOME/tools"
  export PATH="$PATH:$ANDROID_HOME/platform-tools"

  # Install required Android tools
  yes | sdkmanager --licenses
  sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "extras;android;m2repository" "extras;google;m2repository"
fi

# Navigate to the project directory
cd /workspaces/Vision-Week-Virtual-Exploration

# Install project dependencies
flutter pub get

# Run Flutter web
flutter run -d chrome
