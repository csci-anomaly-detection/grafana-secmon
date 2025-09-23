#!/bin/bash

# Automated monitoring with alerts
# Run this every 5 minutes via cron to catch resource issues early

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/grafana-secmon-monitor.log"
ALERT_THRESHOLD_MEM=75    # Alert if memory > 75%
ALERT_THRESHOLD_CPU=70    # Alert if CPU > 70%

# Function to send alerts (customize this)
send_alert() {
    local message="$1"
    echo "$(date): ALERT - $message" >> "$LOG_FILE"
    
    # Add your alerting mechanism here:
    # - Email notification
    # - Slack webhook
    # - SMS alert
    # - System notification
    
    # Example: Log to system journal
    logger "GRAFANA-SECMON ALERT: $message"
}

# Function to auto-shutdown if critical
auto_shutdown_if_critical() {
    local mem_usage="$1"
    local cpu_usage="$2"
    
    # If memory > 85% OR CPU > 80%, auto-shutdown
    if (( $(echo "$mem_usage > 85" | bc -l) )) || (( $(echo "$cpu_usage > 80" | bc -l) )); then
        send_alert "CRITICAL: Auto-shutting down Grafana stack (MEM: ${mem_usage}%, CPU: ${cpu_usage}%)"
        "$SCRIPT_DIR/emergency-shutdown.sh" >> "$LOG_FILE" 2>&1
        return 0
    fi
    return 1
}

# Main monitoring logic
{
    echo "=== Automated Monitor Check: $(date) ==="
    
    # Check if containers are running
    if ! docker ps --format "{{.Names}}" | grep -q "loki-secmon\|grafana-secmon\|promtail-secmon"; then
        echo "INFO: Grafana stack not running, skipping resource check"
        exit 0
    fi
    
    # Get system resources
    MEMORY_USAGE=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    
    echo "System Resources: MEM=${MEMORY_USAGE}%, CPU=${CPU_USAGE}%"
    
    # Check for critical levels (auto-shutdown)
    if auto_shutdown_if_critical "$MEMORY_USAGE" "$CPU_USAGE"; then
        exit 1  # Critical shutdown performed
    fi
    
    # Check for warning levels
    if (( $(echo "$MEMORY_USAGE > $ALERT_THRESHOLD_MEM" | bc -l) )); then
        send_alert "Memory usage high: ${MEMORY_USAGE}% (threshold: ${ALERT_THRESHOLD_MEM}%)"
    fi
    
    if (( $(echo "$CPU_USAGE > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        send_alert "CPU usage high: ${CPU_USAGE}% (threshold: ${ALERT_THRESHOLD_CPU}%)"
    fi
    
    # Check Suricata process
    if ! pgrep -x "suricata" > /dev/null; then
        send_alert "CRITICAL: Suricata process not running!"
    fi
    
    # Check container resource usage
    docker stats --no-stream --format "{{.Container}}: CPU={{.CPUPerc}}, MEM={{.MemUsage}}" | grep -E "(loki-secmon|grafana-secmon|promtail-secmon)"
    
    echo "Monitor check completed successfully"
    
} >> "$LOG_FILE" 2>&1
