#!/bin/bash

# Email Alert Script for Zabbix
# Usage: email_alert.sh <to_email> <subject> <message>

TO_EMAIL="$1"
SUBJECT="$2"
MESSAGE="$3"

# SMTP Configuration
SMTP_SERVER="${SMTP_SERVER:-smtp.gmail.com}"
SMTP_PORT="${SMTP_PORT:-587}"
SMTP_USER="${SMTP_USER:-your_email@gmail.com}"
SMTP_PASS="${SMTP_PASS:-your_app_password}"
FROM_EMAIL="${FROM_EMAIL:-$SMTP_USER}"

if [ -z "$TO_EMAIL" ] || [ -z "$SUBJECT" ]; then
    echo "Usage: $0 <to_email> <subject> <message>"
    exit 1
fi

# Validate email format
if ! echo "$TO_EMAIL" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
    echo "Invalid email format: $TO_EMAIL"
    exit 1
fi

# Create email content with proper formatting
EMAIL_CONTENT="From: Zabbix Monitoring <$FROM_EMAIL>
To: $TO_EMAIL
Subject: $SUBJECT
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 8bit

<!DOCTYPE html>
<html>
<head>
    <meta charset=\"UTF-8\">
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { background-color: #f44336; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
        .header h2 { margin: 0; font-size: 24px; }
        .content { padding: 20px; }
        .content h3 { color: #333; margin-top: 0; }
        .content p { color: #666; line-height: 1.6; margin: 10px 0; }
        .alert-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 15px 0; border-radius: 4px; }
        .info-box { background-color: #e3f2fd; border-left: 4px solid #2196F3; padding: 15px; margin: 15px 0; border-radius: 4px; }
        .footer { background-color: #f9f9f9; padding: 15px; border-top: 1px solid #eee; font-size: 12px; color: #999; text-align: center; border-radius: 0 0 8px 8px; }
        .timestamp { color: #999; font-size: 12px; }
    </style>
</head>
<body>
    <div class=\"container\">
        <div class=\"header\">
            <h2>🚨 Zabbix Alert Notification</h2>
        </div>
        <div class=\"content\">
            <h3>$SUBJECT</h3>
            <div class=\"alert-box\">
                <p>$MESSAGE</p>
            </div>
            <div class=\"info-box\">
                <p><strong>⏰ Time:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
                <p><strong>🖥️ Server:</strong> $(hostname)</p>
            </div>
        </div>
        <div class=\"footer\">
            <p>This is an automated message from Zabbix Monitoring System</p>
            <p class=\"timestamp\">Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
        </div>
    </div>
</body>
</html>"

# Send email using curl with SMTP
# Determine protocol based on port
if [ "$SMTP_PORT" = "465" ]; then
    PROTOCOL="smtps"
    SSL_FLAG=""
else
    PROTOCOL="smtp"
    SSL_FLAG="--ssl-reqd"
fi

RESPONSE=$(echo "$EMAIL_CONTENT" | curl -s --url "$PROTOCOL://$SMTP_SERVER:$SMTP_PORT" \
    $SSL_FLAG \
    --mail-from "$FROM_EMAIL" \
    --mail-rcpt "$TO_EMAIL" \
    --user "$SMTP_USER:$SMTP_PASS" \
    --upload-file - 2>&1)

CURL_EXIT=$?

if [ $CURL_EXIT -eq 0 ]; then
    echo "✅ Email alert sent successfully to $TO_EMAIL"
    exit 0
else
    echo "❌ Failed to send email alert"
    echo "Error: $RESPONSE"
    exit 1
fi