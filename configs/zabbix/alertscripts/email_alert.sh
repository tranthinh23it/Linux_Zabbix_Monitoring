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

# Create email content
EMAIL_CONTENT="From: Zabbix Monitoring <$FROM_EMAIL>
To: $TO_EMAIL
Subject: $SUBJECT
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f44336; color: white; padding: 10px; border-radius: 5px; }
        .content { margin: 20px 0; padding: 15px; border-left: 4px solid #f44336; }
        .footer { font-size: 12px; color: #666; margin-top: 20px; }
    </style>
</head>
<body>
    <div class=\"header\">
        <h2>🚨 Zabbix Alert Notification</h2>
    </div>
    <div class=\"content\">
        <h3>$SUBJECT</h3>
        <p>$MESSAGE</p>
        <hr>
        <p><strong>Time:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
        <p><strong>Server:</strong> $(hostname)</p>
    </div>
    <div class=\"footer\">
        <p>This is an automated message from Zabbix Monitoring System</p>
    </div>
</body>
</html>"

# Send email using curl and SMTP
echo "$EMAIL_CONTENT" | curl -s --url "smtps://$SMTP_SERVER:$SMTP_PORT" \
    --ssl-reqd \
    --mail-from "$FROM_EMAIL" \
    --mail-rcpt "$TO_EMAIL" \
    --user "$SMTP_USER:$SMTP_PASS" \
    --upload-file -

if [ $? -eq 0 ]; then
    echo "Email alert sent successfully to $TO_EMAIL"
    exit 0
else
    echo "Failed to send email alert"
    exit 1
fi