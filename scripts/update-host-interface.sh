#!/bin/bash

# Update Host Interface IP in Zabbix

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

HOSTNAME=$(hostname)
HOST_IP=$(hostname -I | awk '{print $1}')
ZABBIX_URL="http://localhost"
ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"

echo -e "${BLUE}🔄 Updating Host Interface...${NC}"
echo ""
echo -e "${YELLOW}Host: $HOSTNAME${NC}"
echo -e "${YELLOW}IP: $HOST_IP${NC}"
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

echo -e "${GREEN}✅ Host found: $HOST_ID${NC}"
echo ""

# Get interface ID
INTERFACE_ID=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostinterface.get\",
    \"params\": {
      \"hostids\": \"$HOST_ID\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }" | grep -o '"interfaceid":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$INTERFACE_ID" ]; then
    echo -e "${RED}❌ Interface not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Interface found: $INTERFACE_ID${NC}"
echo ""

# Update interface IP
echo -e "${BLUE}Updating interface IP to: $HOST_IP${NC}"

UPDATE_RESPONSE=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostinterface.update\",
    \"params\": {
      \"interfaceid\": \"$INTERFACE_ID\",
      \"ip\": \"$HOST_IP\",
      \"useip\": 1
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

if echo "$UPDATE_RESPONSE" | grep -q '"interfaceids"'; then
    echo -e "${GREEN}✅ Interface updated successfully${NC}"
else
    echo -e "${RED}❌ Failed to update interface${NC}"
    echo "Response: $UPDATE_RESPONSE"
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 Configuration Updated:${NC}"
echo "• Host: $HOSTNAME"
echo "• IP: $HOST_IP"
echo "• Port: 10050"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "1. Wait 1-2 minutes for Zabbix to collect data"
echo "2. Go to Zabbix Web UI: http://localhost"
echo "3. Monitoring → Latest data"
echo "4. Search for: $HOSTNAME"
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
