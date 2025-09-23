#!/bin/bash

# Deploy Grafana stack on separate server
# Usage: ./deploy-separate-server.sh [MAIN_SERVER_IP]

set -e

MAIN_SERVER_IP=${1:-54.226.81.54}

echo "🚀 Deploying Grafana stack on separate server"
echo "📡 Main server IP: $MAIN_SERVER_IP"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please run as non-root user (ubuntu)"
    exit 1
fi

# Check available memory
AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')
echo "📊 Available memory: ${AVAILABLE_MEM}GB"

if (( $(echo "$AVAILABLE_MEM < 3.0" | bc -l) )); then
    echo "⚠️  Warning: Recommended minimum 4GB RAM for separate server deployment"
    echo "Available: ${AVAILABLE_MEM}GB"
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo usermod -aG docker ubuntu
    echo "🔄 Please log out and back in for Docker group membership to take effect"
    exit 1
fi

# Create data directories
echo "📁 Creating data directories..."
sudo mkdir -p /opt/logging/{loki-data,grafana-data}
sudo chown -R 472:472 /opt/logging/grafana-data   # Grafana user
sudo chown -R 10001:10001 /opt/logging/loki-data  # Loki user

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 3000 comment "Grafana"
sudo ufw allow from $MAIN_SERVER_IP to any port 3100 comment "Loki from main server"

# Stop existing services if running
echo "🛑 Stopping existing logging services..."
docker-compose -f docker/docker-compose.separate-server.yml down 2>/dev/null || true

# Pull latest images
echo "📥 Pulling Docker images..."
docker-compose -f docker/docker-compose.separate-server.yml pull

# Start services
echo "🚀 Starting logging stack..."
docker-compose -f docker/docker-compose.separate-server.yml up -d

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 45

# Check service health
echo "🔍 Checking service health..."
if docker-compose -f docker/docker-compose.separate-server.yml ps | grep -q "Up"; then
    echo "✅ Services started successfully"
else
    echo "❌ Some services failed to start"
    docker-compose -f docker/docker-compose.separate-server.yml ps
    exit 1
fi

# Test services
echo "🧪 Testing service connectivity..."

# Test Loki
if curl -s http://localhost:3100/ready > /dev/null; then
    echo "✅ Loki is ready"
else
    echo "❌ Loki not responding"
fi

# Test Grafana
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana is ready"
else
    echo "❌ Grafana not responding"
fi

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "UNKNOWN")

echo ""
echo "🎉 Deployment complete!"
echo "🌐 Public IP: $PUBLIC_IP"
echo "📊 Grafana: http://$PUBLIC_IP:3000"
echo "🔐 Login: admin / secmon_admin_2025"
echo "📈 Loki API: http://$PUBLIC_IP:3100"
echo ""
echo "🔧 Next steps:"
echo "1. Configure Security Groups in AWS Console:"
echo "   - Allow port 3000 from your IP for Grafana access"
echo "   - Port 3100 is already restricted to main server"
echo ""
echo "2. On main server ($MAIN_SERVER_IP), update Promtail config:"
echo "   clients:"
echo "     - url: http://$PUBLIC_IP:3100/loki/api/v1/push"
echo ""
echo "💡 Monitor resources: docker stats"
echo "📋 View logs: docker-compose -f docker/docker-compose.separate-server.yml logs"
