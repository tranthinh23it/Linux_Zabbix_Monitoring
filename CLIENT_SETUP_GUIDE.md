# 🖥️ Hướng dẫn setup máy khác để được giám sát

## 🎯 **Tóm tắt: Máy khác cần gì?**

Để **Zabbix Server** có thể giám sát máy khác, máy đó cần:

### ✅ **Chỉ cần cài 1 thứ: Zabbix Agent**
- **Zabbix Agent**: Service nhỏ chạy trên máy được giám sát
- **Port 10050**: Mở port để Zabbix Server kết nối
- **Network access**: Máy phải ping được tới Zabbix Server

---

## 🚀 **Cách 1: Auto Install (Khuyến nghị)**

### Từ máy Zabbix Server, deploy tự động:

```bash
# Deploy agent to remote server
make deploy-agent IP=192.168.1.100 USER=ubuntu SERVER=192.168.1.50

# Hoặc auto-discover tất cả máy trong mạng
make discover-servers
```

**Script sẽ tự động:**
- ✅ SSH vào máy khác
- ✅ Cài Zabbix Agent
- ✅ Configure agent
- ✅ Mở firewall port 10050
- ✅ Start service

---

## 🔧 **Cách 2: Manual Install trên máy khác**

### Trên máy muốn được giám sát, chạy:

```bash
# Download script
wget https://raw.githubusercontent.com/your-repo/zabbix-monitoring/main/scripts/install-agent-only.sh

# Chạy script (thay IP_ZABBIX_SERVER bằng IP thật)
chmod +x install-agent-only.sh
./install-agent-only.sh 192.168.1.50
```

### Hoặc manual step-by-step:

#### **Ubuntu/Debian:**
```bash
# 1. Cài Zabbix repository
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo apt update

# 2. Cài Zabbix Agent
sudo apt install -y zabbix-agent

# 3. Configure agent
sudo nano /etc/zabbix/zabbix_agentd.conf
```

#### **CentOS/RHEL:**
```bash
# 1. Cài Zabbix repository
sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-release-6.4-1.el8.noarch.rpm

# 2. Cài Zabbix Agent
sudo dnf install -y zabbix-agent

# 3. Configure agent
sudo nano /etc/zabbix/zabbix_agentd.conf
```

---

## ⚙️ **Configuration Agent**

### File config: `/etc/zabbix/zabbix_agentd.conf`

```bash
# Thay IP_ZABBIX_SERVER bằng IP thật của Zabbix Server
Server=192.168.1.50
ServerActive=192.168.1.50
Hostname=Web-Server-01

# Basic settings
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
StartAgents=3
Timeout=3

# Enable custom monitoring
UnsafeUserParameters=1
Include=/etc/zabbix/zabbix_agentd.d/*.conf
```

### Start service:

```bash
# Start và enable
sudo systemctl enable zabbix-agent
sudo systemctl start zabbix-agent

# Check status
sudo systemctl status zabbix-agent
```

---

## 🔥 **Firewall Configuration**

### **Ubuntu/Debian (UFW):**
```bash
sudo ufw allow 10050/tcp
sudo ufw reload
```

### **CentOS/RHEL (Firewalld):**
```bash
sudo firewall-cmd --permanent --add-port=10050/tcp
sudo firewall-cmd --reload
```

### **Manual iptables:**
```bash
sudo iptables -A INPUT -p tcp --dport 10050 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

---

## 🌐 **Network Requirements**

### **Ports cần mở:**

| Port | Direction | Purpose |
|------|-----------|---------|
| **10050** | Inbound | Zabbix Agent (máy được giám sát) |
| **10051** | Outbound | Zabbix Server (máy chủ giám sát) |

### **Test connectivity:**

```bash
# Từ máy được giám sát, test tới Zabbix Server
telnet 192.168.1.50 10051

# Từ Zabbix Server, test tới máy được giám sát
telnet 192.168.1.100 10050
```

---

## 🖥️ **Thêm Host vào Zabbix Web UI**

Sau khi cài agent, cần add host trong Zabbix:

### **1. Login Zabbix Web UI:**
- URL: http://ZABBIX_SERVER_IP
- Username: Admin
- Password: zabbix

### **2. Add Host:**
1. **Configuration** → **Hosts** → **Create host**
2. **Host tab:**
   - **Host name**: Web-Server-01
   - **Visible name**: Web Server 01
   - **Groups**: Linux servers
3. **Interfaces tab:**
   - **Type**: Agent
   - **IP address**: 192.168.1.100
   - **Port**: 10050
4. **Templates tab:**
   - Add: "Linux by Zabbix agent"
5. **Click Add**

### **3. Verify Connection:**
- Sau 1-2 phút, icon "ZBX" sẽ chuyển từ đỏ sang xanh
- **Monitoring** → **Latest data** → Chọn host để xem metrics

---

## 📊 **Custom Monitoring (Advanced)**

### **Custom metrics đã được setup:**

```bash
# System metrics
system.cpu.temperature     # CPU temperature
system.memory.available     # Available memory %
system.process.count        # Number of processes
system.network.connections  # Active connections

# Docker metrics (nếu có Docker)
docker.containers.running   # Running containers
docker.containers.total     # Total containers

# Service monitoring
service.status[nginx]       # Check if nginx is active
service.status[apache2]     # Check if apache is active
```

### **Add custom metrics:**

```bash
# Tạo file custom config
sudo nano /etc/zabbix/zabbix_agentd.d/custom.conf

# Thêm custom parameters
UserParameter=custom.disk.usage,df -h / | awk 'NR==2{print $5}' | sed 's/%//'
UserParameter=custom.load.average,uptime | awk '{print $(NF-2)}' | sed 's/,//'

# Restart agent
sudo systemctl restart zabbix-agent
```

---

## 🔍 **Troubleshooting**

### **Agent không start:**
```bash
# Check logs
sudo tail -f /var/log/zabbix/zabbix_agentd.log

# Check config syntax
sudo zabbix_agentd -t

# Check permissions
sudo chown zabbix:zabbix /var/log/zabbix/zabbix_agentd.log
```

### **Không connect được:**
```bash
# Test network
ping ZABBIX_SERVER_IP
telnet ZABBIX_SERVER_IP 10051

# Check firewall
sudo ufw status
sudo iptables -L | grep 10050

# Check agent status
sudo systemctl status zabbix-agent
sudo netstat -tlnp | grep 10050
```

### **Không có data:**
```bash
# Test agent locally
zabbix_get -s 127.0.0.1 -k system.cpu.load[all,avg1]

# Check item keys
zabbix_get -s AGENT_IP -k system.uname

# Restart agent
sudo systemctl restart zabbix-agent
```

---

## 🎯 **Quick Setup Summary**

### **Trên máy được giám sát:**
1. **Cài Zabbix Agent**: `sudo apt install zabbix-agent`
2. **Configure**: Set Server IP trong `/etc/zabbix/zabbix_agentd.conf`
3. **Start service**: `sudo systemctl start zabbix-agent`
4. **Mở firewall**: `sudo ufw allow 10050/tcp`

### **Trên Zabbix Server:**
1. **Login Web UI**: http://localhost
2. **Add Host**: Configuration → Hosts → Create host
3. **Set IP và Template**: Agent IP + Linux template
4. **Verify**: Check ZBX icon và Latest data

### **Auto Setup (Recommended):**
```bash
# Từ Zabbix Server
make deploy-agent IP=TARGET_IP USER=ubuntu SERVER=ZABBIX_IP
```

**Chỉ cần vậy thôi! Máy khác sẽ được giám sát hoàn toàn! 🚀**