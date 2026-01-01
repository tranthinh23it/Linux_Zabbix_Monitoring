#!/bin/bash

# Setup Email Alerts for Zabbix

set -e

echo "📧 Setting up Email Alerts for Zabbix..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get email configuration
get_email_config() {
    echo -e "${BLUE}📧 Email Configuration Setup${NC}"
    echo "=================================="
    
    read -p "Enter your Gmail address: " SMTP_USER
    echo -e "${YELLOW}⚠️  You need Gmail App Password (not regular password)${NC}"
    echo "   1. Go to Google Account settings"
    echo "   2. Security → 2-Step Verification → App passwords"
    echo "   3. Generate app password for 'Mail'"
    read -s -p "Enter Gmail App Password: " SMTP_PASS
    echo ""
    read -p "Enter recipient email for alerts: " ALERT_EMAIL
    
    echo ""
    echo -e "${GREEN}✅ Email configuration collected${NC}"
}

# Update .env file
update_env_file() {
    echo -e "${YELLOW}📝 Updating .env file...${NC}"
    
    # Backup current .env
    cp .env .env.backup
    
    # Update SMTP settings
    sed -i "s/SMTP_USER=.*/SMTP_USER=$SMTP_USER/" .env
    sed -i "s/SMTP_PASS=.*/SMTP_PASS=$SMTP_PASS/" .env
    sed -i "s/FROM_EMAIL=.*/FROM_EMAIL=$SMTP_USER/" .env
    
    # Add alert email if not exists
    if ! grep -q "ALERT_EMAIL" .env; then
        echo "ALERT_EMAIL=$ALERT_EMAIL" >> .env
    else
        sed -i "s/ALERT_EMAIL=.*/ALERT_EMAIL=$ALERT_EMAIL/" .env
    fi
    
    echo -e "${GREEN}✅ .env file updated${NC}"
}

# Test email sending
test_email() {
    echo -e "${YELLOW}📧 Testing email sending...${NC}"
    
    export SMTP_USER="$SMTP_USER"
    export SMTP_PASS="$SMTP_PASS"
    export FROM_EMAIL="$SMTP_USER"
    
    ./configs/zabbix/alertscripts/email_alert.sh \
        "$ALERT_EMAIL" \
        "Zabbix Test Alert" \
        "This is a test email from your Zabbix monitoring system. If you receive this, email alerts are working correctly!"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Test email sent successfully!${NC}"
        echo "   Check your inbox: $ALERT_EMAIL"
    else
        echo -e "${RED}❌ Failed to send test email${NC}"
        echo "   Please check your Gmail settings and app password"
        return 1
    fi
}

# Create Zabbix media type configuration
create_media_type_config() {
    echo -e "${YELLOW}📋 Creating Zabbix media type configuration...${NC}"
    
    cat > configs/zabbix/email-media-type.json << EOF
{
    "name": "Email Alert",
    "type": 0,
    "smtp_server": "smtp.gmail.com",
    "smtp_port": 587,
    "smtp_helo": "zabbix.local",
    "smtp_email": "$SMTP_USER",
    "smtp_security": 2,
    "smtp_verify_peer": 0,
    "smtp_verify_host": 0,
    "smtp_authentication": 1,
    "username": "$SMTP_USER",
    "passwd": "$SMTP_PASS",
    "content_type": 1,
    "script_name": "",
    "parameters": [],
    "process_tags": 0,
    "show_event_menu": 0,
    "event_menu_url": "",
    "event_menu_name": "",
    "description": "Email notifications via Gmail SMTP",
    "status": 0
}
EOF
    
    echo -e "${GREEN}✅ Media type configuration created${NC}"
}

# Create action configuration
create_action_config() {
    echo -e "${YELLOW}⚡ Creating alert action configuration...${NC}"
    
    cat > configs/zabbix/alert-action.json << EOF
{
    "name": "Email Alert Action",
    "eventsource": 0,
    "status": 0,
    "esc_period": "1h",
    "def_shortdata": "Problem: {EVENT.NAME}",
    "def_longdata": "Problem started at {EVENT.TIME} on {EVENT.DATE}\\nProblem name: {EVENT.NAME}\\nHost: {HOST.NAME}\\nSeverity: {EVENT.SEVERITY}\\nOriginal problem ID: {EVENT.ID}\\n{TRIGGER.URL}",
    "r_shortdata": "Resolved: {EVENT.NAME}",
    "r_longdata": "Problem has been resolved at {EVENT.RECOVERY.TIME} on {EVENT.RECOVERY.DATE}\\nProblem name: {EVENT.NAME}\\nHost: {HOST.NAME}\\nSeverity: {EVENT.SEVERITY}\\nOriginal problem ID: {EVENT.ID}\\n{TRIGGER.URL}",
    "formula": "",
    "conditions": [
        {
            "conditiontype": 5,
            "operator": 0,
            "value": "0"
        }
    ],
    "operations": [
        {
            "operationtype": 0,
            "esc_period": "0s",
            "esc_step_from": 1,
            "esc_step_to": 1,
            "evaltype": 0,
            "opmessage_grp": [],
            "opmessage_usr": [
                {
                    "userid": "1"
                }
            ],
            "opmessage": {
                "default_msg": 1,
                "mediatypeid": "1"
            }
        }
    ],
    "recovery_operations": [
        {
            "operationtype": 0,
            "opmessage_grp": [],
            "opmessage_usr": [
                {
                    "userid": "1"
                }
            ],
            "opmessage": {
                "default_msg": 1,
                "mediatypeid": "1"
            }
        }
    ]
}
EOF
    
    echo -e "${GREEN}✅ Alert action configuration created${NC}"
}

