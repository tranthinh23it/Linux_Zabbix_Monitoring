# 🖥️ Hướng dẫn giám sát nhiều máy với Zabbix

## 🎯 Tổng quan

Hệ thống Zabbix của bạn có thể giám sát hàng trăm máy chủ khác nhau. Có 3 cách chính để setup:

### 1. **Auto-discovery** (Tự động tìm máy)
### 2. **Manual setup** (Thêm từng máy)
### 3. **Bulk deployment** (Thêm nhiều máy cùng lúc)

---

## 🔍 **Phương pháp 1: Auto-discovery (Khuyến nghị)**

### Tự động tìm và setup tất cả máy trong mạng:

```bash
# Tự động scan network và deploy agents
make discover-servers

# Hoặc manual
./scripts/auto-discover-servers.sh
```

**Script sẽ:**
- ✅ Scan network tìm máy đang online
- ✅ Test SSH access với các user phổ biến
- ✅ Detect OS (Ubuntu, CentOS, Debian...)
- ✅ Tạo danh sách máy có thể monitor
- ✅ Tự động deploy Zabbix agent
- ✅ Generate config cho Zabbix Web UI

---

## 🖥️ **Phương pháp 2: Multi-server Setup**

### Setup nhiều máy với giao diện menu:

```bash
# Chạy multi-server setup
make multi-server

# Hoặc manual
./scripts/multi-server-setup.sh
```

**Menu options:**
1. **Add single server** - Thêm 1 máy
2. **Add multiple servers** - Thêm nhiều máy từ file
3. **Show monitoring status** - Xem trạng thái
4. **Generate setup instructions** - Tạo hướng dẫn
5. **Create monitoring dashboard** - Tạo dashboard

---

## ⚡ **Phương pháp 3: Manual Single Server**

### Thêm 1 máy cụ thể:

```bash
# Deploy agent to specific server
make deploy-agent IP=192.168.1.100 USER=ubuntu SERVER=192.168.1.50

# Hoặc manual
./scripts/deploy-agent.sh 192.168.1.100 ubuntu 192.168.1.50
```

**Tham số:**
- `IP`: IP của máy muốn monitor
- `USER`: SSH username (ubuntu, centos, root...)
- `SERVER`: IP của Zabbix server (máy hiện tại)

---

## 📋 **Bulk Deployment từ File**

### Tạo file danh sách máy:

```bash
# Tạo file servers-list.txt
cat > servers-list.txt << EOF
# Format: IP,USERNAME,NAME
192.168.1.100,ubuntu,Web Server 1
192.168.1.101,ubuntu,Database Server
192.168.1.102,centos,App Server 1
192.168.1.103,debian,Cache Server
EOF
```

### Deploy tất cả:

```bash
make multi-server
# Chọn option 2: Add multiple servers from file
```

---

## 🌐 **Thêm Host vào Zabbix Web UI**

Sau khi deploy agent, cần thêm host trong Zabbix:

### **Cách 1: Manual (từng máy)**

1. **Login Zabbix**: http://localhost (Admin/zabbix)
2. **Configuration** → **Hosts** → **Create host**
3. **Điền thông tin:**
   - **Host name**: Web Server 1
   - **Visible name**: Web Server 1  
   - **Groups**: Linux servers
4. **Interfaces tab:**
   - **Type**: Agent
   - **IP address**: 192.168.1.100
   - **Port**: 10050
5. **Templates tab:**
   - Add: "Linux by Zabbix agent"
   - Add: "Linux Server Advanced" (nếu đã import)
6. **Click Add**

### **Cách 2: Import Template**

```bash
# Import advanced templates
# 1. Vào Configuration → Templates → Import
# 2. Chọn file: templates/linux-server-template.xml
# 3. Chọn file: templates/docker-monitoring-template.xml
```

---

## 📊 **Monitoring Dashboard**

### Real-time monitoring dashboard:

```bash
# Chạy dashboard theo dõi real-time
./scripts/monitoring-dashboard.sh
```

**Dashboard hiển thị:**
- ✅ Status của từng server
- ✅ Network connectivity
- ✅ Zabbix agent status
- ✅ Zabbix server components

---

## 🔧 **Troubleshooting**

### **Agent không connect được:**

```bash
# Trên server được monitor
sudo systemctl status zabbix-agent
sudo tail -f /var/log/zabbix/zabbix_agentd.log

# Check firewall
sudo ufw status
sudo ufw allow 10050/tcp

# Test connectivity
telnet ZABBIX_SERVER_IP 10051
```

### **Không có data:**

1. **Check host configuration** trong Zabbix Web UI
2. **Verify templates** đã được assign
3. **Check item keys** có đúng không
4. **Review Zabbix server logs**:
   ```bash
   sudo docker logs zabbix-server
   ```

### **SSH deployment failed:**

```bash
# Check SSH key
ssh-copy-id user@server_ip

# Test SSH access
ssh user@server_ip "echo 'SSH OK'"

# Check sudo permissions
ssh user@server_ip "sudo echo 'SUDO OK'"
```

---

## 🎯 **Advanced Monitoring Features**

### **1. Custom Metrics**

Các custom metrics đã được setup:
- **Docker containers**: Running/stopped containers
- **CPU temperature**: Hardware temperature
- **Network connections**: Active connections
- **Failed logins**: Security monitoring
- **Zombie processes**: System health

### **2. Auto-discovery Rules**

Setup auto-discovery trong Zabbix:
1. **Configuration** → **Discovery**
2. **Create discovery rule**
3. **Network range**: 192.168.1.1-254
4. **Checks**: Zabbix agent, SSH, HTTP
5. **Actions**: Auto-add hosts with templates

### **3. Maintenance Windows**

Setup maintenance mode:
1. **Configuration** → **Maintenance**
2. **Create maintenance period**
3. **Select hosts** cần maintenance
4. **Set time period**

---

## 📈 **Monitoring Best Practices**

### **1. Host Groups Organization**
- **Web Servers**: Nhóm web servers
- **Database Servers**: Nhóm database servers  
- **Application Servers**: Nhóm app servers
- **Network Devices**: Nhóm network equipment

### **2. Template Strategy**
- **Base Template**: Linux by Zabbix agent
- **Service Templates**: Apache, MySQL, Docker
- **Custom Templates**: Company-specific metrics

### **3. Alert Configuration**
- **Critical**: CPU > 90%, Disk > 95%
- **Warning**: CPU > 80%, Memory > 85%
- **Information**: Service restarts, logins

### **4. Dashboard Design**
- **Overview Dashboard**: Tổng quan tất cả servers
- **Service Dashboards**: Specific cho từng service
- **Network Dashboard**: Network performance
- **Security Dashboard**: Security events

---

## 🚀 **Quick Commands Summary**

```bash
# Auto-discover và setup tất cả
make discover-servers

# Multi-server interactive setup
make multi-server

# Deploy single server
make deploy-agent IP=192.168.1.100 USER=ubuntu SERVER=192.168.1.50

# Monitor dashboard
./scripts/monitoring-dashboard.sh

# Check system health
make health

# View all logs
make logs
```

---

## 🎉 **Kết quả mong đợi**

Sau khi setup xong, bạn sẽ có:

✅ **Multi-server monitoring** với real-time metrics
✅ **Centralized dashboard** cho tất cả servers
✅ **Email/Telegram alerts** khi có vấn đề
✅ **Historical data** và performance graphs
✅ **Auto-discovery** cho servers mới
✅ **Custom monitoring** cho services riêng
✅ **Security monitoring** và audit logs

**Hệ thống có thể monitor hàng trăm servers cùng lúc! 🚀**