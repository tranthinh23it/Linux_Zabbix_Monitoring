# 📧 Zabbix Email Alerts - Complete Setup Guide

## Overview

This guide provides everything you need to setup email alerts in your Zabbix monitoring system. Email alerts will notify you when monitoring triggers are activated (CPU > 80%, Memory > 85%, Disk > 90%, etc.).

## Quick Start (3 Steps)

### Step 1: Run Quick Setup

```bash
make quick-email
```

This interactive script will:
- Ask for your Gmail address
- Ask for Gmail App Password
- Ask for recipient email
- Test email sending
- Update configuration

### Step 2: Verify Test Email

Check your email inbox for the test message. If received, proceed to Step 3.

### Step 3: Configure Zabbix Web UI

Follow the manual setup guide: [EMAIL_ALERT_SETUP.md](EMAIL_ALERT_SETUP.md)

---

## What You Need

### Gmail Account Requirements

1. **Gmail Account** - Any Gmail address
2. **2-Step Verification** - Must be enabled
3. **App Password** - 16-character password for Zabbix

### System Requirements

- Docker running
- Zabbix Server running
- Internet connection
- curl installed (usually pre-installed)

---

## Setup Methods

### Method 1: Quick Interactive Setup (Recommended)

```bash
make quick-email
```

**Best for:** First-time setup, quick configuration

**What it does:**
- Prompts for Gmail credentials
- Updates .env file
- Tests email sending
- Provides next steps

**Time:** ~2 minutes

---

### Method 2: Full Setup with Guide

```bash
make setup-email
```

**Best for:** Detailed configuration, troubleshooting

**What it does:**
- Interactive credential collection
- Email configuration testing
- Creates configuration files
- Generates manual setup instructions

**Time:** ~5 minutes

---

### Method 3: Manual Setup

1. Edit `.env` file:
   ```bash
   nano .env
   ```

2. Update these lines:
   ```
   SMTP_USER=your_email@gmail.com
   SMTP_PASS=your_app_password
   FROM_EMAIL=your_email@gmail.com
   ALERT_EMAIL=recipient@gmail.com
   ```

3. Test email:
   ```bash
   make test-email
   ```

4. Configure Zabbix Web UI manually (see EMAIL_ALERT_SETUP.md)

---

## Testing Email Alerts

### Test 1: Send Test Email

```bash
# Interactive
make test-email

# With specific recipient
make test-email recipient@gmail.com
```

### Test 2: Trigger CPU Alert

```bash
# Install stress tool
sudo apt install stress

# Spike CPU usage
stress --cpu 4 --timeout 60s

# Monitor in Zabbix
# Go to Monitoring → Problems
```

### Test 3: Check Zabbix Logs

```bash
# View server logs
docker logs zabbix-server

# Follow logs in real-time
docker logs -f zabbix-server
```

---

## Configuration Files

### .env File

Main configuration file with email settings:

```properties
# SMTP Configuration for Email Alerts
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
FROM_EMAIL=your_email@gmail.com
ALERT_EMAIL=recipient@gmail.com
```

### Email Alert Script

Location: `configs/zabbix/alertscripts/email_alert.sh`

- Sends HTML-formatted emails
- Validates email addresses
- Handles SMTP authentication
- Provides error reporting

### Zabbix Configuration

Files created during setup:
- `configs/zabbix/email-media-type.json` - Media type configuration
- `configs/zabbix/alert-action.json` - Alert action configuration

---

## Zabbix Web UI Configuration

### Create Media Type

1. Go to **Administration** → **Media types**
2. Click **Create media type**
3. Configure:
   - Name: `Email Alert`
   - Type: `Email`
   - SMTP server: `smtp.gmail.com`
   - SMTP port: `587`
   - SMTP email: `your_email@gmail.com`
   - Connection security: `STARTTLS`
   - Username: `your_email@gmail.com`
   - Password: `your_app_password`

### Configure User Media

1. Go to **Administration** → **Users**
2. Click **Admin** user
3. Go to **Media** tab
4. Click **Add**
5. Configure:
   - Type: `Email Alert`
   - Send to: `recipient@gmail.com`
   - When active: `1-7,00:00-24:00`
   - Use if severity: Check all

### Create Alert Action

1. Go to **Configuration** → **Actions**
2. Click **Create action**
3. Configure:
   - Name: `Email Alert Action`
   - Operations: Send message to Admin via Email Alert
   - Recovery operations: Send message to Admin via Email Alert

### Create Monitoring Triggers

