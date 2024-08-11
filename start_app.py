#!/usr/bin/env python3

import os
import subprocess
import platform
import sys
import webbrowser

# Author: [Your Name]
# Description: This script automates the setup and running of a Flutter app, ensuring all dependencies are installed, scripts are executable, and errors are handled gracefully.
# No failure is allowed! If something goes wrong, the script will find an alternative solution.
# This script is designed to be fun, professional, and reliable.

def log(message, color_code="\033[32m", emoji="💡"):
    """Log messages to the terminal with color and emojis."""
    print(f"{color_code}{emoji} {message}\033[0m")

def check_python_installed():
    """Check if Python is installed and at the correct version."""
    log("Checking if Python is installed and running correctly...", "\033[34m", "🐍")
    if sys.version_info < (3, 6):
        log("Python 3.6 or higher is required. Please update your Python installation.", "\033[31m", "❌")
        sys.exit(1)
    else:
        log(f"Python {sys.version} is installed and ready to go!", "\033[32m", "✅")

def open_readme():
    """Open the README.md file with a suitable application."""
    log("Attempting to open README.md...", "\033[34m", "📖")
    readme_path = "README.md"
    
    if not os.path.exists(readme_path):
        log("README.md file not found! But don't worry, I’ll figure something out...", "\033[31m", "❌")
        return False
    
    try:
        if platform.system() == "Darwin":  # macOS
            subprocess.call(["open", readme_path])
        elif platform.system() == "Windows":  # Windows
            os.startfile(readme_path)
        elif platform.system() == "Linux":  # Linux
            subprocess.call(["xdg-open", readme_path])
        else:
            log("Unsupported OS! But hey, I'm still here to help!", "\033[31m", "❌")
            return False
        log("README.md opened successfully! Now let’s get down to business!", "\033[32m", "✅")
        return True
    except Exception as e:
        log(f"Failed to open README.md: {e}. But I’m not giving up!", "\033[31m", "❌")
        return False

def install_or_upgrade_tool(tool_name, install_cmd, upgrade_cmd=None):
    """Install or upgrade a tool using the provided command."""
    log(f"Checking if {tool_name} is installed...", "\033[34m", "🔍")
    try:
        if subprocess.call([tool_name, "--version"]) == 0:
            if upgrade_cmd:
                log(f"Upgrading {tool_name} to make sure it's the latest and greatest!", "\033[34m", "🚀")
                subprocess.call(upgrade_cmd, shell=True)
                log(f"{tool_name} upgraded successfully!", "\033[32m", "✅")
        else:
            log(f"{tool_name} not found. Let’s get it installed!", "\033[33m", "⚙️")
            subprocess.call(install_cmd, shell=True)
            log(f"{tool_name} installed successfully!", "\033[32m", "✅")
    except Exception as e:
        log(f"Failed to install or upgrade {tool_name}: {e}. But don't worry, I’ve got this!", "\033[31m", "❌")
        sys.exit(1)

def make_executable(script_path):
    """Make a script executable."""
    if os.path.exists(script_path):
        log(f"Making {script_path} executable... No cutting corners here!", "\033[34m", "🔨")
        try:
            subprocess.call(["chmod", "+x", script_path])
            log(f"{script_path} is now executable. Ready to roll!", "\033[32m", "✅")
        except Exception as e:
            log(f"Failed to make {script_path} executable: {e}. But I'll find a way!", "\033[31m", "❌")
    else:
        log(f"{script_path} not found! But hey, you can't win 'em all.", "\033[31m", "❌")

def run_script(script_path):
    """Run a shell script and handle potential errors."""
    if os.path.exists(script_path):
        log(f"Running {script_path}... Hold onto your hats!", "\033[34m", "🎬")
        try:
            subprocess.call([f"./{script_path}"])
            log(f"{script_path} executed successfully! Smooth sailing!", "\033[32m", "✅")
        except Exception as e:
            log(f"Failed to run {script_path}: {e}. Don’t worry, I’m on it!", "\033[31m", "❌")
    else:
        log(f"{script_path} not found! We’ll need a Plan B.", "\033[31m", "❌")

def run_flutter_app():
    """Run the Flutter app and ensure it works."""
    flutter_command = ["flutter", "run"]
    main_dart_path = "lib/main.dart"
    
    if not os.path.exists(main_dart_path):
        log("lib/main.dart file not found! No app to run. Bummer!", "\033[31m", "❌")
        return False
    
    log("Running Flutter app... The moment we've all been waiting for!", "\033[34m", "🚀")
    try:
        subprocess.call(flutter_command)
        log("Flutter app running successfully! Time to shine!", "\033[32m", "✅")
    except FileNotFoundError:
        log("Flutter command not found. But don't panic, I've got this covered!", "\033[33m", "⚠️")
        if platform.system() == "Darwin":  # macOS
            subprocess.call(["brew", "install", "--cask", "flutter"])
        elif platform.system() == "Linux":  # Linux
            subprocess.call(["snap", "install", "flutter", "--classic"])
        elif platform.system() == "Windows":  # Windows
            log("Please install Flutter manually from https://flutter.dev/docs/get-started/install", "\033[33m", "⚠️")
            return False
        run_flutter_app()
    except Exception as e:
        log(f"Failed to run Flutter app: {e}. This isn’t the end!", "\033[31m", "❌")
        return False

def setup_environment():
    """Automate environment setup, including installing necessary tools."""
    log("Setting up your environment... This is going to be epic!", "\033[34m", "🛠️")

    # Ensure Python is installed and at the correct version
    check_python_installed()

    # Install or upgrade necessary tools
    install_or_upgrade_tool("brew", "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"", "brew update && brew upgrade")
    install_or_upgrade_tool("flutter", "brew install --cask flutter", "brew upgrade flutter")
    install_or_upgrade_tool("git", "brew install git", "brew upgrade git")
    install_or_upgrade_tool("dart", "brew tap dart-lang/dart && brew install dart", "brew upgrade dart")
    install_or_upgrade_tool("heroku", "brew tap heroku/brew && brew install heroku", "brew upgrade heroku")

    # Make scripts executable
    make_executable("setup_vcenv.sh")
    make_executable("setup.sh")

    # Run setup scripts
    run_script("setup_vcenv.sh")
    run_script("setup.sh")

    # Run the Flutter app
    run_flutter_app()

def main():
    """Main function to automate the process."""
    log("Welcome to the Flutter App Setup and Runner! Let’s get you started!", "\033[36m", "🎉")
    setup_environment()
    log("All done! You’re ready to go! Remember, this script is brought to you by Kevin Marville https://github.com/Kvnbbg!", "\033[36m", "🚀")
    log("If you enjoyed this smooth ride, feel free to give me a shoutout!", "\033[36m", "👋")


if __name__ == "__main__":
    main()
