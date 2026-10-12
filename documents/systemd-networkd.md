
# Ethernet Interface :

```bash
ip -br addr show
ip route show
dpkg-query --show --showformat='${Status}\n' systemd
apt install systemd
dpkg-query --show --showformat='${Status}\n' iproute2
apt install iproute2
dpkg-query --show --showformat='${Status}\n' iputils-ping
apt install iputils-ping
dpkg-query --show --showformat='${Status}\n' iputils-tracepath
apt install iputils-tracepath
```

---

### Server :

Create `/etc/systemd/network/00-server.link` :

```ini
[Match]
Type=ether

[Link]
Name=eth0
```

---

### Hypervisor :

```bash
ip -br link show
```

Create `/etc/systemd/network/00-hypervisor.link` :

```ini
[Match]
MACAddress=mac_address

[Link]
Name=eth0
```

- `mac_address`

---

Create `/etc/systemd/network/10-eth0.network` :

```ini
[Match]
Name=eth0
```

```bash
mkdir /etc/systemd/network/10-ether.network.d/
```

---

### DHCP :

Create `/etc/systemd/network/10-ether.network.d/10-dhcp-ipv4.conf` :

```ini
[Network]
DHCP=ipv4
IPv6AcceptRA=no
LinkLocalAddressing=no

[DHCPv4]
UseDomains=true
ClientIdentifier=mac
```

Create `/etc/systemd/network/10-ether.network.d/10-dhcp-dual.conf` :

```ini
[Network]
DHCP=yes
IPv6AcceptRA=yes
LinkLocalAddressing=ipv6

[DHCPv4]
UseDomains=true
ClientIdentifier=mac

[DHCPv6]
UseDomains=true
DUIDType=link-layer
```

---

### Static :

Create `/etc/systemd/network/10-ether.network.d/10-static-ipv4.conf` :

```ini
[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
```

Create `/etc/systemd/network/10-ether.network.d/10-static-dual.conf` :

```ini
[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=ipv6
```

Create `/etc/systemd/network/10-ether.network.d/20-ip.conf` :

```ini
[Address]
Address=ip_address/network_prefix
```

Replace :

- `ip_address`
- `network_prefix`

Create `/etc/systemd/network/10-ether.network.d/30-route.conf` :

```ini
[Route]
Destination=network_id/network_prefix
Gateway=gateway_address
```

- `network_id`
- `network_prefix`
- `gateway_address`

Create `/etc/systemd/network/10-ether.network.d/40-dns.conf` :

```ini
[Network]
DNS=dns_address:53
```

- `dns_address`

Create `/etc/systemd/network/10-ether.network.d/50-domain.conf` :

```ini
[Network]
Domains=internal_domain
```

- `internal_domain`

---

```bash
systemctl status systemd-networkd
systemctl start systemd-networkd
systemctl status systemd-networkd
systemctl enable systemd-networkd
networkctl list
networkctl status
networkctl status eth0
ip -br addr show
ip route show
ping gateway_address
```

---

### Debian 13 :

```bash
dpkg-query --show --showformat='${Status}' ifupdown
systemctl status networking
systemctl stop networking
systemctl status networking
systemctl disable networking
systemctl status systemd-networkd
apt purge ifupdown
apt autoremove --purge
```

---

### Ubuntu 26 :

```bash
dpkg-query --show --showformat='${Status}' netplan.io
apt purge netplan.io
dpkg-query --show --showformat='${Status}' network-manager
systemctl status NetworkManager
systemctl stop NetworkManager
systemctl status NetworkManager
systemctl disable NetworkManager
systemctl status systemd-networkd
apt purge network-manager
apt autoremove --purge
```

---
