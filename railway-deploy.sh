#!/bin/bash

# Vision Week Virtual Exploration - Railway Deployment Script
# Usage: ./scripts/railway-deploy.sh [environment] [action]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RAILWAY_PROJECT_NAME="vision-week-virtual-exploration"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
Vision Week Virtual Exploration - Railway Deployment Script

Usage: $0 [environment] [action] [options]

Environments:
  production     Deploy to production environment
  staging        Deploy to staging environment

Actions:
  setup          Setup Railway project and services
  deploy         Deploy application to Railway
  status         Show deployment status
  logs           Show application logs
  env            Manage environment variables
  rollback       Rollback to previous deployment
  cleanup        Clean up resources

Options:
  --token TOKEN  Railway authentication token
  --service NAME Specific service to deploy
  --follow       Follow logs in real-time
  --help         Show this help message

Examples:
  $0 production setup
  $0 staging deploy
  $0 production status
  $0 production logs --follow
  $0 staging env set DB_PASSWORD=secret
EOF
}

# Validation functions
validate_environment() {
    local env="$1"
    case "$env" in
        production|staging)
            return 0
            ;;
        *)
            log_error "Invalid environment: $env"
            log_info "Valid environments: production, staging"
            exit 1
            ;;
    esac
}

validate_prerequisites() {
    # Check Railway CLI
    if ! command -v railway >/dev/null 2>&1; then
        log_error "Railway CLI is not installed"
        log_info "Install it with: npm install -g @railway/cli"
        exit 1
    fi
    
    # Check authentication
    if ! railway whoami >/dev/null 2>&1; then
        log_error "Not authenticated with Railway"
        log_info "Login with: railway login"
        exit 1
    fi
}

# Setup functions
setup_railway_project() {
    local environment="$1"
    
    log_info "Setting up Railway project for $environment environment..."
    
    cd "$PROJECT_DIR"
    
    # Create or link project
    if [ ! -f ".railway/project.json" ]; then
        log_info "Creating new Railway project..."
        railway project create "$RAILWAY_PROJECT_NAME-$environment"
    else
        log_info "Using existing Railway project..."
    fi
    
    # Setup services
    setup_services "$environment"
    
    # Configure environment variables
    setup_environment_variables "$environment"
    
    log_success "Railway project setup completed"
}

setup_services() {
    local environment="$1"
    
    log_info "Setting up Railway services..."
    
    # Main application service
    log_info "Creating main application service..."
    railway service create vision-week-app || true
    
    # PostgreSQL database
    log_info "Creating PostgreSQL database..."
    railway add postgresql || true
    
    # Redis cache
    log_info "Creating Redis cache..."
    railway add redis || true
    
    log_success "Services setup completed"
}

setup_environment_variables() {
    local environment="$1"
    
    log_info "Setting up environment variables for $environment..."
    
    # Application variables
    railway variables set APP_ENV="$environment"
    railway variables set APP_DEBUG="false"
    railway variables set NODE_ENV="$environment"
    
    # Database variables (will be auto-configured by Railway)
    log_info "Database variables will be auto-configured by Railway PostgreSQL plugin"
    
    # Redis variables (will be auto-configured by Railway)
    log_info "Redis variables will be auto-configured by Railway Redis plugin"
    
    # Security variables (should be set manually for security)
    log_warning "Please set the following security variables manually:"
    echo "  railway variables set APP_KEY=<your-app-key>"
    echo "  railway variables set JWT_SECRET=<your-jwt-secret>"
    
    log_success "Environment variables setup completed"
}

# Deployment functions
deploy_to_railway() {
    local environment="$1"
    local service="${2:-}"
    
    log_info "Deploying to Railway $environment environment..."
    
    cd "$PROJECT_DIR"
    
    # Switch to correct environment
    railway environment use "$environment" || railway environment create "$environment"
    
    if [ -n "$service" ]; then
        log_info "Deploying specific service: $service"
        railway service use "$service"
        railway up
    else
        log_info "Deploying all services..."
        railway up
    fi
    
    # Wait for deployment to complete
    log_info "Waiting for deployment to complete..."
    sleep 30
    
    # Get deployment URL
    local app_url
    app_url=$(railway domain | grep -o 'https://[^[:space:]]*' | head -1)
    
    if [ -n "$app_url" ]; then
        log_success "Deployment completed successfully!"
        log_info "Application URL: $app_url"
        
        # Run health check
        run_health_check "$app_url"
    else
        log_warning "Could not retrieve application URL"
    fi
}

# Health check functions
run_health_check() {
    local url="$1"
    
    log_info "Running health check..."
    
    # Wait for application to be ready
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url/health" >/dev/null 2>&1; then
            log_success "Health check passed!"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts - waiting for application to be ready..."
        sleep 10
        ((attempt++))
    done
    
    log_error "Health check failed after $max_attempts attempts"
    return 1
}

