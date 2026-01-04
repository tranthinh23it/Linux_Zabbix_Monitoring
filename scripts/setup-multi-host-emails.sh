#!/bin/bash

# Setup Multiple Host Emails via Zabbix API

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔧 Setup Multiple Host Emails${NC}"
echo ""

ZABBIX_URL="http://localhost/api_jsonrpc.php"
ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"

# Authenticate
echo -e "${YELLOW}Authenticating with Zabbix API...${NC}"
AUTH_TOKEN=$(curl -s -X POST "$ZABBIX_URL" \
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
    echo -e "${RED}❌ Failed to authenticate${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Authenticated${NC}"
echo ""

# Function to add custom field to host
add_custom_field() {
    local HOST_NAME=$1
    local EMAIL=$2
    
    echo -n "Adding email for host '$HOST_NAME'... "
    
    # Get host ID
    HOST_ID=$(curl -s -X POST "$ZABBIX_URL" \
      -H "Content-Type: application/json" \
      -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"host.get\",
        \"params\": {
          \"filter\": {
            \"host\": \"$HOST_NAME\"
          }
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1
      }" | grep -o '"hostid":"[^"]*' | head -1 | cut -d'"' -f4)
    
    if [ -z "$HOST_ID" ]; then
        echo -e "${RED}❌ Host not found${NC}"
        return 1
    fi
    
    # Update host with custom field
    RESULT=$(curl -s -X POST "$ZABBIX_URL" \
      -H "Content-Type: application/json" \
      -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"host.update\",
        \"params\": {
          \"hostid\": \"$HOST_ID\",
          \"custom_fields\": {
            \"Owner Email\": \"$EMAIL\"
          }
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 1
      }")
    
    if echo "$RESULT" | grep -q '"hostids"'; then
        echo -e "${GREEN}✅${NC}"
        return 0
    else
        echo -e "${RED}❌${NC}"
        return 1
    fi
}

# Check if config file exists
if [ ! -f "host-emails.conf" ]; then
    echo -e "${YELLOW}Creating host-emails.conf template...${NC}"
    cat > host-emails.conf << 'EOF'
# Format: hostname=email
# Example:
# tranthinh=tranhungthinh30702@gmail.com
# server-2=admin@server2.com
# server-3=ops@server3.com

tranthinh=tranhungthinh30702@gmail.com
EOF
    echo -e "${GREEN}✅ Created host-emails.conf${NC}"
    echo -e "${YELLOW}Edit host-emails.conf and add your hosts/emails${NC}"
    echo ""
    exit 0
fi

# Read config and add custom fields
echo -e "${YELLOW}Adding custom fields from host-emails.conf...${NC}"
echo ""

COUNT=0
while IFS='=' read -r HOST_NAME EMAIL; do
    # Skip comments and empty lines
    [[ "$HOST_NAME" =~ ^#.*$ ]] && continue
    [[ -z "$HOST_NAME" ]] && continue
    
    # Trim whitespace
    HOST_NAME=$(echo "$HOST_NAME" | xargs)
    EMAIL=$(echo "$EMAIL" | xargs)
    
    if add_custom_field "$HOST_NAME" "$EMAIL"; then
        ((COUNT++))
    fi
done < host-emails.conf

echo ""
echo -e "${GREEN}✅ Setup completed!${NC}"
echo -e "${YELLOW}Added custom fields for $COUNT hosts${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Go to Zabbix Web UI → Administration → Media types → Email"
echo "2. Add macro: {HOST.CUSTOM_FIELD.Owner Email}"
echo "3. Create Alert Action using this macro"
echo "4. Configure User Media with the macro"
echo ""
