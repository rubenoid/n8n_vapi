#!/bin/bash

# n8n + Vapi Installation Script
# This script automates the setup process for n8n with Vapi integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}==================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check if Docker is installed
check_docker() {
    print_info "Checking for Docker..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        echo "Please install Docker Desktop from:"
        echo "  Mac: https://docs.docker.com/desktop/install/mac-install/"
        echo "  Windows: https://docs.docker.com/desktop/install/windows-install/"
        echo "  Linux: https://docs.docker.com/desktop/install/linux-install/"
        exit 1
    fi
    print_success "Docker is installed ($(docker --version))"
}

# Check if Docker Compose is installed
check_docker_compose() {
    print_info "Checking for Docker Compose..."
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed!"
        echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Check if Docker daemon is running
check_docker_running() {
    print_info "Checking if Docker is running..."
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running!"
        echo "Please start Docker Desktop and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Setup environment file
setup_env() {
    print_header "Setting up environment configuration"

    if [ -f ".env" ]; then
        print_warning ".env file already exists"
        read -p "Do you want to overwrite it? (y/N): " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_info "Keeping existing .env file"
            return
        fi
    fi

    cp .env.example .env
    print_success "Created .env file from .env.example"

    # Prompt for Vapi credentials
    echo ""
    print_info "Let's configure your Vapi credentials"
    echo "You can skip this now and edit .env manually later"
    echo ""

    read -p "Enter your Vapi API Key (or press Enter to skip): " vapi_key
    if [ ! -z "$vapi_key" ]; then
        sed -i.bak "s|VAPI_API_KEY=.*|VAPI_API_KEY=$vapi_key|g" .env
        rm -f .env.bak
        print_success "Vapi API Key configured"
    fi

    read -p "Enter your Vapi Phone Number (e.g., +1234567890, or press Enter to skip): " vapi_phone
    if [ ! -z "$vapi_phone" ]; then
        sed -i.bak "s|VAPI_PHONE_NUMBER=.*|VAPI_PHONE_NUMBER=$vapi_phone|g" .env
        rm -f .env.bak
        print_success "Vapi Phone Number configured"
    fi

    read -p "Enter your Vapi Assistant ID (or press Enter to skip): " vapi_assistant
    if [ ! -z "$vapi_assistant" ]; then
        sed -i.bak "s|VAPI_ASSISTANT_ID=.*|VAPI_ASSISTANT_ID=$vapi_assistant|g" .env
        rm -f .env.bak
        print_success "Vapi Assistant ID configured"
    fi
}

# Start Docker containers
start_docker() {
    print_header "Starting n8n with Docker Compose"

    print_info "Pulling Docker images (this may take a few minutes on first run)..."
    docker-compose pull

    print_info "Starting containers..."
    docker-compose up -d

    print_success "n8n container started successfully!"
}

# Check container health
check_health() {
    print_header "Checking container health"

    print_info "Waiting for n8n to be ready..."
    sleep 5

    if docker-compose ps | grep -q "Up"; then
        print_success "n8n is running!"
    else
        print_error "n8n failed to start. Check logs with: docker-compose logs"
        exit 1
    fi
}

# Print next steps
print_next_steps() {
    print_header "Installation Complete! 🎉"

    echo "n8n is now running at: ${GREEN}http://localhost:5678${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. ${YELLOW}Open n8n in your browser:${NC}"
    echo "   http://localhost:5678"
    echo ""
    echo "2. ${YELLOW}Set up a tunnel for webhooks (required for Vapi):${NC}"
    echo "   Install ngrok: https://ngrok.com/download"
    echo "   Run: ${GREEN}ngrok http 5678${NC}"
    echo "   Copy the HTTPS URL (e.g., https://abc123.ngrok.io)"
    echo ""
    echo "3. ${YELLOW}Update your .env file with the ngrok URL:${NC}"
    echo "   ${GREEN}WEBHOOK_URL=https://your-ngrok-url.ngrok.io${NC}"
    echo "   Then restart: ${GREEN}docker-compose restart${NC}"
    echo ""
    echo "4. ${YELLOW}Configure Vapi to use your webhook URL${NC}"
    echo "   Go to: https://dashboard.vapi.ai/"
    echo ""
    echo "${BLUE}Useful commands:${NC}"
    echo "  View logs:     ${GREEN}docker-compose logs -f${NC}"
    echo "  Stop n8n:      ${GREEN}docker-compose down${NC}"
    echo "  Restart n8n:   ${GREEN}docker-compose restart${NC}"
    echo "  Update n8n:    ${GREEN}docker-compose pull && docker-compose up -d${NC}"
    echo ""
    echo "For detailed documentation, see: ${GREEN}README.md${NC}"
    echo ""
}

# Main installation flow
main() {
    print_header "n8n + Vapi Installation Script"

    # Prerequisites check
    check_docker
    check_docker_compose
    check_docker_running

    # Setup
    setup_env
    start_docker
    check_health

    # Done
    print_next_steps
}

# Run main function
main
