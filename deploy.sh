#!/bin/bash

# Vision Week Virtual Exploration - Deployment Script
# Usage: ./scripts/deploy.sh [environment] [action]
# Environments: development, staging, production
# Actions: build, deploy, rollback, status, logs, cleanup

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-vision-week}"
IMAGE_NAME="${IMAGE_NAME:-app}"
NAMESPACE_PREFIX="vision-week"

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
Vision Week Virtual Exploration - Deployment Script

Usage: $0 [environment] [action] [options]

Environments:
  development    Deploy to development environment
  staging        Deploy to staging environment  
  production     Deploy to production environment

Actions:
  build          Build Docker images
  deploy         Deploy to Kubernetes
  rollback       Rollback to previous version
  status         Show deployment status
  logs           Show application logs
  cleanup        Clean up resources
  test           Run health checks

Options:
  --tag TAG      Specify image tag (default: latest)
  --dry-run      Show what would be deployed without applying
  --force        Force deployment even if validation fails
  --help         Show this help message

Examples:
  $0 development build
  $0 production deploy --tag v2.0.0
  $0 staging status
  $0 development logs --follow
  $0 production rollback
EOF
}

# Validation functions
validate_environment() {
    local env="$1"
    case "$env" in
        development|staging|production)
            return 0
            ;;
        *)
            log_error "Invalid environment: $env"
            log_info "Valid environments: development, staging, production"
            exit 1
            ;;
    esac
}

validate_prerequisites() {
    local missing_tools=()
    
    # Check required tools
    command -v docker >/dev/null 2>&1 || missing_tools+=("docker")
    command -v kubectl >/dev/null 2>&1 || missing_tools+=("kubectl")
    command -v kustomize >/dev/null 2>&1 || missing_tools+=("kustomize")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and try again"
        exit 1
    fi
    
    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check Kubernetes connection
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
}

# Build functions
build_images() {
    local tag="${1:-latest}"
    local environment="${2:-production}"
    
    log_info "Building Docker images with tag: $tag"
    
    cd "$PROJECT_DIR"
    
    # Build main application image
    log_info "Building main application image..."
    docker build \
        --target "$environment" \
        --tag "$DOCKER_REGISTRY/$IMAGE_NAME:$tag" \
        --tag "$DOCKER_REGISTRY/$IMAGE_NAME:latest" \
        --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
        --build-arg VERSION="$tag" \
        .
    
    log_success "Docker images built successfully"
}

push_images() {
    local tag="${1:-latest}"
    
    log_info "Pushing Docker images to registry..."
    
    docker push "$DOCKER_REGISTRY/$IMAGE_NAME:$tag"
    docker push "$DOCKER_REGISTRY/$IMAGE_NAME:latest"
    
    log_success "Docker images pushed successfully"
}

# Deployment functions
deploy_to_kubernetes() {
    local environment="$1"
    local tag="${2:-latest}"
    local dry_run="${3:-false}"
    
    local namespace="$NAMESPACE_PREFIX"
    if [ "$environment" != "development" ]; then
        namespace="$NAMESPACE_PREFIX-$environment"
    fi
    
    log_info "Deploying to $environment environment (namespace: $namespace)"
    
    cd "$PROJECT_DIR"
    
    # Create namespace if it doesn't exist
    if [ "$dry_run" = "false" ]; then
        kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    # Prepare kustomization
    local kustomize_dir="k8s/overlays/$environment"
    if [ ! -d "$kustomize_dir" ]; then
        kustomize_dir="k8s/base"
        log_warning "No overlay found for $environment, using base configuration"
    fi
    
    # Update image tag
    cd "$kustomize_dir"
    kustomize edit set image "$DOCKER_REGISTRY/$IMAGE_NAME:$tag"
    
    # Apply configuration
    local kubectl_cmd="kubectl apply"
    if [ "$dry_run" = "true" ]; then
        kubectl_cmd="kubectl apply --dry-run=client"
    fi
    
    kustomize build . | $kubectl_cmd -f -
    
    if [ "$dry_run" = "false" ]; then
        # Wait for deployment to complete
        log_info "Waiting for deployment to complete..."
        kubectl rollout status deployment/vision-week-app -n "$namespace" --timeout=600s
        
        log_success "Deployment completed successfully"
        
        # Run health checks
        run_health_checks "$environment"
    else
        log_info "Dry run completed - no changes applied"
    fi
}

