#!/bin/bash

# Zabbix Restore Script

set -e

BACKUP_FILE="$1"
MYSQL_CONTAINER="zabbix-mysql"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    echo "Available backups:"
    ls -la backup/zabbix_backup_*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "🔄 Starting Zabbix restore process..."
echo "⚠️  This will overwrite existing data!"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 1
fi

# Stop services
echo "🛑 Stopping services..."
docker-compose down

# Extract backup
echo "📦 Extracting backup..."
TEMP_DIR=$(mktemp -d)
tar xzf "$BACKUP_FILE" -C "$TEMP_DIR"
BACKUP_DIR=$(ls "$TEMP_DIR")

# Restore MySQL database
echo "🗄️ Restoring MySQL database..."
docker-compose up -d mysql-server
sleep 30

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
until docker exec $MYSQL_CONTAINER mysqladmin ping -h localhost --silent; do
    sleep 2
done

# Drop and recreate database
docker exec $MYSQL_CONTAINER mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2) \
    -e "DROP DATABASE IF EXISTS zabbix; CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;"

# Restore database
docker exec -i $MYSQL_CONTAINER mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2) zabbix \
    < "$TEMP_DIR/$BACKUP_DIR/zabbix_db_"*.sql

# Restore SSL certificates
echo "🔐 Restoring SSL certificates..."
cp -r "$TEMP_DIR/$BACKUP_DIR/ssl/"* ssl/

# Restore Grafana data
echo "📊 Restoring Grafana data..."
docker-compose up -d grafana
sleep 10
docker exec -i zabbix-grafana tar xzf - -C / < "$TEMP_DIR/$BACKUP_DIR/grafana_data_"*.tar.gz

# Start all services
echo "🚀 Starting all services..."
docker-compose up -d

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Restore completed successfully!"
echo "🌐 Zabbix Web UI: https://localhost:8443"
echo "📊 Grafana: https://localhost:8443/grafana"