1. Go to **Configuration** → **Hosts** → **Zabbix server** → **Triggers**
2. Create triggers:
   - **High CPU**: `last(/Zabbix server/system.cpu.util)>80`
   - **High Memory**: `last(/Zabbix server/vm.memory.util)>85`
   - **Low Disk**: `last(/Zabbix server/vfs.fs.size[/,pused])>90`

---

## Troubleshooting

### Email Not Sending

**Check:**
1. Gmail App Password is correct (16 characters)
2. 2-Step Verification is enabled
3. Internet connection is working
4. Zabbix server is running

**Test:**
```bash
make test-email your_email@gmail.com
```

**View logs:**
```bash
docker logs zabbix-server | grep -i email
```

### Trigger Not Firing

**Check:**
1. Zabbix agent is collecting data
2. Trigger expression is correct
3. Trigger is enabled
4. Current values exceed threshold

**View data:**
- Go to **Monitoring** → **Latest data**
- Search for item (e.g., "system.cpu.util")
- Check current values

### Authentication Failed

**Solutions:**
1. Regenerate Gmail App Password
2. Verify 2-Step Verification is enabled
3. Check .env file has correct credentials
4. Test with curl directly

---

## Email Alert Examples

### CPU Alert

```
Trigger: High CPU Usage
Expression: last(/Zabbix server/system.cpu.util)>80
Severity: High
Email: Sent when CPU > 80%
```

### Memory Alert

```
Trigger: High Memory Usage
Expression: last(/Zabbix server/vm.memory.util)>85
Severity: High
Email: Sent when Memory > 85%
```

### Disk Alert

```
Trigger: Low Disk Space
Expression: last(/Zabbix server/vfs.fs.size[/,pused])>90
Severity: Average
Email: Sent when Disk > 90%
```

---

## Advanced Configuration

### Multiple Recipients

1. Create multiple users with different emails
2. Add each user to the action
3. Or use Gmail distribution lists

### Custom Email Templates

1. Go to **Administration** → **Media types** → **Email**
2. Edit **Message templates**
3. Customize subject and message format

### Escalation Rules

1. Go to **Configuration** → **Actions**
2. Set **Escalation period** (e.g., 1h)
3. Add multiple operations with different escalation steps

### Conditional Alerts

1. Go to **Configuration** → **Actions**
2. Add **Conditions** to filter triggers
3. Only send alerts for specific hosts or severity levels

---

## Commands Reference

```bash
# Quick setup (recommended)
make quick-email

# Full setup with guide
make setup-email

# Test email sending
make test-email
make test-email recipient@gmail.com

# View Zabbix logs
make logs-server

# Check system status
make status

# Restart services
make restart
```

---

## Documentation Files

- **EMAIL_ALERT_SETUP.md** - Detailed Zabbix Web UI configuration
- **EMAIL_ALERT_TROUBLESHOOTING.md** - Common issues and solutions
- **EMAIL_ALERTS_README.md** - This file

---

## Support

### Common Issues

1. **Authentication failed** → Check App Password (16 chars)
2. **Connection timeout** → Check internet connection
3. **Email not received** → Check spam folder
4. **Trigger not firing** → Check trigger expression and data

### Resources

- Zabbix Documentation: https://www.zabbix.com/documentation
- Gmail App Passwords: https://support.google.com/accounts/answer/185833
- Zabbix Community: https://www.zabbix.com/forum

### Debug Commands

```bash
# Check configuration
cat .env | grep SMTP

# Test email script
source .env
./configs/zabbix/alertscripts/email_alert.sh \
  "test@gmail.com" "Test" "Test message"

# View Zabbix logs
docker logs zabbix-server

# Check Docker status
docker ps | grep zabbix
```

---

## Next Steps

1. ✅ Run `make quick-email`
2. ✅ Verify test email received
3. ✅ Follow EMAIL_ALERT_SETUP.md for Zabbix Web UI
4. ✅ Create monitoring triggers
5. ✅ Test alerts by triggering conditions
6. ✅ Monitor your system!

---

## FAQ

**Q: Do I need to use Gmail?**
A: No, you can use any SMTP server. Update SMTP_SERVER and SMTP_PORT in .env.

**Q: Can I send to multiple recipients?**
A: Yes, create multiple users in Zabbix with different email addresses.

**Q: How often are alerts sent?**
A: When trigger condition is met. Configure escalation for repeated alerts.

**Q: Can I customize email content?**
A: Yes, edit message templates in Zabbix Web UI.

**Q: What if I forget my App Password?**
A: Regenerate at https://myaccount.google.com → App passwords

---

## Version Info

- Zabbix: 6.4+
- Docker: 20.10+
- Docker Compose: 2.0+
- Gmail: Any account with 2FA enabled

---

**Happy Monitoring! 🚀**