# Create manual setup instructions
create_manual_instructions() {
    echo -e "${YELLOW}📋 Creating manual setup instructions...${NC}"
    
    cat > EMAIL_ALERT_SETUP.md << EOF
# 📧 Manual Email Alert Setup in Zabbix Web UI

## Step 1: Create Media Type
1. Login to Zabbix Web UI: http://localhost
2. Go to **Administration** → **Media types**
3. Click **Create media type**
4. Configure:
   - **Name**: Email Alert
   - **Type**: Email
   - **SMTP server**: smtp.gmail.com
   - **SMTP server port**: 587
   - **SMTP helo**: zabbix.local
   - **SMTP email**: $SMTP_USER
   - **Connection security**: STARTTLS
   - **Authentication**: Username and password
   - **Username**: $SMTP_USER
   - **Password**: $SMTP_PASS
5. Click **Add**

## Step 2: Configure User Media
1. Go to **Administration** → **Users**
2. Click on **Admin** user
3. Go to **Media** tab
4. Click **Add**
5. Configure:
   - **Type**: Email Alert
   - **Send to**: $ALERT_EMAIL
   - **When active**: 1-7,00:00-24:00
   - **Use if severity**: Check all severity levels
6. Click **Add** then **Update**

## Step 3: Create Action
1. Go to **Configuration** → **Actions**
2. Click **Create action**
3. **Action** tab:
   - **Name**: Email Alert Action
   - **Conditions**: Trigger severity >= Not classified
4. **Operations** tab:
   - Click **Add** in Operations
   - **Send to users**: Admin
   - **Send only to**: Email Alert
5. **Recovery operations** tab:
   - Click **Add**
   - **Send to users**: Admin
   - **Send only to**: Email Alert
6. Click **Add**

## Step 4: Test Alert
1. Go to **Configuration** → **Hosts**
2. Find "Zabbix server" host
3. Go to **Triggers**
4. Create a test trigger or wait for real alert

## Email Configuration Used:
- **SMTP Server**: smtp.gmail.com:587
- **From Email**: $SMTP_USER
- **To Email**: $ALERT_EMAIL
- **Authentication**: App Password

## Troubleshooting:
- Make sure Gmail 2FA is enabled
- Use App Password, not regular password
- Check Gmail "Less secure app access" if needed
- Verify SMTP settings in Zabbix logs
EOF
    
    echo -e "${GREEN}✅ Manual setup instructions created: EMAIL_ALERT_SETUP.md${NC}"
}

# Create test trigger for demonstration
create_test_trigger() {
    echo -e "${YELLOW}🧪 Creating test trigger for demonstration...${NC}"
    
    cat > configs/zabbix/test-trigger.md << EOF
# 🧪 Test Trigger Creation

To test email alerts, create a test trigger:

## Method 1: High CPU Usage Trigger
1. Go to **Configuration** → **Hosts**
2. Click on "Zabbix server"
3. Go to **Triggers**
4. Click **Create trigger**
5. Configure:
   - **Name**: High CPU Usage Test
   - **Expression**: last(/Zabbix server/system.cpu.util)>1
   - **Severity**: High
6. Click **Add**

This will trigger when CPU usage > 1% (will trigger immediately)

## Method 2: Manual Test
1. SSH to a monitored server
2. Run: \`stress --cpu 4 --timeout 60s\` (install stress if needed)
3. This will spike CPU and trigger alert

## Method 3: Disk Space Test
1. Create trigger: last(/Zabbix server/vfs.fs.size[/,pused])>50
2. This triggers when disk usage > 50%

## Check Alert Status:
1. **Monitoring** → **Problems** (see active problems)
2. **Reports** → **Action log** (see sent notifications)
3. Check your email inbox
EOF
    
    echo -e "${GREEN}✅ Test trigger instructions created${NC}"
}

# Main setup function
main() {
    clear
    echo -e "${BLUE}"
    echo "=============================================="
    echo "    📧 Zabbix Email Alert Setup"
    echo "=============================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}This script will help you setup email alerts for Zabbix.${NC}"
    echo -e "${YELLOW}You'll need a Gmail account with App Password enabled.${NC}"
    echo ""
    
    read -p "Continue with email setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    get_email_config
    update_env_file
    
    echo -e "${YELLOW}Testing email configuration...${NC}"
    if test_email; then
        create_media_type_config
        create_action_config
        create_manual_instructions
        create_test_trigger
        
        echo -e "${GREEN}"
        echo "=============================================="
        echo "    ✅ Email Alert Setup Completed!"
        echo "=============================================="
        echo -e "${NC}"
        echo "📧 Test email sent to: $ALERT_EMAIL"
        echo "📋 Manual setup guide: EMAIL_ALERT_SETUP.md"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo "1. Check your email inbox for test message"
        echo "2. Follow EMAIL_ALERT_SETUP.md to complete Zabbix configuration"
        echo "3. Create test triggers to verify alerts"
        echo ""
        echo -e "${GREEN}🎉 Your Zabbix system can now send email alerts!${NC}"
    else
        echo -e "${RED}❌ Email setup failed. Please check your Gmail configuration.${NC}"
        exit 1
    fi
}

# Run main function
main