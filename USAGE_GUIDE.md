# 🎯 Hướng dẫn sử dụng Zabbix Monitoring System

## 🌐 Bước 1: Đăng nhập Zabbix

1. Mở trình duyệt và truy cập: **http://localhost**
2. Đăng nhập với:
   - **Username**: `Admin`
   - **Password**: `zabbix`

## 📊 Bước 2: Xem Dashboard chính

Sau khi đăng nhập, bạn sẽ thấy:
- **Global view**: Tổng quan hệ thống
- **Problems**: Các vấn đề hiện tại
- **Latest data**: Dữ liệu mới nhất
- **Graphs**: Biểu đồ monitoring

## 🖥️ Bước 3: Kiểm tra Host đang được monitor

1. Vào **Configuration** → **Hosts**
2. Bạn sẽ thấy host "Zabbix server" đang được monitor
3. Click vào host để xem chi tiết

## 📈 Bước 4: Xem Monitoring Data

### Xem Latest Data:
1. **Monitoring** → **Latest data**
2. Chọn host "Zabbix server"
3. Xem các metrics: CPU, RAM, Disk, Network

### Xem Graphs:
1. **Monitoring** → **Graphs**
2. Chọn host và graph muốn xem
3. Có thể adjust time range

## 🚨 Bước 5: Setup Alerts (Cảnh báo)

### Tạo Media Type (Email):
1. **Administration** → **Media types**
2. Click **Create media type**
3. Chọn **Email** và cấu hình SMTP

### Tạo User để nhận alert:
1. **Administration** → **Users**
2. Tạo user mới hoặc edit user Admin
3. Thêm **Media** (email) để nhận cảnh báo

### Tạo Action:
1. **Configuration** → **Actions**
2. Click **Create action**
3. Setup conditions và operations

## 🔧 Bước 6: Thêm Host mới để monitor

### Cài Zabbix Agent trên server khác:
```bash
# Trên server muốn monitor
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent

# Cấu hình agent
sudo nano /etc/zabbix/zabbix_agentd.conf
# Sửa: Server=<IP_ZABBIX_SERVER>
# Sửa: ServerActive=<IP_ZABBIX_SERVER>

sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
```

### Thêm host trong Zabbix Web:
1. **Configuration** → **Hosts**
2. Click **Create host**
3. Điền thông tin:
   - **Host name**: Tên server
   - **Groups**: Linux servers
   - **Interfaces**: IP address của server
4. **Templates**: Chọn "Linux by Zabbix agent"
5. Click **Add**

## 📊 Bước 7: Sử dụng Grafana (Advanced)

1. Truy cập: **http://localhost:3000**
2. Đăng nhập: `admin` / `admin123`
3. Import dashboard từ file `dashboards/grafana/system-overview.json`
4. Xem visualization nâng cao

## 🛠️ Bước 8: Quản lý hệ thống

### Xem logs:
```bash
sudo docker logs zabbix-server
sudo docker logs zabbix-web
sudo docker logs zabbix-mysql
```

### Restart services:
```bash
sudo docker-compose -f docker-compose.simple.yml restart
```

### Backup database:
```bash
./scripts/backup.sh
```

### Health check:
```bash
./scripts/monitoring-check.sh
```

## 🎯 Các tính năng chính đã setup:

### ✅ Monitoring Metrics:
- **CPU Usage**: Sử dụng CPU theo %
- **Memory Usage**: RAM usage và available
- **Disk Space**: Dung lượng disk các partition
- **Network Traffic**: Lưu lượng mạng in/out
- **System Load**: Load average
- **Process Count**: Số process đang chạy
- **Docker Stats**: Container monitoring

### ✅ Alert System:
- **Email alerts**: Gửi email khi có vấn đề
- **Telegram alerts**: Thông báo qua Telegram
- **Custom triggers**: Tự định nghĩa ngưỡng cảnh báo

### ✅ Advanced Features:
- **Custom dashboards**: Tạo dashboard riêng
- **Templates**: Sử dụng template có sẵn
- **Auto-discovery**: Tự động phát hiện services
- **Maintenance mode**: Chế độ bảo trì
- **User management**: Quản lý người dùng

## 🚀 Quick Commands:

```bash
# Xem status
make status

# Health check
make health

# View logs
make logs

# Backup
make backup

# Deploy agent to remote server
make deploy-agent IP=192.168.1.100 USER=ubuntu SERVER=192.168.1.50
```

## 🔍 Troubleshooting:

### Nếu không truy cập được web:
```bash
sudo docker ps | grep zabbix-web
curl http://localhost
```

### Nếu không có data:
```bash
sudo docker logs zabbix-server
sudo docker logs zabbix-agent-server
```

### Reset password Admin:
```bash
sudo docker exec -it zabbix-mysql mysql -u root -p
# Trong MySQL:
USE zabbix;
UPDATE users SET passwd=MD5('newpassword') WHERE username='Admin';
```

## 📚 Tài liệu tham khảo:
- [Zabbix Documentation](https://www.zabbix.com/documentation/6.4/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)