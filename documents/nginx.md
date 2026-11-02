
https://deb.myguard.nl/articles/nginx-zstd-vs-brotli-vs-zlib-ng-compression/
https://github.com/myguard-labs/nginx-zstd-module
https://github.com/google/ngx_brotli



https://nginx.org/packages/debian/dists/trixie/nginx/source/Sources
https://nginx.org/packages/debian/pool/nginx/n/nginx


https://nginx.org/packages/debian/pool/nginx/n/nginx/nginx_1.30.6.orig.tar.gz
https://nginx.org/packages/debian/pool/nginx/n/nginx/nginx_1.30.6-1~trixie.debian.tar.xz

# Nginx :

```bash
dpkg-query --show --showformat='${Status}\n' nginx
dpkg-query --show --showformat='${Version}\n' nginx
apt purge nginx
apt autoremove --purge
```

- <https://nginx.org/keys/nginx_signing.key>

```bash
dpkg-query --show --showformat='${Status}\n' gpg
apt install --no-install-recommends gpg
gpg --dearmor --output nginx-archive-keyring.pgp nginx.key
cp nginx-archive-keyring.pgp /etc/apt/keyrings/
```

---

### Ubuntu 26 :

Create `/etc/apt/sources.list.d/nginx.sources` :

```text
Types: deb-src
URIs: https://nginx.org/packages/ubuntu
Suites: resolute
Components: nginx
Signed-By: /etc/apt/keyrings/nginx-archive-keyring.pgp
```

---

### Debian 13 :

Create `/etc/apt/sources.list.d/nginx.sources` :

```text
Types: deb-src
URIs: https://nginx.org/packages/debian
Suites: trixie
Components: nginx
Signed-By: /etc/apt/keyrings/nginx-archive-keyring.pgp
```

---

```bash
apt update
apt install build-essential fakeroot xz-utils
apt-get --only-source --download-only source nginx
apt-get --only-source --yes build-dep nginx
```





apt install cmake ca-certificates libzstd-dev
apt install --no-install-recommends git

git clone --recurse-submodules https://github.com/google/ngx_brotli brotli
git clone https://github.com/myguard-labs/nginx-zstd-module.git zstd


nginx_path/debian/rules :

--with-stream_ssl_preread_module --add-module=/literal_brotli_abs_path --add-module=/literal_zstd_abs_path







nginx :

( .br ) extension files


nginx.conf :

server {} , location {} :

brotli_static on

















nginx build dependencies :

debhelper
quilt
lsb-release
libssl-dev
libpcre2-dev
zlib1g-dev

required modules :

njs : libedit-dev , libxml2-dev , libxslt1-dev
geo ip : libgeoip-dev

uneeded modules :

xslt : libxslt1-dev
perl : libperl-dev
telemetry : cmake , libre2-dev , libc-ares-dev , pkgconf
image filter : libgd-dev
acme : clang





disable the build dependency check for dpkg-buildpackage




#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
script_path=$(pwd)
(( $# >= 2 ))
control_file_name=$1
brotli_archive_name=$2
zstd_archive_name=$3
[[ -f $control_file_name ]]
[[ -f $brotli_archive_name ]]
temp_path="$(mktemp --directory)/"


git clone and then create tar archive from zstd and brotli 

decompress archives to their own temp paths  

nginx_path="$(mktemp --directory)/"
brotli_path="$(mktemp --directory)/"
zstd_path="$(mktemp --directory)/"












source_path="${temp_path}source"
dpkg-source --extract $control_file_name $source_path
( cd $source_path && dpkg-checkbuilddeps )
dpkg-buildpackage --build=binary --unsigned-changes --unsigned-source $source_path
temp_path_files=$(find $temp_path -maxdepth 1 -type f -name '*.deb' -print)
readarray -t temp_path_files_list < <(printf '%s' "temp_path_files")
for this_deb_package_path in "${temp_path_files_list[@]}"
do
    cp $this_deb_package_path $script_path
done
rm --force --recursive $temp_path





nginx_*.deb
nginx-module-njs_*.deb
nginx-module-geoip_*.deb





nginx -V 2>&1 | tr ' ' '\n' | grep -E 'stream_ssl_preread|brotli|zstd'











```bash
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
systemctl --quiet is-enabled nginx || systemctl enable nginx
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





dpkg-query --show --showformat='${Status}\n' dpkg-dev
apt install --no-install-recommends dpkg-dev

--with-stream_ssl_preread_module

L4 SNI routing
TLS Passthrough




map $ssl_preread_server_name $name {
    backend.example.com      backend;
    default                  backend2;
}

upstream backend {
    server 192.168.0.1:12345;
    server 192.168.0.2:12345;
}

upstream backend2 {
    server 192.168.0.3:12345;
    server 192.168.0.4:12345;
}

server {
    listen      12346;
    proxy_pass  $name;
    ssl_preread on;
}





Create `/etc/apt/preferences.d/nginx.pref` :

```text
Package: *
Pin: release o=nginx
Pin-Priority: 900
```



## Distro Repository : 

```bash
apt install nginx
rm -rf /etc/nginx/sites-available/
rm -rf /etc/nginx/sites-enabled/
sed '\|/etc/nginx/sites-enabled/\*|d' /etc/nginx/nginx.conf
```


