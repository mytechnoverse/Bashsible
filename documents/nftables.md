
# Nftables :

https://wiki.nftables.org/wiki-nftables/index.php/GeoIP_matching
https://wiki.nftables.org/wiki-nftables/index.php/Synproxy
https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_home_router

---

### Ubuntu 26 :

```bash
dpkg-query --show --showformat='${Status}\n' ufw
ufw status
ufw disable
systemctl status ufw
systemctl stop ufw
apt purge ufw
apt autoremove --purge
```

---

```bash
dpkg-query --show --showformat='${Status}\n' nftables 
apt install nftables
dpkg-query --show --showformat='${Status}\n' procps
apt install procps
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
        meta nfproto ipv6 drop
        ct state invalid meta nfproto ipv4 meter input-invalid-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-invalid-ipv4 : " level warning
        ct state invalid meta nfproto ipv4 counter drop
        ct state established,related accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        icmp type echo-request meter input-ping-meter-ipv4 { ip saddr limit rate 1/second } accept
        icmp type echo-request counter drop
        meta nfproto ipv4 meter input-default-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-default-ipv4 : " level warning
        meta nfproto ipv4 counter drop
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
        ct state invalid meta nfproto ipv4 meter input-invalid-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-invalid-ipv4 : " level warning
        ct state invalid meta nfproto ipv4 counter drop
        ct state invalid meta nfproto ipv6 meter input-invalid-meter-ipv6 { ip6 saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-invalid-ipv6 : " level warning
        ct state invalid meta nfproto ipv6 counter drop
        ct state established,related accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        icmp type echo-request meter input-ping-meter-ipv4 { ip saddr limit rate 1/second } accept
        icmp type echo-request counter drop
        icmpv6 type { destination-unreachable, time-exceeded, parameter-problem, packet-too-big } accept
        icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } ip6 hoplimit 255 accept
        icmpv6 type echo-request meter input-ping-meter-ipv6 { ip6 saddr limit rate 1/second } counter accept
        icmpv6 type echo-request counter drop
        meta nfproto ipv4 meter input-default-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-default-ipv4 : " level warning
        meta nfproto ipv4 counter drop
        meta nfproto ipv6 meter input-default-meter-ipv6 { ip6 saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-default-ipv6 : " level warning
        meta nfproto ipv6 counter drop
    }
    chain output {
        type filter hook output priority 0; policy accept;
        oifname "lo" accept
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
        meta nfproto ipv6 drop
        ct state invalid meta nfproto ipv4 meter input-invalid-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-invalid-ipv4 : " level warning
        ct state invalid meta nfproto ipv4 counter drop
        ct state established,related accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        icmp type echo-request meter input-ping-meter-ipv4 { ip saddr limit rate 1/second } accept
        icmp type echo-request counter drop
        meta nfproto ipv4 udp sport 67 udp dport 68 accept
        meta nfproto ipv4 meter input-default-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-default-ipv4 : " level warning
        meta nfproto ipv4 counter drop
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
        ct state invalid meta nfproto ipv4 meter input-invalid-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-invalid-ipv4 : " level warning
        ct state invalid meta nfproto ipv4 counter drop
        ct state invalid meta nfproto ipv6 meter input-invalid-meter-ipv6 { ip6 saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-invalid-ipv6 : " level warning
        ct state invalid meta nfproto ipv6 counter drop
        ct state established,related accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        icmp type echo-request meter input-ping-meter-ipv4 { ip saddr limit rate 1/second } accept
        icmp type echo-request counter drop
        icmpv6 type { destination-unreachable, time-exceeded, parameter-problem, packet-too-big } accept
        icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } ip6 hoplimit 255 accept
        icmpv6 type nd-router-advert ip6 saddr fe80::/10 ip6 hoplimit 255 accept
        icmpv6 type echo-request meter input-ping-meter-ipv6 { ip6 saddr limit rate 1/second } counter accept
        icmpv6 type echo-request counter drop
        meta nfproto ipv4 udp sport 67 udp dport 68 accept
        ip6 saddr fe80::/10 udp sport 547 udp dport 546 accept
        meta nfproto ipv4 meter input-default-meter-ipv4 { ip saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-default-ipv4 : " level warning
        meta nfproto ipv4 counter drop
        meta nfproto ipv6 meter input-default-meter-ipv6 { ip6 saddr limit rate 5/minute burst 5 packets } log prefix "nft-input-default-ipv6 : " level warning
        meta nfproto ipv6 counter drop
    }
    chain output {
        type filter hook output priority 0; policy accept;
        oifname "lo" accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
}
```

Create `/etc/nftables/conf.d/20-service-http-h2-tls-ipv4.nft` :

```text
add rule inet firewall input meta nfproto ipv4 tcp dport 22 accept
```

Create `/etc/nftables/conf.d/20-service-http-h2-tls-dual.nft` :

```text
add rule inet firewall input meta nfproto ipv4 tcp dport 22 accept
add rule inet firewall input meta nfproto ipv6 tcp dport 22 accept
```

```bash
nft --check --file /etc/nftables.conf
systemctl status nftables
systemctl start nftables
systemctl status nftables
systemctl enable nftables
nft list ruleset
watch --color --differences --interval 1 'nft list counters table inet firewall'
```

```bash
journalctl --dmesg --follow
journalctl --dmesg --grep='nftables_log_prefix' --lines=10
```












tcp connection logging : log flags tcp options
