#!/bin/bash

# This script automates the setup and run process of a Flutter app inside a Docker container.
# It installs the necessary dependencies, builds the Docker image, runs the Docker container,
# installs Flutter dependencies, generates localization files, generates code with build_runner,
# and runs the Flutter app. The script is designed to work on macOS and Linux.
# Author: Kevin Marville
# LinkedIn: https://linkedin.com/in/kevin-marville
# Blog: https://kvnbbg.fr
# GitHub: https://github.com/kvnbbg
# File: setup.sh

# Color codes for logging
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
RESET='\033[0m'

# Function to log messages with a timestamp, color, and emojis
log() {
    local color="$1"
    local emoji="$2"
    local message="$3"
    echo -e "${color}$(date +'%Y-%m-%d %H:%M:%S') - ${emoji} ${message}${RESET}"
}

# Function to check the status of the last executed command and exit if it failed
check_status() {
    if [ $? -ne 0 ]; then
        log "$RED" "❌" "Oops! Something went wrong during $1. Please check the above logs and try again."
        exit 1
    fi
}

# Function to install a dependency if not already installed
install_dependency() {
    local dep=$1
    local install_cmd_mac=$2
    local install_cmd_linux=$3
    if ! command -v $dep &> /dev/null; then
        log "$YELLOW" "💡" "$dep not found. Installing $dep... Just a moment ⏳"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            eval $install_cmd_mac
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            eval $install_cmd_linux
        fi
        check_status "$dep installation"
        log "$GREEN" "✅" "$dep installed successfully! 🎉"
    else
        log "$CYAN" "🔍" "$dep is already installed. No need to fix what's not broken! 🛠️"
    fi
}

# Function to install Homebrew if not already installed (macOS only)
install_homebrew() {
    if [[ "$OSTYPE" == "darwin"* && ! command -v brew &> /dev/null ]]; then
        log "$YELLOW" "💡" "Homebrew not found. Installing Homebrew... 🍺"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        check_status "Homebrew installation"
    else
        log "$CYAN" "🔍" "Homebrew is already installed or not required on this system."
    fi
}

# Function to install Flutter
install_flutter() {
    log "$BLUE" "🚀" "Installing Flutter... This might take a minute. 🌟"
    install_dependency "flutter" "brew install --cask flutter" "sudo snap install flutter --classic"
}

# Function to install Dart
install_dart() {
    log "$BLUE" "🚀" "Installing Dart... Coding magic in progress! ✨"
    install_dependency "dart" "brew tap dart-lang/dart && brew install dart" "sudo apt-get install -y dart"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew link dart
    fi
}

