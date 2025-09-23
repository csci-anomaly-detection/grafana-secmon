#!/bin/bash

# Smart deployment script for servers with existing repositories
# Handles conflicts and provides safe installation options

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DEPLOYMENT_DIR="/opt/grafana-secmon"
REPO_URL="[YOUR_REPO_URL_HERE]"  # Replace with your actual repo URL
SERVICE_USER="grafana-secmon"

echo -e "${BLUE}🚀 Smart Grafana Security Monitoring Deployment${NC}"
echo "=================================================="

# Function to check if we're on the target server
check_environment() {
    echo -e "\n${YELLOW}🔍 Environment Check${NC}"
    
    # Check if this looks like the security monitoring server
    if [ -d "/srv/campus-sim" ]; then
        echo -e "  ✅ Found /srv/campus-sim - looks like the right server"
        SURICATA_LOGS="/srv/campus-sim/logs/suricata"
    else
        echo -e "  ⚠️  /srv/campus-sim not found - might be different server"
        SURICATA_LOGS="/var/log/suricata"  # fallback
    fi
    
    # Check for existing repositories
    echo -e "\n📂 Existing repositories found:"
    find /home /srv /opt -maxdepth 3 -name ".git" -type d 2>/dev/null | head -5 | sed 's/^/  /'
}

# Function to create deployment directory
setup_deployment_dir() {
    echo -e "\n${YELLOW}📁 Setting up deployment directory${NC}"
    
    if [ -d "$DEPLOYMENT_DIR" ]; then
        echo -e "  ⚠️  Directory $DEPLOYMENT_DIR already exists"
        echo -e "  ${RED}Choose action:${NC}"
        echo "  1) Backup existing and continue"
        echo "  2) Use different directory"
        echo "  3) Abort deployment"
        read -p "  Choice (1-3): " choice
        
        case $choice in
            1)
                sudo mv "$DEPLOYMENT_DIR" "${DEPLOYMENT_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
                echo -e "  ✅ Existing directory backed up"
                ;;
            2)
                read -p "  Enter new directory path: " DEPLOYMENT_DIR
                ;;
            3)
                echo -e "  ${RED}Deployment aborted${NC}"
                exit 1
                ;;
        esac
    fi
    
    # Create directory
    sudo mkdir -p "$DEPLOYMENT_DIR"
    sudo chown $USER:$USER "$DEPLOYMENT_DIR"
    echo -e "  ✅ Deployment directory ready: $DEPLOYMENT_DIR"
}

# Function to deploy the monitoring stack
deploy_stack() {
    echo -e "\n${YELLOW}📦 Deploying Grafana Stack${NC}"
    
    cd "$DEPLOYMENT_DIR"
    
    # Clone or update repository
    if [ -d ".git" ]; then
        echo -e "  🔄 Updating existing repository"
        git pull origin main
    else
        echo -e "  📥 Cloning monitoring repository"
        git clone "$REPO_URL" .
    fi
    
    # Make scripts executable
    chmod +x scripts/*.sh
    
    echo -e "  ✅ Repository deployed"
}

# Function to configure for server environment
configure_for_server() {
    echo -e "\n${YELLOW}⚙️  Configuring for server environment${NC}"
    
    # Update docker-compose to use real Suricata logs
    if [ -f "docker/docker-compose.same-server.yml" ]; then
        # Update the promtail volume to point to real logs
        sed -i "s|/var/log/campus-sim|$SURICATA_LOGS|g" docker/docker-compose.same-server.yml
        echo -e "  ✅ Updated log paths to: $SURICATA_LOGS"
    fi
    
    # Create systemd service for auto-start
    create_systemd_service
    
    echo -e "  ✅ Server configuration complete"
}

# Function to create systemd service
create_systemd_service() {
    echo -e "\n${YELLOW}🔧 Creating systemd service${NC}"
    
    sudo tee /etc/systemd/system/grafana-secmon.service > /dev/null << EOF
[Unit]
Description=Grafana Security Monitoring Stack
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DEPLOYMENT_DIR/docker
ExecStart=/usr/bin/docker-compose -f docker-compose.same-server.yml up -d
ExecStop=/usr/bin/docker-compose -f docker-compose.same-server.yml down
TimeoutStartSec=0
User=$USER

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable grafana-secmon.service
    
    echo -e "  ✅ Systemd service created and enabled"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "\n${YELLOW}📋 Checking prerequisites${NC}"
    
    # Check Docker
    if command -v docker >/dev/null 2>&1; then
        echo -e "  ✅ Docker installed"
    else
        echo -e "  ❌ Docker not found - installing..."
        install_docker
    fi
    
    # Check Docker Compose
    if command -v docker-compose >/dev/null 2>&1; then
        echo -e "  ✅ Docker Compose installed"
    else
        echo -e "  ❌ Docker Compose not found - installing..."
        install_docker_compose
    fi
    
    # Check if user can run Docker
    if groups $USER | grep &>/dev/null '\bdocker\b'; then
        echo -e "  ✅ User in docker group"
    else
        echo -e "  ⚠️  Adding user to docker group"
        sudo usermod -aG docker $USER
        echo -e "  ${YELLOW}⚠️  Please log out and back in for docker group to take effect${NC}"
    fi
}

# Function to install Docker (if needed)
install_docker() {
    echo -e "  📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
}

# Function to install Docker Compose (if needed)
install_docker_compose() {
    echo -e "  📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Function to deploy and start
deploy_and_start() {
    echo -e "\n${YELLOW}🚀 Starting deployment${NC}"
    
    cd "$DEPLOYMENT_DIR/docker"
    
    # Use conservative deployment for server
    echo -e "  🔄 Starting with ultra-conservative settings..."
    docker-compose -f docker-compose.ultra-conservative.yml up -d
    
    # Wait for services to start
    echo -e "  ⏳ Waiting for services to start..."
    sleep 30
    
    # Check status
    echo -e "\n📊 Service Status:"
    docker-compose -f docker-compose.ultra-conservative.yml ps
    
    echo -e "\n✅ Deployment complete!"
    echo -e "  🌐 Grafana: http://$(hostname -I | awk '{print $1}'):3000"
    echo -e "  🔑 Login: admin/secmon_admin_2025"
    echo -e "  📊 Monitor: $DEPLOYMENT_DIR/scripts/monitor-resources.sh"
}

# Main execution
main() {
    check_environment
    setup_deployment_dir
    check_prerequisites
    deploy_stack
    configure_for_server
    deploy_and_start
    
    echo -e "\n${GREEN}🎉 Grafana Security Monitoring deployed successfully!${NC}"
    echo -e "=================================================="
    echo -e "Next steps:"
    echo -e "1. Access Grafana at http://[server-ip]:3000"
    echo -e "2. Monitor resources: $DEPLOYMENT_DIR/scripts/monitor-resources.sh"
    echo -e "3. Emergency stop: $DEPLOYMENT_DIR/scripts/emergency-shutdown.sh"
}

# Run main function
main "$@"
