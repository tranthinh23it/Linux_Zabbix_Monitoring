# 📧 Email Alerts - Complete Documentation Index

## 🎯 Start Here

**New to email alerts?** Start with one of these:

1. **[QUICK_EMAIL_REFERENCE.md](QUICK_EMAIL_REFERENCE.md)** ⭐ (2 min read)
   - Quick reference card
   - Essential commands
   - Common issues

2. **[EMAIL_ALERTS_SUMMARY.md](EMAIL_ALERTS_SUMMARY.md)** (5 min read)
   - Overview of what's been setup
   - Quick start guide
   - Learning path

---

## 📚 Complete Documentation

### Setup Guides

| Document | Purpose | Time |
|----------|---------|------|
| [EMAIL_ALERTS_README.md](EMAIL_ALERTS_README.md) | Complete setup guide with all methods | 10 min |
| [EMAIL_ALERT_SETUP.md](EMAIL_ALERT_SETUP.md) | Step-by-step Zabbix Web UI configuration | 15 min |
| [EMAIL_ALERT_TROUBLESHOOTING.md](EMAIL_ALERT_TROUBLESHOOTING.md) | Common issues and solutions | 5 min |

### Quick References

| Document | Purpose |
|----------|---------|
| [QUICK_EMAIL_REFERENCE.md](QUICK_EMAIL_REFERENCE.md) | Quick lookup card |
| [EMAIL_ALERTS_SUMMARY.md](EMAIL_ALERTS_SUMMARY.md) | Setup overview |
| [EMAIL_ALERTS_INDEX.md](EMAIL_ALERTS_INDEX.md) | This file |

---

## 🚀 Quick Start

### Option 1: Interactive Setup (Recommended)

```bash
make quick-email
```

**What it does:**
- Asks for Gmail credentials
- Tests email sending
- Updates configuration
- Shows next steps

**Time:** ~2 minutes

### Option 2: Full Setup

```bash
make setup-email
```

**What it does:**
- Interactive credential collection
- Email testing
- Creates configuration files
- Generates setup instructions

**Time:** ~5 minutes

### Option 3: Manual Setup

1. Edit `.env` file with Gmail credentials
2. Run `make test-email` to verify
3. Follow [EMAIL_ALERT_SETUP.md](EMAIL_ALERT_SETUP.md)

---

## 📋 Scripts Available

### Quick Email Setup
```bash
./scripts/quick-email-setup.sh
# or
make quick-email
```
Interactive setup with Gmail credentials and testing.

### Full Email Setup
```bash
./scripts/setup-email-alerts.sh
# or
make setup-email
```
Complete setup with detailed guide generation.

### Test Email
```bash
./scripts/test-email-alert.sh
# or
make test-email your_email@gmail.com
```
Send test email to verify configuration.

### Email Alert Script
```bash
./configs/zabbix/alertscripts/email_alert.sh <to> <subject> <message>
```
Core script that sends emails (called by Zabbix).

---

## 🔧 Configuration

### Main Configuration File: `.env`

```properties
# SMTP Configuration
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
FROM_EMAIL=your_email@gmail.com
ALERT_EMAIL=recipient@gmail.com
```

### Email Script Location
```
configs/zabbix/alertscripts/email_alert.sh
```

---

## 📧 Gmail Setup

### Get App Password

1. Go to https://myaccount.google.com
2. Security → 2-Step Verification (enable if needed)
3. Security → App passwords
4. Select Mail + your device
5. Copy 16-character password

### Use in Setup

```bash
make quick-email
# Enter Gmail: your_email@gmail.com
# Enter App Password: xxxx xxxx xxxx xxxx
# Enter Recipient: recipient@gmail.com
```

---

## ✅ Zabbix Web UI Configuration

### 1. Create Media Type
- Administration → Media types → Create media type
- Name: `Email Alert`
- SMTP: `smtp.gmail.com:587`
- Email: `your_email@gmail.com`
- Password: `your_app_password`

### 2. Configure User
- Administration → Users → Admin → Media
- Type: `Email Alert`
- Send to: `recipient@gmail.com`

### 3. Create Action
- Configuration → Actions → Create action
- Operations: Send message to Admin via Email Alert

### 4. Create Triggers
- Configuration → Hosts → Zabbix server → Triggers
- High CPU: `last(/Zabbix server/system.cpu.util)>80`
- High Memory: `last(/Zabbix server/vm.memory.util)>85`
- Low Disk: `last(/Zabbix server/vfs.fs.size[/,pused])>90`

**Detailed steps:** See [EMAIL_ALERT_SETUP.md](EMAIL_ALERT_SETUP.md)

---

## 🧪 Testing

### Test Email Sending
```bash
make test-email your_email@gmail.com
```

### Trigger CPU Alert
```bash
sudo apt install stress
stress --cpu 4 --timeout 60s
```

### Check Logs
```bash
docker logs zabbix-server | grep -i email
```

