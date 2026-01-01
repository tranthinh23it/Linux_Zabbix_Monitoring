#!/bin/bash

# Monitoring System Health Check Script

set -e

echo "🔍 Checking Zabbix Monitoring System Health..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Docker containers
echo -e "\n📦 Docker Containers Status:"
docker-compose ps

# Check service health
check_service() {
    local service=$1
    local port=$2
    local name=$3
    
    if curl -s -f "http://localhost:$port" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name is healthy${NC}"
    else
        echo -e "${RED}❌ $name is not responding${NC}"
    fi
}

echo -e "\n🏥 Service Health Checks:"
check_service "zabbix-web" "80" "Zabbix Web UI"
check_service "grafana" "3000" "Grafana"
check_service "elasticsearch" "9200" "Elasticsearch"
check_service "redis" "6379" "Redis"

# Check MySQL connection
echo -e "\n🗄️ Database Connection:"
if docker exec zabbix-mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
    echo -e "${GREEN}✅ MySQL is healthy${NC}"
else
    echo -e "${RED}❌ MySQL connection failed${NC}"
fi

# Check Zabbix server status
echo -e "\n🖥️ Zabbix Server Status:"
if docker exec zabbix-server zabbix_server -R config_cache_reload 2>/dev/null; then
    echo -e "${GREEN}✅ Zabbix Server is running${NC}"
else
    echo -e "${RED}❌ Zabbix Server has issues${NC}"
fi

# Check disk usage
echo -e "\n💾 Disk Usage:"
df -h | grep -E "(Filesystem|/dev/)"

# Check memory usage
echo -e "\n🧠 Memory Usage:"
free -h

# Check Docker volumes
echo -e "\n📁 Docker Volumes:"
docker volume ls | grep zabbix

# Check logs for errors
echo -e "\n📋 Recent Error Logs:"
echo "Zabbix Server errors (last 10):"
docker logs zabbix-server 2>&1 | grep -i error | tail -10 || echo "No errors found"

echo "MySQL errors (last 5):"
docker logs zabbix-mysql 2>&1 | grep -i error | tail -5 || echo "No errors found"

# Performance metrics
echo -e "\n📊 Performance Metrics:"
echo "Active connections to Zabbix:"
netstat -an | grep :10051 | grep ESTABLISHED | wc -l

echo "MySQL processes:"
docker exec zabbix-mysql mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2) \
    -e "SHOW PROCESSLIST;" 2>/dev/null | wc -l || echo "Cannot connect to MySQL"

# SSL certificate check
echo -e "\n🔐 SSL Certificate:"
if [ -f ssl/server.crt ]; then
    CERT_EXPIRY=$(openssl x509 -in ssl/server.crt -noout -enddate | cut -d= -f2)
    echo "Certificate expires: $CERT_EXPIRY"
else
    echo -e "${RED}❌ SSL certificate not found${NC}"
fi

# Backup status
echo -e "\n💾 Backup Status:"
if [ -d backup ]; then
    LATEST_BACKUP=$(ls -t backup/zabbix_backup_*.tar.gz 2>/dev/null | head -1)
    if [ ! -z "$LATEST_BACKUP" ]; then
        echo "Latest backup: $LATEST_BACKUP"
        echo "Backup size: $(du -h "$LATEST_BACKUP" | cut -f1)"
    else
        echo -e "${YELLOW}⚠️ No backups found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Backup directory not found${NC}"
fi

echo -e "\n✅ Health check completed!"