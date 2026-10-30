
```bash
dpkg-query --show --showformat='${Status}\n' openssh-server
apt install openssh-server
```

Create `/etc/ssh/sshd_config.d/00-sshd-hardening.conf` :

```sshd_config
AddressFamily inet
AllowGroups ssh_users
AuthenticationMethods password
PermitRootLogin no
DisableForwarding yes
DebianBanner no
PrintMotd no
ChannelTimeout session=15m
UnusedConnectionTimeout 1m
ClientAliveInterval 20
ClientAliveCountMax 3
Ciphers aes128-gcm@openssh.com
HostKeyAlgorithms ssh-ed25519
KexAlgorithms curve25519-sha256
MACs hmac-sha2-256-etm@openssh.com
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 1
MaxStartups 128:100:128
PerSourceMaxStartups 1
PerSourcePenalties authfail:10m noauth:10m grace-exceeded:10m refuseconnection:10m
Match Group *,!ssh_users
    RefuseConnection yes
```

```bash
sed -i '/pam_motd\.so/ { /^#/! s/^/#/ }' /etc/pam.d/sshd
sshd -t
systemctl restart ssh
systemctl status ssh
systemctl --quiet is-enabled ssh || systemctl enable ssh
```
