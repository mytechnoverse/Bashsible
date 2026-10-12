
# Nginx :

```bash
dpkg-query --show --showformat='${Status}\n' nginx
dpkg-query --show --showformat='${Version}\n' nginx
apt purge nginx
apt autoremove --purge
```

---

## Distro Repository : 

```bash
apt install nginx
rm -rf /etc/nginx/sites-available/
rm -rf /etc/nginx/sites-enabled/
sed '\|/etc/nginx/sites-enabled/\*|d' /etc/nginx/nginx.conf
```

---

## Nginx Repository :

- <https://nginx.org/keys/nginx_signing.key>

```bash
dpkg-query --show --showformat='${Status}\n' gpg
apt install --no-install-recommends gpg
gpg --dearmor --output /root/downloads/nginx-archive-keyring.pgp /root/downloads/nginx_signing.key
cp /root/downloads/nginx-archive-keyring.pgp /etc/apt/keyrings/nginx-archive-keyring.pgp
```

---

### Ubuntu 26 :

Create `/etc/apt/sources.list.d/nginx.sources` :

```text
Types: deb
URIs: https://nginx.org/packages/ubuntu
Suites: resolute
Components: nginx
Signed-By: /etc/apt/keyrings/nginx-archive-keyring.pgp
```

---

### Debian 13 :

Create `/etc/apt/sources.list.d/nginx.sources` :

```text
Types: deb
URIs: https://nginx.org/packages/ubuntu
Suites: trixie
Components: nginx
Signed-By: /etc/apt/keyrings/nginx-archive-keyring.pgp
```

---

Create `/etc/apt/preferences.d/nginx.pref` :

```text
Package: *
Pin: release o=nginx
Pin-Priority: 900
```

```bash
apt update
apt install nginx
nginx -V
rm -f /etc/nginx/conf.d/default.conf
```

---

```bash
mkdir /etc/nginx/server_name/
mkdir /etc/systemd/system/nginx.service.d/
mkdir -p /var/www/server_name/public/
cp /usr/share/nginx/html/index.html /var/www/server_name/public/
```

Create `/etc/nginx/conf.d/server_name.conf` :

```nginx
server {
    listen 80;
    server_name server_name;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    http2 on;
    server_name server_name;
    ssl_certificate /etc/tls/server_name/server_name-fullchain.crt;
    ssl_certificate_key /etc/tls/server_name/server_name.enc.key;
    ssl_password_file /run/credentials/nginx.service/server_name;
    ssl_protocols TLSv1.2 TLSv1.3;
    include /etc/nginx/server_name/*.conf;
    location / {
        root /var/www/server_name/public;
        index index.html;
    }
}
```

Create `/etc/systemd/system/nginx.service.d/server_name.conf` :

```ini
[Service]
LoadCredentialEncrypted=server_name:/etc/tls/server_name/server_name.cred
```

```bash
systemctl daemon-reload
systemctl status nginx
systemctl start nginx
systemctl status nginx
systemctl restart nginx
systemctl status nginx
systemctl enable nginx
ss -lntup
```
















Create `/etc/nftables/conf.d/11-nginx.nft` :

```text
add rule inet filter input tcp dport 80 accept
add rule inet filter input tcp dport 443 accept
```

```bash
nft --check --file /etc/nftables.conf 
nft --file /etc/nftables.conf
nft list ruleset
```

















