#!/bin/bash

# Resource monitoring script for same-server deployment
# Monitors Grafana stack resource usage and alerts if limits are exceeded

set -e

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Thresholds (adjust based on your server capacity)
MAX_MEMORY_PERCENT=70    # Alert if total system memory usage > 70%
MAX_CPU_PERCENT=60       # Alert if CPU usage > 60%
MAX_DISK_PERCENT=80      # Alert if disk usage > 80%

echo "🔍 Grafana Stack Resource Monitor - $(date)"
echo "=================================================="

# Check if containers are running
CONTAINERS=("loki-secmon" "grafana-secmon" "promtail-secmon")
echo -e "\n📦 Container Status:"
for container in "${CONTAINERS[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        echo -e "  ✅ $container: ${GREEN}Running${NC}"
    else
        echo -e "  ❌ $container: ${RED}Not Running${NC}"
    fi
done

# Get container resource usage
echo -e "\n💾 Container Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" | grep -E "(loki-secmon|grafana-secmon|promtail-secmon|CONTAINER)"

# System-wide resource check
echo -e "\n🖥️  System Resources:"

# Memory usage
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
echo -e "  Memory Usage: ${MEMORY_USAGE}%"
if (( $(echo "$MEMORY_USAGE > $MAX_MEMORY_PERCENT" | bc -l) )); then
    echo -e "  ${RED}⚠️  WARNING: Memory usage above ${MAX_MEMORY_PERCENT}%${NC}"
fi

# CPU usage (1-minute average)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
echo -e "  CPU Usage: ${CPU_USAGE}%"
if (( $(echo "$CPU_USAGE > $MAX_CPU_PERCENT" | bc -l) )); then
    echo -e "  ${RED}⚠️  WARNING: CPU usage above ${MAX_CPU_PERCENT}%${NC}"
fi

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo -e "  Disk Usage: ${DISK_USAGE}%"
if [ "$DISK_USAGE" -gt "$MAX_DISK_PERCENT" ]; then
    echo -e "  ${RED}⚠️  WARNING: Disk usage above ${MAX_DISK_PERCENT}%${NC}"
fi

# Check Suricata process (critical - must not be affected)
echo -e "\n🛡️  Suricata Process Check:"
if pgrep -x "suricata" > /dev/null; then
    SURICATA_PID=$(pgrep -x "suricata")
    SURICATA_MEM=$(ps -p $SURICATA_PID -o %mem --no-headers | tr -d ' ')
    SURICATA_CPU=$(ps -p $SURICATA_PID -o %cpu --no-headers | tr -d ' ')
    echo -e "  ✅ Suricata running (PID: $SURICATA_PID)"
    echo -e "  📊 Suricata Memory: ${SURICATA_MEM}%"
    echo -e "  🔄 Suricata CPU: ${SURICATA_CPU}%"
else
    echo -e "  ${RED}❌ Suricata not running - CRITICAL!${NC}"
fi

# Log file sizes
echo -e "\n📄 Log File Sizes:"
if [ -d "/srv/campus-sim/logs/suricata" ]; then
    du -sh /srv/campus-sim/logs/suricata/* 2>/dev/null | head -5
else
    echo "  📂 Suricata logs directory not found"
fi

# Docker volume usage
echo -e "\n💿 Docker Volume Usage:"
docker system df

echo -e "\n🕐 Monitor completed at $(date)"
echo "=================================================="
