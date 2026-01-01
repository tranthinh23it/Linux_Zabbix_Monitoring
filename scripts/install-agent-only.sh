#!/bin/bash

# Script cài Zabbix Agent trên máy khác (máy được giám sát)

set -e

echo "📦 Installing Zabbix Agent on Remote Server..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get Zabbix Server IP
if [ -z "$1" ]; then
    read -p "Enter Zabbix Server IP: " ZABBIX_SERVER_IP
else
    ZABBIX_SERVER_IP="$1"
fi

echo -e "${BLUE}🔧 Installing Zabbix Agent...${NC}"
echo "Zabbix Server IP: $ZABBIX_SERVER_IP"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo -e "${RED}❌ Cannot detect OS${NC}"
    exit 1
fi

echo -e "${CYAN}📋 Detected OS: $OS $VERSION${NC}"

# Install based on OS
case $OS in
    "ubuntu"|"debian")
        echo -e "${YELLOW}📦 Installing on Ubuntu/Debian...${NC}"
        
        # Update system
        sudo apt update
        
        # Install Zabbix repository
        if [ "$OS" = "ubuntu" ]; then
            if [ "${VERSION%%.*}" -ge 22 ]; then
                REPO_VERSION="22.04"
            elif [ "${VERSION%%.*}" -ge 20 ]; then
                REPO_VERSION="20.04"
            else
                REPO_VERSION="18.04"
            fi
        else
            REPO_VERSION="11"  # Debian
        fi
        
        wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu${REPO_VERSION}_all.deb
        sudo dpkg -i zabbix-release_6.4-1+ubuntu${REPO_VERSION}_all.deb
        sudo apt update
        
        # Install Zabbix agent
        sudo apt install -y zabbix-agent
        ;;
        
    "centos"|"rhel"|"rocky"|"almalinux")
        echo -e "${YELLOW}📦 Installing on CentOS/RHEL...${NC}"
        
        # Install Zabbix repository
        sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-release-6.4-1.el8.noarch.rpm
        
        # Install Zabbix agent
        sudo dnf install -y zabbix-agent
        ;;
        
    *)
        echo -e "${RED}❌ Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

# Configure Zabbix Agent
echo -e "${YELLOW}⚙️ Configuring Zabbix Agent...${NC}"

# Get hostname
HOSTNAME=$(hostname)

# Create configuration
sudo tee /etc/zabbix/zabbix_agentd.conf > /dev/null << EOF
# Zabbix Agent Configuration
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0

# Server configuration
Server=$ZABBIX_SERVER_IP
ServerActive=$ZABBIX_SERVER_IP
Hostname=$HOSTNAME

# Security
AllowRoot=0
User=zabbix

# Performance
StartAgents=3
Timeout=3

