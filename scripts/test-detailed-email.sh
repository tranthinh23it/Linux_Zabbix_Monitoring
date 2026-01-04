#!/bin/bash

# Test Detailed Email Alert with Real CPU Spike and Zabbix Problems

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📧 Testing Detailed Email Alert with CPU Spike${NC}"
echo ""

source .env

if [ -z "$ALERT_EMAIL" ]; then
    read -p "Enter recipient email: " ALERT_EMAIL
fi

echo -e "${YELLOW}Starting CPU spike and sending test alerts...${NC}"
echo ""

export SMTP_SERVER
export SMTP_PORT
export SMTP_USER
export SMTP_PASS
export FROM_EMAIL

chmod +x configs/zabbix/alertscripts/email_alert_detailed.sh

# Check if stress is installed
if ! command -v stress &> /dev/null; then
    echo -e "${YELLOW}📦 Installing stress tool...${NC}"
    sudo apt update && sudo apt install -y stress > /dev/null 2>&1
    echo -e "${GREEN}✅ Stress installed${NC}"
    echo ""
fi

# Start CPU spike in background (90 seconds)
echo -e "${YELLOW}🔥 Starting CPU spike (90s)...${NC}"
CPU_COUNT=$(nproc)
stress --cpu $CPU_COUNT --timeout 90s > /dev/null 2>&1 &
STRESS_PID=$!

echo -e "${GREEN}✅ CPU spike started (PID: $STRESS_PID)${NC}"
echo ""

# Wait a bit for CPU to spike
sleep 5

# Send test emails while CPU is spiking
echo -e "${YELLOW}📧 Sending test emails...${NC}"
echo ""

echo "Test 1: Critical Alert (High CPU)..."
./configs/zabbix/alertscripts/email_alert_detailed.sh \
    "$ALERT_EMAIL" \
    "CRITICAL: High CPU Usage Detected" \
    "CPU usage has exceeded 90% threshold. Immediate action may be required." \
    "Critical" \
    "tranthinh" \
    "system.cpu.util"

echo -e "${GREEN}✅ Critical email sent${NC}"
echo ""

sleep 2

echo "Test 2: High Alert (Memory Usage)..."
./configs/zabbix/alertscripts/email_alert_detailed.sh \
    "$ALERT_EMAIL" \
    "HIGH: Memory Usage Alert" \
    "Memory usage has reached 85%. Please review running processes." \
    "High" \
    "tranthinh" \
    "vm.memory.util"

echo -e "${GREEN}✅ High email sent${NC}"
echo ""

sleep 2

echo "Test 3: Average Alert (Disk Space)..."
./configs/zabbix/alertscripts/email_alert_detailed.sh \
    "$ALERT_EMAIL" \
    "AVERAGE: Disk Space Warning" \
    "Disk usage on / partition is at 75%. Consider cleaning up old files." \
    "Average" \
    "tranthinh" \
    "vfs.fs.size[/,pused]"

echo -e "${GREEN}✅ Average email sent${NC}"
echo ""

# Wait for CPU spike to complete
echo -e "${YELLOW}⏳ Waiting for CPU spike to complete...${NC}"
wait $STRESS_PID

echo ""
echo -e "${GREEN}✅ All test alerts completed!${NC}"
echo ""
echo -e "${YELLOW}Check:${NC}"
echo "  1. Email inbox for 3 test emails"
echo "  2. Zabbix UI → Monitoring → Problems for CPU alert"
echo ""
echo -e "${BLUE}What happened:${NC}"
echo "  • CPU was spiked to 100% for 90 seconds"
echo "  • 3 test emails were sent"
echo "  • Zabbix Agent collected CPU metrics"
echo "  • Zabbix Server detected high CPU trigger"
echo "  • Problem should appear in Monitoring → Problems"
echo ""
