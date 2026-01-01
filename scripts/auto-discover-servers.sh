#!/bin/bash

# Auto-discover servers on network for monitoring

set -e

echo "🔍 Auto-discovering servers on network..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get network range
get_network_range() {
    echo -e "${CYAN}🌐 Detecting network range...${NC}"
    
    # Get default gateway and network
    GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
    NETWORK=$(ip route | grep "$GATEWAY" | grep -v default | awk '{print $1}' | head -1)
    
    if [ -z "$NETWORK" ]; then
        # Fallback method
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        NETWORK=$(echo $LOCAL_IP | cut -d'.' -f1-3).0/24
    fi
    
    echo -e "${GREEN}📍 Network range: $NETWORK${NC}"
    echo -e "${GREEN}📍 Gateway: $GATEWAY${NC}"
    
    read -p "Use this network range? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter network range (e.g., 192.168.1.0/24): " NETWORK
    fi
}

# Scan network for live hosts
scan_network() {
    echo -e "${YELLOW}🔍 Scanning network for live hosts...${NC}"
    echo "This may take a few minutes..."
    echo ""
    
    # Extract network base and CIDR
    NETWORK_BASE=$(echo $NETWORK | cut -d'/' -f1 | cut -d'.' -f1-3)
    CIDR=$(echo $NETWORK | cut -d'/' -f2)
    
    # Create temporary file for results
    SCAN_RESULTS=$(mktemp)
    
    # Scan network range
    if [ "$CIDR" = "24" ]; then
        for i in {1..254}; do
            IP="$NETWORK_BASE.$i"
            (ping -c 1 -W 1 "$IP" > /dev/null 2>&1 && echo "$IP") &
        done
        wait
    else
        # Use nmap for other CIDR ranges
        if command -v nmap > /dev/null; then
            nmap -sn "$NETWORK" | grep "Nmap scan report" | awk '{print $5}'
        else
            echo -e "${RED}❌ nmap not installed. Installing...${NC}"
            sudo apt update && sudo apt install -y nmap
            nmap -sn "$NETWORK" | grep "Nmap scan report" | awk '{print $5}'
        fi
    fi > "$SCAN_RESULTS"
    
    # Filter out current machine
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    grep -v "$LOCAL_IP" "$SCAN_RESULTS" > "${SCAN_RESULTS}.filtered" || true
    mv "${SCAN_RESULTS}.filtered" "$SCAN_RESULTS"
    
    LIVE_HOSTS=$(cat "$SCAN_RESULTS" | wc -l)
    echo -e "${GREEN}✅ Found $LIVE_HOSTS live hosts${NC}"
    echo ""
}

# Check SSH access and OS
check_ssh_access() {
    echo -e "${CYAN}🔐 Checking SSH access and OS detection...${NC}"
    echo ""
    
    ACCESSIBLE_HOSTS=$(mktemp)
    
    while read -r host; do
        if [ -z "$host" ]; then continue; fi
        
        echo -n "Checking $host... "
        
        # Common SSH users to try
        SSH_USERS=("ubuntu" "centos" "debian" "root" "admin" "user")
        SSH_SUCCESS=false
        DETECTED_USER=""
        DETECTED_OS=""
        
        for user in "${SSH_USERS[@]}"; do
            if ssh -o ConnectTimeout=3 -o BatchMode=yes -o StrictHostKeyChecking=no "$user@$host" "echo 'SSH_OK'" 2>/dev/null | grep -q "SSH_OK"; then
                SSH_SUCCESS=true
                DETECTED_USER="$user"
                
                # Detect OS
                DETECTED_OS=$(ssh -o ConnectTimeout=3 -o BatchMode=yes -o StrictHostKeyChecking=no "$user@$host" "cat /etc/os-release | grep '^ID=' | cut -d'=' -f2 | tr -d '\"'" 2>/dev/null || echo "unknown")
                
                break
            fi
        done
        
        if [ "$SSH_SUCCESS" = true ]; then
            echo -e "${GREEN}✅ SSH OK ($DETECTED_USER@$host - $DETECTED_OS)${NC}"
            echo "$host,$DETECTED_USER,$DETECTED_OS" >> "$ACCESSIBLE_HOSTS"
        else
            echo -e "${YELLOW}⚠️  No SSH access${NC}"
        fi
        
    done < "$SCAN_RESULTS"
    
    ACCESSIBLE_COUNT=$(cat "$ACCESSIBLE_HOSTS" | wc -l)
    echo ""
    echo -e "${GREEN}✅ Found $ACCESSIBLE_COUNT servers with SSH access${NC}"
    
    rm "$SCAN_RESULTS"
}

