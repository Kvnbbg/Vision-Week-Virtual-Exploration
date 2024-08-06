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
    install_dependency "dart" "brew tap dart-lang/dart && brew install dart" "sudo apt-get install dart"
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

# Function to install git-filter-repo
install_git_filter_repo() {
    log "Installing git-filter-repo..."
    install_dependency "git-filter-repo" "brew install git-filter-repo" "pip install git-filter-repo"
    check_status "git-filter-repo installation"
}

# Function to set up cross-platform development tools
setup_crossplatform_tools() {
    log "Setting up cross-platform development tools..."
    # Add additional cross-platform setup commands here
    check_status "Cross-platform setup"
}

# Function to set up API development tools
setup_api_tools() {
    log "Setting up API development tools..."
    # Add additional API setup commands here
    check_status "API setup"
}

# Function to set up AI development tools
setup_ai_tools() {
    log "Setting up AI development tools..."
    # Add additional AI setup commands here
    check_status "AI setup"
}

# Function to clean the project
clean_project() {
    log "Cleaning the project..."
    ./gradlew clean
    check_status "Gradle clean"
}

# Function to update Flutter dependencies
update_flutter_dependencies() {
    log "Updating Flutter dependencies..."
    flutter pub get
    check_status "Flutter pub get"
}

# Function to rebuild the project
rebuild_project() {
    log "Rebuilding the project..."
    ./gradlew build --warning-mode all --stacktrace
    check_status "Gradle build"
}

# Function to run Flutter doctor
run_flutter_doctor() {
    log "Running Flutter doctor..."
    flutter doctor
    check_status "Flutter doctor"
}

# Function to synchronize project with Gradle files
synchronize_gradle() {
    log "Synchronizing project with Gradle files..."
    ./gradlew --refresh-dependencies
    check_status "Gradle synchronization"
}

# Function to resolve Git pull conflicts
resolve_git_conflicts() {
    log "Resolving Git pull conflicts..."
    git config pull.rebase true
    git pull origin main
    if [ $? -ne 0 ]; then
        log "Git pull failed. Attempting to rebase..."
        git pull --rebase origin main
        check_status "Git pull rebase"
    fi
}

# Function to build Docker image
build_docker_image() {
    log "Building Docker image..."
    docker build -t kvnbbg/vision-week .
    check_status "Docker build"
}

# Function to run Docker container
run_docker_container() {
    log "Running Docker container..."
    docker run -d -p 80:80 --name vision-week kvnbbg/vision-week
    check_status "Docker run"
}

# Function to clean up Docker containers and images
cleanup_docker() {
    log "Cleaning up Docker containers and images..."
    docker container prune -f
    docker image prune -f
    check_status "Docker cleanup"
}

# Function to reinstall the script from the remote repository
reinstall_script() {
    log "Reinstalling the script from the remote repository..."
    remote_script_url="https://raw.githubusercontent.com/Kvnbbg/Vision-Week-Virtual-Exploration/main/enhanced_script.sh"
    curl -o enhanced_script.sh $remote_script_url
    check_status "Script reinstallation"
    chmod +x enhanced_script.sh
}

# Main function to orchestrate the build process
main() {
    log "Starting the cleaning and rebuilding process..."

    install_homebrew

    install_flutter
    install_dart
    install_android_sdk
    install_gradle
    install_cocoapods
    install_docker
    install_docker_compose
    install_git_filter_repo

    setup_crossplatform_tools
    setup_api_tools
    setup_ai_tools

    clean_project
    update_flutter_dependencies
    synchronize_gradle
    rebuild_project
    run_flutter_doctor

    # Check if there are any issues reported by flutter doctor
    flutter doctor -v | grep -q "Doctor found issues"
    if [ $? -eq 0 ]; then
        log "Flutter doctor reported issues. Please resolve them before continuing."
        exit 1
    fi

    resolve_git_conflicts

    build_docker_image
    run_docker_container
    cleanup_docker

    reinstall_script

    log "Cleaning and rebuilding process completed successfully."
}

