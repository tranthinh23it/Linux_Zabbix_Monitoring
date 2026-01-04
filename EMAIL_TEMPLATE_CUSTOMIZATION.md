# 📧 Email Template Customization Guide

## Overview

Zabbix có 2 email scripts:

1. **email_alert.sh** - Simple email (basic)
2. **email_alert_detailed.sh** - Detailed email (recommended)

## Email Content Included

### Detailed Email Includes:

✅ **Alert Information**
- Subject
- Message
- Severity level with color coding
- Alert time

✅ **System Metrics**
- CPU Usage (%)
- Memory Usage (%)
- Disk Usage (%)
- Load Average

✅ **System Information**
- Hostname
- Alert Host
- Metric Name
- Uptime
- Alert Time
- Severity Badge

✅ **Recommended Actions**
- Check Zabbix Web UI
- Review system logs
- Monitor situation
- Take corrective action
- Update alert status

✅ **Visual Design**
- Color-coded by severity
- Professional HTML layout
- Responsive design
- Easy to read

## Severity Levels & Colors

| Severity | Color | Icon | Use Case |
|----------|-------|------|----------|
| Critical/Disaster | Red (#d32f2f) | 🔴 | System down, critical failure |
| High | Orange (#f57c00) | 🟠 | High resource usage, errors |
| Average/Medium | Yellow (#fbc02d) | 🟡 | Warning, needs attention |
| Warning/Low | Blue (#1976d2) | 🔵 | Minor issues, informational |
| Info | Green (#388e3c) | 🟢 | Normal, informational |

## Customizing Email Template

### Option 1: Edit email_alert_detailed.sh

Location: `configs/zabbix/alertscripts/email_alert_detailed.sh`

**Customize:**
- Colors
- Layout
- Metrics displayed
- Recommended actions
- Footer text

### Option 2: Add Custom Metrics

Edit the script to include additional metrics:

```bash
# Add custom metric
CUSTOM_METRIC=$(your_command_here)

# Add to email template
<div class=\"metric-card\">
    <div class=\"metric-label\">Custom Metric</div>
    <div class=\"metric-value\">$CUSTOM_METRIC</div>
</div>
```

### Option 3: Change Email Layout

Modify CSS in the script:

```bash
# Change header color
.header {
    background: linear-gradient(135deg, #YOUR_COLOR 0%, #YOUR_COLOR99 100%);
}

# Change font
body { 
    font-family: 'Your Font', sans-serif;
}

# Change layout
.metrics-grid {
    grid-template-columns: repeat(3, 1fr); /* 3 columns instead of 2 */
}
```

## Using Detailed Email in Zabbix

### Step 1: Update Zabbix Alert Script

In Zabbix Web UI:
1. Administration → Media types → Email
2. Script name: `email_alert_detailed.sh`
3. Parameters:
   - {ALERT.SENDTO}
   - {ALERT.SUBJECT}
   - {ALERT.MESSAGE}
   - {EVENT.SEVERITY}
   - {HOST.NAME}
   - {TRIGGER.NAME}

### Step 2: Create Alert Action

1. Configuration → Actions
2. Create action with detailed email script
3. Set operations to use detailed email

### Step 3: Test

```bash
./scripts/test-detailed-email.sh
```

## Email Variables Available

In Zabbix, you can use these variables in email templates:

```
{ALERT.SENDTO}          - Recipient email
{ALERT.SUBJECT}         - Email subject
{ALERT.MESSAGE}         - Email message
{EVENT.SEVERITY}        - Alert severity
{EVENT.NAME}            - Event name
{EVENT.TIME}            - Event time
{EVENT.DATE}            - Event date
{HOST.NAME}             - Host name
{HOST.IP}               - Host IP
{TRIGGER.NAME}          - Trigger name
{TRIGGER.URL}           - Trigger URL
{ITEM.NAME}             - Item name
{ITEM.VALUE}            - Item value
```

## Example: Custom Email Template

```bash
#!/bin/bash

TO_EMAIL="$1"
SUBJECT="$2"
MESSAGE="$3"
SEVERITY="$4"
HOST="$5"
METRIC="$6"

# Custom variables
COMPANY_NAME="Your Company"
SUPPORT_EMAIL="support@company.com"
SUPPORT_PHONE="+1-800-123-4567"

# Create custom email
EMAIL_CONTENT="From: Zabbix <$FROM_EMAIL>
To: $TO_EMAIL
Subject: [$SEVERITY] $SUBJECT
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<body>
    <h1>$COMPANY_NAME - Alert Notification</h1>
    <p><strong>Severity:</strong> $SEVERITY</p>
    <p><strong>Host:</strong> $HOST</p>
    <p><strong>Metric:</strong> $METRIC</p>
    <p><strong>Message:</strong></p>
    <p>$MESSAGE</p>
    
    <hr>
    <p>Support: $SUPPORT_EMAIL | $SUPPORT_PHONE</p>
</body>
</html>"

# Send email...
```

## Testing Different Scenarios

### Test 1: CPU Alert
```bash
./configs/zabbix/alertscripts/email_alert_detailed.sh \
    "recipient@gmail.com" \
    "High CPU Usage" \
    "CPU exceeded 80%" \
    "High" \
    "server1" \
    "system.cpu.util"
```

### Test 2: Memory Alert
```bash
./configs/zabbix/alertscripts/email_alert_detailed.sh \
    "recipient@gmail.com" \
    "High Memory Usage" \
    "Memory exceeded 85%" \
    "Critical" \
    "server1" \
    "vm.memory.util"
```

### Test 3: Disk Alert
```bash
./configs/zabbix/alertscripts/email_alert_detailed.sh \
    "recipient@gmail.com" \
    "Low Disk Space" \
    "Disk usage at 90%" \
    "Average" \
    "server1" \
    "vfs.fs.size[/,pused]"
```

## Best Practices

1. **Keep emails concise** - Include only relevant information
2. **Use color coding** - Make severity obvious
3. **Include metrics** - Show current system state
4. **Provide actions** - Tell users what to do
5. **Add links** - Link to Zabbix Web UI
6. **Test thoroughly** - Test all severity levels
7. **Monitor delivery** - Ensure emails are received

## Troubleshooting

### Email not received
- Check recipient email
- Check spam folder
- Verify SMTP settings
- Check Zabbix logs

### Email formatting issues
- Check HTML syntax
- Verify CSS styles
- Test in different email clients
- Check character encoding

### Missing metrics
- Verify commands work
- Check permissions
- Test metrics manually
- Add error handling

## Next Steps

1. ✅ Test detailed email
2. Configure Zabbix to use detailed email script
3. Create alert actions with detailed email
4. Customize template as needed
5. Test with real alerts

## Support

- Zabbix Documentation: https://www.zabbix.com/documentation
- Email Customization: See email_alert_detailed.sh
- Test Script: ./scripts/test-detailed-email.sh
