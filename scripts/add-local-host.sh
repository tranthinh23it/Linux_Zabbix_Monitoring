#!/bin/bash

# Add Local Host to Zabbix Server

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🖥️ Adding Local Host to Zabbix Server...${NC}"
echo ""

# Zabbix API Configuration
ZABBIX_URL="http://localhost"
ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
HOSTNAME=$(hostname)
HOST_IP="127.0.0.1"

echo -e "${YELLOW}Host Information:${NC}"
echo "  Hostname: $HOSTNAME"
echo "  IP: $HOST_IP"
echo ""

# Step 1: Authenticate
echo -e "${BLUE}🔐 Authenticating with Zabbix API...${NC}"

AUTH_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.login\",
    \"params\": {
      \"username\": \"$ZABBIX_USER\",
      \"password\": \"$ZABBIX_PASS\"
    },
    \"id\": 1
  }")

AUTH_TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"result":"[^"]*' | cut -d'"' -f4)

if [ -z "$AUTH_TOKEN" ]; then
    echo -e "${RED}❌ Authentication failed${NC}"
    echo "Response: $AUTH_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✅ Authenticated${NC}"
echo ""

# Step 2: Get Linux template ID
echo -e "${BLUE}📋 Getting Linux template...${NC}"

TEMPLATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\",
    \"params\": {
      \"filter\": {
        \"host\": \"Linux by Zabbix agent\"
      }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

TEMPLATE_ID=$(echo "$TEMPLATE_RESPONSE" | grep -o '"templateid":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$TEMPLATE_ID" ]; then
    echo -e "${YELLOW}⚠️  Linux template not found, trying alternative...${NC}"
    
    TEMPLATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
      -H "Content-Type: application/json" \
      -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"template.get\",
        \"params\": {
          \"search\": {
            \"host\": \"Linux\"
          },
          \"limit\": 1
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1
      }")
    
    TEMPLATE_ID=$(echo "$TEMPLATE_RESPONSE" | grep -o '"templateid":"[^"]*' | head -1 | cut -d'"' -f4)
fi

if [ -z "$TEMPLATE_ID" ]; then
    echo -e "${YELLOW}⚠️  No Linux template found, creating host without template${NC}"
    TEMPLATE_ID=""
else
    echo -e "${GREEN}✅ Template found: $TEMPLATE_ID${NC}"
fi

echo ""

# Step 3: Get host group ID
echo -e "${BLUE}📁 Getting host group...${NC}"

GROUP_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostgroup.get\",
    \"params\": {
      \"filter\": {
        \"name\": \"Linux servers\"
      }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

GROUP_ID=$(echo "$GROUP_RESPONSE" | grep -o '"groupid":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$GROUP_ID" ]; then
    echo -e "${YELLOW}⚠️  Host group not found, creating new group...${NC}"
    
    GROUP_CREATE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
      -H "Content-Type: application/json" \
      -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"hostgroup.create\",
        \"params\": {
          \"name\": \"Linux servers\"
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1
      }")
    
    GROUP_ID=$(echo "$GROUP_CREATE" | grep -o '"groupids":\["[^"]*' | cut -d'"' -f4)
    echo -e "${GREEN}✅ Host group created: $GROUP_ID${NC}"
else
    echo -e "${GREEN}✅ Host group found: $GROUP_ID${NC}"
fi

echo ""

# Step 4: Check if host already exists
echo -e "${BLUE}🔍 Checking if host already exists...${NC}"

EXISTING_HOST=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
      \"filter\": {
        \"host\": \"$HOSTNAME\"
      }
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

EXISTING_HOST_ID=$(echo "$EXISTING_HOST" | grep -o '"hostid":"[^"]*' | head -1 | cut -d'"' -f4)

if [ ! -z "$EXISTING_HOST_ID" ]; then
    echo -e "${YELLOW}⚠️  Host already exists: $EXISTING_HOST_ID${NC}"
    echo -e "${BLUE}Updating host...${NC}"
    
    # Update existing host
    if [ ! -z "$TEMPLATE_ID" ]; then
        UPDATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
          -H "Content-Type: application/json" \
          -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"host.update\",
            \"params\": {
              \"hostid\": \"$EXISTING_HOST_ID\",
              \"interfaces\": [
                {
                  \"type\": 1,
                  \"main\": 1,
                  \"useip\": 1,
                  \"ip\": \"$HOST_IP\",
                  \"dns\": \"$HOSTNAME\",
                  \"port\": \"10050\"
                }
              ],
              \"templates\": [
                {
                  \"templateid\": \"$TEMPLATE_ID\"
                }
              ]
            },
            \"auth\": \"$AUTH_TOKEN\",
            \"id\": 1
          }")
    else
        UPDATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
          -H "Content-Type: application/json" \
          -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"host.update\",
            \"params\": {
              \"hostid\": \"$EXISTING_HOST_ID\",
              \"interfaces\": [
                {
                  \"type\": 1,
                  \"main\": 1,
                  \"useip\": 1,
                  \"ip\": \"$HOST_IP\",
                  \"dns\": \"$HOSTNAME\",
                  \"port\": \"10050\"
                }
              ]
            },
            \"auth\": \"$AUTH_TOKEN\",
            \"id\": 1
          }")
    fi
    
    echo -e "${GREEN}✅ Host updated${NC}"