# Health check functions
run_health_checks() {
    local environment="$1"
    local namespace="$NAMESPACE_PREFIX"
    if [ "$environment" != "development" ]; then
        namespace="$NAMESPACE_PREFIX-$environment"
    fi
    
    log_info "Running health checks..."
    
    # Check pod status
    local ready_pods
    ready_pods=$(kubectl get pods -n "$namespace" -l app=vision-week-virtual-exploration --field-selector=status.phase=Running --no-headers | wc -l)
    
    if [ "$ready_pods" -gt 0 ]; then
        log_success "$ready_pods pods are running"
    else
        log_error "No pods are running"
        return 1
    fi
    
    # Check service endpoints
    local service_name="vision-week-app-service"
    if kubectl get service "$service_name" -n "$namespace" >/dev/null 2>&1; then
        local endpoints
        endpoints=$(kubectl get endpoints "$service_name" -n "$namespace" -o jsonpath='{.subsets[0].addresses[*].ip}' | wc -w)
        
        if [ "$endpoints" -gt 0 ]; then
            log_success "Service has $endpoints healthy endpoints"
        else
            log_warning "Service has no healthy endpoints"
        fi
    fi
    
    # Test application health endpoint
    if command -v curl >/dev/null 2>&1; then
        local health_url
        if [ "$environment" = "production" ]; then
            health_url="https://vision-week.com/health"
        else
            # Port forward for testing
            kubectl port-forward service/vision-week-app-service 8080:80 -n "$namespace" >/dev/null 2>&1 &
            local port_forward_pid=$!
            sleep 2
            health_url="http://localhost:8080/health"
        fi
        
        if curl -f -s "$health_url" >/dev/null 2>&1; then
            log_success "Application health check passed"
        else
            log_warning "Application health check failed"
        fi
        
        # Clean up port forward
        if [ -n "${port_forward_pid:-}" ]; then
            kill "$port_forward_pid" 2>/dev/null || true
        fi
    fi
}

# Rollback functions
rollback_deployment() {
    local environment="$1"
    local namespace="$NAMESPACE_PREFIX"
    if [ "$environment" != "development" ]; then
        namespace="$NAMESPACE_PREFIX-$environment"
    fi
    
    log_info "Rolling back deployment in $environment environment..."
    
    kubectl rollout undo deployment/vision-week-app -n "$namespace"
    kubectl rollout status deployment/vision-week-app -n "$namespace" --timeout=300s
    
    log_success "Rollback completed successfully"
}

# Status functions
show_status() {
    local environment="$1"
    local namespace="$NAMESPACE_PREFIX"
    if [ "$environment" != "development" ]; then
        namespace="$NAMESPACE_PREFIX-$environment"
    fi
    
    log_info "Deployment status for $environment environment:"
    echo
    
    # Show deployments
    echo "Deployments:"
    kubectl get deployments -n "$namespace" -l app=vision-week-virtual-exploration
    echo
    
    # Show pods
    echo "Pods:"
    kubectl get pods -n "$namespace" -l app=vision-week-virtual-exploration
    echo
    
    # Show services
    echo "Services:"
    kubectl get services -n "$namespace" -l app=vision-week-virtual-exploration
    echo
    
    # Show ingress
    echo "Ingress:"
    kubectl get ingress -n "$namespace" -l app=vision-week-virtual-exploration
}

# Logging functions
show_logs() {
    local environment="$1"
    local follow="${2:-false}"
    local namespace="$NAMESPACE_PREFIX"
    if [ "$environment" != "development" ]; then
        namespace="$NAMESPACE_PREFIX-$environment"
    fi
    
    local kubectl_cmd="kubectl logs"
    if [ "$follow" = "true" ]; then
        kubectl_cmd="kubectl logs -f"
    fi
    
    log_info "Showing logs for $environment environment..."
    
    $kubectl_cmd -n "$namespace" -l app=vision-week-virtual-exploration --tail=100
}

# Cleanup functions
cleanup_resources() {
    local environment="$1"
    local namespace="$NAMESPACE_PREFIX"
    if [ "$environment" != "development" ]; then
        namespace="$NAMESPACE_PREFIX-$environment"
    fi
    
    log_warning "This will delete all resources in namespace: $namespace"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleaning up resources..."
        kubectl delete namespace "$namespace" --ignore-not-found=true
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Main function
main() {
    local environment="${1:-}"
    local action="${2:-}"
    local tag="latest"
    local dry_run="false"
    local force="false"
    local follow="false"
    
    # Parse arguments
    shift 2 2>/dev/null || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --tag)
                tag="$2"
                shift 2
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            --force)
                force="true"
                shift
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
    
    # Validate inputs
    validate_environment "$environment"
    validate_prerequisites
    
    # Execute action
    case "$action" in
        build)
            build_images "$tag" "$environment"
            ;;
        deploy)
            build_images "$tag" "$environment"
            push_images "$tag"
            deploy_to_kubernetes "$environment" "$tag" "$dry_run"
            ;;
        rollback)
            rollback_deployment "$environment"
            ;;
        status)
            show_status "$environment"
            ;;
        logs)
            show_logs "$environment" "$follow"
            ;;
        cleanup)
            cleanup_resources "$environment"
            ;;
        test)
            run_health_checks "$environment"
            ;;
        *)
            log_error "Invalid action: $action"
            log_info "Valid actions: build, deploy, rollback, status, logs, cleanup, test"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"

