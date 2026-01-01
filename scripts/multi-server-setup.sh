#!/bin/bash

# Multi-Server Monitoring Setup Script

set -e

echo "🖥️ Multi-Server Monitoring Setup for Zabbix"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get Zabbix server IP
get_zabbix_server_ip() {
    echo -e "${CYAN}🔍 Detecting Zabbix Server IP...${NC}"
    
    # Try to get Docker container IP
    ZABBIX_SERVER_IP=$(sudo docker inspect zabbix-server 2>/dev/null | grep '"IPAddress"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$ZABBIX_SERVER_IP" ]; then
        # Fallback to host IP
        ZABBIX_SERVER_IP=$(hostname -I | awk '{print $1}')
    fi
    
    echo -e "${GREEN}📍 Zabbix Server IP: $ZABBIX_SERVER_IP${NC}"
    
    read -p "Is this correct? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter Zabbix Server IP: " ZABBIX_SERVER_IP
    fi
}

# Add single server
add_single_server() {
    echo -e "${BLUE}➕ Adding Single Server${NC}"
    echo "=========================="
    
    read -p "Server IP: " SERVER_IP
    read -p "SSH Username: " SERVER_USER
    read -p "Server Name (optional): " SERVER_NAME
    
    if [ -z "$SERVER_NAME" ]; then
        SERVER_NAME="Server-$SERVER_IP"
    fi
    
    echo -e "${YELLOW}🚀 Deploying agent to $SERVER_IP...${NC}"
    
    # Deploy agent
    ./scripts/deploy-agent.sh "$SERVER_IP" "$SERVER_USER" "$ZABBIX_SERVER_IP"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Agent deployed successfully${NC}"
        
        # Add to servers list
        echo "$SERVER_IP,$SERVER_USER,$SERVER_NAME" >> servers.txt
        
        echo -e "${CYAN}📝 Server added to monitoring list${NC}"
        echo "   IP: $SERVER_IP"
        echo "   User: $SERVER_USER"
        echo "   Name: $SERVER_NAME"
    else
        echo -e "${RED}❌ Failed to deploy agent${NC}"
    fi
}

# Add multiple servers from file
add_multiple_servers() {
    echo -e "${BLUE}📋 Adding Multiple Servers from File${NC}"
    echo "=================================="
    
    if [ ! -f "servers-list.txt" ]; then
        echo -e "${YELLOW}Creating servers-list.txt template...${NC}"
        cat > servers-list.txt << EOF
# Server list format: IP,USERNAME,NAME
# Example:
# 192.168.1.100,ubuntu,Web Server 1
# 192.168.1.101,ubuntu,Database Server
# 192.168.1.102,centos,App Server 1
EOF
        echo -e "${GREEN}✅ Template created: servers-list.txt${NC}"
        echo "Please edit this file and run the script again."
        return
    fi
    
    echo -e "${YELLOW}📖 Reading servers from servers-list.txt...${NC}"
    
    while IFS=',' read -r server_ip server_user server_name; do
        # Skip comments and empty lines
        if [[ "$server_ip" =~ ^#.*$ ]] || [ -z "$server_ip" ]; then
            continue
        fi
        
        echo -e "${CYAN}🚀 Deploying to $server_name ($server_ip)...${NC}"
        
        ./scripts/deploy-agent.sh "$server_ip" "$server_user" "$ZABBIX_SERVER_IP"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $server_name deployed successfully${NC}"
            echo "$server_ip,$server_user,$server_name" >> servers.txt
        else
            echo -e "${RED}❌ Failed to deploy to $server_name${NC}"
        fi
        
        echo ""
    done < servers-list.txt
}

# Create Zabbix host configuration
create_host_config() {
    local server_ip="$1"
    local server_name="$2"
    
    cat > "configs/zabbix/host-$server_ip.json" << EOF
{
    "host": "$server_name",
    "name": "$server_name",
    "groups": [
        {
            "groupid": "2"
        }
    ],
    "interfaces": [
        {
            "type": 1,
            "main": 1,
            "useip": 1,
            "ip": "$server_ip",
            "dns": "",
            "port": "10050"
        }
    ],
    "templates": [
        {
            "templateid": "10001"
        }
    ],
    "status": 0,
    "inventory_mode": 1
}
EOF
}

# Generate Zabbix import instructions
generate_import_instructions() {
    echo -e "${BLUE}📋 Generating Zabbix Web UI Instructions${NC}"
    
    cat > ZABBIX_HOST_SETUP.md << EOF
# 🖥️ Adding Hosts to Zabbix Web UI

## Automatic Host Addition (Recommended)

### Step 1: Login to Zabbix
1. Open: http://localhost
2. Login: Admin / zabbix

### Step 2: Add Hosts
For each server you deployed agents to:

EOF

    if [ -f servers.txt ]; then
        while IFS=',' read -r server_ip server_user server_name; do
            cat >> ZABBIX_HOST_SETUP.md << EOF
#### $server_name ($server_ip)
1. Go to **Configuration** → **Hosts**
2. Click **Create host**
3. Configure:
   - **Host name**: $server_name
   - **Visible name**: $server_name
   - **Groups**: Linux servers
   - **Interfaces**: 
     - Type: Agent
     - IP address: $server_ip
     - Port: 10050
4. **Templates** tab:
   - Add: "Linux by Zabbix agent"
   - Add: "Linux Server Advanced" (if imported)
5. Click **Add**

EOF
        done < servers.txt
    fi

    cat >> ZABBIX_HOST_SETUP.md << EOF

## Manual Host Addition

### For each server:
1. **Configuration** → **Hosts** → **Create host**
2. **Host** tab:
   - Host name: [Server Name]
   - Visible name: [Server Name]
   - Groups: Linux servers
3. **Interfaces** tab:
   - Type: Agent
   - IP: [Server IP]
   - Port: 10050
4. **Templates** tab:
   - Linux by Zabbix agent
   - Linux Server Advanced
5. **Macros** tab (optional):
   - Add custom macros if needed
6. Click **Add**

## Verification

### Check Agent Connection:
1. **Configuration** → **Hosts**
2. Look for green "ZBX" icon next to host
3. If red, check:
   - Agent is running: \`sudo systemctl status zabbix-agent\`
   - Firewall allows port 10050
   - Network connectivity

### View Monitoring Data:
1. **Monitoring** → **Latest data**
2. Select your host
3. Should see CPU, Memory, Disk metrics

### Create Custom Dashboards:
1. **Monitoring** → **Dashboards**
2. Create dashboard for each server group
3. Add graphs and widgets

## Troubleshooting

### Agent not connecting:
\`\`\`bash
# On monitored server
sudo systemctl status zabbix-agent
sudo tail -f /var/log/zabbix/zabbix_agentd.log
sudo ufw status
\`\`\`

### No data appearing:
1. Check host configuration
2. Verify templates are linked
3. Check item keys are correct
4. Review Zabbix server logs
EOF

    echo -e "${GREEN}✅ Instructions created: ZABBIX_HOST_SETUP.md${NC}"
}

# Show monitoring status
show_monitoring_status() {
    echo -e "${CYAN}📊 Current Monitoring Status${NC}"
    echo "=================================="
    
    if [ -f servers.txt ]; then
        echo -e "${GREEN}Monitored Servers:${NC}"
        while IFS=',' read -r server_ip server_user server_name; do
            echo "  🖥️  $server_name ($server_ip)"
            
            # Test connectivity
            if ping -c 1 -W 1 "$server_ip" > /dev/null 2>&1; then
                echo "      ✅ Network: Reachable"
            else
                echo "      ❌ Network: Unreachable"
            fi
            
            # Test Zabbix agent port
            if nc -z -w 1 "$server_ip" 10050 2>/dev/null; then
                echo "      ✅ Agent: Running"
            else
                echo "      ❌ Agent: Not responding"
            fi
            
            echo ""
        done < servers.txt
    else
        echo -e "${YELLOW}No servers configured yet${NC}"
    fi
    
    echo -e "${BLUE}Zabbix Server Status:${NC}"
    if sudo docker ps | grep -q zabbix-server; then
        echo "  ✅ Zabbix Server: Running"
    else
        echo "  ❌ Zabbix Server: Not running"
    fi
    
    if sudo docker ps | grep -q zabbix-web; then
        echo "  ✅ Web Interface: Running"
    else
        echo "  ❌ Web Interface: Not running"
    fi
}

# Create monitoring dashboard
create_monitoring_dashboard() {
    echo -e "${YELLOW}📊 Creating monitoring dashboard...${NC}"
    
    cat > scripts/monitoring-dashboard.sh << 'EOF'
#!/bin/bash

# Real-time monitoring dashboard

watch -n 5 '
clear
echo "🖥️  ZABBIX MULTI-SERVER MONITORING DASHBOARD"
echo "=============================================="
echo "Updated: $(date)"
echo ""

if [ -f servers.txt ]; then
    while IFS="," read -r server_ip server_user server_name; do
        echo "🖥️  $server_name ($server_ip)"
        echo "   Network: $(ping -c 1 -W 1 $server_ip >/dev/null 2>&1 && echo "✅ UP" || echo "❌ DOWN")"
        echo "   Agent:   $(nc -z -w 1 $server_ip 10050 2>/dev/null && echo "✅ RUNNING" || echo "❌ STOPPED")"
        echo ""
    done < servers.txt
else
    echo "No servers configured"
fi

echo "Zabbix Server Status:"
echo "   Server:  $(sudo docker ps | grep -q zabbix-server && echo "✅ RUNNING" || echo "❌ STOPPED")"
echo "   Web UI:  $(sudo docker ps | grep -q zabbix-web && echo "✅ RUNNING" || echo "❌ STOPPED")"
echo "   MySQL:   $(sudo docker ps | grep -q zabbix-mysql && echo "✅ RUNNING" || echo "❌ STOPPED")"
echo ""
echo "Press Ctrl+C to exit"
'
EOF
    
    chmod +x scripts/monitoring-dashboard.sh
    echo -e "${GREEN}✅ Dashboard created: scripts/monitoring-dashboard.sh${NC}"
}

# Main menu
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}"
        echo "=============================================="
        echo "    🖥️  Multi-Server Monitoring Setup"
        echo "=============================================="
        echo -e "${NC}"
        
        echo "1) Add single server"
        echo "2) Add multiple servers from file"
        echo "3) Show monitoring status"
        echo "4) Generate Zabbix setup instructions"
        echo "5) Create monitoring dashboard"
        echo "6) Test server connectivity"
        echo "0) Exit"
        echo ""
        
        read -p "Select option [0-6]: " choice
        
        case $choice in
            1)
                add_single_server
                read -p "Press Enter to continue..."
                ;;
            2)
                add_multiple_servers
                read -p "Press Enter to continue..."
                ;;
            3)
                show_monitoring_status
                read -p "Press Enter to continue..."
                ;;
            4)
                generate_import_instructions
                read -p "Press Enter to continue..."
                ;;
            5)
                create_monitoring_dashboard
                read -p "Press Enter to continue..."
                ;;
            6)
                if [ -f servers.txt ]; then
                    echo -e "${CYAN}Testing connectivity...${NC}"
                    while IFS=',' read -r server_ip server_user server_name; do
                        echo -n "Testing $server_name ($server_ip)... "
                        if ping -c 1 -W 2 "$server_ip" > /dev/null 2>&1; then
                            echo -e "${GREEN}✅ OK${NC}"
                        else
                            echo -e "${RED}❌ FAILED${NC}"
                        fi
                    done < servers.txt
                else
                    echo -e "${YELLOW}No servers configured${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Initialize
get_zabbix_server_ip
main_menu