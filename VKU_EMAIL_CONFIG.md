# 📧 VKU Email Configuration for Zabbix

## VKU Email Settings

### Email Account
- **Email**: thinhtdh.23it@vku.udn.vn
- **Password**: (Your VKU password)

### SMTP Server Information

VKU typically uses one of these SMTP servers:

**Option 1: Standard VKU Mail Server**
```
SMTP Server: mail.vku.udn.vn
SMTP Port: 587 (TLS) or 25 (Plain)
```

**Option 2: Alternative VKU Mail Server**
```
SMTP Server: smtp.vku.udn.vn
SMTP Port: 587 (TLS) or 25 (Plain)
```

**Option 3: Outlook/Office 365 (if VKU uses this)**
```
SMTP Server: smtp.office365.com
SMTP Port: 587 (TLS)
```

## How to Find Correct Settings

### Method 1: Check VKU Email Client Settings
1. Open your email client (Outlook, Thunderbird, etc.)
2. Go to Settings/Preferences
3. Look for SMTP Server settings
4. Note the server address and port

### Method 2: Contact VKU IT Department
- Email: it@vku.udn.vn (or similar)
- Ask for: SMTP server, port, and authentication method

### Method 3: Check VKU Website
- Go to: https://vku.udn.vn
- Look for: Email/IT Support section
- Find: Email configuration guide

## Configuration Steps

Once you have the SMTP settings:

```bash
# Run configuration script
./scripts/configure-email.sh

# Select option 2 (VKU Email)
# Enter SMTP Server: mail.vku.udn.vn (or your server)
# Enter SMTP Port: 587 (or your port)
# Enter Password: (Your VKU password)
# Enter Recipient: (Your email or recipient)
```

Or manually edit `.env`:

```properties
SMTP_SERVER=mail.vku.udn.vn
SMTP_PORT=587
SMTP_USER=thinhtdh.23it@vku.udn.vn
SMTP_PASS=your_vku_password
FROM_EMAIL=thinhtdh.23it@vku.udn.vn
ALERT_EMAIL=recipient@vku.udn.vn
```

## Test Configuration

```bash
# Test email
make test-email recipient@vku.udn.vn

# Or manually
./scripts/test-email-alert.sh recipient@vku.udn.vn
```

## Troubleshooting

### "Connection refused"
- Check SMTP server address
- Verify port number
- Check firewall settings

### "Authentication failed"
- Verify email address
- Verify password
- Check if account is active

### "Timeout"
- Check internet connection
- Try different port (25, 587, 465)
- Check firewall

## Next Steps

1. Find VKU SMTP settings
2. Configure email using script or .env
3. Test email sending
4. Configure Zabbix Web UI
5. Create alert actions

## Support

- VKU IT: it@vku.udn.vn
- VKU Portal: https://vku.udn.vn
- Email Support: (Check VKU website)