# Include additional configs
Include=/etc/zabbix/zabbix_agentd.d/*.conf

# Enable user parameters
UnsafeUserParameters=1

# Custom user parameters for advanced monitoring
UserParameter=system.cpu.temperature,cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print \$1/1000}' || echo 0
UserParameter=system.memory.available,free -m | awk 'NR==2{printf "%.1f", \$7*100/\$2}'
UserParameter=system.swap.usage,free | awk 'NR==3{printf "%.1f", \$3*100/\$2}'
UserParameter=system.process.count,ps aux | wc -l
UserParameter=system.zombie.processes,ps aux | awk '{print \$8}' | grep -c Z || echo 0
UserParameter=system.network.connections,netstat -an | grep ESTABLISHED | wc -l
UserParameter=system.uptime.seconds,cat /proc/uptime | awk '{print int(\$1)}'
UserParameter=system.logged.users,who | wc -l
UserParameter=system.failed.logins,journalctl --since "1 hour ago" | grep "Failed password" | wc -l || echo 0

# Docker monitoring (if Docker is installed)
UserParameter=docker.containers.running,docker ps -q 2>/dev/null | wc -l || echo 0
UserParameter=docker.containers.total,docker ps -aq 2>/dev/null | wc -l || echo 0
UserParameter=docker.images.total,docker images -q 2>/dev/null | wc -l || echo 0

# Web server monitoring
UserParameter=apache.status,curl -s http://localhost/server-status?auto 2>/dev/null | grep "Total Accesses" | awk '{print \$3}' || echo 0
UserParameter=nginx.status,curl -s http://localhost/nginx_status 2>/dev/null | grep "Active connections" | awk '{print \$3}' || echo 0

# Database monitoring
UserParameter=mysql.ping,mysqladmin ping 2>/dev/null | grep -c "mysqld is alive" || echo 0
UserParameter=mysql.version,mysql --version 2>/dev/null | awk '{print \$5}' | cut -d',' -f1 || echo "not_installed"

# Custom service monitoring
UserParameter=service.status[*],systemctl is-active \$1 2>/dev/null | grep -c "active" || echo 0
UserParameter=service.enabled[*],systemctl is-enabled \$1 2>/dev/null | grep -c "enabled" || echo 0
EOF

# Create log directory
sudo mkdir -p /var/log/zabbix
sudo chown zabbix:zabbix /var/log/zabbix

# Configure firewall
echo -e "${YELLOW}🔥 Configuring firewall...${NC}"

if command -v ufw > /dev/null; then
    # Ubuntu/Debian firewall
    sudo ufw allow 10050/tcp
    echo -e "${GREEN}✅ UFW: Allowed port 10050${NC}"
elif command -v firewall-cmd > /dev/null; then
    # CentOS/RHEL firewall
    sudo firewall-cmd --permanent --add-port=10050/tcp
    sudo firewall-cmd --reload
    echo -e "${GREEN}✅ Firewalld: Allowed port 10050${NC}"
fi

# Start and enable Zabbix Agent
echo -e "${YELLOW}🚀 Starting Zabbix Agent...${NC}"

sudo systemctl enable zabbix-agent
sudo systemctl start zabbix-agent

# Check status
sleep 3
if sudo systemctl is-active --quiet zabbix-agent; then
    echo -e "${GREEN}✅ Zabbix Agent is running${NC}"
else
    echo -e "${RED}❌ Zabbix Agent failed to start${NC}"
    echo "Checking logs..."
    sudo journalctl -u zabbix-agent --no-pager -l
    exit 1
fi

# Test connectivity
echo -e "${YELLOW}🔍 Testing connectivity to Zabbix Server...${NC}"

if nc -z -w 5 "$ZABBIX_SERVER_IP" 10051; then
    echo -e "${GREEN}✅ Can connect to Zabbix Server${NC}"
else
    echo -e "${RED}❌ Cannot connect to Zabbix Server${NC}"
    echo "Please check:"
    echo "1. Zabbix Server is running"
    echo "2. Network connectivity"
    echo "3. Firewall settings"
fi

# Show status
echo ""
echo -e "${BLUE}📊 Installation Summary:${NC}"
echo "=================================="
echo "✅ Zabbix Agent: Installed and running"
echo "✅ Configuration: /etc/zabbix/zabbix_agentd.conf"
echo "✅ Log file: /var/log/zabbix/zabbix_agentd.log"
echo "✅ Firewall: Port 10050 opened"
echo "✅ Server IP: $ZABBIX_SERVER_IP"
echo "✅ Hostname: $HOSTNAME"
echo ""
echo -e "${GREEN}🎉 Zabbix Agent installation completed!${NC}"
echo ""
echo -e "${CYAN}📝 Next steps:${NC}"
echo "1. Add this host in Zabbix Web UI"
echo "2. Go to: http://$ZABBIX_SERVER_IP"
echo "3. Configuration → Hosts → Create host"
echo "4. Use IP: $(hostname -I | awk '{print $1}') and Hostname: $HOSTNAME"

# Show useful commands
echo ""
echo -e "${BLUE}🔧 Useful commands:${NC}"
echo "Check status: sudo systemctl status zabbix-agent"
echo "View logs: sudo tail -f /var/log/zabbix/zabbix_agentd.log"
echo "Restart agent: sudo systemctl restart zabbix-agent"
echo "Test config: sudo zabbix_agentd -t"