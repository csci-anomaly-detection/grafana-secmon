#!/bin/bash

# Deploy Grafana stack locally for development and testing
# Usage: ./deploy-local.sh

set -e

echo "🚀 Deploying Grafana stack locally for development"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Create local data directories
echo "📁 Creating local data directories..."
mkdir -p loki-data grafana-data sample-logs/suricata

# Stop existing services if running
echo "🛑 Stopping existing local services..."
docker-compose -f docker/docker-compose.local.yml down 2>/dev/null || true

# Clean up old data for fresh start
read -p "🗑️  Clean up existing data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf loki-data/* grafana-data/* sample-logs/*
    echo "✅ Data cleaned"
fi

# Pull latest images
echo "📥 Pulling Docker images..."
docker-compose -f docker/docker-compose.local.yml pull

# Start services
echo "🚀 Starting local logging stack..."
docker-compose -f docker/docker-compose.local.yml up -d

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
if docker-compose -f docker/docker-compose.local.yml ps | grep -q "Up"; then
    echo "✅ Services started successfully"
else
    echo "❌ Some services failed to start"
    docker-compose -f docker/docker-compose.local.yml ps
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

echo ""
echo "🎉 Local deployment complete!"
echo "📊 Grafana: http://localhost:3000"
echo "🔐 Login: admin / admin123"
echo "📈 Loki API: http://localhost:3100"
echo ""
echo "🔬 Sample logs are being generated automatically"
echo "📋 View logs: docker-compose -f docker/docker-compose.local.yml logs"
echo "🛑 Stop: docker-compose -f docker/docker-compose.local.yml down"
echo ""
echo "💡 Try these queries in Grafana Explore:"
echo "   - {job=\"suricata\"} | json"
echo "   - {job=\"suricata\", event_type=\"alert\"}"
echo "   - rate({job=\"suricata\"}[5m])"
echo ""
echo "🚀 Once you're happy with the setup, deploy to your server!"

# Open Grafana in browser (macOS)
if command -v open &> /dev/null; then
    echo "🌐 Opening Grafana in browser..."
    sleep 5
    open http://localhost:3000
fi
