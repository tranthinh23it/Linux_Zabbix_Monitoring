#!/bin/bash

# Database Selection Script for Zabbix

set -e

echo "🗄️ Zabbix Database Selection"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "   Choose Database for Zabbix Monitoring"
    echo "=============================================="
    echo -e "${NC}"
    echo "1) MySQL (Default - Most stable)"
    echo "   ✅ Official Zabbix support"
    echo "   ✅ Best performance for large datasets"
    echo "   ✅ Extensive documentation"
    echo "   ❌ Requires more resources"
    echo ""
    echo "2) PostgreSQL (Enterprise grade)"
    echo "   ✅ Advanced features and performance"
    echo "   ✅ Better for complex queries"
    echo "   ✅ ACID compliance"
    echo "   ❌ Slightly more complex setup"
    echo ""
    echo "3) SQLite (Lightweight)"
    echo "   ✅ No external database needed"
    echo "   ✅ Perfect for testing/small deployments"
    echo "   ✅ Minimal resource usage"
    echo "   ❌ Limited concurrent access"
    echo ""
    echo "4) MongoDB (NoSQL - Experimental)"
    echo "   ✅ Flexible schema"
    echo "   ✅ Good for log data"
    echo "   ✅ Horizontal scaling"
    echo "   ❌ Requires custom Zabbix build"
    echo ""
    echo "0) Exit"
    echo ""
}

setup_mysql() {
    echo -e "${GREEN}Setting up MySQL variant...${NC}"
    cp docker-compose.yml docker-compose.active.yml
    echo "COMPOSE_FILE=docker-compose.active.yml" > .env.db
    echo "DATABASE_TYPE=mysql" >> .env.db
    echo ""
    echo -e "${GREEN}✅ MySQL configuration ready!${NC}"
    echo "Access URLs after setup:"
    echo "  - Zabbix Web: https://localhost:8443 (Admin/zabbix)"
    echo "  - MySQL: localhost:3306"
}

setup_postgresql() {
    echo -e "${GREEN}Setting up PostgreSQL variant...${NC}"
    cp docker-compose.postgresql.yml docker-compose.active.yml
    echo "COMPOSE_FILE=docker-compose.active.yml" > .env.db
    echo "DATABASE_TYPE=postgresql" >> .env.db
    echo "POSTGRES_PASSWORD=zabbix_password" >> .env.db
    echo "POSTGRES_ROOT_PASSWORD=root_password" >> .env.db
    echo "PGADMIN_PASSWORD=admin123" >> .env.db
    echo ""
    echo -e "${GREEN}✅ PostgreSQL configuration ready!${NC}"
    echo "Access URLs after setup:"
    echo "  - Zabbix Web: https://localhost:8443 (Admin/zabbix)"
    echo "  - PostgreSQL: localhost:5432"
    echo "  - pgAdmin: http://localhost:8082 (admin@zabbix.local/admin123)"
}

setup_sqlite() {
    echo -e "${GREEN}Setting up SQLite variant...${NC}"
    cp docker-compose.sqlite.yml docker-compose.active.yml
    echo "COMPOSE_FILE=docker-compose.active.yml" > .env.db
    echo "DATABASE_TYPE=sqlite" >> .env.db
    echo ""
    echo -e "${GREEN}✅ SQLite configuration ready!${NC}"
    echo "Access URLs after setup:"
    echo "  - Zabbix Web: https://localhost:8443 (Admin/zabbix)"
    echo "  - SQLite Browser: http://localhost:8083"
}

setup_mongodb() {
    echo -e "${YELLOW}⚠️  MongoDB setup requires custom Docker builds...${NC}"
    echo "This is experimental and may require additional configuration."
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp docker-compose.mongodb.yml docker-compose.active.yml
        echo "COMPOSE_FILE=docker-compose.active.yml" > .env.db
        echo "DATABASE_TYPE=mongodb" >> .env.db
        echo "MONGO_ROOT_PASSWORD=mongodb_password" >> .env.db
        echo "MONGO_ZABBIX_PASSWORD=zabbix_password" >> .env.db
        echo "MONGO_EXPRESS_PASSWORD=admin123" >> .env.db
        echo ""
        echo -e "${GREEN}✅ MongoDB configuration ready!${NC}"
        echo "Access URLs after setup:"
        echo "  - Zabbix Web: https://localhost:8443 (Admin/zabbix)"
        echo "  - MongoDB: localhost:27017"
        echo "  - Mongo Express: http://localhost:8081 (admin/admin123)"
    else
        echo "MongoDB setup cancelled."
        return
    fi
}

start_services() {
    echo -e "${YELLOW}Starting services...${NC}"
    if [ -f docker-compose.active.yml ]; then
        docker-compose -f docker-compose.active.yml up -d
        echo -e "${GREEN}✅ Services started successfully!${NC}"
        echo ""
        echo "Check status with: docker-compose -f docker-compose.active.yml ps"
        echo "View logs with: docker-compose -f docker-compose.active.yml logs -f"
    else
        echo -e "${RED}❌ No active configuration found. Please select a database first.${NC}"
    fi
}

show_status() {
    if [ -f docker-compose.active.yml ]; then
        echo -e "${BLUE}Current Configuration:${NC}"
        if [ -f .env.db ]; then
            cat .env.db
        fi
        echo ""
        echo -e "${BLUE}Service Status:${NC}"
        docker-compose -f docker-compose.active.yml ps
    else
        echo -e "${YELLOW}No active configuration found.${NC}"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Select option [1-4, 0 to exit]: " choice
    
    case $choice in
        1)
            setup_mysql
            read -p "Start services now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                start_services
            fi
            ;;
        2)
            setup_postgresql
            read -p "Start services now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                start_services
            fi
            ;;
        3)
            setup_sqlite
            read -p "Start services now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                start_services
            fi
            ;;
        4)
            setup_mongodb
            read -p "Start services now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                start_services
            fi
            ;;
        "status"|"s")
            show_status
            ;;
        "start")
            start_services
            ;;
        0)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done