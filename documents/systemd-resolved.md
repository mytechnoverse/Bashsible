
# Systemd Resolved :

```bash
dpkg-query --show --showformat='${Status}\n' systemd-resolved
apt install systemd-resolved
```

```bash
systemctl status systemd-resolved
systemctl start systemd-resolved
systemctl status systemd-resolved
systemctl enable systemd-resolved
test -L /etc/resolv.conf && readlink /etc/resolv.conf
ln --symbolic --force /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
resolvectl status
resolvectl dns eth0
getent ahostsv4 google.com
getent ahostsv6 google.com
```
