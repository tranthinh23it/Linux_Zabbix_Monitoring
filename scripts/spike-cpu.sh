#!/bin/bash

# Spike CPU Usage for Testing

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔥 CPU Spike Test - Alert Testing    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if stress is installed
if ! command -v stress &> /dev/null; then
    echo -e "${YELLOW}📦 Installing stress tool...${NC}"
    sudo apt update && sudo apt install -y stress
    echo -e "${GREEN}✅ Stress installed${NC}"
    echo ""
fi

# Get CPU count
CPU_COUNT=$(nproc)
DURATION=${1:-60}

echo -e "${YELLOW}System Information:${NC}"
echo "  CPU Cores: $CPU_COUNT"
echo "  Duration: ${DURATION}s"
echo ""

echo -e "${BLUE}📊 Current CPU Usage:${NC}"
top -bn1 | grep "Cpu(s)" | awk '{print "  " $0}'
echo ""

echo -e "${YELLOW}🔥 Starting CPU spike...${NC}"
echo ""

# Run stress
stress --cpu $CPU_COUNT --timeout ${DURATION}s &
STRESS_PID=$!

# Monitor CPU usage
echo -e "${BLUE}📈 Monitoring CPU Usage:${NC}"
echo ""

for i in $(seq 1 $((DURATION / 5))); do
    sleep 5
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "  [$i] CPU Usage: ${CPU}%"
done

wait $STRESS_PID

echo ""
echo -e "${GREEN}✅ CPU spike completed${NC}"
echo ""

echo -e "${BLUE}📊 Current CPU Usage:${NC}"
top -bn1 | grep "Cpu(s)" | awk '{print "  " $0}'
echo ""

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${YELLOW}💡 What Happened:${NC}"
echo ""
echo "1. CPU was spiked to 100% for ${DURATION}s"
echo "2. Zabbix Agent collected CPU metrics"
echo "3. Zabbix Server detected high CPU"
echo "4. Alert trigger should have fired"
echo "5. Email should have been sent"
echo ""
echo -e "${BLUE}📧 Check Your Email:${NC}"
echo "  Look for alert notification about high CPU"
echo ""
echo -e "${BLUE}📊 View in Zabbix Web UI:${NC}"
echo "  1. Go to http://localhost"
echo "  2. Monitoring → Problems"
echo "  3. You should see CPU alert"
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
