# System Monitoring with Zabbix Platform

Hệ thống giám sát tài nguyên server sử dụng Zabbix với Docker deployment và các tính năng nâng cao.

## Tính năng chính

- Zabbix Server với MySQL backend
- Zabbix Web Interface
- Multi-agent monitoring
- Custom dashboards và graphs
- Email/Telegram alerts
- SSL/TLS security
- Auto-discovery hosts
- Custom templates
- Performance monitoring
- Log monitoring với Fluentd
- Grafana integration
- Backup automation

## Cấu trúc project

```
zabbix-monitoring/
├── docker-compose.yml          # Main orchestration
├── docker-compose.prod.yml     # Production config
├── configs/                    # Configuration files
├── scripts/                    # Automation scripts
├── templates/                  # Zabbix templates
├── dashboards/                 # Custom dashboards
├── ssl/                        # SSL certificates
└── backup/                     # Backup scripts
```

## Quick Start

```bash
# 1. Install Docker (if not installed)
make install-docker

# 2. Choose database
make select-db

# 3. Setup and start
make setup

# Or manual steps:
./scripts/database-selector.sh
docker-compose -f docker-compose.active.yml up -d
```

## Database Options

| Database | Pros | Cons | Best For |
|----------|------|------|----------|
| **MySQL** | ✅ Official support<br>✅ Best performance<br>✅ Extensive docs | ❌ More resources | Production |
| **PostgreSQL** | ✅ Advanced features<br>✅ ACID compliance<br>✅ Complex queries | ❌ Complex setup | Enterprise |
| **SQLite** | ✅ No external DB<br>✅ Lightweight<br>✅ Easy setup | ❌ Limited concurrent | Testing/Small |
| **MongoDB** | ✅ Flexible schema<br>✅ Horizontal scaling<br>✅ Log data | ❌ Experimental | NoSQL needs |