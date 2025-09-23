# Deployment Architecture Options

## Current Infrastructure
- **Main Server**: AWS EC2 (54.226.81.54)
- **Current Services**: Suricata (Docker), synthetic traffic generation
- **Log Location**: /srv/campus-sim/logs/suricata
- **Concern**: Memory overload on main instance

## Deployment Strategy Recommendations

### Option 1: Separate Logging Infrastructure (RECOMMENDED)
**Deploy Grafana/Loki stack on a separate EC2 instance**

**Pros:**
- Isolates logging infrastructure from critical security monitoring
- Prevents memory pressure on Suricata operations
- Allows independent scaling and maintenance
- Better fault isolation

**Cons:**
- Additional EC2 costs (~$20-50/month for t3.medium)
- Network latency for log shipping
- More complex network configuration

**Resource Requirements:**
- Instance Type: t3.medium (2 vCPU, 4GB RAM) minimum
- Storage: 50GB+ EBS for log retention
- Network: VPC peering or public internet with TLS

### Option 2: Same Server with Resource Limits
**Deploy on main server with strict memory/CPU limits**

**Pros:**
- No additional infrastructure costs
- Simplified networking
- Single point of management

**Cons:**
- Risk of impacting Suricata performance
- Limited scalability
- Single point of failure

**Resource Constraints:**
- Loki: 512MB memory limit
- Grafana: 256MB memory limit  
- Promtail: 128MB memory limit

### Option 3: Hybrid Approach
**Promtail on main server, Loki/Grafana elsewhere**

**Pros:**
- Minimal impact on main server (Promtail is lightweight)
- Centralized visualization
- Good performance balance

**Implementation:**
- Promtail: Local container with memory limit
- Loki/Grafana: Separate server or cloud service

## Recommended Implementation

### Phase 1: Separate Infrastructure
1. Launch new t3.medium EC2 instance for logging
2. Deploy Loki/Grafana stack with proper security groups
3. Configure log shipping from main server

### Phase 2: Monitoring & Optimization
1. Implement CloudWatch monitoring
2. Set up alerting for resource usage
3. Optimize retention policies

### Phase 3: Advanced Features
1. Add log aggregation from multiple sources
2. Implement advanced dashboards
3. Set up automated threat detection
