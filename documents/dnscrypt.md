
# DNSCrypt :

```bash
dpkg-query --show --showformat='${Status}\n' dnscrypt-proxy
apt install dnscrypt-proxy
dpkg-query --show --showformat='${Status}\n' bind9-dnsutils
apt install bind9-dnsutils
```

Edit `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` :

```toml
server_names = ['cloudflare']
listen_addresses = ['127.0.0.1:dnscrypt_port']
ipv4_servers = true
doh_servers = true
require_dnssec = true
require_nofilter = true
ignore_system_dns = true
ipv6_servers = false
dnscrypt_servers = false
odoh_servers = false
block_ipv6 = true
cache = true
cache_size = 4096
```

- `dnscrypt_port`
- `[query_log]`
- `[nx_log]`
- `[sources]`

```bash
dnscrypt-proxy -check -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```

```bash
systemctl daemon-reload
systemctl status dnscrypt-proxy
systemctl start dnscrypt-proxy
systemctl status dnscrypt-proxy
systemctl restart dnscrypt-proxy
systemctl status dnscrypt-proxy
systemctl enable dnscrypt-proxy
ss -lntup
dig @127.0.0.1 -p dnscrypt_port whoami.cloudflare ch txt +short
```

