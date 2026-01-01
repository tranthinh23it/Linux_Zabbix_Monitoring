# Zabbix Monitoring System Makefile

.PHONY: help setup start stop restart logs backup restore clean health deploy-agent

# Default target
help:
	@echo "🚀 Zabbix Monitoring System Commands:"
	@echo ""
	@echo "Installation:"
	@echo "  make analyze        - Analyze system and recommend database"
	@echo "  make install-docker - Install Docker & Docker Compose"
	@echo "  make select-db      - Choose database (MySQL/PostgreSQL/SQLite/MongoDB)"
	@echo ""
	@echo "Setup & Management:"
	@echo "  make setup          - Initial setup and start services"
	@echo "  make start          - Start all services"
	@echo "  make stop           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make logs           - Show logs from all services"
	@echo "  make health         - Check system health"
	@echo ""
	@echo "Production:"
	@echo "  make prod-start     - Start in production mode"
	@echo "  make prod-stop      - Stop production services"
	@echo ""
	@echo "Backup & Restore:"
	@echo "  make backup         - Create system backup"
	@echo "  make restore FILE=  - Restore from backup file"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean          - Clean up containers and volumes"
	@echo "  make update         - Update Docker images"
	@echo "  make ssl            - Generate SSL certificates"
	@echo ""
	@echo "Agent Deployment:"
	@echo "  make deploy-agent IP= USER= SERVER= - Deploy agent to remote server"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make deploy-agent IP=192.168.1.100 USER=ubuntu SERVER=192.168.1.50"
	@echo "  make restore FILE=backup/zabbix_backup_20240101_120000.tar.gz"

# Setup and start services
setup:
	@echo "🚀 Setting up Zabbix Monitoring System..."
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

# Install Docker (if not installed)
install-docker:
	@echo "🐳 Installing Docker..."
	@./scripts/install-docker.sh

# System analysis
analyze:
	@echo "�️ Analyzing system..."
	@./scripts/system-analyzer.sh

# Database selection menu
select-db:
	@echo "🗄️ Database Selection..."
	@./scripts/database-selector.sh

# Quick demo
demo:
	@echo "🎯 Running quick demo..."
	@./scripts/quick-demo.sh

# Setup email alerts
setup-email:
	@echo "📧 Setting up email alerts..."
	@./scripts/setup-email-alerts.sh

# Test email alerts
test-email:
	@echo "📧 Testing email alerts..."
	@./scripts/test-email-alert.sh

# Multi-server monitoring setup
multi-server:
	@echo "🖥️ Multi-server monitoring setup..."
	@./scripts/multi-server-setup.sh

# Auto-discover servers on network
discover-servers:
	@echo "🔍 Auto-discovering servers..."
	@./scripts/auto-discover-servers.sh

# Install agent on current machine (for testing)
install-agent:
	@echo "📦 Installing Zabbix Agent..."
	@./scripts/install-agent-only.sh

# Start services
start:
	@echo "▶️ Starting services..."
	@docker-compose up -d
	@echo "✅ Services started successfully!"

# Stop services
stop:
	@echo "⏹️ Stopping services..."
	@docker-compose down
	@echo "✅ Services stopped successfully!"

# Restart services
restart: stop start

# Production start
prod-start:
	@echo "🏭 Starting production services..."
	@docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@echo "✅ Production services started!"

# Production stop
prod-stop:
	@echo "🏭 Stopping production services..."
	@docker-compose -f docker-compose.yml -f docker-compose.prod.yml down
	@echo "✅ Production services stopped!"

# Show logs
logs:
	@docker-compose logs -f

# Show logs for specific service
logs-%:
	@docker-compose logs -f $*

# Health check
health:
	@./scripts/monitoring-check.sh

# Create backup
backup:
	@echo "💾 Creating backup..."
	@./scripts/backup.sh
	@echo "✅ Backup completed!"

# Restore from backup
restore:
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Please specify backup file: make restore FILE=backup/file.tar.gz"; \
		exit 1; \
	fi
	@echo "🔄 Restoring from $(FILE)..."
	@./scripts/restore.sh $(FILE)
	@echo "✅ Restore completed!"

# Clean up
clean:
	@echo "🧹 Cleaning up..."
	@docker-compose down -v --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed!"

# Update images
update:
	@echo "🔄 Updating Docker images..."
	@docker-compose pull
	@docker-compose up -d
	@echo "✅ Update completed!"

# Generate SSL certificates
ssl:
	@echo "🔐 Generating SSL certificates..."
	@mkdir -p ssl
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ssl/server.key \
		-out ssl/server.crt \
		-subj "/C=VN/ST=HCM/L=HoChiMinh/O=ZabbixMonitoring/CN=localhost"
	@chmod 600 ssl/server.key
	@chmod 644 ssl/server.crt
	@echo "✅ SSL certificates generated!"

# Deploy agent to remote server
deploy-agent:
	@if [ -z "$(IP)" ] || [ -z "$(USER)" ] || [ -z "$(SERVER)" ]; then \
		echo "❌ Usage: make deploy-agent IP=<server_ip> USER=<username> SERVER=<zabbix_server_ip>"; \
		exit 1; \
	fi
	@echo "🚀 Deploying Zabbix Agent to $(IP)..."
	@./scripts/deploy-agent.sh $(IP) $(USER) $(SERVER)
	@echo "✅ Agent deployment completed!"

# Show service status
status:
	@echo "📊 Service Status:"
	@docker-compose ps

# Show resource usage
resources:
	@echo "💻 Resource Usage:"
	@docker stats --no-stream

# Import templates
import-templates:
	@echo "📋 Importing Zabbix templates..."
	@echo "Please import templates manually through Zabbix Web UI:"
	@echo "  - templates/linux-server-template.xml"
	@echo "  - templates/docker-monitoring-template.xml"

# Show access URLs
urls:
	@echo "🌐 Access URLs:"
	@echo "  Zabbix Web UI: https://localhost:8443"
	@echo "  Grafana: https://localhost:8443/grafana"
	@echo "  Elasticsearch: http://localhost:9200"

# Development mode
dev: start
	@echo "🔧 Development mode started"
	@echo "Watching logs..."
	@make logs