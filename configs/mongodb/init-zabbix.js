// MongoDB initialization script for Zabbix

// Switch to zabbix database
db = db.getSiblingDB('zabbix');

// Create zabbix user
db.createUser({
  user: 'zabbix',
  pwd: 'zabbix_password',
  roles: [
    {
      role: 'readWrite',
      db: 'zabbix'
    }
  ]
});

// Create collections for Zabbix data
db.createCollection('hosts');
db.createCollection('items');
db.createCollection('history');
db.createCollection('trends');
db.createCollection('triggers');
db.createCollection('events');
db.createCollection('alerts');
db.createCollection('users');
db.createCollection('groups');
db.createCollection('templates');

// Create indexes for performance
db.history.createIndex({ "itemid": 1, "clock": 1 });
db.trends.createIndex({ "itemid": 1, "clock": 1 });
db.events.createIndex({ "clock": 1 });
db.alerts.createIndex({ "clock": 1 });
db.items.createIndex({ "hostid": 1 });
db.triggers.createIndex({ "hostid": 1 });

// Insert initial admin user (similar to Zabbix default)
db.users.insertOne({
  userid: 1,
  username: "Admin",
  name: "Zabbix",
  surname: "Administrator",
  passwd: "$2y$10$L9tjKByfruByB.BaTQJz/epcbDQn5w2CfP7JCqCdP.Q8UfIuFcqRm", // zabbix
  type: 3, // Super admin
  theme: "default",
  lang: "en_US",
  refresh: "30s",
  rows_per_page: 50,
  url: "",
  autologin: 0,
  autologout: "15m",
  created: new Date(),
  attempt_failed: 0,
  attempt_ip: "",
  attempt_clock: 0,
  roleid: 3
});

// Insert default host group
db.groups.insertOne({
  groupid: 1,
  name: "Linux servers",
  internal: 0,
  flags: 0
});

// Insert localhost host
db.hosts.insertOne({
  hostid: 1,
  host: "Zabbix server",
  visible_name: "Zabbix server",
  name: "Zabbix server",
  status: 0,
  disable_until: 0,
  error: "",
  available: 1,
  errors_from: 0,
  lastaccess: 0,
  ipmi_authtype: -1,
  ipmi_privilege: 2,
  ipmi_username: "",
  ipmi_password: "",
  ipmi_disable_until: 0,
  ipmi_available: 0,
  snmp_disable_until: 0,
  snmp_available: 0,
  maintenanceid: 0,
  maintenance_status: 0,
  maintenance_type: 0,
  maintenance_from: 0,
  ipmi_errors_from: 0,
  snmp_errors_from: 0,
  ipmi_error: "",
  snmp_error: "",
  jmx_disable_until: 0,
  jmx_available: 0,
  jmx_errors_from: 0,
  jmx_error: "",
  name: "Zabbix server",
  flags: 0,
  templateid: 0,
  description: "",
  tls_connect: 1,
  tls_accept: 1,
  tls_issuer: "",
  tls_subject: "",
  tls_psk_identity: "",
  tls_psk: "",
  proxy_address: "",
  auto_compress: 1,
  custom_interfaces: 0,
  uuid: "",
  created: new Date()
});

print("Zabbix MongoDB initialization completed!");
print("Created user: zabbix");
print("Created collections and indexes");
print("Inserted default admin user and host");