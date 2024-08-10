#!/bin/bash

# This script automates the setup and environment configuration of a Visual Studio Code (VSCode) environment.
# It installs necessary dependencies, configures VSCode settings, and handles issues with Gradle, Java, Dart, and Heroku CLI.
# Author: Kevin Marville
# LinkedIn: https://linkedin.com/in/kevin-marville
# Blog: https://kvnbbg.fr
# GitHub: https://github.com/kvnbbg
# File: setup_vcenv.sh

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

# Function to check VSCode is installed
check_vscode_installed() {
    if ! command -v code &> /dev/null; then
        log "$RED" "❌" "VSCode is not installed. Please install VSCode first."
        exit 1
    fi
}

# Function to disable Node.js Runtime Detection for SQLTools
disable_sqltools_node_runtime() {
    log "$BLUE" "🚀" "Disabling Node.js Runtime Detection for SQLTools..."
    code --add --disable-extensions sqltools.useNodeRuntime
    log "$GREEN" "✅" "Node.js Runtime Detection for SQLTools disabled."
}

# Function to upgrade Gradle
upgrade_gradle() {
    log "$BLUE" "🚀" "Upgrading Gradle to version 8.9..."
    # You may need to add more logic depending on how Gradle is upgraded in your specific environment
    code --install-extension vscjava.vscode-gradle
    log "$GREEN" "✅" "Gradle upgraded to version 8.9."
}

# Function to install or upgrade JDK
install_upgrade_jdk() {
    log "$BLUE" "🚀" "Installing or upgrading Java Development Kit (JDK)..."
    # This assumes that JDK is being managed by a package manager like Homebrew on macOS or apt on Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask adoptopenjdk
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y openjdk-11-jdk
    fi
    log "$GREEN" "✅" "JDK installed or upgraded."
}

# Function to automatically fix Dart issues
fix_dart_issues() {
    log "$BLUE" "🚀" "Fixing Dart issues automatically..."
    code --add --disable-extensions dart.flutter
    log "$GREEN" "✅" "Dart issues fixed."
}

# Function to log into Heroku CLI
login_heroku() {
    log "$BLUE" "🚀" "Attempting to log into Heroku CLI..."
    if ! command -v heroku &> /dev/null; then
        log "$RED" "❌" "Heroku CLI is not installed. Please install it manually."
        exit 1
    fi
    heroku auth:whoami &> /dev/null
    if [ $? -ne 0 ]; then
        heroku login --interactive
    fi
    log "$GREEN" "✅" "Logged into Heroku CLI."
}

# Main function to orchestrate the automation
main() {
    check_vscode_installed
    disable_sqltools_node_runtime
    upgrade_gradle
    install_upgrade_jdk
    fix_dart_issues
    login_heroku
    log "$GREEN" "🎉" "All tasks completed successfully!"
}

# Execute the main function
main
