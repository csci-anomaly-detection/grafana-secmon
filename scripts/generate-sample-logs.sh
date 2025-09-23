#!/bin/sh

# Sample log generator for local development
# Simulates Suricata logs for testing Grafana dashboards

LOG_DIR="/var/log/campus-sim/suricata"
mkdir -p "$LOG_DIR"

# Sample source and destination IPs
SRC_IPS=("192.168.1.100" "192.168.1.105" "10.0.0.50" "172.16.0.25" "192.168.1.200")
DEST_IPS=("8.8.8.8" "1.1.1.1" "192.168.1.1" "172.16.0.1" "10.0.0.1")
PORTS=(22 80 443 8080 3389 21 25 53 135 445)

# Alert signatures
SIGNATURES=(
    "ET SCAN SSH BruteForce Tool frequent connections"
    "ET MALWARE Suspicious outbound connection"
    "ET POLICY HTTP suspicious request"
    "ET SCAN Nmap TCP"
    "ET TROJAN Backdoor communication"
    "ET POLICY DNS over HTTPS DoH Query"
    "ET SCAN Port Scan detected"
    "ET WEB_SPECIFIC_APPS SQL Injection attempt"
)

CLASSIFICATIONS=(
    "Attempted Administrator Privilege Gain"
    "A Network Trojan was Detected"
    "Potentially Bad Traffic"
    "Detection of a Network Scan"
    "Generic Protocol Command Decode"
)

echo "🚀 Starting sample log generation..."

# Generate logs continuously
while true; do
    TIMESTAMP=$(date '+%m/%d/%Y-%H:%M:%S.%6N')
    SRC_IP=${SRC_IPS[$RANDOM % ${#SRC_IPS[@]}]}
    DEST_IP=${DEST_IPS[$RANDOM % ${#DEST_IPS[@]}]}
    SRC_PORT=$((RANDOM % 65535 + 1))
    DEST_PORT=${PORTS[$RANDOM % ${#PORTS[@]}]}
    SIGNATURE=${SIGNATURES[$RANDOM % ${#SIGNATURES[@]}]}
    CLASSIFICATION=${CLASSIFICATIONS[$RANDOM % ${#CLASSIFICATIONS[@]}]}
    PRIORITY=$((RANDOM % 3 + 1))
    GID=$((RANDOM % 10 + 1))
    SID=$((RANDOM % 999999 + 1))
    REV=$((RANDOM % 10 + 1))
    
    # Generate Fast Log entry
    echo "$TIMESTAMP [**] [$GID:$SID:$REV] $SIGNATURE [**] [Classification: $CLASSIFICATION] [Priority: $PRIORITY] {TCP} $SRC_IP:$SRC_PORT -> $DEST_IP:$DEST_PORT" >> "$LOG_DIR/fast.log"
    
    # Generate EVE JSON entry
    EVE_TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%S.%6NZ')
    cat >> "$LOG_DIR/eve.json" << EOF
{"timestamp":"$EVE_TIMESTAMP","flow_id":$((RANDOM*1000)),"event_type":"alert","src_ip":"$SRC_IP","src_port":$SRC_PORT,"dest_ip":"$DEST_IP","dest_port":$DEST_PORT,"proto":"TCP","alert":{"signature":"$SIGNATURE","category":"$CLASSIFICATION","severity":$PRIORITY,"gid":$GID,"signature_id":$SID,"rev":$REV}}
EOF
    
    # Occasionally generate flow events
    if [ $((RANDOM % 3)) -eq 0 ]; then
        cat >> "$LOG_DIR/eve.json" << EOF
{"timestamp":"$EVE_TIMESTAMP","flow_id":$((RANDOM*1000)),"event_type":"flow","src_ip":"$SRC_IP","src_port":$SRC_PORT,"dest_ip":"$DEST_IP","dest_port":$DEST_PORT,"proto":"TCP","flow":{"bytes_toserver":$((RANDOM*1000)),"bytes_toclient":$((RANDOM*2000)),"start":"$EVE_TIMESTAMP"}}
EOF
    fi
    
    # Random interval between 1-5 seconds
    sleep $((RANDOM % 5 + 1))
done
