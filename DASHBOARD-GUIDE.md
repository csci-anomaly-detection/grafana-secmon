# 📊 Grafana Security Dashboard Guide

This guide provides detailed information about each dashboard in the AI-Augmented Security Monitoring system.

---

## Security Master Spreadsheet
**⏱ Time Range:** Last 6 hours | **🔄 Refresh:** 30 seconds

### Purpose
Unified all-in-one dashboard combining critical elements from multiple views into a single comprehensive monitoring interface.

### What You'll See
- **Current Alert Summary**: Visual count of High/Medium/Low severity alerts with emoji indicators (🔴 High, 🟠 Medium, 🟡 Low)
- **Alert Timeline**: 6-hour trend graph showing alert patterns by severity over time
- **Alert Signatures by Frequency**: Top 15 most common attack signatures detected
- **Recent Critical Alerts**: Real-time table of Severity 1 (High) alerts with full details
- **All Live Security Logs**: Real-time log feed with JSON formatting and full event details

### Best Use Cases
- **Primary monitoring dashboard** - Single view for most common tasks
- **Daily security review** - All essential information in one place
- **Incident response** - Quick access to critical alerts and live logs
- **SOC operations** - Comprehensive view for security analysts
- **Executive briefings** - High-level summary with drill-down capability
- **Shift handovers** - Complete picture of security posture

### Key Features
- **Compact Summary**: Horizontal stat panel showing all severity levels at once
- **Interactive Filters**: Severity and Category variables for focused analysis
- **Color-Coded Data**: Consistent red/orange/yellow scheme across all panels
- **Real-time Updates**: 30-second refresh keeps data current
- **Comprehensive Coverage**: Combines overview, deep-dive, and log viewing

### Navigation Tips
- Start with the Alert Summary to see overall threat level
- Check the Timeline for patterns and trends
- Review Top Signatures to identify recurring attacks
- Investigate Critical Alerts table for immediate threats
- Use Live Logs panel for detailed event inspection
- Apply Severity/Category filters to focus analysis

---

## Network Traffic Analysis
**Time Range:** Last 2 hours | **🔄 Refresh:** 30 seconds

### Purpose
Network behavior monitoring focusing on traffic patterns, connections, and anomalies.

### What You'll See
- **Network Overview**: Active sources, destinations, total connections
- **Traffic Volume by Protocol**: Time-series of network protocols
- **Top Talkers**: Most active systems by volume
- **Connection States**: Zeek analysis of connection health
- **Port Distribution**: Most accessed network services
- **Network Communication Matrix**: Detailed connection logs
- **Weird Events**: Network anomalies detected by Zeek
- **Traffic Flow Visualization**: Inbound vs outbound data flows

### Best Use Cases
- **Network administration** - Understanding traffic patterns
- **Capacity planning** - Bandwidth and connection analysis
- **Anomaly detection** - Spotting unusual network behavior
- **Service monitoring** - Checking network service health
- **Performance optimization** - Identifying network bottlenecks

### Key Insights
- **Connection States**: Normal (SF), Failed (S0), Rejected (REJ), etc.
- **Protocol Analysis**: HTTP, HTTPS, SSH, DNS traffic patterns
- **Port Usage**: Common services (80, 443, 22, 53) vs unusual ports
- **Zeek Weird Events**: Network protocol anomalies and errors

---

## Dashboard Usage Tips

### Getting Started
1. **Start with "Security Master Spreadsheet"** - unified view of all critical information
3. **Check "Network Traffic Analysis"** - for network-specific issues

### Troubleshooting
- **"Legacy query" errors**: Dashboards still work, ignore the errors
- **No data showing**: Check time range and refresh rate
- **Slow loading**: Reduce time range or increase refresh interval
- **Query timeouts**: System is configured with 60-second timeouts

### Performance Optimization
- **Shorter time ranges** load faster (1 hour vs 6 hours)
- **Fewer concurrent users** - share screens when possible
- **Close unused browser tabs** - each dashboard uses resources
- **Apply filters** to reduce query load on the system

### Best Practices
- **Set appropriate time ranges** based on your analysis needs
- **Use filters** to focus on relevant data
- **Export data** from table views for reports
- **Bookmark specific views** with applied filters
- **Share dashboard URLs** with applied time ranges and filters

---

## Support & Troubleshooting

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

*Last Updated: October 29, 2025*
*Version: Campus Security Monitoring v1.0*