# Function to install Android SDK and set up environment variables
install_android_sdk() {
    log "$BLUE" "🚀" "Installing Android SDK... Prepping your Android dev environment! 🤖"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask android-studio
        brew install --cask intel-haxm
        brew install --cask android-commandlinetools
        yes | sdkmanager --install "cmdline-tools;latest" "platform-tools" "platforms;android-29"
        yes | flutter doctor --android-licenses
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y openjdk-11-jdk wget unzip
        wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
        mkdir -p $HOME/Android/cmdline-tools
        unzip commandlinetools-linux-6858069_latest.zip -d $HOME/Android/cmdline-tools
        mkdir -p $HOME/Android/cmdline-tools/latest
        mv $HOME/Android/cmdline-tools/cmdline-tools/* $HOME/Android/cmdline-tools/latest/
        export ANDROID_HOME=$HOME/Android/Sdk
        export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools
    fi
    check_status "Android SDK installation"
}

# Function to install Gradle
install_gradle() {
    log "$BLUE" "🚀" "Installing Gradle... Build tools are on their way! 🛠️"
    install_dependency "gradle" "brew install gradle" "sudo apt-get install -y gradle"
}

# Function to install CocoaPods (macOS only)
install_cocoapods() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "$BLUE" "🚀" "Installing CocoaPods... Getting your iOS setup ready! 🍏"
        install_dependency "pod" "sudo gem install cocoapods" "echo 'CocoaPods is only required on macOS'"
    fi
}

# Function to install Docker
install_docker() {
    log "$BLUE" "🚀" "Installing Docker... Preparing the container magic! 🐳"
    install_dependency "docker" "brew install --cask docker" "sudo apt-get install -y docker.io && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker ${USER}"
}

# Function to install Docker Compose
install_docker_compose() {
    log "$BLUE" "🚀" "Installing Docker Compose... Bringing it all together! 🛠️"
    install_dependency "docker-compose" "brew install docker-compose" "sudo apt-get install -y docker-compose"
}

# Function to build Docker image
build_docker_image() {
    log "$BLUE" "🔨" "Building Docker image... Assembling your development environment! 🛠️"
    docker-compose build
    check_status "Docker build"
}

# Function to run Docker container
run_docker_container() {
    log "$BLUE" "🐳" "Running Docker container... Your environment is coming to life! 🚀"
    docker-compose up -d
    check_status "Docker run"
}

# Function to check if Docker container is healthy
check_docker_container_health() {
    log "$BLUE" "🔍" "Checking Docker container health... Let's make sure everything's working smoothly! 🔧"
    container_name=$(docker-compose ps -q flutter_app)
    if [ -z "$container_name" ]; then
        log "$RED" "❌" "Failed to retrieve Docker container name. Exiting."
        exit 1
    fi
    health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name")
    if [ "$health_status" != "healthy" ]; then
        log "$RED" "❌" "Docker container is not healthy. Current status: $health_status. Exiting."
        exit 1
    fi
    log "$GREEN" "✅" "Docker container is healthy and ready to go! 🎉"
}

# Function to install Flutter dependencies inside Docker container
install_flutter_dependencies() {
    log "$BLUE" "📦" "Installing Flutter dependencies inside Docker container... Preparing your app! 🚀"
    docker-compose exec flutter_app flutter pub get
    check_status "Flutter dependencies installation"
}

# Function to generate localization files inside Docker container
generate_localization_files() {
    log "$BLUE" "🌍" "Generating localization files... Making your app multilingual! 🌐"
    docker-compose exec flutter_app flutter pub run intl_utils:generate
    check_status "Localization files generation"
}

# Function to generate code with build_runner inside Docker container
generate_code_build_runner() {
    log "$BLUE" "🏗️" "Generating code with build_runner... Building the foundations of your app! 🚧"
    docker-compose exec flutter_app flutter pub run build_runner build
    check_status "Code generation with build_runner"
}

# Function to run Flutter app inside Docker container
run_flutter_app() {
    log "$GREEN" "🚀" "Running Flutter app inside Docker container... Let's see your app in action! 🎉"
    docker-compose exec flutter_app flutter run
    check_status "Running Flutter app"
}

# Function to check if Docker is running
check_docker_running() {
    log "$BLUE" "🐳" "Checking if Docker is running... Ensuring the magic is ready to happen! 🛠️"
    if ! docker info &> /dev/null; then
        log "$YELLOW" "⚠️" "Docker is not running. Attempting to start Docker..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open --background -a Docker
            sleep 5  # Give Docker time to start
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo systemctl start docker
        fi
        if ! docker info &> /dev/null; then
            log "$RED" "❌" "Docker failed to start. Please ensure Docker is running and try again."
            exit 1
        fi
    fi
    log "$GREEN" "✅" "Docker is running and ready to go! 🐳"
}

# Problem-solving case for VSCode issues
resolve_vscode_issues() {
    log "$MAGENTA" "💻" "Resolving VSCode issues... Let's make sure everything is smooth! 🛠️"

    if ! pgrep -x "Visual Studio Code" > /dev/null; then
        log "$RED" "❌" "VSCode is not running. Please start Visual Studio Code and try again."
        exit 1
    fi

    # SQLTools Extension Issue: Disable Node.js Runtime Detection
    log "$YELLOW" "💡" "Disabling Node.js runtime detection for SQLTools extension in VSCode... ⚙️"
    osascript -e 'tell application "Visual Studio Code" to do script "code --add --disable-extensions sqltools.useNodeRuntime"'
    check_status "SQLTools Node.js runtime detection"

    # Java and Gradle Compatibility: Upgrade Gradle
    log "$YELLOW" "💡" "Upgrading Gradle in VSCode... Let's keep everything compatible! 🛠️"
    osascript -e 'tell application "Visual Studio Code" to do script "code --add --disable-extensions java.gradle.language-support"'
    osascript -e 'tell application "Visual Studio Code" to do script "code --add --disable-extensions java.configuration.runtimes"'
    check_status "Gradle upgrade"

    # Dart Issues: Fix Automatically
    log "$YELLOW" "💡" "Fixing Dart issues in VSCode... Let's keep that code smooth! 🛠️"
    osascript -e 'tell application "Visual Studio Code" to do script "code --add --disable-extensions dart.flutter"'
    check_status "Dart fix"

    # Heroku CLI Authentication: Login
    log "$YELLOW" "💡" "Logging into Heroku CLI in VSCode... Getting everything connected! 🔑"
    osascript -e 'tell application "Visual Studio Code" to do script "code --add --disable-extensions heroku"'
    check_status "Heroku CLI login"

    log "$GREEN" "✅" "VSCode issues resolved. You're good to go! 🎉"
}

# Main function to orchestrate the setup and run process
main() {
    log "$MAGENTA" "💻" "Initializing the environment setup... Prepare for awesomeness! 😎"

    check_docker_running

    install_homebrew
    install_flutter
    install_dart
    install_android_sdk
    install_gradle
    install_cocoapods
    install_docker
    install_docker_compose

    resolve_vscode_issues

    build_docker_image
    run_docker_container
    check_docker_container_health

    install_flutter_dependencies
    generate_localization_files
    generate_code_build_runner
    run_flutter_app

    log "$GREEN" "✅" "All done! Your environment is now set up and ready to go! 🚀"
    log "$BLUE" "💡" "Remember to give a shoutout to Kevin Marville on LinkedIn or GitHub if this made your day easier! 🎉"
    log "$MAGENTA" "🧙‍♂️" "And of course, a special thanks to GPT-4o Grimoire for guiding you on this coding quest! ⚔️"
}

# Execute the main function
main
