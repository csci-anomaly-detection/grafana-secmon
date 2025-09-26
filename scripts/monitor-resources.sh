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

# Calculate total monitoring stack usage
echo -e "\n📊 Monitoring Stack Summary:"
TOTAL_STACK_MEMORY=0
TOTAL_STACK_CPU=0
for container in "loki-secmon" "grafana-secmon" "promtail-secmon"; do
    if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        CONTAINER_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" $container 2>/dev/null | sed 's/MiB.*//' | sed 's/GiB.*//')
        CONTAINER_CPU=$(docker stats --no-stream --format "{{.CPUPerc}}" $container 2>/dev/null | sed 's/%//')
        if [[ "$CONTAINER_MEM" =~ ^[0-9]+\.?[0-9]*$ ]] && [ $(echo "$CONTAINER_MEM > 0" | bc -l) -eq 1 ]; then
            TOTAL_STACK_MEMORY=$(echo "$TOTAL_STACK_MEMORY + $CONTAINER_MEM" | bc -l 2>/dev/null)
        fi
        if [[ "$CONTAINER_CPU" =~ ^[0-9]+\.?[0-9]*$ ]] && [ $(echo "$CONTAINER_CPU > 0" | bc -l) -eq 1 ]; then
            TOTAL_STACK_CPU=$(echo "$TOTAL_STACK_CPU + $CONTAINER_CPU" | bc -l 2>/dev/null)
        fi
    fi
done
if [ $(echo "$TOTAL_STACK_MEMORY > 0" | bc -l 2>/dev/null) -eq 1 ] 2>/dev/null; then
    STACK_MEMORY_PERCENT=$(echo "scale=2; $TOTAL_STACK_MEMORY * 100 / $MEMORY_TOTAL_MB" | bc -l 2>/dev/null)
    echo -e "  Total Stack Memory: ${TOTAL_STACK_MEMORY}MB (${STACK_MEMORY_PERCENT}% of system)"
else
    echo -e "  Total Stack Memory: Unable to calculate (containers may be starting)"
fi
echo -e "  Total Stack CPU: ${TOTAL_STACK_CPU}%"

# System-wide resource check
echo -e "\n🖥️  System Resources:"

# Memory usage (more accurate - uses actual available memory)
MEMORY_TOTAL=$(free | awk 'NR==2{print $2}')
MEMORY_AVAILABLE=$(free | awk 'NR==2{print $7}')
MEMORY_USED=$((MEMORY_TOTAL - MEMORY_AVAILABLE))
MEMORY_USAGE=$(echo "scale=1; $MEMORY_USED * 100 / $MEMORY_TOTAL" | bc -l)
MEMORY_USED_MB=$((MEMORY_USED / 1024))
MEMORY_TOTAL_MB=$((MEMORY_TOTAL / 1024))
echo -e "  Memory Usage: ${MEMORY_USAGE}% (${MEMORY_USED_MB}MB / ${MEMORY_TOTAL_MB}MB)"
if (( $(echo "$MEMORY_USAGE > $MAX_MEMORY_PERCENT" | bc -l) )); then
    echo -e "  ${RED}⚠️  WARNING: Memory usage above ${MAX_MEMORY_PERCENT}%${NC}"
fi

# CPU usage (using /proc/stat for accuracy)
CPU_LINE1=$(grep '^cpu ' /proc/stat)
sleep 1
CPU_LINE2=$(grep '^cpu ' /proc/stat)

CPU1_IDLE=$(echo $CPU_LINE1 | awk '{print $5}')
CPU1_TOTAL=$(echo $CPU_LINE1 | awk '{print $2+$3+$4+$5+$6+$7+$8}')
CPU2_IDLE=$(echo $CPU_LINE2 | awk '{print $5}')
CPU2_TOTAL=$(echo $CPU_LINE2 | awk '{print $2+$3+$4+$5+$6+$7+$8}')

CPU_IDLE_DELTA=$((CPU2_IDLE - CPU1_IDLE))
CPU_TOTAL_DELTA=$((CPU2_TOTAL - CPU1_TOTAL))

if [ $CPU_TOTAL_DELTA -gt 0 ]; then
    CPU_USAGE=$(echo "scale=1; 100 - ($CPU_IDLE_DELTA * 100 / $CPU_TOTAL_DELTA)" | bc -l)
else
    CPU_USAGE="0.0"
fi
echo -e "  CPU Usage: ${CPU_USAGE}%"
if (( $(echo "$CPU_USAGE > $MAX_CPU_PERCENT" | bc -l) )); then
    echo -e "  ${RED}⚠️  WARNING: CPU usage above ${MAX_CPU_PERCENT}%${NC}"
fi

# Load averages (more reliable for system health)
LOAD_AVERAGES=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
CPU_CORES=$(nproc)
LOAD_1MIN=$(echo $LOAD_AVERAGES | awk -F',' '{print $1}' | tr -d ' ')
LOAD_PERCENT=$(echo "scale=1; $LOAD_1MIN * 100 / $CPU_CORES" | bc -l)
echo -e "  Load Average: $LOAD_AVERAGES (${LOAD_PERCENT}% of ${CPU_CORES} cores)"
if (( $(echo "$LOAD_PERCENT > 80" | bc -l) )); then
    echo -e "  ${RED}⚠️  WARNING: High system load!${NC}"
fi

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo -e "  Disk Usage: ${DISK_USAGE}%"
if [ "$DISK_USAGE" -gt "$MAX_DISK_PERCENT" ]; then
    echo -e "  ${RED}⚠️  WARNING: Disk usage above ${MAX_DISK_PERCENT}%${NC}"
fi

# Check Suricata process (critical - must not be affected)
echo -e "\n🛡️  Suricata Process Check:"
# Try multiple patterns to find Suricata
SURICATA_PID=$(pgrep -f "suricata" | head -1)
if [ -z "$SURICATA_PID" ]; then
    SURICATA_PID=$(pgrep -f "Suricata" | head -1)
fi

if [ -n "$SURICATA_PID" ]; then
    SURICATA_CMD=$(ps -p $SURICATA_PID -o comm= 2>/dev/null)
    SURICATA_MEM=$(ps -p $SURICATA_PID -o %mem --no-headers 2>/dev/null | tr -d ' ')
    SURICATA_CPU=$(ps -p $SURICATA_PID -o %cpu --no-headers 2>/dev/null | tr -d ' ')
    SURICATA_RSS=$(ps -p $SURICATA_PID -o rss --no-headers 2>/dev/null | tr -d ' ')
    SURICATA_RSS_MB=$((SURICATA_RSS / 1024))
    
    echo -e "  ✅ Suricata running (PID: $SURICATA_PID, Command: $SURICATA_CMD)"
    echo -e "  📊 Suricata Memory: ${SURICATA_MEM}% (${SURICATA_RSS_MB}MB)"
    echo -e "  🔄 Suricata CPU: ${SURICATA_CPU}%"
    
    # Check if running in Docker
    if grep -q docker /proc/$SURICATA_PID/cgroup 2>/dev/null; then
        CONTAINER_NAME=$(docker ps --format "table {{.Names}}\t{{.ID}}" | grep $(cat /proc/$SURICATA_PID/cgroup | grep docker | head -1 | sed 's/.*docker\///;s/\.scope//') 2>/dev/null | awk '{print $1}')
        if [ -n "$CONTAINER_NAME" ]; then
            echo -e "  🐳 Running in Docker container: $CONTAINER_NAME"
        fi
    fi
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
