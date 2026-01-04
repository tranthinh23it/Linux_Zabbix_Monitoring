#!/bin/bash

# Detailed Email Alert Script for Zabbix
# Usage: email_alert_detailed.sh <to_email> <subject> <message> <severity> <host> <metric>

TO_EMAIL="$1"
SUBJECT="$2"
MESSAGE="$3"
SEVERITY="${4:-High}"
HOST="${5:-Unknown}"
METRIC="${6:-System Alert}"

# SMTP Configuration
SMTP_SERVER="${SMTP_SERVER:-smtp.gmail.com}"
SMTP_PORT="${SMTP_PORT:-587}"
SMTP_USER="${SMTP_USER:-your_email@gmail.com}"
SMTP_PASS="${SMTP_PASS:-your_app_password}"
FROM_EMAIL="${FROM_EMAIL:-$SMTP_USER}"

if [ -z "$TO_EMAIL" ] || [ -z "$SUBJECT" ]; then
    echo "Usage: $0 <to_email> <subject> <message> [severity] [host] [metric]"
    exit 1
fi

# Get system metrics
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)
UPTIME=$(uptime -p 2>/dev/null || uptime)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100)}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# Determine severity color
case "$SEVERITY" in
    "Critical"|"Disaster")
        SEVERITY_COLOR="#d32f2f"
        SEVERITY_ICON="🔴"
        ;;
    "High")
        SEVERITY_COLOR="#f57c00"
        SEVERITY_ICON="🟠"
        ;;
    "Average"|"Medium")
        SEVERITY_COLOR="#fbc02d"
        SEVERITY_ICON="🟡"
        ;;
    "Warning"|"Low")
        SEVERITY_COLOR="#1976d2"
        SEVERITY_ICON="🔵"
        ;;
    *)
        SEVERITY_COLOR="#388e3c"
        SEVERITY_ICON="🟢"
        ;;
esac

