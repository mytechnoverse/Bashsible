
```bash
dpkg-query --show --showformat='${Status}\n' systemd-timesyncd
apt purge systemd-timesyncd
apt autoremove --purge
dpkg-query --show --showformat='${Status}\n' ca-certificates
apt install ca-certificates
dpkg-query --show --showformat='${Status}\n' systemd
apt install systemd
timedatectl set-timezone Etc/UTC
timedatectl set-local-rtc 0
dpkg-query --show --showformat='${Status}\n' chrony
apt install chrony
```


server : nts + chrony + static
clients : normal + chrony + dhcp and static

---

### Ubuntu 26 :

rm -rf /etc/chrony/sources.d/*
rm -rf /etc/chrony/conf.d/*

---

use debian default chrony.conf +

Overwrite `/etc/chrony/chrony.conf` :

```text
port 0
include /etc/chrony/chrony.d/*.conf
```

Create `/etc/chrony/chrony.d/static.conf` :

```text
authselectmode require
sourcedir /etc/chrony/sources.d/
```

Create `/etc/chrony/chrony.d/dhcp.conf` :

```text
sourcedir /run/chrony-dhcp
```

Create `/etc/chrony/sources.d/00-nts-static-ipv4.sources` : 

```text
server time.cloudflare.com iburst nts ipv4
server ntp.ubuntu.com iburst nts ipv4
```

Create `/etc/chrony/sources.d/00-nts-static-dual.sources` : 

```text
server time.cloudflare.com iburst nts
pool ntp.ubuntu.com iburst nts
```

systemctl status chrony
systemctl start chrony
systemctl status chrony
systemctl restart chrony
systemctl status chrony

chronyc tracking
chronyc -N sources
chronyc -N authdata





https://ubuntu.com/server/docs/how-to/networking/serve-ntp-with-chrony/


[DHCPv4]
UseNTP=yes

[DHCPv6]
UseNTP=yes







