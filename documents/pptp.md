
# PPTP :

---

### Ubuntu 26 :

- <https://archive.ubuntu.com/ubuntu/pool/main/p/ppp/ppp_2.5.2-1+1.2_amd64.deb>
- <https://archive.ubuntu.com/ubuntu/pool/main/p/pptp-linux/pptp-linux_1.10.0-2build1_amd64.deb>

---

```bash
dpkg-query --show --showformat='${Status}\n' ppp
dpkg --install /root/downloads/ppp.deb
dpkg-query --show --showformat='${Status}\n' pptp-linux
dpkg --install /root/downloads/pptp-linux.deb
```

Create `/etc/ppp/peers/pptp-vpn` :

```text
pty "pptp pptp_server_ip --nolaunchpppd"
name pptp_username
password pptp_password
require-mschap-v2
refuse-mschap
refuse-chap
refuse-pap
refuse-eap
defaultroute
replacedefaultroute
usepeerdns
noauth
nodetach
```

- `pptp_server_ip`
- `pptp_username`
- `pptp_password`

Create `/etc/systemd/system/pptp-vpn.service` :

```ini
[Unit]
Description=PPTP VPN
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/sbin/pppd call pptp-vpn
Restart=always
RestartSec=300

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl status pptp-vpn
systemctl start pptp-vpn
systemctl status pptp-vpn
systemctl enable pptp-vpn
```

meta nfproto ipv4 ip saddr pptp_server_ip ip protocol gre accept


