#!/bin/bash

# System Analyzer for Zabbix Database Selection

set -e

echo "🔍 Analyzing Ubuntu System for Zabbix Setup..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# System info variables
TOTAL_RAM=""
AVAILABLE_RAM=""
CPU_CORES=""
DISK_SPACE=""
UBUNTU_VERSION=""
ARCHITECTURE=""

# Database availability
MYSQL_INSTALLED=""
POSTGRESQL_INSTALLED=""
MONGODB_INSTALLED=""
SQLITE_INSTALLED=""
DOCKER_INSTALLED=""

# Get system information
get_system_info() {
    echo -e "${CYAN}📊 System Information:${NC}"
    
    # Ubuntu version
    UBUNTU_VERSION=$(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")
    echo "OS: $UBUNTU_VERSION"
    
    # Architecture
    ARCHITECTURE=$(uname -m)
    echo "Architecture: $ARCHITECTURE"
    
    # CPU info
    CPU_CORES=$(nproc)
    CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    echo "CPU: $CPU_MODEL ($CPU_CORES cores)"
    
    # Memory info
    TOTAL_RAM=$(free -h | awk 'NR==2{print $2}')
    AVAILABLE_RAM=$(free -h | awk 'NR==2{print $7}')
    TOTAL_RAM_MB=$(free -m | awk 'NR==2{print $2}')
    echo "RAM: $TOTAL_RAM total, $AVAILABLE_RAM available"
    
    # Disk space
    DISK_SPACE=$(df -h / | awk 'NR==2{print $4}')
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    echo "Disk: $DISK_TOTAL total, $DISK_SPACE available"
    
    echo ""
}

# Check installed databases
check_databases() {
    echo -e "${CYAN}🗄️ Database Availability:${NC}"
    
    # MySQL
    if command -v mysql &> /dev/null; then
        MYSQL_VERSION=$(mysql --version | cut -d' ' -f3 | cut -d',' -f1)
        echo -e "MySQL: ${GREEN}✅ Installed${NC} (v$MYSQL_VERSION)"
        MYSQL_INSTALLED="yes"
    else
        echo -e "MySQL: ${RED}❌ Not installed${NC}"
        MYSQL_INSTALLED="no"
    fi
    
    # PostgreSQL
    if command -v psql &> /dev/null; then
        POSTGRESQL_VERSION=$(psql --version | cut -d' ' -f3)
        echo -e "PostgreSQL: ${GREEN}✅ Installed${NC} (v$POSTGRESQL_VERSION)"
        POSTGRESQL_INSTALLED="yes"
    else
        echo -e "PostgreSQL: ${RED}❌ Not installed${NC}"
        POSTGRESQL_INSTALLED="no"
    fi
    
    # MongoDB
    if command -v mongod &> /dev/null; then
        MONGODB_VERSION=$(mongod --version | head -1 | cut -d' ' -f3)
        echo -e "MongoDB: ${GREEN}✅ Installed${NC} (v$MONGODB_VERSION)"
        MONGODB_INSTALLED="yes"
    else
        echo -e "MongoDB: ${RED}❌ Not installed${NC}"
        MONGODB_INSTALLED="no"
    fi
    
    # SQLite
    if command -v sqlite3 &> /dev/null; then
        SQLITE_VERSION=$(sqlite3 --version | cut -d' ' -f1)
        echo -e "SQLite: ${GREEN}✅ Installed${NC} (v$SQLITE_VERSION)"
        SQLITE_INSTALLED="yes"
    else
        echo -e "SQLite: ${RED}❌ Not installed${NC}"
        SQLITE_INSTALLED="no"
    fi
    
    # Docker
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        echo -e "Docker: ${GREEN}✅ Installed${NC} (v$DOCKER_VERSION)"
        DOCKER_INSTALLED="yes"
    else
        echo -e "Docker: ${RED}❌ Not installed${NC}"
        DOCKER_INSTALLED="no"
    fi
    
    echo ""
}

# Check system resources
check_resources() {
    echo -e "${CYAN}⚡ Resource Analysis:${NC}"
    
    # RAM analysis
    if [ "$TOTAL_RAM_MB" -lt 1024 ]; then
        echo -e "RAM Status: ${RED}⚠️  Low RAM ($TOTAL_RAM)${NC}"
        RAM_LEVEL="low"
    elif [ "$TOTAL_RAM_MB" -lt 4096 ]; then
        echo -e "RAM Status: ${YELLOW}⚠️  Medium RAM ($TOTAL_RAM)${NC}"
        RAM_LEVEL="medium"
    else
        echo -e "RAM Status: ${GREEN}✅ High RAM ($TOTAL_RAM)${NC}"
        RAM_LEVEL="high"
    fi
    
    # CPU analysis
    if [ "$CPU_CORES" -lt 2 ]; then
        echo -e "CPU Status: ${RED}⚠️  Low CPU ($CPU_CORES cores)${NC}"
        CPU_LEVEL="low"
    elif [ "$CPU_CORES" -lt 4 ]; then
        echo -e "CPU Status: ${YELLOW}⚠️  Medium CPU ($CPU_CORES cores)${NC}"
        CPU_LEVEL="medium"
    else
        echo -e "CPU Status: ${GREEN}✅ High CPU ($CPU_CORES cores)${NC}"
        CPU_LEVEL="high"
    fi
    
    # Disk analysis
    DISK_AVAILABLE_GB=$(df --output=avail / | tail -1 | awk '{print int($1/1024/1024)}')
    if [ "$DISK_AVAILABLE_GB" -lt 5 ]; then
        echo -e "Disk Status: ${RED}⚠️  Low Disk Space ($DISK_SPACE)${NC}"
        DISK_LEVEL="low"
    elif [ "$DISK_AVAILABLE_GB" -lt 20 ]; then
        echo -e "Disk Status: ${YELLOW}⚠️  Medium Disk Space ($DISK_SPACE)${NC}"
        DISK_LEVEL="medium"
    else
        echo -e "Disk Status: ${GREEN}✅ Sufficient Disk Space ($DISK_SPACE)${NC}"
        DISK_LEVEL="high"
    fi
    
    echo ""
}

# Recommend database based on system
recommend_database() {
    echo -e "${BLUE}🎯 Database Recommendations:${NC}"
    echo ""
    
    # Score each database option
    MYSQL_SCORE=0
    POSTGRESQL_SCORE=0
    SQLITE_SCORE=0
    MONGODB_SCORE=0
    
    # Resource-based scoring
    case $RAM_LEVEL in
        "low")
            SQLITE_SCORE=$((SQLITE_SCORE + 3))
            MYSQL_SCORE=$((MYSQL_SCORE - 1))
            POSTGRESQL_SCORE=$((POSTGRESQL_SCORE - 1))
            MONGODB_SCORE=$((MONGODB_SCORE - 2))
            ;;
        "medium")
            MYSQL_SCORE=$((MYSQL_SCORE + 2))
            POSTGRESQL_SCORE=$((POSTGRESQL_SCORE + 2))
            SQLITE_SCORE=$((SQLITE_SCORE + 1))
            ;;
        "high")
            MYSQL_SCORE=$((MYSQL_SCORE + 3))
            POSTGRESQL_SCORE=$((POSTGRESQL_SCORE + 3))
            MONGODB_SCORE=$((MONGODB_SCORE + 2))
            ;;
    esac
    
    # Installation status bonus
    [ "$MYSQL_INSTALLED" = "yes" ] && MYSQL_SCORE=$((MYSQL_SCORE + 2))
    [ "$POSTGRESQL_INSTALLED" = "yes" ] && POSTGRESQL_SCORE=$((POSTGRESQL_SCORE + 2))
    [ "$MONGODB_INSTALLED" = "yes" ] && MONGODB_SCORE=$((MONGODB_SCORE + 2))
    [ "$SQLITE_INSTALLED" = "yes" ] && SQLITE_SCORE=$((SQLITE_SCORE + 1))
    
    # Docker bonus (all databases get bonus if Docker available)
    if [ "$DOCKER_INSTALLED" = "yes" ]; then
        MYSQL_SCORE=$((MYSQL_SCORE + 1))
        POSTGRESQL_SCORE=$((POSTGRESQL_SCORE + 1))
        MONGODB_SCORE=$((MONGODB_SCORE + 1))
        SQLITE_SCORE=$((SQLITE_SCORE + 1))
    fi
    
    # Create recommendations array
    declare -A recommendations
    recommendations["MySQL"]=$MYSQL_SCORE
    recommendations["PostgreSQL"]=$POSTGRESQL_SCORE
    recommendations["SQLite"]=$SQLITE_SCORE
    recommendations["MongoDB"]=$MONGODB_SCORE
    
    # Sort and display recommendations
    echo "Recommendation scores (higher = better fit):"
    echo ""
    
    # MySQL recommendation
    echo -e "${GREEN}1. MySQL (Score: $MYSQL_SCORE)${NC}"
    echo "   ✅ Industry standard for Zabbix"
    echo "   ✅ Excellent performance and stability"
    echo "   ✅ Extensive documentation"
    if [ "$MYSQL_INSTALLED" = "yes" ]; then
        echo "   ✅ Already installed on your system"
    else
        echo "   📦 Will be installed via Docker"
    fi
    if [ "$RAM_LEVEL" = "low" ]; then
        echo "   ⚠️  May use significant RAM"
    fi
    echo ""
    
    # PostgreSQL recommendation
    echo -e "${GREEN}2. PostgreSQL (Score: $POSTGRESQL_SCORE)${NC}"
    echo "   ✅ Advanced features and performance"
    echo "   ✅ Better for complex queries"
    echo "   ✅ ACID compliance"
    if [ "$POSTGRESQL_INSTALLED" = "yes" ]; then
        echo "   ✅ Already installed on your system"
    else
        echo "   📦 Will be installed via Docker"
    fi
    echo ""
    
    # SQLite recommendation
    echo -e "${GREEN}3. SQLite (Score: $SQLITE_SCORE)${NC}"
    echo "   ✅ Lightweight and fast setup"
    echo "   ✅ No external database needed"
    echo "   ✅ Perfect for testing/small deployments"
    if [ "$RAM_LEVEL" = "low" ]; then
        echo "   ✅ Ideal for low-resource systems"
    fi
    if [ "$SQLITE_INSTALLED" = "yes" ]; then
        echo "   ✅ Already installed on your system"
    fi
    echo "   ⚠️  Limited concurrent access"
    echo ""
    
    # MongoDB recommendation
    echo -e "${YELLOW}4. MongoDB (Score: $MONGODB_SCORE)${NC}"
    echo "   ✅ Flexible NoSQL schema"
    echo "   ✅ Good for log data and scaling"
    if [ "$MONGODB_INSTALLED" = "yes" ]; then
        echo "   ✅ Already installed on your system"
    else
        echo "   📦 Will be installed via Docker"
    fi
    echo "   ⚠️  Experimental Zabbix support"
    echo "   ⚠️  Requires custom configuration"
    echo ""
}

