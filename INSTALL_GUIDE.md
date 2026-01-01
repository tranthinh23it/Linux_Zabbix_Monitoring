# 🚀 Hướng dẫn cài đặt Zabbix Monitoring System

## Bước 1: Cài Docker (Manual)

```bash
# Update system
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose standalone
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Test installation
sudo docker run --rm hello-world
```

## Bước 2: Logout và Login lại
```bash
# Logout và login lại để apply docker group
# Hoặc chạy:
newgrp docker

# Test Docker without sudo
docker run --rm hello-world
```

## Bước 3: Chọn Database
```bash
# Chạy database selector
make select-db

# Hoặc manual:
./scripts/database-selector.sh
```

## Bước 4: Start Zabbix
```bash
# Setup và start services
make setup

# Hoặc manual:
docker-compose -f docker-compose.active.yml up -d
```

## 🎯 Quick Commands

```bash
# Cài Docker
make install-docker

# Phân tích hệ thống
make analyze

# Chọn database
make select-db

# Start services
make setup

# Check health
make health

# View logs
make logs
```

## 🌐 Access URLs

- **Zabbix Web**: https://localhost:8443 (Admin/zabbix)
- **Grafana**: https://localhost:8443/grafana (admin/admin123)
- **Database Admin**: Tùy theo database đã chọn

## 🔧 Troubleshooting

### Docker permission denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Port conflicts
```bash
# Check ports in use
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

### Container issues
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```