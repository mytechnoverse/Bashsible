
# Nftables :

---

### Ubuntu :

```bash
ufw status
ufw disable
systemctl status ufw
systemctl stop ufw
systemctl status ufw
apt purge ufw
apt autoremove --purge
```

---

MaxAuthTries 6 -> 3
nginx rate limiting per ip

```bash
dpkg-query --show --showformat='${Status}\n' nftables
apt install nftables
mkdir -p /etc/nftables/conf.d/
```

Overwrite `/etc/nftables.conf` :

```text
#!/usr/sbin/nft --file
table inet firewall
delete table inet firewall
include "/etc/nftables/conf.d/*.nft"
```

Create `/etc/nftables/conf.d/00-server-static-ipv4.nft` :

```text
table inet firewall {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state invalid drop
        ct state established,related accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        ip protocol icmp icmp type echo-request limit rate 1/second burst 5 packets accept
    }
    chain output {
        type filter hook output priority 0; policy accept;
        oifname "lo" accept
        meta nfproto ipv6 drop
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
}
```

Create `/etc/nftables/conf.d/00-server-static-dual.nft` :

```text
table inet firewall {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state invalid drop
        ct state established,related accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        ip protocol icmp icmp type echo-request limit rate 1/second burst 5 packets accept
        icmpv6 type { destination-unreachable, time-exceeded, parameter-problem, packet-too-big } accept
        icmpv6 type echo-request limit rate 1/second burst 5 packets accept
        icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } ip6 hoplimit 255 accept
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
}
```

Create `/etc/nftables/conf.d/00-server-dhcp-ipv4.nft` :

```text
table inet firewall {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state invalid drop
        ct state established,related accept
        meta nfproto ipv4 udp sport 67 udp dport 68 accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        ip protocol icmp icmp type echo-request limit rate 1/second burst 5 packets accept
    }
    chain output {
        type filter hook output priority 0; policy accept;
        oifname "lo" accept
        meta nfproto ipv6 drop
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
}
```

Create `/etc/nftables/conf.d/00-server-dhcp-dual.nft` :

```text
table inet firewall {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state invalid drop
        ct state established,related accept
        meta nfproto ipv4 udp sport 67 udp dport 68 accept
        ip6 saddr fe80::/10 udp sport 547 udp dport 546 accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        ip protocol icmp icmp type echo-request limit rate 1/second burst 5 packets accept
        icmpv6 type { destination-unreachable, time-exceeded, parameter-problem, packet-too-big } accept
        icmpv6 type echo-request limit rate 1/second burst 5 packets accept
        icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } ip6 hoplimit 255 accept
        icmpv6 type nd-router-advert ip6 saddr fe80::/10 ip6 hoplimit 255 accept
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
}
```

Create `/etc/nftables/conf.d/20-service-ssh-ipv4.nft` :

```text
add rule inet firewall input meta nfproto ipv4 tcp dport 22 accept
```

```bash
nft --check --file /etc/nftables.conf 
nft --file /etc/nftables.conf
nft list ruleset
systemctl status nftables
systemctl start nftables
systemctl status nftables
systemctl enable nftables
```