# Show deployment options
show_deployment_options() {
    echo -e "${BLUE}🚀 Deployment Options:${NC}"
    echo ""
    
    if [ "$DOCKER_INSTALLED" = "yes" ]; then
        echo -e "${GREEN}Option 1: Docker Deployment (Recommended)${NC}"
        echo "   ✅ Isolated containers"
        echo "   ✅ Easy management"
        echo "   ✅ Consistent environment"
        echo "   ✅ Quick setup and teardown"
        echo "   Command: make select-db"
        echo ""
    else
        echo -e "${YELLOW}Option 1: Install Docker First${NC}"
        echo "   📦 Install Docker for containerized deployment"
        echo "   Command: make install-docker"
        echo ""
    fi
    
    echo -e "${CYAN}Option 2: Native Installation${NC}"
    echo "   📦 Install databases directly on Ubuntu"
    echo "   ⚠️  More complex management"
    echo "   ⚠️  Potential conflicts with system"
    echo ""
}

# Generate configuration recommendations
generate_config_recommendations() {
    echo -e "${BLUE}⚙️  Configuration Recommendations:${NC}"
    echo ""
    
    # Based on system resources
    if [ "$RAM_LEVEL" = "low" ]; then
        echo "For your system (Low RAM):"
        echo "  - Use SQLite for testing/demo"
        echo "  - If using MySQL/PostgreSQL, limit cache sizes"
        echo "  - Reduce Zabbix poller processes"
        echo "  - Consider shorter data retention"
    elif [ "$RAM_LEVEL" = "medium" ]; then
        echo "For your system (Medium RAM):"
        echo "  - MySQL or PostgreSQL recommended"
        echo "  - Standard Zabbix configuration"
        echo "  - Monitor up to 100-200 hosts"
        echo "  - 30-day data retention"
    else
        echo "For your system (High RAM):"
        echo "  - Any database will work well"
        echo "  - Can handle large deployments"
        echo "  - Monitor 500+ hosts"
        echo "  - Extended data retention possible"
    fi
    echo ""
}

