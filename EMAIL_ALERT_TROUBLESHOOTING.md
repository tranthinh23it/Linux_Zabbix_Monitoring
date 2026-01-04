# 🔧 Email Alert Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: "Authentication failed" Error

**Symptoms:**
- Email not sending
- Error message: "Authentication failed" or "535 5.7.8 Username and password not accepted"

**Solutions:**

1. **Verify App Password (Most Common)**
   - App Password must be exactly 16 characters
   - No spaces or dashes
   - Example: `abcd efgh ijkl mnop` → `abcdefghijklmnop`
   - Regenerate if unsure: https://myaccount.google.com → App passwords

2. **Check 2-Step Verification**
   - Must be enabled on Gmail account
   - Go to https://myaccount.google.com → Security
   - Enable 2-Step Verification if not done

3. **Verify Email in .env**
   ```bash
   grep SMTP_USER .env
   grep SMTP_PASS .env
   ```
   - Should show your Gmail and app password
   - No quotes or special characters

4. **Test with curl directly**
   ```bash
   source .env
   echo "test" | curl -s --url "smtp://smtp.gmail.com:587" \
     --ssl-reqd \
     --mail-from "$SMTP_USER" \
     --mail-rcpt "your_email@gmail.com" \
     --user "$SMTP_USER:$SMTP_PASS" \
     --upload-file -
   ```

---

### Issue 2: "Connection timeout" Error

**Symptoms:**
- Email sending hangs
- Error: "Connection timeout" or "Connection refused"

**Solutions:**

1. **Check Internet Connection**
   ```bash
   ping smtp.gmail.com
   ```

2. **Verify SMTP Settings**
   - Server: `smtp.gmail.com` (not `smtps://`)
   - Port: `587` (not 465 or 25)
   - Security: `STARTTLS` (not SSL)

3. **Check Firewall**
   ```bash
   # Test port 587
   telnet smtp.gmail.com 587
   ```
   - Should connect successfully
   - If not, firewall may be blocking

4. **Check Docker Network**
   ```bash
   docker exec zabbix-server curl -v smtp.gmail.com:587
   ```

---

### Issue 3: Email Not Received

**Symptoms:**
- Email sent successfully but not in inbox
- No error messages

**Solutions:**

1. **Check Spam Folder**
   - Gmail may classify as spam
   - Add sender to contacts to whitelist

2. **Check Email Address**
   - Verify recipient email is correct
   - Test with different email address

3. **Check Zabbix Logs**
   ```bash
   docker logs zabbix-server | grep -i email
   docker logs zabbix-server | grep -i alert
   ```

4. **Verify Media Type Configuration**
   - Go to Zabbix Web UI → Administration → Media types
   - Check Email media type settings
   - Test with "Test" button if available

5. **Check Action Configuration**
   - Go to Configuration → Actions
   - Verify action is enabled
   - Check conditions and operations

---

### Issue 4: Trigger Not Firing

**Symptoms:**
- Trigger created but no alerts sent
- No problems shown in Monitoring → Problems

**Solutions:**

1. **Verify Trigger Expression**
   ```bash
   # Go to Monitoring → Latest data
   # Check if item values match trigger condition
   ```

2. **Check Item Data Collection**
   - Go to Monitoring → Latest data
   - Search for the item (e.g., "system.cpu.util")
   - Should show recent values
   - If empty, agent not collecting data

3. **Verify Trigger Threshold**
   - Trigger: `last(/Zabbix server/system.cpu.util)>80`
   - Check current CPU: `top -bn1 | grep Cpu`
   - Adjust threshold if needed

4. **Check Trigger Status**
   - Go to Configuration → Hosts → Triggers
   - Verify trigger is enabled (green icon)
   - Check trigger expression syntax

5. **Test with Low Threshold**
   - Create test trigger: `last(/Zabbix server/system.cpu.util)>1`
   - Should trigger immediately
   - Verify alert is sent

---

### Issue 5: "Less secure app access" Error

**Symptoms:**
- Error: "Please log in via your web browser"
- Gmail blocking the connection

**Solutions:**

1. **Enable Less Secure App Access** (if 2FA not available)
   - Go to https://myaccount.google.com/lesssecureapps
   - Turn on "Allow less secure app access"
   - Note: Not recommended, use App Password instead

2. **Use App Password Instead** (Recommended)
   - Go to https://myaccount.google.com
   - Security → App passwords
   - Generate new app password
   - Use in Zabbix configuration

---

### Issue 6: Email Script Permission Denied

**Symptoms:**
- Error: "Permission denied" when running test
- Error: "scripts/test-email-alert.sh: Permission denied"

