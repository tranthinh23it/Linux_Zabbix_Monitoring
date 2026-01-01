#!/bin/bash

# MySQL Maintenance Script for Zabbix

set -e

MYSQL_CONTAINER="zabbix-mysql"
MYSQL_ROOT_PASS=$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2)

echo "🔧 Zabbix MySQL Maintenance Script"

# Function to execute MySQL commands
mysql_exec() {
    docker exec $MYSQL_CONTAINER mysql -u root -p$MYSQL_ROOT_PASS -e "$1"
}

# Check database size
check_db_size() {
    echo "📊 Database Size Information:"
    mysql_exec "
    SELECT 
        table_schema AS 'Database',
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size_MB'
    FROM information_schema.tables 
    WHERE table_schema = 'zabbix'
    GROUP BY table_schema;
    "
}

# Show largest tables
show_largest_tables() {
    echo "📋 Top 10 Largest Tables:"
    mysql_exec "
    SELECT 
        table_name AS 'Table',
        ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size_MB',
        table_rows AS 'Rows'
    FROM information_schema.TABLES 
    WHERE table_schema = 'zabbix'
    ORDER BY (data_length + index_length) DESC
    LIMIT 10;
    "
}

# Show data retention info
show_data_retention() {
    echo "📅 Data Retention Information:"
    
    echo "History data range:"
    mysql_exec "
    SELECT 
        'History' as Type,
        FROM_UNIXTIME(MIN(clock)) as Oldest,
        FROM_UNIXTIME(MAX(clock)) as Newest,
        COUNT(*) as Records
    FROM history
    UNION ALL
    SELECT 
        'Trends' as Type,
        FROM_UNIXTIME(MIN(clock)) as Oldest,
        FROM_UNIXTIME(MAX(clock)) as Newest,
        COUNT(*) as Records
    FROM trends;
    "
}

# Cleanup old data
cleanup_old_data() {
    local days=${1:-30}
    echo "🧹 Cleaning up data older than $days days..."
    
    # Backup before cleanup
    echo "Creating backup before cleanup..."
    docker exec $MYSQL_CONTAINER mysqldump -u root -p$MYSQL_ROOT_PASS \
        --single-transaction zabbix > "backup/pre_cleanup_$(date +%Y%m%d_%H%M%S).sql"
    
    # Delete old history
    mysql_exec "
    DELETE FROM history 
    WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL $days DAY));
    "
    
    mysql_exec "
    DELETE FROM history_uint 
    WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL $days DAY));
    "
    
    mysql_exec "
    DELETE FROM history_str 
    WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL $days DAY));
    "
    
    mysql_exec "
    DELETE FROM history_text 
    WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL $days DAY));
    "
    
    mysql_exec "
    DELETE FROM history_log 
    WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL $days DAY));
    "
    
    echo "✅ Cleanup completed!"
}

# Optimize database
optimize_database() {
    echo "⚡ Optimizing database tables..."
    
    # Get list of tables
    TABLES=$(mysql_exec "SHOW TABLES FROM zabbix;" | tail -n +2)
    
    for table in $TABLES; do
        echo "Optimizing table: $table"
        mysql_exec "OPTIMIZE TABLE zabbix.$table;"
    done
    
    echo "✅ Database optimization completed!"
}

# Show database performance stats
show_performance_stats() {
    echo "📈 Database Performance Statistics:"
    
    mysql_exec "
    SELECT 
        VARIABLE_NAME,
        VARIABLE_VALUE
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME IN (
        'Queries',
        'Questions',
        'Slow_queries',
        'Connections',
        'Threads_connected',
        'Threads_running',
        'Innodb_buffer_pool_read_requests',
        'Innodb_buffer_pool_reads'
    );
    "
}

# Show recent monitoring data
show_recent_data() {
    echo "📊 Recent Monitoring Data Sample:"
    
    mysql_exec "
    SELECT 
        h.host,
        i.name,
        FROM_UNIXTIME(hist.clock) as timestamp,
        hist.value
    FROM history hist
    JOIN items i ON hist.itemid = i.itemid
    JOIN hosts h ON i.hostid = h.hostid
    WHERE hist.clock > UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 1 HOUR))
    ORDER BY hist.clock DESC
    LIMIT 20;
    "
}

# Main menu
case "${1:-menu}" in
    "size")
        check_db_size
        ;;
    "tables")
        show_largest_tables
        ;;
    "retention")
        show_data_retention
        ;;
    "cleanup")
        cleanup_old_data ${2:-30}
        ;;
    "optimize")
        optimize_database
        ;;
    "stats")
        show_performance_stats
        ;;
    "recent")
        show_recent_data
        ;;
    "full-maintenance")
        echo "🔧 Running full maintenance..."
        check_db_size
        show_largest_tables
        show_data_retention
        cleanup_old_data ${2:-30}
        optimize_database
        check_db_size
        echo "✅ Full maintenance completed!"
        ;;
    "menu"|*)
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  size              - Show database size"
        echo "  tables            - Show largest tables"
        echo "  retention         - Show data retention info"
        echo "  cleanup [days]    - Cleanup old data (default: 30 days)"
        echo "  optimize          - Optimize database tables"
        echo "  stats             - Show performance statistics"
        echo "  recent            - Show recent monitoring data"
        echo "  full-maintenance  - Run complete maintenance"
        echo ""
        echo "Examples:"
        echo "  $0 size"
        echo "  $0 cleanup 60"
        echo "  $0 full-maintenance"
        ;;
esac