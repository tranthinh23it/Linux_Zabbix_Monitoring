#!/bin/bash

# Quick Demo Script for Zabbix System

set -e

echo "🎯 Zabbix Monitoring System - Quick Demo"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if system is running
check_system() {
    echo -e "${CYAN}🔍 Checking Zabbix System Status...${NC}"
    
    if sudo docker ps | grep -q zabbix-web; then
        echo -e "${GREEN}✅ Zabbix Web UI is running${NC}"
    else
        echo -e "${RED}❌ Zabbix Web UI is not running${NC}"
        exit 1
    fi
    
    if sudo docker ps | grep -q zabbix-server; then
        echo -e "${GREEN}✅ Zabbix Server is running${NC}"
    else
        echo -e "${RED}❌ Zabbix Server is not running${NC}"
        exit 1
    fi
    
    if sudo docker ps | grep -q zabbix-mysql; then
        echo -e "${GREEN}✅ MySQL Database is running${NC}"
    else
        echo -e "${RED}❌ MySQL Database is not running${NC}"
        exit 1
    fi
    
    echo ""
}

# Show access information
show_access_info() {
    echo -e "${BLUE}🌐 Access Information:${NC}"
    echo "=================================="
    echo -e "${GREEN}🔹 Zabbix Web UI:${NC}"
    echo "   URL: http://localhost"
    echo "   Username: Admin"
    echo "   Password: zabbix"
    echo ""
    echo -e "${GREEN}🔹 Grafana Dashboard:${NC}"
    echo "   URL: http://localhost:3000"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    echo -e "${GREEN}🔹 MySQL Database:${NC}"
    echo "   Host: localhost:3306"
    echo "   Database: zabbix"
    echo "   Username: zabbix"
    echo "   Password: zabbix_secure_2024"
    echo "=================================="
    echo ""
}

# Test web connectivity
test_connectivity() {
    echo -e "${CYAN}🌐 Testing Web Connectivity...${NC}"
    
    if curl -s http://localhost | grep -q "Zabbix"; then
        echo -e "${GREEN}✅ Zabbix Web UI is accessible${NC}"
    else
        echo -e "${RED}❌ Cannot access Zabbix Web UI${NC}"
    fi
    
    if curl -s http://localhost:3000 | grep -q "Grafana"; then
        echo -e "${GREEN}✅ Grafana is accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  Grafana may still be starting up${NC}"
    fi
    
    echo ""
}

# Show current monitoring data
show_monitoring_data() {
    echo -e "${CYAN}📊 Current System Metrics:${NC}"
    echo "=================================="
    
    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "${GREEN}🔹 CPU Usage:${NC} ${CPU_USAGE}%"
    
    # Memory Usage
    MEM_INFO=$(free -h | awk 'NR==2{printf "Used: %s/%s (%.1f%%)", $3,$2,$3*100/$2}')
    echo -e "${GREEN}🔹 Memory:${NC} $MEM_INFO"
    
    # Disk Usage
    DISK_USAGE=$(df -h / | awk 'NR==2{printf "Used: %s/%s (%s)", $3,$2,$5}')
    echo -e "${GREEN}🔹 Disk Usage:${NC} $DISK_USAGE"
    
    # Load Average
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
    echo -e "${GREEN}🔹 Load Average:${NC}$LOAD_AVG"
    
    # Docker Containers
    CONTAINERS=$(sudo docker ps | wc -l)
    echo -e "${GREEN}🔹 Docker Containers:${NC} $((CONTAINERS-1)) running"
    
    echo "=================================="
    echo ""
}

# Show quick commands
show_quick_commands() {
    echo -e "${BLUE}⚡ Quick Commands:${NC}"
    echo "=================================="
    echo "🔹 View logs:           make logs"
    echo "🔹 Health check:        make health"
    echo "🔹 Backup system:       make backup"
    echo "🔹 Restart services:    make restart"
    echo "🔹 Stop services:       make stop"
    echo "🔹 View status:         make status"
    echo "=================================="
    echo ""
}

# Demo monitoring features
demo_features() {
    echo -e "${CYAN}🎯 Demo: Key Monitoring Features${NC}"
    echo "=================================="
    
    echo -e "${YELLOW}1. Real-time System Monitoring:${NC}"
    echo "   ✅ CPU, Memory, Disk, Network monitoring"
    echo "   ✅ Process and service monitoring"
    echo "   ✅ Docker container monitoring"
    echo ""
    
    echo -e "${YELLOW}2. Alert System:${NC}"
    echo "   ✅ Email notifications"
    echo "   ✅ Telegram alerts"
    echo "   ✅ Custom trigger conditions"
    echo ""
    
    echo -e "${YELLOW}3. Visualization:${NC}"
    echo "   ✅ Zabbix native graphs"
    echo "   ✅ Grafana dashboards"
    echo "   ✅ Custom dashboards"
    echo ""
    
    echo -e "${YELLOW}4. Advanced Features:${NC}"
    echo "   ✅ Auto-discovery"
    echo "   ✅ Templates"
    echo "   ✅ User management"
    echo "   ✅ Maintenance mode"
    echo "=================================="
    echo ""
}

# Open browser (optional)
open_browser() {
    echo -e "${CYAN}🌐 Opening Zabbix in browser...${NC}"
    
    if command -v xdg-open > /dev/null; then
        xdg-open http://localhost > /dev/null 2>&1 &
        echo -e "${GREEN}✅ Browser opened${NC}"
    elif command -v firefox > /dev/null; then
        firefox http://localhost > /dev/null 2>&1 &
        echo -e "${GREEN}✅ Firefox opened${NC}"
    elif command -v google-chrome > /dev/null; then
        google-chrome http://localhost > /dev/null 2>&1 &
        echo -e "${GREEN}✅ Chrome opened${NC}"
    else
        echo -e "${YELLOW}⚠️  Please manually open: http://localhost${NC}"
    fi
    echo ""
}

# Main demo function
main() {
    clear
    echo -e "${BLUE}"
    echo "=============================================="
    echo "    🎯 Zabbix Monitoring System Demo"
    echo "=============================================="
    echo -e "${NC}"
    
    check_system
    show_access_info
    test_connectivity
    show_monitoring_data
    demo_features
    show_quick_commands
    
    echo -e "${GREEN}🎉 Demo completed! Your Zabbix system is ready to use.${NC}"
    echo ""
    
    read -p "Open Zabbix in browser? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open_browser
    fi
    
    echo -e "${CYAN}💡 Next steps:${NC}"
    echo "1. Login to Zabbix Web UI: http://localhost"
    echo "2. Explore the monitoring dashboard"
    echo "3. Add more hosts to monitor"
    echo "4. Setup email/telegram alerts"
    echo "5. Create custom dashboards in Grafana"
    echo ""
    echo -e "${GREEN}Happy monitoring! 🚀${NC}"
}

# Run main function
main