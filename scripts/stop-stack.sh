#!/bin/bash

echo "🛑 Stopping Grafana Security Monitoring Stack..."

cd "$(dirname "$0")/../docker"

# Stop all services
docker-compose -f docker-compose.local.yml down

echo "✅ All services stopped!"
echo ""
echo "💡 To restart later, run: ./start-stack.sh"
echo "🧹 To clean up data: docker-compose -f docker-compose.local.yml down -v"
