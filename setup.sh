#!/bin/bash

# Author: Kevin Marville
# LinkedIn: https://linkedin.com/in/kevin-marville
# Blog: https://kvnbbg.fr

# Function to log messages with a timestamp
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check the status of the last executed command and continue if it failed
check_status() {
    if [ $? -ne 0 ]; then
        log "Warning: Error encountered during $1. Continuing with the next step."
    fi
}

# Function to install a dependency if not already installed
install_dependency() {
    local dep=$1
    local install_cmd_mac=$2
    local install_cmd_linux=$3
    if ! command -v $dep &> /dev/null; then
        log "$dep not found. Installing $dep..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            eval $install_cmd_mac
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            eval $install_cmd_linux
        fi
        check_status "$dep installation"
    else
        log "$dep is already installed."
    fi
}

# Function to install Homebrew if not already installed (macOS only)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        check_status "Homebrew installation"
    else
        log "Homebrew is already installed."
    fi
}

# Function to install Flutter
install_flutter() {
    log "Installing Flutter..."
    install_dependency "flutter" "brew install --cask flutter" "sudo snap install flutter --classic"
    check_status "Flutter installation"
}

# Function to install Dart
install_dart() {
    log "Installing Dart..."
    install_dependency "dart" "brew tap dart-lang/dart && brew install dart" "sudo apt-get install -y dart"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew link dart
    fi
    check_status "Dart installation"
}

# Function to install Android SDK and set up environment variables
install_android_sdk() {
    log "Installing Android SDK..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask android-studio
        brew install --cask intel-haxm
        brew install --cask android-commandlinetools
        yes | sdkmanager --install "cmdline-tools;latest" "platform-tools" "platforms;android-29"
        yes | flutter doctor --android-licenses
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y openjdk-11-jdk
        wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
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
    install_dependency "gradle" "brew install gradle" "sudo apt-get install -y gradle"
}

# Function to install CocoaPods
install_cocoapods() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Installing CocoaPods..."
        install_dependency "pod" "sudo gem install cocoapods" "echo 'CocoaPods is only required on macOS'"
        check_status "CocoaPods installation"
    fi
}

# Function to install Docker
install_docker() {
    log "Installing Docker..."
    install_dependency "docker" "brew install --cask docker" "sudo apt-get install -y docker.io && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker ${USER}"
    check_status "Docker installation"
}

# Function to install Docker Compose
install_docker_compose() {
    install_dependency "docker-compose" "brew install docker-compose" "sudo apt-get install -y docker-compose"
}

# Function to build Docker image
build_docker_image() {
    log "Building Docker image..."
    docker-compose build
    check_status "Docker build"
}

# Function to run Docker container
run_docker_container() {
    log "Running Docker container..."
    docker-compose up -d
    check_status "Docker run"
}

# Function to install Flutter dependencies inside Docker container
install_flutter_dependencies() {
    log "Installing Flutter dependencies inside Docker container..."
    docker-compose exec flutter_app flutter pub get
    check_status "Flutter dependencies installation"
}

# Function to generate localization files inside Docker container
generate_localization_files() {
    log "Generating localization files inside Docker container..."
    docker-compose exec flutter_app flutter pub run intl_utils:generate
    check_status "Localization files generation"
}

# Function to generate code with build_runner inside Docker container
generate_code_build_runner() {
    log "Generating code with build_runner inside Docker container..."
    docker-compose exec flutter_app flutter pub run build_runner build
    check_status "Code generation with build_runner"
}

# Function to run Flutter app inside Docker container
run_flutter_app() {
    log "Running Flutter app inside Docker container..."
    docker-compose exec flutter_app flutter run
    check_status "Running Flutter app"
}

# Function to check if Docker is running
check_docker_running() {
    log "Checking if Docker is running..."
    if ! docker info &> /dev/null; then
        log "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Main function to orchestrate the setup and run process
main() {
    log "Starting the setup and run process..."

    check_docker_running

    install_homebrew

    install_flutter
    install_dart
    install_android_sdk
    install_gradle
    install_cocoapods
    install_docker
    install_docker_compose

    build_docker_image
    run_docker_container

    install_flutter_dependencies
    generate_localization_files
    generate_code_build_runner
    run_flutter_app

    log "Setup and run process completed successfully."
}

# Execute the main function
main
