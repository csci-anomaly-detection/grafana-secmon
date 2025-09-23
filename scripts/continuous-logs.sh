#!/bin/bash

# Script to continuously add sample logs for demo purposes

LOG_DIR="../sample-logs/suricata"

# Arrays of sample data
SOURCE_IPS=("192.168.1.100" "192.168.1.105" "10.0.0.50" "172.16.0.25" "192.168.1.200" "172.16.0.100" "10.0.0.75")
DEST_IPS=("8.8.8.8" "1.1.1.1" "192.168.1.1" "172.16.0.1" "10.0.0.1" "172.217.12.46")
PORTS=(22 80 443 8080 3389 21 25 53 135 445 23)

SIGNATURES=(
    "ET SCAN SSH BruteForce Tool frequent connections"
    "ET MALWARE Suspicious outbound connection"
    "ET POLICY HTTP suspicious request"
    "ET SCAN Nmap TCP"
    "ET TROJAN Backdoor communication"
    "ET POLICY DNS over HTTPS DoH Query"
    "ET SCAN Port Scan detected"
    "ET WEB_SPECIFIC_APPS SQL Injection attempt"
    "ET SCAN RDP Brute Force attempt"
    "ET SCAN SMB Share Enumeration"
    "ET TROJAN DNS tunneling detected"
    "ET SCAN Telnet Brute Force attempt"
)

CATEGORIES=(
    "Attempted Administrator Privilege Gain"
    "A Network Trojan was Detected"
    "Potentially Bad Traffic"
    "Detection of a Network Scan"
    "Web Application Attack"
)

echo "🚀 Starting continuous log generation..."
echo "Press Ctrl+C to stop"

COUNTER=100000

while true; do
    TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%S.%6NZ')
    FAST_TIMESTAMP=$(date '+%m/%d/%Y-%H:%M:%S.%6N')
    SRC_IP=${SOURCE_IPS[$RANDOM % ${#SOURCE_IPS[@]}]}
    DEST_IP=${DEST_IPS[$RANDOM % ${#DEST_IPS[@]}]}
    SRC_PORT=$((RANDOM % 65535 + 1024))
    DEST_PORT=${PORTS[$RANDOM % ${#PORTS[@]}]}
    SIGNATURE=${SIGNATURES[$RANDOM % ${#SIGNATURES[@]}]}
    CATEGORY=${CATEGORIES[$RANDOM % ${#CATEGORIES[@]}]}
    PRIORITY=$((RANDOM % 3 + 1))
    SEVERITY=$PRIORITY
    GID=1
    SID=$((RANDOM % 999999 + 2000000))
    REV=$((RANDOM % 10 + 1))
    FLOW_ID=$((COUNTER++))
    
    # Choose event type (70% alerts, 30% flows)
    if [ $((RANDOM % 10)) -lt 7 ]; then
        EVENT_TYPE="alert"
        
        # Generate Fast Log entry
        echo "$FAST_TIMESTAMP [**] [$GID:$SID:$REV] $SIGNATURE [**] [Classification: $CATEGORY] [Priority: $PRIORITY] {TCP} $SRC_IP:$SRC_PORT -> $DEST_IP:$DEST_PORT" >> "$LOG_DIR/fast.log"
        
        # Generate EVE JSON entry
        cat >> "$LOG_DIR/eve.json" << EOF
{"timestamp":"$TIMESTAMP","flow_id":$FLOW_ID,"event_type":"alert","src_ip":"$SRC_IP","src_port":$SRC_PORT,"dest_ip":"$DEST_IP","dest_port":$DEST_PORT,"proto":"TCP","alert":{"signature":"$SIGNATURE","category":"$CATEGORY","severity":$SEVERITY,"gid":$GID,"signature_id":$SID,"rev":$REV}}
EOF
    else
        # Generate flow event
        BYTES_TO_SERVER=$((RANDOM * 10))
        BYTES_TO_CLIENT=$((RANDOM * 20))
        
        cat >> "$LOG_DIR/eve.json" << EOF
{"timestamp":"$TIMESTAMP","flow_id":$FLOW_ID,"event_type":"flow","src_ip":"$SRC_IP","src_port":$SRC_PORT,"dest_ip":"$DEST_IP","dest_port":$DEST_PORT,"proto":"TCP","flow":{"bytes_toserver":$BYTES_TO_SERVER,"bytes_toclient":$BYTES_TO_CLIENT,"start":"$TIMESTAMP"}}
EOF
    fi
    
    # Random interval between 2-8 seconds
    sleep $((RANDOM % 7 + 2))
done
