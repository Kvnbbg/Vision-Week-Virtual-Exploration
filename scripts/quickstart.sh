#!/usr/bin/env bash
# Vision Week Virtual Exploration quickstart helper
# Usage: scripts/quickstart.sh [web|android] [options]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_COMPOSE_FILE="${PROJECT_ROOT}/docker-compose.yml"
DOCKER_PROJECT_NAME="visionweek-dev"
WEB_PORT="${WEB_PORT:-5173}"
WEB_HOST="${WEB_HOST:-0.0.0.0}"
BACKEND_SERVICES=(mysql_db slim_api websocket_server)
CLEANUP_REQUIRED=false

log() {
    local level="$1"; shift
    printf '[%s] %s\n' "$level" "$*"
}

usage() {
    cat <<USAGE
Vision Week Virtual Exploration quickstart

Usage: $(basename "$0") <web|android> [options]

Options:
  --skip-backend       (web) Skip starting Docker backend services
  --device <id>        (android) Explicit device id passed to flutter run/install
  --release            (android) Build a release APK/AppBundle instead of debug
  --help               Show this message

Environment overrides:
  WEB_PORT             Port for flutter web-server (default: ${WEB_PORT})
  WEB_HOST             Hostname for flutter web-server (default: ${WEB_HOST})
USAGE
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log ERROR "Missing required command: $cmd"
        exit 1
    fi
}

start_backend() {
    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
        log ERROR "docker-compose.yml not found at $DOCKER_COMPOSE_FILE"
        exit 1
    fi

    require_command docker

    log INFO "Starting API, WebSocket, and MySQL services via Docker Compose..."
    docker compose -p "$DOCKER_PROJECT_NAME" -f "$DOCKER_COMPOSE_FILE" up -d "${BACKEND_SERVICES[@]}"
    CLEANUP_REQUIRED=true

    log INFO "Waiting for MySQL to accept connections..."
    until docker compose -p "$DOCKER_PROJECT_NAME" -f "$DOCKER_COMPOSE_FILE" exec -T mysql_db \
        mysqladmin ping -h "127.0.0.1" --silent >/dev/null 2>&1; do
        sleep 1
    done
}

stop_backend() {
    if [[ "$CLEANUP_REQUIRED" == true ]]; then
        log INFO "Stopping backend containers..."
        docker compose -p "$DOCKER_PROJECT_NAME" -f "$DOCKER_COMPOSE_FILE" down --remove-orphans
    fi
}

run_web() {
    local skip_backend=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-backend)
                skip_backend=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log ERROR "Unknown option for web mode: $1"
                usage
                exit 1
                ;;
        esac
    done

    require_command flutter

    if [[ "$skip_backend" == false ]]; then
        start_backend
    else
        log INFO "Skipping backend bootstrap per user request"
    fi

    trap stop_backend EXIT

    log INFO "Fetching Flutter dependencies..."
    (cd "$PROJECT_ROOT" && flutter pub get)

    log INFO "Launching Flutter web-server on http://$WEB_HOST:$WEB_PORT"
    (cd "$PROJECT_ROOT" && flutter run -d web-server --web-port "$WEB_PORT" --web-hostname "$WEB_HOST")
}

run_android() {
    local device_id=""
    local build_mode="debug"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --device)
                device_id="$2"
                shift 2
                ;;
            --release)
                build_mode="release"
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log ERROR "Unknown option for android mode: $1"
                usage
                exit 1
                ;;
        esac
    done

    require_command flutter

    log INFO "Fetching Flutter dependencies..."
    (cd "$PROJECT_ROOT" && flutter pub get)

    if [[ "$build_mode" == "release" ]]; then
        log INFO "Building signed-ready release bundle..."
        (cd "$PROJECT_ROOT" && flutter build appbundle --obfuscate --split-debug-info=build/app/obfuscation-symbols)
        local bundle_path="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"
        if [[ -f "$bundle_path" ]]; then
            log INFO "Release bundle ready: $bundle_path"
        else
            log WARNING "Expected bundle not found at $bundle_path"
        fi
    else
        log INFO "Building debug APK..."
        (cd "$PROJECT_ROOT" && flutter build apk --debug)
        local apk_path="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"
        log INFO "Debug APK available at: $apk_path"

        if command -v adb >/dev/null 2>&1; then
            if adb get-state >/dev/null 2>&1; then
                log INFO "Installing APK on connected device..."
                if [[ -n "$device_id" ]]; then
                    adb -s "$device_id" install -r "$apk_path"
                else
                    adb install -r "$apk_path"
                fi
                log INFO "Launch the app from your device's app drawer"
            else
                log INFO "No Android device detected via adb; skip auto-install"
            fi
        else
            log INFO "adb not found; skipping device installation"
        fi
    fi

    log INFO "Android build complete"
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    case "$1" in
        web)
            shift
            run_web "$@"
            ;;
        android)
            shift
            run_android "$@"
            ;;
        --help|-h)
            usage
            ;;
        *)
            log ERROR "Unknown mode: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"
