# 🔧 VKU Email Configuration - Troubleshooting

## Problem: Connection Timeout to mail.vku.udn.vn

### Symptoms
- Error: "Connection timed out"
- Cannot connect to mail.vku.udn.vn:587 or :465
- Email not sending

### Root Cause
VKU SMTP server (mail.vku.udn.vn) may only accept connections from within VKU network (VPN or on-campus).

## Solutions

### Solution 1: Use VPN to Connect to VKU Network
1. Connect to VKU VPN
2. Then test email sending
3. Configure Zabbix to use VKU email

**Steps:**
```bash
# Connect to VKU VPN first
# Then run:
source .env
./configs/zabbix/alertscripts/email_alert.sh "recipient@gmail.com" "Test" "Test message"
```

### Solution 2: Use Gmail Instead
Gmail SMTP works from anywhere:

```bash
# Edit .env
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_gmail@gmail.com
SMTP_PASS=your_app_password
FROM_EMAIL=your_gmail@gmail.com
```

Then test:
```bash
make test-email recipient@gmail.com
```

### Solution 3: Contact VKU IT for External SMTP Access
1. Email: it@vku.udn.vn
2. Ask for: External SMTP server access
3. Request: SMTP server, port, and credentials for external use

### Solution 4: Use Alternative Email Provider
- Outlook/Office 365
- Yahoo Mail
- ProtonMail
- Other corporate email

## Current Configuration

```
SMTP Server: mail.vku.udn.vn
SMTP Port: 587
Email: thinhtdh.23it@vku.udn.vn
App Password: pygzpmzvppvnhelt
```

## Testing

### Test 1: Check Network Connectivity
```bash
# Can you reach VKU SMTP server?
ping mail.vku.udn.vn

# Can you connect to port 587?
telnet mail.vku.udn.vn 587
```

### Test 2: Check if VPN is Needed
```bash
# Without VPN - likely fails
curl -v --url "smtp://mail.vku.udn.vn:587"

# With VPN - should work
# (Connect to VPN first, then run above)
```

### Test 3: Try Gmail Instead
```bash
# Update .env with Gmail
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_gmail@gmail.com
SMTP_PASS=your_app_password

# Test
make test-email recipient@gmail.com
```

## Recommended Solution

**Use Gmail for Zabbix Email Alerts:**

1. Create Gmail account (if needed)
2. Enable 2-Step Verification
3. Generate App Password
4. Update .env with Gmail settings
5. Test email sending

**Why Gmail?**
- Works from anywhere
- No VPN needed
- Reliable and free
- Easy to setup

## Configuration for Gmail

```bash
# Edit .env
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_gmail@gmail.com
SMTP_PASS=your_16_char_app_password
FROM_EMAIL=your_gmail@gmail.com
ALERT_EMAIL=recipient@gmail.com
```

Then test:
```bash
./scripts/test-email-alert.sh recipient@gmail.com
```

## Next Steps

1. **Option A**: Connect to VKU VPN and test VKU email
2. **Option B**: Setup Gmail for email alerts
3. **Option C**: Contact VKU IT for external SMTP access

## Support

- VKU IT: it@vku.udn.vn
- Gmail Help: https://support.google.com/accounts
- Zabbix Email: See EMAIL_ALERT_SETUP.md