---

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution | Details |
|-------|----------|---------|
| Auth failed | Check App Password (16 chars) | [See guide](EMAIL_ALERT_TROUBLESHOOTING.md#issue-1-authentication-failed-error) |
| Connection timeout | Check internet connection | [See guide](EMAIL_ALERT_TROUBLESHOOTING.md#issue-2-connection-timeout-error) |
| Email not received | Check spam folder | [See guide](EMAIL_ALERT_TROUBLESHOOTING.md#issue-3-email-not-received) |
| Trigger not firing | Check trigger expression | [See guide](EMAIL_ALERT_TROUBLESHOOTING.md#issue-4-trigger-not-firing) |

**Full troubleshooting guide:** [EMAIL_ALERT_TROUBLESHOOTING.md](EMAIL_ALERT_TROUBLESHOOTING.md)

---

## 💡 Makefile Commands

```bash
make quick-email              # Interactive setup
make setup-email              # Full setup with guide
make test-email               # Test email sending
make test-email user@gmail.com # Test to specific email
make logs-server              # View Zabbix logs
make status                   # Check service status
make restart                  # Restart services
make help                     # Show all commands
```

---

## 📊 Trigger Examples

### High CPU Usage
```
Expression: last(/Zabbix server/system.cpu.util)>80
Severity: High
```

### High Memory Usage
```
Expression: last(/Zabbix server/vm.memory.util)>85
Severity: High
```

### Low Disk Space
```
Expression: last(/Zabbix server/vfs.fs.size[/,pused])>90
Severity: Average
```

### High Network Traffic
```
Expression: last(/Zabbix server/net.if.in[eth0])>100
Severity: Warning
```

---

## 📚 Documentation Map

```
Email Alerts Setup
├── Quick Start
│   ├── QUICK_EMAIL_REFERENCE.md ⭐ (Start here)
│   └── EMAIL_ALERTS_SUMMARY.md
├── Setup Guides
│   ├── EMAIL_ALERTS_README.md (Complete guide)
│   ├── EMAIL_ALERT_SETUP.md (Zabbix Web UI)
│   └── EMAIL_ALERT_TROUBLESHOOTING.md (Issues)
└── Scripts
    ├── scripts/quick-email-setup.sh
    ├── scripts/setup-email-alerts.sh
    ├── scripts/test-email-alert.sh
    └── configs/zabbix/alertscripts/email_alert.sh
```

---

## 🎯 Learning Path

### Beginner (15 minutes)
1. Read [QUICK_EMAIL_REFERENCE.md](QUICK_EMAIL_REFERENCE.md)
2. Run `make quick-email`
3. Check email inbox

### Intermediate (30 minutes)
1. Read [EMAIL_ALERTS_README.md](EMAIL_ALERTS_README.md)
2. Run `make quick-email`
3. Follow [EMAIL_ALERT_SETUP.md](EMAIL_ALERT_SETUP.md)
4. Create test triggers

### Advanced (1 hour)
1. Read all documentation
2. Setup custom triggers
3. Configure escalation rules
4. Setup multiple recipients

---

## 🔐 Security Notes

- App Password stored in `.env` file
- Backup `.env` before changes
- Don't share `.env` with others
- Use strong Gmail password
- Enable 2-Step Verification
- Regenerate App Password if needed

---

## 📞 Support

### Resources
- [Zabbix Documentation](https://www.zabbix.com/documentation)
- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)
- [Gmail Security](https://support.google.com/accounts/answer/3466521)
- [Zabbix Community](https://www.zabbix.com/forum)

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

## ✅ Checklist

- [ ] Gmail account with 2FA enabled
- [ ] Gmail App Password generated
- [ ] Run `make quick-email`
- [ ] Test email received
- [ ] Zabbix Media Type created
- [ ] User media configured
- [ ] Alert action created
- [ ] Monitoring triggers created
- [ ] Alerts tested and working

---

## 🎉 Next Steps

1. **Start:** `make quick-email`
2. **Verify:** Check email inbox
3. **Configure:** Follow [EMAIL_ALERT_SETUP.md](EMAIL_ALERT_SETUP.md)
4. **Create:** Setup monitoring triggers
5. **Test:** Trigger alerts
6. **Monitor:** Watch your system!

---

## 📝 File Structure

```
.
├── EMAIL_ALERTS_INDEX.md (this file)
├── EMAIL_ALERTS_README.md
├── EMAIL_ALERTS_SUMMARY.md
├── EMAIL_ALERT_SETUP.md
├── EMAIL_ALERT_TROUBLESHOOTING.md
├── QUICK_EMAIL_REFERENCE.md
├── .env (configuration)
├── Makefile (commands)
└── scripts/
    ├── quick-email-setup.sh
    ├── setup-email-alerts.sh
    ├── test-email-alert.sh
    └── configs/zabbix/alertscripts/
        └── email_alert.sh
```

---

**Happy Monitoring! 🚀**

*Last Updated: January 2026*
