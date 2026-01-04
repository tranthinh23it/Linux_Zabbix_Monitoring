# 📧 Zabbix Alert Action Setup Guide

## Overview

Để email tự động gửi khi CPU/RAM/Disk cao, bạn cần:

1. ✅ **Triggers** (Đã tạo)
2. ✅ **Email Script** (Đã có)
3. ⏳ **Media Type** (Cần config)
4. ⏳ **User Media** (Cần config)
5. ⏳ **Alert Action** (Cần config)

---

## Step 1: Configure Media Type

### Trong Zabbix Web UI:

1. Go to: **Administration → Media types**
2. Click **Create media type** (or edit existing Email)
3. Fill in:

```
Name: Email Alert
Type: Email
SMTP server: smtp.gmail.com
SMTP server port: 587
SMTP helo: zabbix.local
SMTP email: thinhtdh.23it@vku.udn.vn
Connection security: STARTTLS
Authentication: Username and password
Username: thinhtdh.23it@vku.udn.vn
Password: pygzpmzvppvnhelt
```

4. Click **Add**

---

## Step 2: Configure User Media

### Trong Zabbix Web UI:

1. Go to: **Administration → Users**
2. Click on **Admin** user
3. Go to **Media** tab
4. Click **Add**
5. Fill in:

```
Type: Email Alert (the one you just created)
Send to: tranhungthinh30702@gmail.com
When active: 1-7,00:00-24:00 (all day, all week)
Use if severity: Check all:
  ✓ Not classified
  ✓ Information
  ✓ Warning
  ✓ Average
  ✓ High
  ✓ Disaster
```

6. Click **Add**
7. Click **Update** to save user

---

## Step 3: Create Alert Action

### Trong Zabbix Web UI:

1. Go to: **Configuration → Actions**
2. Click **Create action**
3. **Action** tab:
   - **Name**: Email Alert Action
   - **Conditions**: Leave as default (all triggers)
   - **Enabled**: ✓ (checked)

4. **Operations** tab:
   - Click **Add** button
   - **Operation type**: Send message
   - **Send to users**: Select **Admin**
   - **Send only to**: Email Alert
   - **Default message**: ✓ (checked)
   - Click **Add**

5. **Recovery operations** tab:
   - Click **Add** button
   - **Operation type**: Send message
   - **Send to users**: Select **Admin**
   - **Send only to**: Email Alert
   - **Default message**: ✓ (checked)
   - Click **Add**

6. Click **Add** to save action

---

## Step 4: Verify Setup

### Check Triggers:

1. Go to: **Configuration → Hosts → tranthinh → Triggers**
2. You should see:
   - High CPU Usage (>80%)
   - High Memory Usage (>85%)
   - High Disk Usage (>90%)

### Check Media Type:

1. Go to: **Administration → Media types**
2. You should see: **Email Alert**

### Check User Media:

1. Go to: **Administration → Users → Admin → Media**
2. You should see: **Email Alert** with recipient email

### Check Action:

1. Go to: **Configuration → Actions**
2. You should see: **Email Alert Action**

---

## Step 5: Test Email Alerts

### Test 1: Spike CPU

```bash
./scripts/spike-cpu.sh 30
```

Then check:
1. Zabbix Web UI: **Monitoring → Problems**
2. Your email inbox for alert

### Test 2: Manual Test

```bash
./scripts/test-detailed-email.sh
```

---

## 📊 How It Works

```
CPU Usage > 80%
    ↓
Zabbix Agent Collects Data
    ↓
Trigger "High CPU Usage" Fires
    ↓
Alert Action Triggered
    ↓
Email Script Called
    ↓
Email Sent to: tranhungthinh30702@gmail.com
    ↓
You Receive Email ✉️
```

---

## 🎯 For Multiple Agents

### Scenario: 3 Agents Monitoring

```
Agent 1 (tranthinh)
Agent 2 (server2)
Agent 3 (server3)
    ↓
All Send to Zabbix Server
    ↓
Zabbix Server Checks Triggers
    ↓
If Any Trigger Fires
    ↓
Email Sent to: tranhungthinh30702@gmail.com
```

**Important:** All agents send alerts to the **same email address**

### If You Want Different Emails:

1. Create multiple Users in Zabbix
2. Each User has different email
3. Create different Actions for each User
4. Each Action sends to different email

Example:
- User: Admin → Email: admin@company.com
- User: DevOps → Email: devops@company.com
- User: Support → Email: support@company.com

---

## 🔧 Troubleshooting

### Email Not Sending

**Check:**
1. Media Type configured correctly
2. User Media configured
3. Action created and enabled
4. Trigger fired (check Monitoring → Problems)

**Test:**
```bash
./scripts/test-detailed-email.sh
```

### Trigger Not Firing

**Check:**
1. Trigger exists (Configuration → Hosts → Triggers)
2. Trigger is enabled
3. Metrics are being collected (Monitoring → Latest data)
4. Current value exceeds threshold

**Test:**
```bash
./scripts/spike-cpu.sh 30
```

### Email Format Issues

**Check:**
1. Email script is correct
2. SMTP settings are correct
3. Test with simple email first

**Test:**
```bash
make test-email recipient@gmail.com
```

---

## 📋 Checklist

- [ ] Triggers created (3 triggers)
- [ ] Media Type configured
- [ ] User Media configured
- [ ] Alert Action created
- [ ] Test email sent
- [ ] CPU spike test done
- [ ] Email received

---

## 🎉 When Everything Works

1. CPU/RAM/Disk goes high
2. Zabbix detects it
3. Trigger fires
4. Alert Action runs
5. Email sent automatically ✉️

---

## 📞 Support

- Zabbix Documentation: https://www.zabbix.com/documentation
- Email Setup: See EMAIL_ALERT_SETUP.md
- Troubleshooting: See EMAIL_ALERT_TROUBLESHOOTING.md
