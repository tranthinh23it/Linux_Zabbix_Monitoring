#!/bin/bash

# Zabbix Backup Script

set -e

BACKUP_DIR="./backup"
DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_CONTAINER="zabbix-mysql"

echo "🔄 Starting Zabbix backup process..."

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

# Backup MySQL database
echo "📦 Backing up MySQL database..."
docker exec $MYSQL_CONTAINER mysqldump -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2) \
    --single-transaction --routines --triggers zabbix > "$BACKUP_DIR/$DATE/zabbix_db_$DATE.sql"

# Backup Zabbix configuration
echo "📦 Backing up Zabbix configuration..."
docker cp zabbix-server:/etc/zabbix/zabbix_server.conf "$BACKUP_DIR/$DATE/"
docker cp zabbix-server:/usr/lib/zabbix/alertscripts "$BACKUP_DIR/$DATE/"
docker cp zabbix-server:/usr/lib/zabbix/externalscripts "$BACKUP_DIR/$DATE/"

# Backup Grafana data
echo "📦 Backing up Grafana data..."
docker exec zabbix-grafana tar czf - /var/lib/grafana > "$BACKUP_DIR/$DATE/grafana_data_$DATE.tar.gz"

# Backup SSL certificates
echo "📦 Backing up SSL certificates..."
cp -r ssl "$BACKUP_DIR/$DATE/"

# Create compressed archive
echo "🗜️ Creating compressed archive..."
cd "$BACKUP_DIR"
tar czf "zabbix_backup_$DATE.tar.gz" "$DATE"
rm -rf "$DATE"

# Cleanup old backups (keep last 7 days)
echo "🧹 Cleaning up old backups..."
find . -name "zabbix_backup_*.tar.gz" -mtime +7 -delete

echo "✅ Backup completed: $BACKUP_DIR/zabbix_backup_$DATE.tar.gz"

# Optional: Upload to cloud storage
if [ ! -z "$AWS_S3_BUCKET" ]; then
    echo "☁️ Uploading to S3..."
    aws s3 cp "zabbix_backup_$DATE.tar.gz" "s3://$AWS_S3_BUCKET/zabbix-backups/"
fi