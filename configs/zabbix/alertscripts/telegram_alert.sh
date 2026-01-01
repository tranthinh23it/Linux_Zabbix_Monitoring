#!/bin/bash

# Telegram Alert Script for Zabbix
# Usage: telegram_alert.sh <chat_id> <subject> <message>

TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-YOUR_BOT_TOKEN}"
CHAT_ID="$1"
SUBJECT="$2"
MESSAGE="$3"

if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$CHAT_ID" ] || [ -z "$SUBJECT" ]; then
    echo "Usage: $0 <chat_id> <subject> <message>"
    exit 1
fi

# Format message
FORMATTED_MESSAGE="🚨 *Zabbix Alert*

*Subject:* $SUBJECT

*Message:*
$MESSAGE

*Time:* $(date '+%Y-%m-%d %H:%M:%S')
*Server:* $(hostname)"

# Send to Telegram
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${FORMATTED_MESSAGE}" \
    -d "parse_mode=Markdown" \
    > /dev/null

if [ $? -eq 0 ]; then
    echo "Telegram alert sent successfully"
    exit 0
else
    echo "Failed to send Telegram alert"
    exit 1
fi