
```bash
apt install snmpd
```


comment-directives file_path directive1 directive2 ...

sysContact
sysLocation
agentaddress
view
rocommunity
rocommunity6
rouser








```bash
printf '%s\n' "0x$(openssl rand -hex 16)"
```

Create `/etc/snmp/snmpd.conf.d/00-engine-id.conf` :

```text
engineID snmp_engine_id
```

- `snmp_engine_id`

Create `/etc/snmp/snmpd.conf.d/00-udp-plain-ipv4.conf` :

```text
agentaddress udp:161
rouser snmp_user_name noauth
```

- `snmp_user_name`

Create `/etc/snmp/snmpd.conf.d/00-tcp-crypto-ipv4.conf` :

```text
agentaddress tcp:161
rouser snmp_user_name authpriv
```

- `snmp_user_name`

Create `create-snmp-user.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
snmp_auth_algorithm='SHA-256'
snmp_enc_algorithm='AES-128'
snmp_min_password_length=8
(( $# == 1 || $# == 3 ))
snmp_user_name=$1
(( $# == 3 )) && {
    snmp_auth_password=$2
    snmp_enc_password=$3
    (( ${#snmp_auth_password} >= $snmp_min_password_length ))
    (( ${#snmp_enc_password} >= $snmp_min_password_length ))
}
snmp_user_hex=$(printf '%s' $snmp_user_name | od --output-duplicates --address-radix=none --format=x1)
snmp_user_hex=${snmp_user_hex//[[:space:]]/}
snmp_state_file_path='/var/lib/snmp/snmpd.conf'
systemctl --quiet is-active snmpd && systemctl stop snmpd
grep --quiet --extended-regexp "^usmUser[[:space:]].*[[:space:]]0x${snmp_user_hex}(00)?[[:space:]]" $snmp_state_file_path && sed --in-place --regexp-extended "/^usmUser[[:space:]].*[[:space:]]0x${snmp_user_hex}(00)?[[:space:]]/d" $snmp_state_file_path
grep --quiet --extended-regexp "^createUser[[:space:]]${snmp_user_name}([[:space:]]|$)" $snmp_state_file_path && sed --in-place --regexp-extended "/^createUser[[:space:]]${snmp_user_name}([[:space:]]|$)/d" $snmp_state_file_path

if (( $# == 1 ))
then
    printf '%s\n' "createUser $snmp_user_name" >> $snmp_state_file_path
else
    printf '%s\n' "createUser $snmp_user_name $snmp_auth_algorithm $snmp_auth_password $snmp_enc_algorithm $snmp_enc_password" >> $snmp_state_file_path
fi
systemctl start snmpd
```




snmpwalk -r 1 -v3 -l authPriv -u $snmp_user_name -a $snmp_auth_algorithm -A $snmp_auth_password -x $snmp_enc_algorithm -X $snmp_enc_password snmp_transport:snmp_agent_ip .1 >/dev/null































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
systemctl status snmpd
systemctl start snmpd
systemctl status snmpd
systemctl restart snmpd
systemctl status snmpd
systemctl --quiet is-enabled snmpd || systemctl enable snmpd
```

```bash
apt install --no-install-recommends snmp
snmpwalk -r 1 -v3 -l noAuthNoPriv -u snmp_user_name udp:snmp_agent_ip .1

```




1 : ok
0 : error

Create `/usr/local/bin/check_nfs_mount.sh` :

#!/bin/bash
mount_path='/mnt/local_mount_point'
if timeout 5s ls -1f $mount_path &>/dev/null
then
    echo '1'
else
    echo '0'
fi

chmod 755 /usr/local/bin/check_nfs_mount.sh

/etc/snmp/snmpd.conf :

skipNFSInHostResources yes
extend nfs_mount_check /usr/local/bin/check_nfs_mount.sh

systemctl restart snmpd


Zabbix :

--- snmp item :

Type: SNMP agent
Key : nfs.mount.status
SNMP OID : .1.3.6.1.4.1.8072.1.3.2.4.1.2.11.110.102.115.95.109.111.117.110.116.95.99.104.101.99.107
Type : Numeric (unsigned)

--- snmp trigger :

Expression: {nfs_client_ip:snmp.nfs.mount.status.last()} = 0
Severity : High


Prefix + character length + ( nfs_mount_check ) in ASCII decimal 

.1.3.6.1.4.1.8072.1.3.2.4.1.2