# Main execution
main() {
    clear
    echo -e "${BLUE}"
    echo "=============================================="
    echo "    Zabbix System Analyzer for Ubuntu"
    echo "=============================================="
    echo -e "${NC}"
    
    get_system_info
    check_databases
    check_resources
    recommend_database
    show_deployment_options
    generate_config_recommendations
    
    echo -e "${GREEN}🎯 Quick Start Recommendations:${NC}"
    
    if [ "$DOCKER_INSTALLED" = "no" ]; then
        echo "1. Install Docker: make install-docker"
        echo "2. Choose database: make select-db"
        echo "3. Start services: make setup"
    else
        if [ "$RAM_LEVEL" = "low" ]; then
            echo "1. Choose SQLite: make select-db (option 3)"
        elif [ "$MYSQL_INSTALLED" = "yes" ]; then
            echo "1. Use existing MySQL: make select-db (option 1)"
        elif [ "$POSTGRESQL_INSTALLED" = "yes" ]; then
            echo "1. Use existing PostgreSQL: make select-db (option 2)"
        else
            echo "1. Choose MySQL (recommended): make select-db (option 1)"
        fi
        echo "2. Start services: make setup"
    fi
    
    echo ""
    echo -e "${CYAN}💡 Tip: Run 'make select-db' for interactive database selection${NC}"
}

# Run main function
main