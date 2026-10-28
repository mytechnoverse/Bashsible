
```bash
apt install snmpd
```

Services is the sum of operating layers :

Layer 7 : 64
Layer 4 : 8
Layer 3 : 4
Layer 2 : 2

Create `/etc/snmp/snmpd.conf` :

```text
SysLocation
SysContact
sysServices 72
master agentx
agentaddress udp:161
rouser snmp_user authpriv
createUser snmp_user SHA-256 snmp_auth_password AES-256 snmp_encrypt_password
```

```bash
systemctl restart snmpd
systemctl enable snmpd
```

```bash
apt install --no-install-recommends snmp
snmpwalk -v3 -r 1 -l authPriv -u snmp_user -a SHA-256 -A snmp_auth_password -x AES-256 -X snmp_encrypt_password udp:snmp_server_ip:161 .1
```

snmpwalk : tcp:snmp_server_ip:snmp_server_port
snmpd : agentaddress udp:161,tcp:161,udp6:161,tcp6:161






