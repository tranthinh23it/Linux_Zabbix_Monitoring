#!/bin/bash

# Check if Zabbix Agent is sending data

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

HOSTNAME=$(hostname)
ZABBIX_URL="http://localhost"
ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"

echo -e "${BLUE}📊 Checking Zabbix Agent Data...${NC}"
echo ""

# Authenticate
AUTH_TOKEN=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.login\",
    \"params\": {
      \"username\": \"$ZABBIX_USER\",
      \"password\": \"$ZABBIX_PASS\"
    },
    \"id\": 1
  }" | grep -o '"result":"[^"]*' | cut -d'"' -f4)

if [ -z "$AUTH_TOKEN" ]; then
    echo -e "${RED}❌ Authentication failed${NC}"
    exit 1
fi

# Get host ID
HOST_ID=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
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
  }" | grep -o '"hostid":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$HOST_ID" ]; then
    echo -e "${RED}❌ Host not found: $HOSTNAME${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Host found: $HOSTNAME (ID: $HOST_ID)${NC}"
echo ""

# Get latest items
echo -e "${BLUE}📈 Latest Data from Agent:${NC}"
echo ""

ITEMS=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"item.get\",
    \"params\": {
      \"hostids\": \"$HOST_ID\",
      \"limit\": 20,
      \"sortfield\": \"name\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

# Extract item names and values
echo "$ITEMS" | grep -o '"name":"[^"]*' | cut -d'"' -f4 | while read item; do
    VALUE=$(echo "$ITEMS" | grep -A 5 "\"name\":\"$item\"" | grep -o '"lastvalue":"[^"]*' | head -1 | cut -d'"' -f4)
    if [ ! -z "$VALUE" ]; then
        echo "  • $item: $VALUE"
    fi
done

echo ""
echo -e "${BLUE}🔍 Agent Status:${NC}"
echo ""

# Check agent service
if sudo systemctl is-active --quiet zabbix-agent; then
    echo -e "${GREEN}✅ Agent service: Running${NC}"
else
    echo -e "${RED}❌ Agent service: Stopped${NC}"
fi

# Check agent port
if netstat -tuln 2>/dev/null | grep -q ":10050"; then
    echo -e "${GREEN}✅ Agent port 10050: Listening${NC}"
else
    echo -e "${YELLOW}⚠️  Agent port 10050: Not listening${NC}"
fi

# Check agent config
AGENT_CONFIG="/etc/zabbix/zabbix_agentd.conf"
if [ -f "$AGENT_CONFIG" ]; then
    echo -e "${GREEN}✅ Agent config: Found${NC}"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    grep -E "^Server=|^ServerActive=|^Hostname=" "$AGENT_CONFIG" | sed 's/^/  /'
else
    echo -e "${RED}❌ Agent config: Not found${NC}"
fi

echo ""
echo -e "${BLUE}📋 Recent Agent Activity:${NC}"
echo ""

# Show last 5 lines of agent log
if [ -f "/var/log/zabbix/zabbix_agentd.log" ]; then
    sudo tail -5 /var/log/zabbix/zabbix_agentd.log | sed 's/^/  /'
else
    echo "  (Log file not found)"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${BLUE}💡 Next Steps:${NC}"
echo "1. Go to Zabbix Web UI: http://localhost"
echo "2. Monitoring → Latest data"
echo "3. Search for: $HOSTNAME"
echo "4. You should see CPU, Memory, Disk data"
echo ""
echo -e "${YELLOW}⏱️  Note: Data may take 1-2 minutes to appear${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
