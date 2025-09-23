#!/bin/bash

# Deploy Grafana stack on same server as Suricata (memory constrained)
# Usage: ./deploy-same-server.sh

set -e

echo "🚀 Deploying Grafana stack on same server (memory constrained)"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please run as non-root user (ubuntu)"
    exit 1
fi

# Check available memory
AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')
echo "📊 Available memory: ${AVAILABLE_MEM}GB"

if (( $(echo "$AVAILABLE_MEM < 1.5" | bc -l) )); then
    echo "⚠️  Warning: Low available memory. Consider separate server deployment."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create data directories
echo "📁 Creating data directories..."
sudo mkdir -p /opt/secmon/{loki-data,grafana-data}
sudo chown -R 472:472 /opt/secmon/grafana-data   # Grafana user
sudo chown -R 10001:10001 /opt/secmon/loki-data  # Loki user

# Check if Suricata logs exist
if [ ! -d "/srv/campus-sim/logs/suricata" ]; then
    echo "⚠️  Warning: Suricata logs directory not found at /srv/campus-sim/logs/suricata"
    echo "Please ensure Suricata is running and generating logs"
fi

# Stop existing services if running
echo "🛑 Stopping existing logging services..."
docker-compose -f docker/docker-compose.same-server.yml down 2>/dev/null || true

# Pull latest images
echo "📥 Pulling Docker images..."
docker-compose -f docker/docker-compose.same-server.yml pull

# Start services
echo "🚀 Starting logging stack..."
docker-compose -f docker/docker-compose.same-server.yml up -d

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
if docker-compose -f docker/docker-compose.same-server.yml ps | grep -q "Up"; then
    echo "✅ Services started successfully"
else
    echo "❌ Some services failed to start"
    docker-compose -f docker/docker-compose.same-server.yml ps
    exit 1
fi

# Test Loki connectivity
if curl -s http://localhost:3100/ready > /dev/null; then
    echo "✅ Loki is ready"
else
    echo "❌ Loki not responding"
fi

# Test Grafana connectivity
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana is ready"
else
    echo "❌ Grafana not responding"
fi

echo ""
echo "🎉 Deployment complete!"
echo "📊 Grafana: http://$(hostname -I | awk '{print $1}'):3000"
echo "🔐 Login: admin / secmon_admin_2025"
echo "📈 Loki API: http://$(hostname -I | awk '{print $1}'):3100"
echo ""
echo "💡 To monitor resource usage: docker stats"
echo "📋 To view logs: docker-compose -f docker/docker-compose.same-server.yml logs"
echo ""
echo "⚠️  Remember: This deployment has strict memory limits to protect Suricata"
