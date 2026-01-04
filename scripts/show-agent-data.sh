#!/bin/bash

# Show Zabbix Agent Data

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

HOSTNAME=$(hostname)
HOST_IP=$(hostname -I | awk '{print $1}')

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📊 Zabbix Agent Data - $HOSTNAME${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Host Information:${NC}"
echo "  Hostname: $HOSTNAME"
echo "  IP: $HOST_IP"
echo "  Port: 10050"
echo ""

echo -e "${YELLOW}System Metrics:${NC}"
echo ""

# CPU Usage
CPU=$(docker exec zabbix-server zabbix_get -s $HOST_IP -p 10050 -k "system.cpu.util" 2>/dev/null)
if [ ! -z "$CPU" ] && [ "$CPU" != "ZBX_NOTSUPPORTED" ]; then
    CPU_INT=${CPU%.*}
    if [ "$CPU_INT" -gt 80 ]; then
        echo -e "  ${RED}🔴 CPU Usage: ${CPU}%${NC}"
    elif [ "$CPU_INT" -gt 50 ]; then
        echo -e "  ${YELLOW}🟡 CPU Usage: ${CPU}%${NC}"
    else
        echo -e "  ${GREEN}🟢 CPU Usage: ${CPU}%${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  CPU Usage: (no data)${NC}"
fi

# Memory Usage
MEM=$(docker exec zabbix-server zabbix_get -s $HOST_IP -p 10050 -k "vm.memory.pused" 2>/dev/null)
if [ -z "$MEM" ] || [ "$MEM" = "ZBX_NOTSUPPORTED" ]; then
    MEM=$(docker exec zabbix-server zabbix_get -s $HOST_IP -p 10050 -k "proc.mem[,,,rss]" 2>/dev/null)
fi
if [ ! -z "$MEM" ] && [ "$MEM" != "ZBX_NOTSUPPORTED" ]; then
    MEM_INT=${MEM%.*}
    if [ "$MEM_INT" -gt 85 ]; then
        echo -e "  ${RED}🔴 Memory Usage: ${MEM}%${NC}"
    elif [ "$MEM_INT" -gt 50 ]; then
        echo -e "  ${YELLOW}🟡 Memory Usage: ${MEM}%${NC}"
    else
        echo -e "  ${GREEN}🟢 Memory Usage: ${MEM}%${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  Memory Usage: (no data)${NC}"
fi

# Disk Usage
DISK=$(docker exec zabbix-server zabbix_get -s $HOST_IP -p 10050 -k "vfs.fs.size[/,pused]" 2>/dev/null)
if [ ! -z "$DISK" ] && [ "$DISK" != "ZBX_NOTSUPPORTED" ]; then
    DISK_INT=${DISK%.*}
    if [ "$DISK_INT" -gt 90 ]; then
        echo -e "  ${RED}🔴 Disk Usage: ${DISK}%${NC}"
    elif [ "$DISK_INT" -gt 70 ]; then
        echo -e "  ${YELLOW}🟡 Disk Usage: ${DISK}%${NC}"
    else
        echo -e "  ${GREEN}🟢 Disk Usage: ${DISK}%${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  Disk Usage: (no data)${NC}"
fi

# Uptime
UPTIME=$(docker exec zabbix-server zabbix_get -s $HOST_IP -p 10050 -k "system.uptime" 2>/dev/null)
if [ ! -z "$UPTIME" ] && [ "$UPTIME" != "ZBX_NOTSUPPORTED" ]; then
    UPTIME_DAYS=$((UPTIME / 86400))
    UPTIME_HOURS=$(((UPTIME % 86400) / 3600))
    echo -e "  ${GREEN}⏱️  Uptime: ${UPTIME_DAYS}d ${UPTIME_HOURS}h${NC}"
else
    echo -e "  ${YELLOW}⚠️  Uptime: (no data)${NC}"
fi

echo ""
echo -e "${YELLOW}Network Interfaces:${NC}"
echo ""

# Get network interfaces
INTERFACES=$(docker exec zabbix-server zabbix_get -s $HOST_IP -p 10050 -k "net.if.list" 2>/dev/null)
if [ ! -z "$INTERFACES" ] && [ "$INTERFACES" != "ZBX_NOTSUPPORTED" ]; then
    echo "$INTERFACES" | tr ',' '\n' | while read iface; do
        if [ ! -z "$iface" ]; then
            echo "  • $iface"
        fi
    done
else
    echo "  (no data)"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Agent is sending data to Zabbix!${NC}"
echo ""
echo -e "${YELLOW}💡 View in Zabbix Web UI:${NC}"
echo "  1. Go to http://localhost"
echo "  2. Monitoring → Latest data"
echo "  3. Search for: $HOSTNAME"
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
