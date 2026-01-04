#!/bin/bash

# Setup Auto Triggers and Alert Actions

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

clear

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚨 Setup Auto Triggers & Alert Actions                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

HOSTNAME=$(hostname)
ZABBIX_URL="http://localhost"
ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"

echo -e "${YELLOW}Setting up for host: $HOSTNAME${NC}"
echo ""

# Authenticate
echo -e "${BLUE}🔐 Authenticating...${NC}"
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

echo -e "${GREEN}✅ Authenticated${NC}"

# Get host ID
echo -e "${BLUE}🔍 Finding host...${NC}"
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

# Create Triggers
echo -e "${BLUE}📊 Creating Triggers...${NC}"
echo ""

# Trigger 1: High CPU
echo -e "${YELLOW}1. Creating High CPU Trigger (>80%)...${NC}"
TRIGGER1=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": {
      \"description\": \"High CPU Usage\",
      \"expression\": \"last(/$HOSTNAME/system.cpu.util)>80\",
      \"priority\": 3,
      \"status\": 0,
      \"comments\": \"Alert when CPU usage exceeds 80%\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

if echo "$TRIGGER1" | grep -q '"triggerids"'; then
    echo -e "${GREEN}✅ High CPU Trigger created${NC}"
else
    echo -e "${YELLOW}⚠️  High CPU Trigger may already exist${NC}"
fi

# Trigger 2: High Memory
echo -e "${YELLOW}2. Creating High Memory Trigger (>85%)...${NC}"
TRIGGER2=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": {
      \"description\": \"High Memory Usage\",
      \"expression\": \"last(/$HOSTNAME/proc.mem[,,,rss])>85\",
      \"priority\": 3,
      \"status\": 0,
      \"comments\": \"Alert when memory usage exceeds 85%\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

if echo "$TRIGGER2" | grep -q '"triggerids"'; then
    echo -e "${GREEN}✅ High Memory Trigger created${NC}"
else
    echo -e "${YELLOW}⚠️  High Memory Trigger may already exist${NC}"
fi

# Trigger 3: High Disk
echo -e "${YELLOW}3. Creating High Disk Usage Trigger (>90%)...${NC}"
TRIGGER3=$(curl -s -X POST "$ZABBIX_URL/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": {
      \"description\": \"High Disk Usage\",
      \"expression\": \"last(/$HOSTNAME/vfs.fs.size[/,pused])>90\",
      \"priority\": 4,
      \"status\": 0,
      \"comments\": \"Alert when disk usage exceeds 90%\"
    },
    \"auth\": \"$AUTH_TOKEN\",
    \"id\": 1
  }")

if echo "$TRIGGER3" | grep -q '"triggerids"'; then
    echo -e "${GREEN}✅ High Disk Trigger created${NC}"
else
    echo -e "${YELLOW}⚠️  High Disk Trigger may already exist${NC}"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${BLUE}✅ Triggers Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📋 Triggers Created:${NC}"
echo "  1. High CPU Usage (>80%)"
echo "  2. High Memory Usage (>85%)"
echo "  3. High Disk Usage (>90%)"
echo ""

echo -e "${BLUE}📧 Next Steps:${NC}"
echo ""
echo "1. Configure Media Type in Zabbix Web UI:"
echo "   Administration → Media types → Email"
echo "   • SMTP: smtp.gmail.com:587"
echo "   • Email: thinhtdh.23it@vku.udn.vn"
echo "   • Password: pygzpmzvppvnhelt"
echo ""
echo "2. Configure User Media:"
echo "   Administration → Users → Admin → Media"
echo "   • Type: Email"
echo "   • Send to: tranhungthinh30702@gmail.com"
echo ""
echo "3. Create Alert Action:"
echo "   Configuration → Actions → Create action"
echo "   • Name: Email Alert Action"
echo "   • Operations: Send message to Admin via Email"
echo ""
echo "4. Test:"
echo "   ./scripts/spike-cpu.sh 30"
echo "   (Check email for alert)"
echo ""

echo -e "${GREEN}════════════════════════════════════════${NC}"
