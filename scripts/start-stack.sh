#!/bin/bash

echo "🚀 Starting Grafana Security Monitoring Stack..."

cd "$(dirname "$0")/../docker"

# Start all services
docker-compose -f docker-compose.local.yml up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "✅ Stack started!"
echo ""
echo "🌐 Grafana: http://localhost:3000 (admin/admin123)"
echo "📊 Loki API: http://localhost:3100"
echo ""
echo "🛑 To stop: ./stop-stack.sh"
