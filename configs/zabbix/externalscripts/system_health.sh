#!/bin/bash

# System Health Check Script
# Usage: system_health.sh <check_type>

CHECK_TYPE="$1"

case "$CHECK_TYPE" in
    "load_average")
        uptime | awk '{print $(NF-2)}' | sed 's/,//'
        ;;
    "disk_io_read")
        iostat -d 1 2 | tail -n +4 | awk '{sum += $3} END {print sum}'
        ;;
    "disk_io_write")
        iostat -d 1 2 | tail -n +4 | awk '{sum += $4} END {print sum}'
        ;;
    "network_connections")
        netstat -an | grep ESTABLISHED | wc -l
        ;;
    "process_count")
        ps aux | wc -l
        ;;
    "zombie_processes")
        ps aux | awk '{print $8}' | grep -c Z
        ;;
    "memory_available")
        free -m | awk 'NR==2{printf "%.1f", $7*100/$2}'
        ;;
    "swap_usage")
        free | awk 'NR==3{printf "%.1f", $3*100/$2}'
        ;;
    "cpu_temperature")
        if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
            cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}'
        else
            echo "0"
        fi
        ;;
    "uptime_seconds")
        cat /proc/uptime | awk '{print int($1)}'
        ;;
    "logged_users")
        who | wc -l
        ;;
    "failed_logins")
        journalctl --since "1 hour ago" | grep "Failed password" | wc -l
        ;;
    *)
        echo "Unknown check type: $CHECK_TYPE"
        echo "Available checks: load_average, disk_io_read, disk_io_write, network_connections, process_count, zombie_processes, memory_available, swap_usage, cpu_temperature, uptime_seconds, logged_users, failed_logins"
        exit 1
        ;;
esac