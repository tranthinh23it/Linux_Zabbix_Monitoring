# 📧 Zabbix Email Alert Setup Guide

## Overview
This guide helps you setup email alerts in Zabbix to receive notifications when monitoring triggers are activated (CPU > 80%, Memory > 85%, Disk > 90%, etc.).

## Prerequisites
- Zabbix Server running (http://localhost)
- Gmail account with 2-Step Verification enabled
- Gmail App Password generated

## Step 1: Generate Gmail App Password

1. Go to https://myaccount.google.com
2. Click **Security** in the left menu
3. Enable **2-Step Verification** if not already enabled
4. Scroll down and click **App passwords**
5. Select:
   - App: **Mail**
   - Device: **Windows Computer** (or your device type)
6. Click **Generate**
7. Copy the 16-character password (you'll need this)

## Step 2: Configure Email in Zabbix Web UI

### 2.1 Create Media Type

1. Login to Zabbix Web UI: http://localhost
   - Username: **Admin**
   - Password: **zabbix**

2. Go to **Administration** → **Media types**

3. Click **Create media type** button

4. Fill in the following:
   - **Name**: `Email Alert`
   - **Type**: `Email`
   - **SMTP server**: `smtp.gmail.com`
   - **SMTP server port**: `587`
   - **SMTP helo**: `zabbix.local`
   - **SMTP email**: `your_email@gmail.com` (your Gmail address)
   - **Connection security**: `STARTTLS`
   - **Authentication**: `Username and password`
   - **Username**: `your_email@gmail.com`
   - **Password**: `xxxx xxxx xxxx xxxx` (your 16-char app password)

5. Click **Add**

### 2.2 Configure User Media

1. Go to **Administration** → **Users**

2. Click on **Admin** user

3. Go to **Media** tab

4. Click **Add** button

5. Configure:
   - **Type**: `Email Alert` (the one we just created)
   - **Send to**: `your_email@gmail.com` (recipient email)
   - **When active**: `1-7,00:00-24:00` (all day, all week)
   - **Use if severity**: Check all severity levels:
     - ✓ Not classified
     - ✓ Information
     - ✓ Warning
     - ✓ Average
     - ✓ High
     - ✓ Disaster

6. Click **Add**

7. Click **Update** to save user changes

### 2.3 Create Alert Action

1. Go to **Configuration** → **Actions**

2. Click **Create action** button

3. **Action** tab:
   - **Name**: `Email Alert Action`
   - **Conditions**: Leave as default (all triggers)
   - **Enabled**: ✓ (checked)

4. **Operations** tab:
   - Click **Add** button
   - **Operation type**: `Send message`
   - **Send to users**: Select **Admin**
   - **Send only to**: `Email Alert`
   - **Default message**: ✓ (checked)
   - Click **Add**

5. **Recovery operations** tab:
   - Click **Add** button
   - **Operation type**: `Send message`
   - **Send to users**: Select **Admin**
   - **Send only to**: `Email Alert`
   - **Default message**: ✓ (checked)
   - Click **Add**

6. Click **Add** to save the action

## Step 3: Create Test Triggers

### 3.1 High CPU Usage Trigger

1. Go to **Configuration** → **Hosts**

2. Click on **Zabbix server** host

3. Go to **Triggers** tab

4. Click **Create trigger** button

5. Configure:
   - **Name**: `High CPU Usage`
   - **Expression**: `last(/Zabbix server/system.cpu.util)>80`
   - **Severity**: `High`
   - **Enabled**: ✓ (checked)

6. Click **Add**

### 3.2 High Memory Usage Trigger

1. Click **Create trigger** button again

2. Configure:
   - **Name**: `High Memory Usage`
   - **Expression**: `last(/Zabbix server/vm.memory.util)>85`
   - **Severity**: `High`
   - **Enabled**: ✓ (checked)

3. Click **Add**

### 3.3 Low Disk Space Trigger

1. Click **Create trigger** button again

2. Configure:
   - **Name**: `Low Disk Space`
   - **Expression**: `last(/Zabbix server/vfs.fs.size[/,pused])>90`
   - **Severity**: `Average`
   - **Enabled**: ✓ (checked)

3. Click **Add**

## Step 4: Test Email Alerts

### Method 1: Using Test Script

Run the test script from your terminal:

```bash
make test-email your_email@gmail.com
```

Or manually:

```bash
./scripts/test-email-alert.sh your_email@gmail.com
```

### Method 2: Trigger CPU Alert

1. SSH to your server
2. Run: `stress --cpu 4 --timeout 60s` (install stress if needed: `sudo apt install stress`)
3. This will spike CPU usage and trigger the alert
4. Check your email inbox

### Method 3: Manual Trigger Test

1. Go to **Monitoring** → **Problems**
2. You should see active problems/triggers
3. Check your email for notifications

## Step 5: Verify Email Delivery

1. Check your Gmail inbox for emails from Zabbix
2. If not found, check **Spam** folder
3. If still not found, check Zabbix logs:

```bash
docker logs zabbix-server
```

## Troubleshooting

### Email Not Sending

**Problem**: Emails not received
**Solutions**:
1. Verify Gmail App Password is correct (16 characters)
2. Check Gmail 2FA is enabled
3. Verify SMTP settings in Media Type
4. Check Zabbix logs: `docker logs zabbix-server`
5. Test with: `make test-email your_email@gmail.com`

### Authentication Failed

**Problem**: "Authentication failed" error
**Solutions**:
1. Use App Password, not regular Gmail password
2. Ensure 2-Step Verification is enabled
3. Regenerate App Password if needed
4. Update password in Media Type

### Connection Timeout

**Problem**: "Connection timeout" error
**Solutions**:
1. Check internet connection
2. Verify SMTP server: `smtp.gmail.com`
3. Verify SMTP port: `587`
4. Check firewall rules

### Trigger Not Firing

**Problem**: Triggers created but not firing
**Solutions**:
1. Verify trigger expression is correct
2. Check if Zabbix agent is collecting data
3. Go to **Monitoring** → **Latest data** to see current values
4. Adjust trigger threshold if needed

## Quick Commands

```bash
# Setup email alerts interactively
make setup-email

# Test email sending
make test-email your_email@gmail.com

# View Zabbix logs
make logs-server

# Check Zabbix server status
make status
```

## Email Alert Examples

### CPU Alert
- **Trigger**: CPU usage > 80%
- **Expression**: `last(/Zabbix server/system.cpu.util)>80`
- **Severity**: High

### Memory Alert
- **Trigger**: Memory usage > 85%
- **Expression**: `last(/Zabbix server/vm.memory.util)>85`
- **Severity**: High

### Disk Alert
- **Trigger**: Disk usage > 90%
- **Expression**: `last(/Zabbix server/vfs.fs.size[/,pused])>90`
- **Severity**: Average

### Network Alert
- **Trigger**: Network errors > 100
- **Expression**: `last(/Zabbix server/net.if.in[eth0])>100`
- **Severity**: Warning

## Advanced Configuration

### Custom Email Templates

Edit email message templates in:
- **Administration** → **Media types** → **Email** → **Message templates**

### Multiple Recipients

1. Create multiple users with different email addresses
2. Add each user to the action
3. Or use distribution lists in Gmail

### Escalation Rules

1. Go to **Configuration** → **Actions**
2. Edit action
3. Set **Escalation period** (e.g., 1h)
4. Add multiple operations with different escalation steps

## Support

For more information:
- Zabbix Documentation: https://www.zabbix.com/documentation
- Gmail App Passwords: https://support.google.com/accounts/answer/185833
- Zabbix Community: https://www.zabbix.com/forum
