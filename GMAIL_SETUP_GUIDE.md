# 📧 Gmail Setup Guide for Zabbix Email Alerts

## Step-by-Step Instructions

### Step 1: Create Gmail Account (if needed)

1. Go to: https://accounts.google.com/signup
2. Fill in your information
3. Create account

### Step 2: Enable 2-Step Verification

**IMPORTANT: This is required for App Passwords**

1. Go to: https://myaccount.google.com
2. Click **Security** in the left menu
3. Scroll down to **2-Step Verification**
4. Click **Get Started**
5. Follow the prompts to enable 2-Step Verification
6. Verify your phone number

### Step 3: Generate App Password

1. Go to: https://myaccount.google.com
2. Click **Security** in the left menu
3. Scroll down to **App passwords**
4. Select:
   - **App**: Mail
   - **Device**: Windows Computer (or your device type)
5. Click **Generate**
6. **IMPORTANT**: Copy the 16-character password that appears
   - Example: `abcd efgh ijkl mnop`
   - Remove spaces: `abcdefghijklmnop`

### Step 4: Configure Zabbix

Run the email configuration script:

```bash
./scripts/configure-email.sh
```

Or manually edit `.env`:

```properties
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=abcdefghijklmnop
FROM_EMAIL=your_email@gmail.com
ALERT_EMAIL=recipient@gmail.com
```

### Step 5: Test Email

```bash
make test-email recipient@gmail.com
```

## Troubleshooting

### "Authentication failed" Error

**Problem**: Email not sending, authentication error

**Solutions**:
1. Verify App Password is exactly 16 characters
2. Remove any spaces from App Password
3. Verify 2-Step Verification is enabled
4. Regenerate App Password if needed

### "Connection refused" Error

**Problem**: Cannot connect to Gmail SMTP

**Solutions**:
1. Check internet connection
2. Verify SMTP settings:
   - Server: `smtp.gmail.com`
   - Port: `587`
3. Check firewall settings

### Email Not Received

**Problem**: Email sent but not in inbox

**Solutions**:
1. Check spam folder
2. Verify recipient email is correct
3. Check Gmail security settings
4. Try sending to different email address

## Common Issues

### Issue 1: "Less secure app access" Error

**Solution**: Use App Password instead of regular password

### Issue 2: "Invalid credentials" Error

**Solution**: 
1. Verify App Password (16 chars, no spaces)
2. Verify 2-Step Verification is enabled
3. Regenerate App Password

### Issue 3: "SMTP connection timeout"

**Solution**:
1. Check internet connection
2. Try different port (465 instead of 587)
3. Check firewall

## Verify Setup

After configuration, verify with:

```bash
# Check .env file
grep SMTP .env

# Test email
make test-email your_email@gmail.com

# View logs
docker logs zabbix-server | grep -i email
```

## Next Steps

1. ✅ Gmail configured
2. ✅ Test email sent
3. Configure Zabbix Web UI:
   - Administration → Media types → Email
   - Set SMTP settings
4. Configure User Media:
   - Administration → Users → Admin → Media
5. Create Alert Action:
   - Configuration → Actions

See EMAIL_ALERT_SETUP.md for Zabbix Web UI configuration.

## Security Notes

- App Password is stored in `.env` file
- Backup `.env` before changes
- Don't share `.env` with others
- Regenerate App Password if compromised
- Use strong Gmail account password

## Support

- Gmail Help: https://support.google.com/accounts
- App Passwords: https://support.google.com/accounts/answer/185833
- 2-Step Verification: https://support.google.com/accounts/answer/185839