# Status functions
show_status() {
    local environment="$1"
    
    log_info "Railway deployment status for $environment environment:"
    echo
    
    # Switch to environment
    railway environment use "$environment" 2>/dev/null || {
        log_error "Environment $environment not found"
        return 1
    }
    
    # Show project info
    echo "Project Information:"
    railway status
    echo
    
    # Show services
    echo "Services:"
    railway service list
    echo
    
    # Show deployments
    echo "Recent Deployments:"
    railway deployment list --limit 5
    echo
    
    # Show domains
    echo "Domains:"
    railway domain list
}

# Logging functions
show_logs() {
    local environment="$1"
    local follow="${2:-false}"
    local service="${3:-}"
    
    log_info "Showing logs for $environment environment..."
    
    # Switch to environment
    railway environment use "$environment" 2>/dev/null || {
        log_error "Environment $environment not found"
        return 1
    }
    
    if [ -n "$service" ]; then
        railway service use "$service"
    fi
    
    if [ "$follow" = "true" ]; then
        railway logs --follow
    else
        railway logs --tail 100
    fi
}

# Environment variable management
manage_environment_variables() {
    local environment="$1"
    local action="$2"
    shift 2
    
    # Switch to environment
    railway environment use "$environment" 2>/dev/null || {
        log_error "Environment $environment not found"
        return 1
    }
    
    case "$action" in
        list)
            railway variables list
            ;;
        set)
            if [ $# -eq 0 ]; then
                log_error "No variables provided"
                log_info "Usage: $0 $environment env set KEY=value [KEY2=value2 ...]"
                return 1
            fi
            
            for var in "$@"; do
                if [[ "$var" =~ ^[A-Z_][A-Z0-9_]*=.+ ]]; then
                    railway variables set "$var"
                    log_success "Set variable: ${var%%=*}"
                else
                    log_error "Invalid variable format: $var"
                    log_info "Use format: KEY=value"
                fi
            done
            ;;
        unset)
            if [ $# -eq 0 ]; then
                log_error "No variable names provided"
                return 1
            fi
            
            for var in "$@"; do
                railway variables unset "$var"
                log_success "Unset variable: $var"
            done
            ;;
        *)
            log_error "Invalid env action: $action"
            log_info "Valid actions: list, set, unset"
            return 1
            ;;
    esac
}

# Rollback functions
rollback_deployment() {
    local environment="$1"
    
    log_info "Rolling back deployment in $environment environment..."
    
    # Switch to environment
    railway environment use "$environment" 2>/dev/null || {
        log_error "Environment $environment not found"
        return 1
    }
    
    # Get previous deployment
    local previous_deployment
    previous_deployment=$(railway deployment list --limit 2 --json | jq -r '.[1].id' 2>/dev/null)
    
    if [ -n "$previous_deployment" ] && [ "$previous_deployment" != "null" ]; then
        log_info "Rolling back to deployment: $previous_deployment"
        railway deployment rollback "$previous_deployment"
        log_success "Rollback completed successfully"
    else
        log_error "No previous deployment found for rollback"
        return 1
    fi
}

# Cleanup functions
cleanup_resources() {
    local environment="$1"
    
    log_warning "This will delete the $environment environment and all its resources"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleaning up resources..."
        
        # Switch to environment
        railway environment use "$environment" 2>/dev/null || {
            log_error "Environment $environment not found"
            return 1
        }
        
        # Delete environment
        railway environment delete "$environment" --yes
        
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Main function
main() {
    local environment="${1:-}"
    local action="${2:-}"
    local token=""
    local service=""
    local follow="false"
    
    # Parse arguments
    shift 2 2>/dev/null || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --token)
                token="$2"
                shift 2
                ;;
            --service)
                service="$2"
                shift 2
                ;;
            --follow)
                follow="true"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                # For env command, pass remaining args
                if [ "$action" = "env" ]; then
                    break
                fi
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Show help if no arguments
    if [ -z "$environment" ] || [ -z "$action" ]; then
        show_help
        exit 1
    fi
    
    # Set Railway token if provided
    if [ -n "$token" ]; then
        export RAILWAY_TOKEN="$token"
    fi
    
    # Validate inputs
    validate_environment "$environment"
    validate_prerequisites
    
    # Execute action
    case "$action" in
        setup)
            setup_railway_project "$environment"
            ;;
        deploy)
            deploy_to_railway "$environment" "$service"
            ;;
        status)
            show_status "$environment"
            ;;
        logs)
            show_logs "$environment" "$follow" "$service"
            ;;
        env)
            if [ $# -eq 0 ]; then
                manage_environment_variables "$environment" "list"
            else
                local env_action="$1"
                shift
                manage_environment_variables "$environment" "$env_action" "$@"
            fi
            ;;
        rollback)
            rollback_deployment "$environment"
            ;;
        cleanup)
            cleanup_resources "$environment"
            ;;
        *)
            log_error "Invalid action: $action"
            log_info "Valid actions: setup, deploy, status, logs, env, rollback, cleanup"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"