else
    echo -e "${BLUE}Creating new host...${NC}"
    
    # Create new host
    if [ ! -z "$TEMPLATE_ID" ]; then
        CREATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
          -H "Content-Type: application/json" \
          -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"host.create\",
            \"params\": {
              \"host\": \"$HOSTNAME\",
              \"groups\": [
                {
                  \"groupid\": \"$GROUP_ID\"
                }
              ],
              \"interfaces\": [
                {
                  \"type\": 1,
                  \"main\": 1,
                  \"useip\": 1,
                  \"ip\": \"$HOST_IP\",
                  \"dns\": \"$HOSTNAME\",
                  \"port\": \"10050\"
                }
              ],
              \"templates\": [
                {
                  \"templateid\": \"$TEMPLATE_ID\"
                }
              ]
            },
            \"auth\": \"$AUTH_TOKEN\",
            \"id\": 1
          }")
    else
        CREATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
          -H "Content-Type: application/json" \
          -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"host.create\",
            \"params\": {
              \"host\": \"$HOSTNAME\",
              \"groups\": [
                {
                  \"groupid\": \"$GROUP_ID\"
                }
              ],
              \"interfaces\": [
                {
                  \"type\": 1,
                  \"main\": 1,
                  \"useip\": 1,
                  \"ip\": \"$HOST_IP\",
                  \"dns\": \"$HOSTNAME\",
                  \"port\": \"10050\"
                }
              ]
            },
            \"auth\": \"$AUTH_TOKEN\",
            \"id\": 1
          }")
    fi
    
    NEW_HOST_ID=$(echo "$CREATE_RESPONSE" | grep -o '"hostids":\["[^"]*' | cut -d'"' -f4)
    
    if [ ! -z "$NEW_HOST_ID" ]; then
        echo -e "${GREEN}✅ Host created: $NEW_HOST_ID${NC}"
    else
        echo -e "${RED}❌ Failed to create host${NC}"
        echo "Response: $CREATE_RESPONSE"
        exit 1
    fi
fi

echo ""

# Step 5: Add host to email config
echo -e "${BLUE}📧 Adding host to email configuration...${NC}"

# Check if host-emails.conf exists
if [ ! -f "host-emails.conf" ]; then
    echo -e "${YELLOW}Creating host-emails.conf...${NC}"
    cat > host-emails.conf << 'EOF'
# Format: hostname=email
# Example:
# tranthinh=tranhungthinh30702@gmail.com
# server-2=admin@server2.com
# server-3=ops@server3.com

EOF
fi

# Check if host already in config
if grep -q "^$HOSTNAME=" host-emails.conf; then
    echo -e "${YELLOW}⚠️  Host already in config${NC}"
else
    # Prompt for email
    read -p "Enter email for $HOSTNAME (or press Enter to skip): " HOST_EMAIL
    
    if [ ! -z "$HOST_EMAIL" ]; then
        echo "$HOSTNAME=$HOST_EMAIL" >> host-emails.conf
        echo -e "${GREEN}✅ Added to host-emails.conf${NC}"
    else
        echo -e "${YELLOW}⚠️  Skipped email configuration${NC}"
    fi
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Host Added Successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📊 Next Steps:${NC}"
echo "1. Go to Zabbix Web UI: http://localhost"
echo "2. Configuration → Hosts"
echo "3. Find host: $HOSTNAME"
echo "4. Wait 1-2 minutes for data collection"
echo "5. Go to Monitoring → Latest data"
echo "6. Search for: $HOSTNAME"
echo ""
echo -e "${YELLOW}💡 Email Configuration:${NC}"
echo "• Host email saved in: host-emails.conf"
echo "• Run: bash scripts/setup-multi-host-emails.sh"
echo "• This will add custom fields to all hosts"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "• Agent port: 10050"
echo "• Check agent status: sudo systemctl status zabbix-agent"
echo "• View agent logs: sudo tail -f /var/log/zabbix/zabbix_agentd.log"
echo ""