**Solutions:**

```bash
# Make scripts executable
chmod +x scripts/test-email-alert.sh
chmod +x scripts/setup-email-alerts.sh
chmod +x configs/zabbix/alertscripts/email_alert.sh

# Verify permissions
ls -la scripts/test-email-alert.sh
ls -la configs/zabbix/alertscripts/email_alert.sh
```

---

### Issue 7: .env File Not Found

**Symptoms:**
- Error: ".env file not found"
- Scripts cannot read configuration

**Solutions:**

```bash
# Check if .env exists
ls -la .env

# If not, copy from example
cp .env.example .env

# Edit with your settings
nano .env
```

---

### Issue 8: Zabbix Server Not Running

**Symptoms:**
- Cannot connect to Zabbix Web UI
- Error: "Connection refused"

**Solutions:**

```bash
# Check if containers are running
docker ps | grep zabbix

# Start services
make start

# Check logs
docker logs zabbix-server

# Restart services
make restart
```

---

## Testing Procedures

### Test 1: Email Script Direct Test

```bash
# Set environment variables
export SMTP_USER="your_email@gmail.com"
export SMTP_PASS="your_app_password"
export FROM_EMAIL="your_email@gmail.com"

# Run email script
./configs/zabbix/alertscripts/email_alert.sh \
  "recipient@gmail.com" \
  "Test Subject" \
  "Test Message"
```

### Test 2: Using Make Command

```bash
# Test email with recipient
make test-email recipient@gmail.com

# Or interactive
make test-email
```

### Test 3: Trigger CPU Alert

```bash
# Install stress tool
sudo apt install stress

# Spike CPU usage
stress --cpu 4 --timeout 60s

# Monitor in Zabbix
# Go to Monitoring → Problems
# Should see "High CPU Usage" trigger
```

### Test 4: Check Zabbix Logs

```bash
# View server logs
docker logs zabbix-server

# View specific error
docker logs zabbix-server | grep -i error

# Follow logs in real-time
docker logs -f zabbix-server
```

---

## Debugging Steps

### Step 1: Verify Configuration

```bash
# Check .env file
cat .env | grep SMTP

# Should show:
# SMTP_USER=your_email@gmail.com
# SMTP_PASS=your_app_password
# FROM_EMAIL=your_email@gmail.com
# ALERT_EMAIL=recipient@gmail.com
```

### Step 2: Test Email Script

```bash
# Source environment
source .env

# Test email sending
./configs/zabbix/alertscripts/email_alert.sh \
  "$ALERT_EMAIL" \
  "Debug Test" \
  "Testing email configuration"
```

### Step 3: Check Zabbix Media Type

```bash
# In Zabbix Web UI:
# Administration → Media types → Email
# Click "Test" button
# Should show success or error
```

### Step 4: Verify Action Configuration

```bash
# In Zabbix Web UI:
# Configuration → Actions
# Check if action is enabled
# Verify operations are configured
```

### Step 5: Monitor Problem Events

```bash
# In Zabbix Web UI:
# Monitoring → Problems
# Should show active problems
# Check "Action log" for sent notifications
```

---

## Quick Fixes

### Fix 1: Reset Email Configuration

```bash
# Restore from backup
cp .env.backup .env

# Run setup again
make setup-email
```

### Fix 2: Regenerate App Password

1. Go to https://myaccount.google.com
2. Security → App passwords
3. Delete old password
4. Generate new password
5. Update .env file
6. Test again

### Fix 3: Restart Services

```bash
# Restart all services
make restart

# Or specific service
docker restart zabbix-server
```

### Fix 4: Clear Zabbix Cache

```bash
# Restart Zabbix server
docker restart zabbix-server

# Wait for startup
sleep 10

# Check status
docker ps | grep zabbix-server
```

---

## Support Resources

- **Zabbix Documentation**: https://www.zabbix.com/documentation
- **Gmail App Passwords**: https://support.google.com/accounts/answer/185833
- **Gmail Security**: https://support.google.com/accounts/answer/3466521
- **Zabbix Community**: https://www.zabbix.com/forum
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/zabbix

---

## Contact Support

If issues persist:

1. Collect logs:
   ```bash
   docker logs zabbix-server > zabbix-server.log
   docker logs zabbix-web > zabbix-web.log
   cat .env > config.log
   ```

2. Check system resources:
   ```bash
   docker stats
   df -h
   free -h
   ```

3. Verify network:
   ```bash
   ping smtp.gmail.com
   telnet smtp.gmail.com 587
   ```

4. Share logs with support team
