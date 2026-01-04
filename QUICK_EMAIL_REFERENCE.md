# 📧 Email Alerts - Quick Reference Card

## 🚀 Get Started in 3 Steps

```bash
# Step 1: Run quick setup
make quick-email

# Step 2: Check email inbox for test message

# Step 3: Configure Zabbix Web UI (see EMAIL_ALERT_SETUP.md)
```

---

## 📋 Commands

| Command | Purpose |
|---------|---------|
| `make quick-email` | Interactive email setup (recommended) |
| `make setup-email` | Full setup with detailed guide |
| `make test-email` | Send test email |
| `make test-email user@gmail.com` | Send test to specific email |
| `make logs-server` | View Zabbix server logs |
| `make status` | Check service status |

---

## 🔧 Configuration

### .env File Location
```
.env
```

### Key Settings
```properties
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password (16 chars)
FROM_EMAIL=your_email@gmail.com
ALERT_EMAIL=recipient@gmail.com
```

---

## 📧 Gmail Setup

1. Go to https://myaccount.google.com
2. Security → 2-Step Verification (enable if needed)
3. Security → App passwords
4. Select Mail + your device
5. Copy 16-character password
6. Use in `make quick-email`

---

## ✅ Zabbix Web UI Setup

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

| Issue | Solution |
|-------|----------|
| Auth failed | Check App Password (16 chars) |
| Connection timeout | Check internet, verify SMTP settings |
| Email not received | Check spam folder, verify recipient |
| Trigger not firing | Check trigger expression, verify data |
| Permission denied | `chmod +x scripts/*.sh` |

---

## 📚 Documentation

- **EMAIL_ALERTS_README.md** - Complete guide
- **EMAIL_ALERT_SETUP.md** - Zabbix Web UI setup
- **EMAIL_ALERT_TROUBLESHOOTING.md** - Common issues

---

## 🎯 Trigger Examples

```
High CPU:     last(/Zabbix server/system.cpu.util)>80
High Memory:  last(/Zabbix server/vm.memory.util)>85
Low Disk:     last(/Zabbix server/vfs.fs.size[/,pused])>90
High Network: last(/Zabbix server/net.if.in[eth0])>100
```

---

## 💡 Tips

- Use App Password, not regular Gmail password
- Enable 2-Step Verification on Gmail
- Test email before creating triggers
- Check spam folder for test emails
- Verify Zabbix agent is collecting data
- Use low threshold for testing (e.g., >1 instead of >80)

---

## 🆘 Quick Fixes

```bash
# Reset configuration
cp .env.backup .env

# Restart services
make restart

# View all logs
make logs

# Check status
make status
```

---

**Need help?** See EMAIL_ALERT_TROUBLESHOOTING.md