# Execute the main function
main
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

# Function to install git-filter-repo
install_git_filter_repo() {
    log "Installing git-filter-repo..."
    install_dependency "git-filter-repo" "brew install git-filter-repo" "pip install git-filter-repo"
    check_status "git-filter-repo installation"
}

# Function to set up cross-platform development tools
setup_crossplatform_tools() {
    log "Setting up cross-platform development tools..."
    # Add additional cross-platform setup commands here
    check_status "Cross-platform setup"
}

# Function to set up API development tools
setup_api_tools() {
    log "Setting up API development tools..."
    # Add additional API setup commands here
    check_status "API setup"
}

# Function to set up AI development tools
setup_ai_tools() {
    log "Setting up AI development tools..."
    # Add additional AI setup commands here
    check_status "AI setup"
}

# Function to clean the project
clean_project() {
    log "Cleaning the project..."
    ./gradlew clean
    check_status "Gradle clean"
}

# Function to update Flutter dependencies
update_flutter_dependencies() {
    log "Updating Flutter dependencies..."
    flutter pub get
    check_status "Flutter pub get"
}

# Function to rebuild the project
rebuild_project() {
    log "Rebuilding the project..."
    ./gradlew build --warning-mode all --stacktrace
    check_status "Gradle build"
}

# Function to run Flutter doctor
run_flutter_doctor() {
    log "Running Flutter doctor..."
    flutter doctor
    check_status "Flutter doctor"
}

# Function to synchronize project with Gradle files
synchronize_gradle() {
    log "Synchronizing project with Gradle files..."
    ./gradlew --refresh-dependencies
    check_status "Gradle synchronization"
}

# Function to resolve Git pull conflicts
resolve_git_conflicts() {
    log "Resolving Git pull conflicts..."
    git config pull.rebase true
    git pull origin main
    if [ $? -ne 0 ]; then
        log "Git pull failed. Attempting to rebase..."
        git pull --rebase origin main
        check_status "Git pull rebase"
    fi
}

# Function to build Docker image
build_docker_image() {
    log "Building Docker image..."
    docker build -t kvnbbg/vision-week .
    check_status "Docker build"
}

# Function to run Docker container
run_docker_container() {
    log "Running Docker container..."
    docker run -d -p 80:80 --name vision-week kvnbbg/vision-week
    check_status "Docker run"
}

# Function to clean up Docker containers and images
cleanup_docker() {
    log "Cleaning up Docker containers and images..."
    docker container prune -f
    docker image prune -f
    check_status "Docker cleanup"
}

# Function to reinstall the script from the remote repository
reinstall_script() {
    log "Reinstalling the script from the remote repository..."
    remote_script_url="https://raw.githubusercontent.com/Kvnbbg/Vision-Week-Virtual-Exploration/main/enhanced_script.sh"
    curl -o enhanced_script.sh $remote_script_url
    check_status "Script reinstallation"
    chmod +x enhanced_script.sh
}

# Main function to orchestrate the build process
main() {
    log "Starting the cleaning and rebuilding process..."

    install_homebrew

    install_flutter
    install_dart
    install_android_sdk
    install_gradle
    install_cocoapods
    install_docker
    install_docker_compose
    install_git_filter_repo

    setup_crossplatform_tools
    setup_api_tools
    setup_ai_tools

    clean_project
    update_flutter_dependencies
    synchronize_gradle
    rebuild_project
    run_flutter_doctor

    # Check if there are any issues reported by flutter doctor
    flutter doctor -v | grep -q "Doctor found issues"
    if [ $? -eq 0 ]; then
        log "Flutter doctor reported issues. Please resolve them before continuing."
        exit 1
    fi

    resolve_git_conflicts

    build_docker_image
    run_docker_container
    cleanup_docker

    reinstall_script

    log "Cleaning and rebuilding process completed successfully."
}

# Execute the main function
main
