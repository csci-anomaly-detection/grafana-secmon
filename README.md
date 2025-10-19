# AI-Augmented Security Monitoring - Grafana Stack

This repository contains the logging and visualization infrastructure for the AI-Augmented Security Monitoring project. It provides Grafana dashboards, Loki log aggregation, and Promtail log shipping for Suricata network security monitoring.

## 📊 Dashboard Overview

The system includes **5 comprehensive security dashboards** designed for different monitoring needs:

### 🏠 **1. Security Overview - Campus Network** 
- **Purpose**: Main security command center dashboard
- **Time Range**: Last 1 hour | **Refresh**: 30 seconds
- **Best For**: Daily monitoring, executive briefings, security operations center
- **Shows**: Threat levels, alert summaries, top sources/targets, real-time metrics

### 🔍 **2. Alert Analysis - Deep Dive**
- **Purpose**: Detailed incident investigation and forensic analysis  
- **Time Range**: Last 6 hours | **Refresh**: 1 minute
- **Best For**: Security analysts, incident response, threat hunting
- **Shows**: Alert heatmaps, signature patterns, correlation matrix, live log feeds

### 🌐 **3. Network Traffic Analysis**
- **Purpose**: Network behavior monitoring and traffic analysis
- **Time Range**: Last 2 hours | **Refresh**: 30 seconds  
- **Best For**: Network administrators, capacity planning, anomaly detection
- **Shows**: Connection patterns, protocol distribution, port analysis, traffic flows

### 📋 **4. Security Log Spreadsheet** ⭐ **CLEAN VIEW**
- **Purpose**: Excel-like clean view of security events (minimal clutter)
- **Time Range**: Last 1 hour | **Refresh**: 30 seconds
- **Best For**: Log review, reporting, exporting data, executive summaries
- **Shows**: Real-time security events in organized table format with color-coded severity

### 🎯 **5. Simple Security Monitor**
- **Purpose**: Basic monitoring with simplified queries
- **Time Range**: Last 30 minutes | **Refresh**: 30 seconds
- **Best For**: System testing, when complex dashboards have issues
- **Shows**: Basic alert counts, system health checks

> 💡 **Tip**: Start with "Security Log Spreadsheet" for the cleanest, most organized view of your security data!

## 📚 Documentation

### 📖 **Detailed Dashboard Guide**
For comprehensive information about each dashboard, see **[DASHBOARD-GUIDE.md](./DASHBOARD-GUIDE.md)**

This guide includes:
- **Detailed purpose** of each dashboard
- **What you'll see** in each panel
- **Best use cases** for different scenarios  
- **Navigation tips** and troubleshooting
- **Performance optimization** recommendations

### 🚀 **Quick Access**
- **Grafana URL**: `http://your-server-ip:3000`
- **Default Login**: `admin` / `secmon_admin_2025`
- **Recommended Starting Point**: "Security Log Spreadsheet" dashboard

## Quick Start

### For Separate Server Deployment (Recommended)

1. **Launch new EC2 instance** (t3.medium minimum):
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Docker and Docker Compose
   sudo apt install docker.io docker-compose -y
   sudo usermod -aG docker ubuntu
   
   # Create data directories
   sudo mkdir -p /opt/logging/{loki-data,grafana-data}
   sudo chown -R 472:472 /opt/logging/grafana-data
   sudo chown -R 10001:10001 /opt/logging/loki-data
   ```

2. **Deploy the stack**:
   ```bash
   git clone <this-repo>
   cd grafana-secmon
   docker-compose -f docker/docker-compose.separate-server.yml up -d
   ```

3. **Configure Security Groups**:
   - Allow port 3000 (Grafana) from your IP
   - Allow port 3100 (Loki) from main server (54.226.81.54)

### For Same Server Deployment (Memory Constrained)

1. **On your main server (54.226.81.54)**:
   ```bash
   cd /srv/campus-sim
   git clone <this-repo> grafana-stack
   cd grafana-stack
   
   # Create minimal data directories
   sudo mkdir -p /opt/secmon/{loki-data,grafana-data}
   sudo chown -R 472:472 /opt/secmon/grafana-data
   sudo chown -R 10001:10001 /opt/secmon/loki-data
   
   # Deploy with resource limits
   docker-compose -f docker/docker-compose.same-server.yml up -d
   ```

## Architecture Options

### Option 1: Separate Infrastructure (Recommended)
- **Benefits**: No memory pressure on main monitoring server
- **Cost**: ~$20-50/month for additional EC2 instance
- **Use**: Production environments, multiple monitored servers

### Option 2: Same Server with Limits
- **Benefits**: No additional costs, simple networking
- **Constraints**: 896MB total memory limit for logging stack
- **Use**: Development, testing, single server monitoring

## Configuration Details

### Memory Limits (Same Server)
- **Loki**: 512MB limit, 256MB reserved
- **Grafana**: 256MB limit, 128MB reserved  
- **Promtail**: 128MB limit, 64MB reserved
- **Total**: <1GB to preserve resources for Suricata

### Log Retention
- **Separate Server**: 30 days (configurable)
- **Same Server**: 7 days (memory optimized)

### Monitored Logs
- `/srv/campus-sim/logs/suricata/fast.log` - Basic alerts
- `/srv/campus-sim/logs/suricata/eve.json` - Rich JSON events
- `/srv/campus-sim/logs/suricata/stats.log` - Statistics
- `/var/log/syslog` - System context
- `/var/log/docker.log` - Container logs

## Dashboards

### 1. Security Monitoring - Suricata Overview
- Alert distribution by type and severity
- Top source/destination IPs
- Recent security events
- Alert signature analysis

### 2. Network Traffic Analysis  
- Protocol distribution and bandwidth
- Port usage statistics
- Active IP addresses
- Traffic flow rates

## Access Information

- **Grafana URL**: `http://your-server:3000`
- **Default Login**: admin / secmon_admin_2025
- **Loki API**: `http://your-server:3100`

