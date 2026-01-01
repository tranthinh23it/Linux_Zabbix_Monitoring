# MySQL Database Schema Overview

## 📊 Zabbix Database Tables

### Core Configuration Tables
```sql
-- Hosts being monitored
hosts (hostid, host, name, status, ...)

-- Monitoring items (CPU, RAM, etc.)
items (itemid, hostid, name, key_, type, ...)

-- Alert triggers
triggers (triggerid, expression, description, priority, ...)

-- User accounts
users (userid, username, passwd, ...)

-- Host groups
hstgrp (groupid, name, ...)
```

### Historical Data Tables
```sql
-- Real-time metric values
history (itemid, clock, value, ns)
history_uint (itemid, clock, value, ns)
history_str (itemid, clock, value, ns)
history_text (itemid, clock, value, ns)
history_log (itemid, clock, value, ns)

-- Aggregated hourly/daily data
trends (itemid, clock, num, value_min, value_avg, value_max)
trends_uint (itemid, clock, num, value_min, value_avg, value_max)
```

### Event & Alert Tables
```sql
-- System events
events (eventid, source, object, objectid, clock, ...)

-- Alert notifications
alerts (alertid, actionid, eventid, userid, clock, ...)

-- Problem tracking
problem (eventid, source, object, objectid, clock, ...)
```

## 💾 Data Volume Examples

### Typical Storage Requirements:
- **Small environment** (10 hosts): ~500MB/month
- **Medium environment** (100 hosts): ~5GB/month  
- **Large environment** (1000 hosts): ~50GB/month

### Data Retention:
- **History**: 30 days (configurable)
- **Trends**: 365 days (configurable)
- **Events**: 365 days (configurable)

## 🔍 Sample Queries

### Check database size:
```sql
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'zabbix'
GROUP BY table_schema;
```

### Top 10 largest tables:
```sql
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES 
WHERE table_schema = 'zabbix'
ORDER BY (data_length + index_length) DESC
LIMIT 10;
```

### Recent CPU data:
```sql
SELECT 
    h.host,
    i.name,
    FROM_UNIXTIME(hist.clock) as time,
    hist.value
FROM history hist
JOIN items i ON hist.itemid = i.itemid
JOIN hosts h ON i.hostid = h.hostid
WHERE i.key_ LIKE '%cpu%'
ORDER BY hist.clock DESC
LIMIT 10;
```

## 🛠️ Maintenance Commands

### Cleanup old data:
```sql
-- Delete history older than 30 days
DELETE FROM history WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 30 DAY));

-- Delete trends older than 1 year
DELETE FROM trends WHERE clock < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 1 YEAR));
```

### Database optimization:
```sql
-- Optimize tables
OPTIMIZE TABLE history, trends, events;

-- Check table status
SHOW TABLE STATUS FROM zabbix;
```