-- PostgreSQL initialization script for Zabbix

-- Create additional indexes for better performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS history_1_clock ON history_uint USING btree (clock);
CREATE INDEX CONCURRENTLY IF NOT EXISTS history_1_itemid_clock ON history_uint USING btree (itemid, clock);
CREATE INDEX CONCURRENTLY IF NOT EXISTS trends_1_clock ON trends_uint USING btree (clock);
CREATE INDEX CONCURRENTLY IF NOT EXISTS trends_1_itemid_clock ON trends_uint USING btree (itemid, clock);

-- Optimize for Zabbix workload
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET track_activity_query_size = 2048;
ALTER SYSTEM SET pg_stat_statements.track = 'all';

-- Create partitioning function for history tables (optional, for large deployments)
CREATE OR REPLACE FUNCTION create_monthly_partitions()
RETURNS void AS $$
DECLARE
    start_date date;
    end_date date;
    table_name text;
BEGIN
    -- Create partitions for next 12 months
    FOR i IN 0..11 LOOP
        start_date := date_trunc('month', CURRENT_DATE + interval '1 month' * i);
        end_date := start_date + interval '1 month';
        
        -- History table partition
        table_name := 'history_' || to_char(start_date, 'YYYY_MM');
        EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF history 
                       FOR VALUES FROM (%L) TO (%L)', 
                       table_name, start_date, end_date);
        
        -- Trends table partition  
        table_name := 'trends_' || to_char(start_date, 'YYYY_MM');
        EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF trends 
                       FOR VALUES FROM (%L) TO (%L)', 
                       table_name, start_date, end_date);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create maintenance user for backups
CREATE USER zabbix_backup WITH PASSWORD 'backup_password';
GRANT CONNECT ON DATABASE zabbix TO zabbix_backup;
GRANT USAGE ON SCHEMA public TO zabbix_backup;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO zabbix_backup;

-- Set up automatic statistics collection
ALTER DATABASE zabbix SET log_statement = 'mod';
ALTER DATABASE zabbix SET log_min_duration_statement = 1000;

-- Optimize for Zabbix specific queries
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_trgm;