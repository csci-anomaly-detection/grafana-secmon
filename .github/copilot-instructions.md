# AI-Augmented Security Monitoring - Grafana Stack

This workspace contains the logging and visualization infrastructure for the AI-Augmented Security Monitoring project running on AWS EC2.

## Project Context
- Main monitoring server: 54.226.81.54
- Suricata logs location: /srv/campus-sim/logs/suricata
- Focus on memory-efficient deployment of Grafana, Loki, and Promtail
- Priority: Avoid overloading the main security monitoring instance

## Development Guidelines
- Use Docker Compose for service orchestration
- Implement proper resource limits and constraints
- Focus on security log visualization and alerting
- Consider deployment options: same server vs. separate infrastructure
- Prioritize reliability of core Suricata monitoring