# Create detailed email content
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
        * { margin: 0; padding: 0; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, $SEVERITY_COLOR 0%, $(echo $SEVERITY_COLOR | sed 's/#//')99 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        .alert-section {
            padding: 25px;
            border-bottom: 1px solid #eee;
        }
        .alert-section h2 {
            color: $SEVERITY_COLOR;
            font-size: 18px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-message {
            background-color: #f9f9f9;
            border-left: 4px solid $SEVERITY_COLOR;
            padding: 15px;
            border-radius: 4px;
            line-height: 1.6;
            color: #333;
        }
        .metrics-section {
            padding: 25px;
            border-bottom: 1px solid #eee;
        }
        .metrics-section h2 {
            color: #333;
            font-size: 18px;
            margin-bottom: 15px;
        }
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }
        .metric-card {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #2196F3;
        }
        .metric-card.warning {
            border-left-color: #ff9800;
        }
        .metric-card.critical {
            border-left-color: #f44336;
        }
        .metric-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .metric-value {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        .system-info {
            padding: 25px;
            border-bottom: 1px solid #eee;
        }
        .system-info h2 {
            color: #333;
            font-size: 18px;
            margin-bottom: 15px;
        }
        .info-table {
            width: 100%;
            border-collapse: collapse;
        }
        .info-table tr {
            border-bottom: 1px solid #eee;
        }
        .info-table td {
            padding: 10px;
            font-size: 14px;
        }
        .info-table td:first-child {
            font-weight: bold;
            color: #666;
            width: 30%;
        }
        .info-table td:last-child {
            color: #333;
        }
        .action-section {
            padding: 25px;
            background-color: #f9f9f9;
            border-bottom: 1px solid #eee;
        }
        .action-section h2 {
            color: #333;
            font-size: 18px;
            margin-bottom: 15px;
        }
        .action-list {
            list-style: none;
            padding-left: 0;
        }
        .action-list li {
            padding: 8px 0;
            padding-left: 25px;
            position: relative;
            color: #333;
        }
        .action-list li:before {
            content: \"✓\";
            position: absolute;
            left: 0;
            color: #4caf50;
            font-weight: bold;
        }
        .footer {
            padding: 20px;
            background-color: #f5f5f5;
            text-align: center;
            font-size: 12px;
            color: #999;
        }
        .button {
            display: inline-block;
            padding: 12px 24px;
            background-color: $SEVERITY_COLOR;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 10px;
        }
        .severity-badge {
            display: inline-block;
            padding: 6px 12px;
            background-color: $SEVERITY_COLOR;
            color: white;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class=\"container\">
        <!-- Header -->
        <div class=\"header\">
            <h1>$SEVERITY_ICON Zabbix Alert Notification</h1>
            <p>$CURRENT_TIME</p>
        </div>

        <!-- Alert Message -->
        <div class=\"alert-section\">
            <h2>$SEVERITY_ICON Alert Details</h2>
            <div class=\"alert-message\">
                <strong>Subject:</strong> $SUBJECT<br><br>
                <strong>Message:</strong><br>
                $MESSAGE<br><br>
                <span class=\"severity-badge\">$SEVERITY</span>
            </div>
        </div>

        <!-- System Metrics -->
        <div class=\"metrics-section\">
            <h2>📊 Current System Metrics</h2>
            <div class=\"metrics-grid\">
                <div class=\"metric-card\">
                    <div class=\"metric-label\">CPU Usage</div>
                    <div class=\"metric-value\">${CPU_USAGE}%</div>
                </div>
                <div class=\"metric-card\">
                    <div class=\"metric-label\">Memory Usage</div>
                    <div class=\"metric-value\">${MEMORY_USAGE}%</div>
                </div>
                <div class=\"metric-card\">
                    <div class=\"metric-label\">Disk Usage (/)</div>
                    <div class=\"metric-value\">$DISK_USAGE</div>
                </div>
                <div class=\"metric-card\">
                    <div class=\"metric-label\">Load Average</div>
                    <div class=\"metric-value\">$LOAD_AVG</div>
                </div>
            </div>
        </div>

        <!-- System Information -->
        <div class=\"system-info\">
            <h2>🖥️ System Information</h2>
            <table class=\"info-table\">
                <tr>
                    <td>Hostname</td>
                    <td>$HOSTNAME</td>
                </tr>
                <tr>
                    <td>Alert Host</td>
                    <td>$HOST</td>
                </tr>
                <tr>
                    <td>Metric</td>
                    <td>$METRIC</td>
                </tr>
                <tr>
                    <td>Uptime</td>
                    <td>$UPTIME</td>
                </tr>
                <tr>
                    <td>Alert Time</td>
                    <td>$CURRENT_TIME</td>
                </tr>
                <tr>
                    <td>Severity</td>
                    <td><span class=\"severity-badge\">$SEVERITY</span></td>
                </tr>
            </table>
        </div>

        <!-- Recommended Actions -->
        <div class=\"action-section\">
            <h2>⚡ Recommended Actions</h2>
            <ul class=\"action-list\">
                <li>Check Zabbix Web UI for detailed information</li>
                <li>Review system logs for error messages</li>
                <li>Monitor the situation closely</li>
                <li>Take corrective action if necessary</li>
                <li>Update alert status when resolved</li>
            </ul>
            <a href=\"http://localhost\" class=\"button\">View in Zabbix</a>
        </div>

        <!-- Footer -->
        <div class=\"footer\">
            <p>This is an automated alert from Zabbix Monitoring System</p>
            <p>Do not reply to this email. Please contact your system administrator.</p>
            <p style=\"margin-top: 10px; color: #ccc;\">Generated: $CURRENT_TIME | Host: $HOSTNAME</p>
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
    echo "✅ Detailed email alert sent successfully to $TO_EMAIL"
    exit 0
else
    echo "❌ Failed to send email alert"
    echo "Error: $RESPONSE"
    exit 1
fi
