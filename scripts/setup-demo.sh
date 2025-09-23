#!/bin/bash

# Presentation Demo Setup Script
# Run this before your presentation to ensure everything works perfectly

set -e

echo "🎭 Setting up presentation demo environment..."

# Check if we're in the right directory
if [ ! -f "docker/docker-compose.local.yml" ]; then
    echo "❌ Please run this script from the grafana-secmon directory"
    exit 1
fi

# Start the local stack
echo "🚀 Starting demo environment..."
./scripts/deploy-local.sh

# Wait for services to be fully ready
echo "⏳ Waiting for all services to be ready for demo..."
sleep 60

# Test all endpoints
echo "🧪 Testing demo endpoints..."

# Test Grafana
if curl -s http://localhost:3000/api/health | grep -q "ok"; then
    echo "✅ Grafana ready for demo"
else
    echo "❌ Grafana not ready - check logs"
    exit 1
fi

# Test Loki
if curl -s http://localhost:3100/ready | grep -q "ready"; then
    echo "✅ Loki ready for demo"
else
    echo "❌ Loki not ready - check logs"
    exit 1
fi

# Check if we have sample data
echo "📊 Checking sample data availability..."
ALERT_COUNT=$(curl -s "http://localhost:3100/loki/api/v1/query?query={job=\"suricata\",event_type=\"alert\"}" | jq -r '.data.result | length')

if [ "$ALERT_COUNT" -gt 0 ]; then
    echo "✅ Sample alerts available: $ALERT_COUNT streams"
else
    echo "⚠️  No alerts yet - giving log generator more time..."
    sleep 30
fi

# Pre-load dashboards by accessing them
echo "📈 Pre-loading dashboards..."
curl -s "http://admin:admin123@localhost:3000/api/dashboards/uid/suricata-overview" > /dev/null
curl -s "http://admin:admin123@localhost:3000/api/dashboards/uid/network-traffic" > /dev/null

# Prepare demo URLs
echo ""
echo "🎬 DEMO READY! Here are your presentation URLs:"
echo ""
echo "📊 Main Dashboard: http://localhost:3000/d/suricata-overview"
echo "📈 Network Traffic: http://localhost:3000/d/network-traffic"
echo "🔍 Log Explorer: http://localhost:3000/explore"
echo "🔐 Login: admin / admin123"
echo ""

# Demo queries to show
echo "💡 DEMO QUERIES to show in Explore:"
echo ""
echo "1. Basic log query:"
echo '   {job="suricata"} | json'
echo ""
echo "2. Security alerts only:"
echo '   {job="suricata", event_type="alert"} | json'
echo ""
echo "3. Alert rate over time:"
echo '   rate({job="suricata", event_type="alert"}[5m])'
echo ""
echo "4. Top source IPs:"
echo '   topk(10, sum by (src_ip) (count_over_time({job="suricata", event_type="alert"} | json | src_ip != "" [1h])))'
echo ""
echo "5. SSH brute force attempts:"
echo '   {job="suricata", event_type="alert"} | json | alert_signature =~ ".*SSH.*"'
echo ""

# Create demo data summary
echo "📋 Current demo data status:"
docker-compose -f docker/docker-compose.local.yml exec -T log-generator find /var/log/campus-sim -name "*.log" -o -name "*.json" | while read file; do
    lines=$(docker-compose -f docker/docker-compose.local.yml exec -T log-generator wc -l < "$file" 2>/dev/null || echo "0")
    echo "   $(basename $file): $lines lines"
done

echo ""
echo "🎉 Demo environment is ready!"
echo "💡 Pro tip: Keep this terminal open to monitor services during your presentation"
echo ""
echo "🛑 To stop demo: docker-compose -f docker/docker-compose.local.yml down"
