#!/bin/bash

# Zabbix Monitoring Setup Script

set -e

echo "🚀 Setting up Zabbix Monitoring System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p ssl backup/mysql backup/zabbix logs

# Generate SSL certificates if they don't exist
if [ ! -f ssl/server.crt ]; then
    echo -e "${YELLOW}Generating SSL certificates...${NC}"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/server.key \
        -out ssl/server.crt \
        -subj "/C=VN/ST=HCM/L=HoChiMinh/O=ZabbixMonitoring/CN=localhost"
    chmod 600 ssl/server.key
    chmod 644 ssl/server.crt
fi

# Make scripts executable
echo -e "${YELLOW}Setting permissions...${NC}"
chmod +x configs/zabbix/alertscripts/*.sh
chmod +x configs/zabbix/externalscripts/*.sh
chmod +x scripts/*.sh

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating environment file...${NC}"
    cat > .env << EOF
# MySQL Configuration
MYSQL_PASSWORD=$(openssl rand -base64 32)
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)

# Grafana Configuration
GRAFANA_PASSWORD=admin123

# Domain Configuration
DOMAIN_NAME=localhost

# Telegram Bot (optional)
TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN

# SMTP Configuration (optional)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
FROM_EMAIL=your_email@gmail.com
EOF
    echo -e "${GREEN}Environment file created. Please update .env with your settings.${NC}"
fi

# Pull Docker images
echo -e "${YELLOW}Pulling Docker images...${NC}"
docker-compose pull

# Start services
echo -e "${YELLOW}Starting services...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 30

# Check service status
echo -e "${YELLOW}Checking service status...${NC}"
docker-compose ps

# Display access information
echo -e "${GREEN}"
echo "=============================================="
echo "🎉 Zabbix Monitoring System is ready!"
echo "=============================================="
echo "Zabbix Web UI: https://localhost:8443"
echo "  Username: Admin"
echo "  Password: zabbix"
echo ""
echo "Grafana: https://localhost:8443/grafana"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "MySQL: localhost:3306"
echo "  Database: zabbix"
echo "  Username: zabbix"
echo ""
echo "Elasticsearch: http://localhost:9200"
echo "Redis: localhost:6379"
echo "=============================================="
echo -e "${NC}"

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Configure Zabbix hosts and templates"
echo "2. Set up alerting (email/telegram)"
echo "3. Import Grafana dashboards"
echo "4. Configure log monitoring"

echo -e "${GREEN}Setup completed successfully!${NC}"