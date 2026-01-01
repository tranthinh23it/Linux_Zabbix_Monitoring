#!/bin/bash

# Zabbix Agent Deployment Script for Remote Servers

set -e

SERVER_IP="$1"
SERVER_USER="$2"
ZABBIX_SERVER_IP="$3"

if [ -z "$SERVER_IP" ] || [ -z "$SERVER_USER" ] || [ -z "$ZABBIX_SERVER_IP" ]; then
    echo "Usage: $0 <server_ip> <server_user> <zabbix_server_ip>"
    echo "Example: $0 192.168.1.100 ubuntu 192.168.1.50"
    exit 1
fi

echo "🚀 Deploying Zabbix Agent to $SERVER_IP..."

# Create agent configuration
AGENT_CONFIG="# Zabbix Agent Configuration
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$ZABBIX_SERVER_IP
ServerActive=$ZABBIX_SERVER_IP
Hostname=$(ssh $SERVER_USER@$SERVER_IP hostname)
Include=/etc/zabbix/zabbix_agentd.d/*.conf
UnsafeUserParameters=1

# Custom user parameters
UserParameter=docker.containers.running,docker ps -q | wc -l
UserParameter=docker.containers.total,docker ps -aq | wc -l
UserParameter=docker.images.total,docker images -q | wc -l
UserParameter=system.cpu.temperature,cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print \$1/1000}' || echo 0
UserParameter=system.memory.available,free -m | awk 'NR==2{printf \"%.1f\", \$7*100/\$2}'
UserParameter=system.swap.usage,free | awk 'NR==3{printf \"%.1f\", \$3*100/\$2}'
UserParameter=system.process.count,ps aux | wc -l
UserParameter=system.zombie.processes,ps aux | awk '{print \$8}' | grep -c Z
UserParameter=system.network.connections,netstat -an | grep ESTABLISHED | wc -l
UserParameter=system.uptime.seconds,cat /proc/uptime | awk '{print int(\$1)}'
UserParameter=system.logged.users,who | wc -l
UserParameter=system.failed.logins,journalctl --since \"1 hour ago\" | grep \"Failed password\" | wc -l"

# Deploy agent via SSH
ssh $SERVER_USER@$SERVER_IP << EOF
    # Update system
    sudo apt update

    # Install Zabbix repository
    wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
    sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
    sudo apt update

    # Install Zabbix agent
    sudo apt install -y zabbix-agent

    # Create configuration
    echo '$AGENT_CONFIG' | sudo tee /etc/zabbix/zabbix_agentd.conf

    # Create log directory
    sudo mkdir -p /var/log/zabbix
    sudo chown zabbix:zabbix /var/log/zabbix

    # Enable and start service
    sudo systemctl enable zabbix-agent
    sudo systemctl restart zabbix-agent
    sudo systemctl status zabbix-agent

    # Configure firewall
    sudo ufw allow 10050/tcp

    echo "✅ Zabbix Agent installed and configured successfully!"
EOF

echo "✅ Zabbix Agent deployment completed on $SERVER_IP"
echo "📝 Next steps:"
echo "1. Add host in Zabbix Web UI"
echo "2. Assign templates"
echo "3. Configure monitoring items"