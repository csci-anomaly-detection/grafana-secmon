#!/bin/bash

# Emergency shutdown script for Grafana stack
# Use this if resource usage gets too high and threatens Suricata

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}🚨 EMERGENCY SHUTDOWN: Grafana Stack${NC}"
echo "======================================"

# Check current resource usage before shutdown
echo -e "\n📊 Current System State:"
free -h | head -2
top -bn1 | head -3

# Stop containers gracefully
echo -e "\n🛑 Stopping Grafana Stack containers..."

# Stop in reverse dependency order
CONTAINERS=("promtail-secmon" "grafana-secmon" "loki-secmon")
for container in "${CONTAINERS[@]}"; do
    if docker ps --format "{{.Names}}" | grep -q "$container"; then
        echo -e "  🔄 Stopping $container..."
        docker stop "$container" --time 10
        echo -e "  ✅ $container stopped"
    else
        echo -e "  ℹ️  $container not running"
    fi
done

# Force remove if they don't stop gracefully
echo -e "\n🧹 Cleaning up resources..."
docker system prune -f --volumes > /dev/null 2>&1

# Verify Suricata is still running
echo -e "\n🛡️  Verifying Suricata status:"
if pgrep -x "suricata" > /dev/null; then
    echo -e "  ✅ ${GREEN}Suricata still running - GOOD!${NC}"
    SURICATA_PID=$(pgrep -x "suricata")
    echo -e "  📊 Suricata PID: $SURICATA_PID"
else
    echo -e "  ❌ ${RED}Suricata not running - CHECK IMMEDIATELY!${NC}"
fi

# Final resource check
echo -e "\n📈 Post-shutdown system state:"
free -h | head -2
echo -e "\n✅ Emergency shutdown completed at $(date)"
echo "=================================================="
