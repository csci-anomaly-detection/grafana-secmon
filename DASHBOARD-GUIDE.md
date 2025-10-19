# 📊 Grafana Security Dashboard Guide

This guide provides detailed information about each dashboard in the AI-Augmented Security Monitoring system.

## 🎯 Quick Navigation

| Dashboard | Purpose | Best For | Complexity |
|-----------|---------|----------|------------|
| [Security Log Spreadsheet](#-security-log-spreadsheet) | Clean data view | Daily review, reports | ⭐ Simple |
| [Security Overview](#-security-overview---campus-network) | Command center | Operations, executives | ⭐⭐ Medium |
| [Alert Analysis](#-alert-analysis---deep-dive) | Investigations | Analysts, incidents | ⭐⭐⭐ Advanced |
| [Network Traffic](#-network-traffic-analysis) | Network monitoring | Admins, capacity | ⭐⭐⭐ Advanced |
| [Simple Monitor](#-simple-security-monitor) | Basic checks | Testing, troubleshooting | ⭐ Simple |

---

## 📋 Security Log Spreadsheet
**⏱ Time Range:** Last 1 hour | **🔄 Refresh:** 30 seconds

### Purpose
The cleanest, most organized view of your security data - designed like a spreadsheet for easy reading and analysis.

### What You'll See
- **Live Security Events Table**: Real-time stream of security alerts
- **Color-Coded Severity**: 🔴 High, 🟠 Medium, 🟡 Low priority alerts
- **Clean Columns**: Time, Severity, Source, Destination, Protocol, Alert Description
- **Summary Statistics**: Quick counts of alert types and frequency
- **Filtering Options**: By severity level, category, source IP

### Best Use Cases
- ✅ **Daily log review** - Start your day here
- ✅ **Executive reporting** - Clean data for presentations  
- ✅ **Data export** - Easy to copy/paste for reports
- ✅ **Incident documentation** - Clear timeline view
- ✅ **Trend analysis** - See patterns in alert frequency

### Navigation Tips
- Use severity filters to focus on high-priority events
- Adjust "Max Results" dropdown (25, 50, 100, 200, 500) for different views
- Sort by any column by clicking the header
- Use the search box to find specific IPs or signatures

---

## 🏠 Security Overview - Campus Network  
**⏱ Time Range:** Last 1 hour | **🔄 Refresh:** 30 seconds

### Purpose
Your main security command center dashboard providing high-level situational awareness.

### What You'll See
- **🚨 Current Threat Level**: Visual threat indicator with severity breakdown
- **📊 Alert Categories**: Pie chart showing types of security events
- **🌐 Network Activity**: Summary of active sources, targets, and protocols
- **📈 Alert Timeline**: Trend graph showing alert patterns over time
- **🎯 Top Sources/Targets**: Tables showing most active IP addresses
- **🔗 Protocol Distribution**: Bar chart of network protocols in use

### Best Use Cases
- ✅ **Security Operations Center (SOC)** - Wall display dashboard
- ✅ **Daily briefings** - Quick security status updates
- ✅ **Executive summaries** - High-level security posture
- ✅ **Shift handovers** - What happened during previous shift
- ✅ **Compliance reporting** - Security monitoring evidence

### Key Metrics
- **Threat Level Colors**: Green (safe) → Yellow (caution) → Orange (elevated) → Red (critical)
- **Active Sources**: Unique IP addresses generating alerts
- **Unique Targets**: Systems being targeted by attacks
- **Protocol Mix**: TCP, UDP, ICMP traffic distribution

---

## 🔍 Alert Analysis - Deep Dive
**⏱ Time Range:** Last 6 hours | **🔄 Refresh:** 1 minute

### Purpose
Detailed forensic analysis dashboard for incident investigation and threat hunting.

### What You'll See
- **🌡️ Alert Frequency Heatmap**: Visual pattern analysis over time
- **📋 Top Alert Signatures**: Most frequent attack patterns
- **🔍 Source IP Analysis**: Detailed breakdown of attacking systems
- **📊 Alert Trend by Severity**: Time-series graph of alert criticality
- **🕸️ Communication Patterns**: Network graph of connections
- **📜 Live Log Feed**: Real-time detailed log stream
- **📈 Alert Correlation Matrix**: Full details of all security events

### Best Use Cases
- ✅ **Incident response** - Deep investigation of security events
- ✅ **Threat hunting** - Proactive search for advanced threats
- ✅ **Forensic analysis** - Post-incident investigation
- ✅ **Attack pattern analysis** - Understanding attacker behavior
- ✅ **Security research** - Analyzing new attack techniques

### Advanced Features
- **Interactive Filters**: Severity, category, source IP selection
- **Drill-down Capability**: Click on metrics to filter other panels
- **Correlation View**: See relationships between different alerts
- **Time Navigation**: Easily jump to specific time periods

---

## 🌐 Network Traffic Analysis
**⏱ Time Range:** Last 2 hours | **🔄 Refresh:** 30 seconds

### Purpose
Network behavior monitoring focusing on traffic patterns, connections, and anomalies.

### What You'll See
- **📊 Network Overview**: Active sources, destinations, total connections
- **📈 Traffic Volume by Protocol**: Time-series of network protocols
- **🗣️ Top Talkers**: Most active systems by volume
- **🔗 Connection States**: Zeek analysis of connection health
- **🚪 Port Distribution**: Most accessed network services
- **🗺️ Network Communication Matrix**: Detailed connection logs
- **⚠️ Weird Events**: Network anomalies detected by Zeek
- **📊 Traffic Flow Visualization**: Inbound vs outbound data flows

### Best Use Cases
- ✅ **Network administration** - Understanding traffic patterns
- ✅ **Capacity planning** - Bandwidth and connection analysis
- ✅ **Anomaly detection** - Spotting unusual network behavior
- ✅ **Service monitoring** - Checking network service health
- ✅ **Performance optimization** - Identifying network bottlenecks

### Key Insights
- **Connection States**: Normal (SF), Failed (S0), Rejected (REJ), etc.
- **Protocol Analysis**: HTTP, HTTPS, SSH, DNS traffic patterns
- **Port Usage**: Common services (80, 443, 22, 53) vs unusual ports
- **Zeek Weird Events**: Network protocol anomalies and errors

---

## 🎯 Simple Security Monitor
**⏱ Time Range:** Last 30 minutes | **🔄 Refresh:** 30 seconds

### Purpose
Basic monitoring dashboard with simplified queries for system testing and troubleshooting.

### What You'll See
- **🚨 Security Alerts Counter**: Simple count of recent alerts
- **🔴 High Severity Alerts**: Critical security events
- **📊 System Status**: Basic health check of log sources
- **📋 Recent Alerts Table**: Simple table of latest security events

### Best Use Cases
- ✅ **System testing** - Verify dashboards are working
- ✅ **Troubleshooting** - When complex dashboards have issues
- ✅ **Quick checks** - Fast security status verification
- ✅ **New user training** - Simple introduction to the system
- ✅ **Mobile viewing** - Optimized for smaller screens

---

## 🛠️ Dashboard Usage Tips

### Getting Started
1. **Start with "Security Log Spreadsheet"** - easiest to understand
2. **Check "Simple Security Monitor"** - verify system is working
3. **Move to "Security Overview"** - get the big picture
4. **Use specialized dashboards** as needed for investigations

### Troubleshooting
- **"Legacy query" errors**: Dashboards still work, ignore the errors
- **No data showing**: Check time range and refresh rate
- **Slow loading**: Reduce time range or increase refresh interval
- **Query timeouts**: System is configured with 60-second timeouts

### Performance Optimization
- **Shorter time ranges** load faster (30min vs 6 hours)
- **Fewer concurrent users** - share screens when possible
- **Close unused browser tabs** - each dashboard uses resources
- **Use "Simple Security Monitor"** when system is under load

### Best Practices
- **Set appropriate time ranges** based on your analysis needs
- **Use filters** to focus on relevant data
- **Export data** from table views for reports
- **Bookmark specific views** with applied filters
- **Share dashboard URLs** with applied time ranges and filters

---

## 📞 Support & Troubleshooting

### Common Issues
- **Empty dashboards**: Check Promtail is running and collecting logs
- **Query errors**: System still works, errors can be ignored
- **Slow performance**: Reduce time ranges, check system resources
- **Missing data**: Verify Suricata is generating alerts

### Resource Monitoring
```bash
# Check container resources
docker stats

# Check logs
docker logs grafana-secmon
docker logs loki-secmon
docker logs promtail-secmon
```

### Configuration Files
- **Dashboards**: `/srv/campus-sim/grafana-secmon/dashboards/`
- **Loki Config**: `/srv/campus-sim/grafana-secmon/config/loki-config-minimal.yml`
- **Promtail Config**: `/srv/campus-sim/grafana-secmon/config/promtail-config.yml`
- **Docker Compose**: `/srv/campus-sim/grafana-secmon/docker/docker-compose.ultra-conservative.yml`

---

*Last Updated: October 19, 2025*
*Version: Campus Security Monitoring v1.0*