## Security Considerations

### Network Security
```bash
# Restrict Grafana access to specific IPs
sudo ufw allow from YOUR_IP to any port 3000

# Internal Loki access only
sudo ufw allow from 54.226.81.54 to any port 3100
```

### SSL/TLS (Production)
For production deployments, configure nginx proxy with SSL:
1. Obtain SSL certificate (Let's Encrypt recommended)
2. Update `config/nginx.conf` with SSL settings
3. Redirect HTTP to HTTPS

## Monitoring and Maintenance

### Health Checks
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs loki
docker-compose logs grafana
docker-compose logs promtail

# Check resource usage
docker stats
```

### Log Rotation
Loki handles log retention automatically based on configuration:
- Same server: 7 days retention
- Separate server: 30 days retention

### Backup Strategy
```bash
# Backup Grafana dashboards and settings
docker exec grafana-secmon grafana-cli admin export-dashboard > dashboards-backup.json

# Backup Loki configuration
cp config/loki-config*.yml /backup/location/
```

## Troubleshooting

### Common Issues

1. **Out of Memory (Same Server)**:
   ```bash
   # Check memory usage
   free -h
   
   # Restart with lower limits
   docker-compose down
   # Edit docker-compose.same-server.yml memory limits
   docker-compose up -d
   ```

2. **Promtail Not Collecting Logs**:
   ```bash
   # Check log file permissions
   ls -la /srv/campus-sim/logs/suricata/
   
   # Verify Promtail can access logs
   docker exec promtail-secmon ls -la /var/log/campus-sim/suricata/
   ```

3. **Grafana Can't Connect to Loki**:
   ```bash
   # Test Loki connectivity
   curl http://localhost:3100/ready
   
   # Check network configuration
   docker network ls
   docker network inspect grafana-secmon_secmon-logging
   ```

### Performance Optimization

1. **Reduce Log Volume**:
   - Filter noisy logs in Promtail configuration
   - Adjust Suricata log levels
   - Use log sampling for high-volume events

2. **Optimize Queries**:
   - Use specific time ranges
   - Filter by labels early in queries
   - Avoid complex regex operations

## Integration with Campus Sim

### Promtail Remote Configuration
To ship logs from main server to separate Loki instance:

```yaml
# On main server, update promtail config
clients:
  - url: http://YOUR_LOKI_SERVER:3100/loki/api/v1/push
```

### Automated Deployment
```bash
# Deploy to main server
./scripts/deploy-same-server.sh

# Deploy to separate server  
./scripts/deploy-separate-server.sh YOUR_LOKI_SERVER_IP
```

## Cost Analysis

### Same Server Deployment
- **Additional Cost**: $0
- **Memory Impact**: ~900MB
- **Risk**: Potential impact on Suricata performance

### Separate Server Deployment
- **EC2 t3.medium**: ~$30/month
- **EBS 50GB**: ~$5/month
- **Data Transfer**: ~$1/month
- **Total**: ~$36/month

## Future Enhancements

1. **Advanced Analytics**:
   - Machine learning anomaly detection
   - Automated threat correlation
   - Behavioral analysis dashboards

2. **Alerting Integration**:
   - Slack/email notifications
   - PagerDuty integration
   - Custom webhook alerts

3. **Multi-Campus Support**:
   - Centralized log aggregation
   - Campus-specific dashboards
   - Federation and scaling

## Contributing

1. Test configurations in lab environment first
2. Monitor resource usage after changes
3. Update documentation for new features
4. Consider backward compatibility

## Support

For issues related to:
- **Configuration**: Check logs and config files
- **Performance**: Monitor resource usage
- **Security**: Review firewall and access controls

Contact the security monitoring team for campus-specific deployment questions.