# Generate server list
generate_server_list() {
    echo -e "${BLUE}📋 Generating server list...${NC}"
    
    if [ ! -s "$ACCESSIBLE_HOSTS" ]; then
        echo -e "${YELLOW}No accessible servers found${NC}"
        return
    fi
    
    echo "# Auto-discovered servers - $(date)" > discovered-servers.txt
    echo "# Format: IP,USERNAME,OS" >> discovered-servers.txt
    
    counter=1
    while IFS=',' read -r host user os; do
        server_name="Server-$counter-$(echo $os | tr '[:lower:]' '[:upper:]')"
        echo "$host,$user,$server_name" >> discovered-servers.txt
        counter=$((counter + 1))
    done < "$ACCESSIBLE_HOSTS"
    
    echo -e "${GREEN}✅ Server list created: discovered-servers.txt${NC}"
    echo ""
    echo -e "${CYAN}📋 Discovered servers:${NC}"
    cat discovered-servers.txt | grep -v "^#"
    
    rm "$ACCESSIBLE_HOSTS"
}

# Deploy agents to discovered servers
deploy_to_discovered() {
    if [ ! -f "discovered-servers.txt" ]; then
        echo -e "${RED}❌ No discovered servers file found${NC}"
        return
    fi
    
    echo -e "${BLUE}🚀 Deploy agents to discovered servers?${NC}"
    cat discovered-servers.txt | grep -v "^#"
    echo ""
    
    read -p "Deploy to all servers? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    
    # Get Zabbix server IP
    ZABBIX_SERVER_IP=$(sudo docker inspect zabbix-server 2>/dev/null | grep '"IPAddress"' | head -1 | cut -d'"' -f4)
    if [ -z "$ZABBIX_SERVER_IP" ]; then
        ZABBIX_SERVER_IP=$(hostname -I | awk '{print $1}')
    fi
    
    echo -e "${CYAN}Using Zabbix Server IP: $ZABBIX_SERVER_IP${NC}"
    
    while IFS=',' read -r server_ip server_user server_name; do
        if [[ "$server_ip" =~ ^#.*$ ]] || [ -z "$server_ip" ]; then
            continue
        fi
        
        echo -e "${YELLOW}🚀 Deploying to $server_name ($server_ip)...${NC}"
        
        ./scripts/deploy-agent.sh "$server_ip" "$server_user" "$ZABBIX_SERVER_IP"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $server_name deployed successfully${NC}"
            echo "$server_ip,$server_user,$server_name" >> servers.txt
        else
            echo -e "${RED}❌ Failed to deploy to $server_name${NC}"
        fi
        
        echo ""
    done < discovered-servers.txt
}

# Port scan for common services
scan_services() {
    echo -e "${CYAN}🔍 Scanning for common services...${NC}"
    
    if [ ! -s "$SCAN_RESULTS" ]; then
        echo -e "${RED}No hosts to scan${NC}"
        return
    fi
    
    SERVICES_FILE=$(mktemp)
    
    while read -r host; do
        if [ -z "$host" ]; then continue; fi
        
        echo -n "Scanning services on $host... "
        
        # Common ports to check
        PORTS=(22 80 443 3306 5432 6379 9200 3000 8080 8443)
        OPEN_PORTS=()
        
        for port in "${PORTS[@]}"; do
            if nc -z -w 1 "$host" "$port" 2>/dev/null; then
                OPEN_PORTS+=("$port")
            fi
        done
        
        if [ ${#OPEN_PORTS[@]} -gt 0 ]; then
            PORTS_STR=$(IFS=','; echo "${OPEN_PORTS[*]}")
            echo -e "${GREEN}✅ Ports: $PORTS_STR${NC}"
            echo "$host,${PORTS_STR}" >> "$SERVICES_FILE"
        else
            echo -e "${YELLOW}⚠️  No common services${NC}"
        fi
        
    done < "$SCAN_RESULTS"
    
    if [ -s "$SERVICES_FILE" ]; then
        echo ""
        echo -e "${BLUE}📊 Services Summary:${NC}"
        while IFS=',' read -r host ports; do
            echo "  $host: $ports"
        done < "$SERVICES_FILE"
    fi
    
    rm "$SERVICES_FILE"
}

# Main function
main() {
    clear
    echo -e "${BLUE}"
    echo "=============================================="
    echo "    🔍 Auto-discover Network Servers"
    echo "=============================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}This script will:${NC}"
    echo "1. Scan your network for live hosts"
    echo "2. Check SSH access to discovered hosts"
    echo "3. Generate server list for monitoring"
    echo "4. Optionally deploy Zabbix agents"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    get_network_range
    scan_network
    scan_services
    check_ssh_access
    generate_server_list
    
    echo ""
    read -p "Deploy Zabbix agents to discovered servers? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_to_discovered
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Auto-discovery completed!${NC}"
    echo ""
    echo -e "${CYAN}📝 Next steps:${NC}"
    echo "1. Review discovered-servers.txt"
    echo "2. Run multi-server setup if needed"
    echo "3. Add hosts in Zabbix Web UI"
    echo "4. Configure monitoring templates"
}

# Run main function
main