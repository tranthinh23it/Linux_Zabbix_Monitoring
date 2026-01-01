#!/bin/bash

# Quick Test Email Alert Script

set -e

echo "📧 Testing Zabbix Email Alert System..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if email is configured
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found. Run 'make setup-email' first.${NC}"
    exit 1
fi

# Load environment variables
source .env

if [ -z "$SMTP_USER" ] || [ "$SMTP_USER" = "your_email@gmail.com" ]; then
    echo -e "${RED}❌ Email not configured. Run 'make setup-email' first.${NC}"
    exit 1
fi

# Get recipient email
if [ -z "$1" ]; then
    read -p "Enter recipient email: " RECIPIENT_EMAIL
else
    RECIPIENT_EMAIL="$1"
fi

echo -e "${YELLOW}📧 Sending test alert to: $RECIPIENT_EMAIL${NC}"

# Export environment variables for the script
export SMTP_SERVER="smtp.gmail.com"
export SMTP_PORT="587"
export SMTP_USER="$SMTP_USER"
export SMTP_PASS="$SMTP_PASS"
export FROM_EMAIL="$SMTP_USER"

# Create test alert message
TEST_SUBJECT="🚨 Zabbix Test Alert - $(date '+%Y-%m-%d %H:%M:%S')"
TEST_MESSAGE="This is a test alert from your Zabbix Monitoring System.

Alert Details:
- Host: $(hostname)
- Time: $(date '+%Y-%m-%d %H:%M:%S')
- Severity: WARNING
- Problem: Test Alert Triggered
- Current CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')
- Current Memory: $(free -h | awk 'NR==2{printf \"%.1f%%\", $3*100/$2}')
- Current Disk: $(df -h / | awk 'NR==2{print $5}')

This is a test message to verify that email alerts are working correctly.
If you receive this email, your Zabbix email alert system is configured properly.

System Information:
- Zabbix Server: Running
- Database: MySQL
- Web Interface: http://localhost
- Monitoring Status: Active

Next Steps:
1. Login to Zabbix Web UI
2. Configure real alert triggers
3. Set up monitoring for your servers
4. Customize alert templates

Happy Monitoring! 🚀"

# Send test email
./configs/zabbix/alertscripts/email_alert.sh "$RECIPIENT_EMAIL" "$TEST_SUBJECT" "$TEST_MESSAGE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test email sent successfully!${NC}"
    echo ""
    echo -e "${GREEN}📧 Email Details:${NC}"
    echo "   To: $RECIPIENT_EMAIL"
    echo "   From: $SMTP_USER"
    echo "   Subject: $TEST_SUBJECT"
    echo ""
    echo -e "${YELLOW}💡 Check your inbox and spam folder${NC}"
    echo ""
    echo -e "${GREEN}🎯 Next Steps:${NC}"
    echo "1. Verify email received"
    echo "2. Setup Zabbix Web UI media type"
    echo "3. Configure alert actions"
    echo "4. Create monitoring triggers"
    echo ""
    echo "Run 'make setup-email' for full configuration guide"
else
    echo -e "${RED}❌ Failed to send test email${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
    echo "1. Check Gmail App Password"
    echo "2. Verify SMTP settings"
    echo "3. Check internet connection"
    echo "4. Review Gmail security settings"
    exit 1
fi