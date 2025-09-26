# Quick Reference - Grafana Monitoring Stack

## 🚀 Start/Stop Commands

### Start the Stack
```bash
cd /srv/campus-sim/grafana-secmon
docker compose -f docker/docker-compose.ultra-conservative.yml up -d
```

### Stop the Stack
```bash
cd /srv/campus-sim/grafana-secmon
docker compose -f docker/docker-compose.ultra-conservative.yml down
```

### Check Status
```bash
cd /srv/campus-sim/grafana-secmon
docker compose -f docker/docker-compose.ultra-conservative.yml ps
```

## 🌐 Access Information

- **Grafana URL**: `http://your-server-ip:3000`
- **Username**: `admin`
- **Password**: `secmon_admin_2025`

## 📊 Available Dashboards

After logging in, go to **Dashboards** → **Security** folder:

1. **Security Monitoring - Suricata Overview** - Main security dashboard
2. **Security Monitoring - Comprehensive Suricata Dashboard** - Detailed analytics  
3. **Network Traffic Analysis** - Traffic patterns

## 🔧 Troubleshooting

### No Data Showing?
```bash
# Check if logs are being read
docker logs promtail-secmon | tail -5

# Check if Suricata is generating logs
tail -f /srv/campus-sim/ai-sec-monitor/logs/suricata/fast.log
```

### Container Issues?
```bash
# Restart all services
cd /srv/campus-sim/grafana-secmon
docker compose -f docker/docker-compose.ultra-conservative.yml restart

# Check container health
docker compose -f docker/docker-compose.ultra-conservative.yml ps
```

### System Resources
```bash
# Monitor resource usage
cd /srv/campus-sim/grafana-secmon
./scripts/monitor-resources.sh
```

## ⚡ Resource Usage

- **Total Memory**: ~640MB (ultra-conservative)
- **CPU**: ~0.65 cores total
- **Ports**: 3000 (Grafana), 3100 (Loki internal)

## 🆘 Emergency Stop

```bash
cd /srv/campus-sim/grafana-secmon
docker compose -f docker/docker-compose.ultra-conservative.yml down --remove-orphans
```

---
**Quick Setup Complete!** The full README.md contains detailed configuration options.
