
https://deb.myguard.nl/articles/nginx-zstd-vs-brotli-vs-zlib-ng-compression/
https://github.com/myguard-labs/nginx-zstd-module
https://github.com/google/ngx_brotli
https://github.com/HanadaLee/ngx_ssl_fingerprint_module
https://tls.peet.ws/
https://httpcloak.dev/reference/presets
https://httpcloak.dev/



disable http3 ???



http3 is advertised as ( Alt-Svc ) in negotiation


nginx log ???

https://nginx.org/packages/debian/dists/trixie/nginx/source/Sources
https://nginx.org/packages/debian/pool/nginx/n/nginx

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




nginx :

server {
    ...
    location = /ja4 {
        default_type application/json;
        return 200 '{"user_agent": "$http_user_agent", "tls": {"ja4": "$ssl_fingerprint_ja4"}}';
    }
}

Golang :







https://httpcloak.dev/http-protocols/http1

generate 2 values for http1.1 and h2 for websockets




package main

import (
	"context"
	"fmt"
	"time"
	"github.com/sardanioss/httpcloak"
)

type JA4Response struct {
	UserAgent string `json:"user_agent"`
	TLS struct {
		JA4 string `json:"ja4"`
	} `json:"tls"`
}

func main() {
	targetURL := "https://xyz.internal/ja4"
	presets := []string{
		"chrome-latest-windows",
		"chrome-latest-android",
        "chrome-latest-ios",
	}
	for _, preset := range presets {
		s := httpcloak.NewSession(preset,
			httpcloak.WithSessionTimeout(20*time.Second),
		)
		ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
		resp, err := s.Get(ctx, targetURL)
		cancel()
		s.Close()
		if err != nil {
			fmt.Printf("Preset %s: Request failed: %v\n", preset, err)
			continue
		}
		var result JA4Response
		err = resp.JSON(&result)
		resp.Close()
		if err != nil {
			fmt.Printf("Preset %s: Failed to parse JSON: %v\n", preset, err)
			continue
		}
		fmt.Printf("Preset: %s\n", preset)
		fmt.Printf("JA4: %s\n", result.TLS.JA4)
		fmt.Printf("User-Agent: %s\n", result.UserAgent)
		fmt.Println("---")
	}
}












package main

import (
	"context"
	"fmt"
	"time"

	"github.com/sardanioss/httpcloak"
)

type JA4Response struct {
	UserAgent string `json:"user_agent"`
	TLS       struct {
		JA4 string `json:"ja4"`
	} `json:"tls"`
}

func main() {
	targetURL := "https://xyz.internal/ja4"

	presets := []string{
		"chrome-latest-windows",
		"chrome-latest-android",
		"chrome-latest-ios",
	}

	// Protocol variants to test: h2 (default) and h1 (forced).
	protocols := []struct {
		name string
		opts []httpcloak.SessionOption
	}{
		{"h2", nil}, // Default negotiation will pick h2 against an http2-enabled Nginx
		{"h1", []httpcloak.SessionOption{httpcloak.WithForceHTTP1()}},
	}

	for _, preset := range presets {
		for _, proto := range protocols {
			// Build session options: always set a timeout, then append protocol-specific opts.
			opts := []httpcloak.SessionOption{
				httpcloak.WithSessionTimeout(20 * time.Second),
			}
			opts = append(opts, proto.opts...)

			s := httpcloak.NewSession(preset, opts...)

			ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
			resp, err := s.Get(ctx, targetURL)
			cancel()
			s.Close()

			if err != nil {
				fmt.Printf("❌ Preset %s [%s]: Request failed: %v\n", preset, proto.name, err)
				continue
			}

			var result JA4Response
			err = resp.JSON(&result)
			resp.Close()

			if err != nil {
				fmt.Printf("❌ Preset %s [%s]: Failed to parse JSON: %v\n", preset, proto.name, err)
				continue
			}

			fmt.Printf("✅ Preset: %s\n", preset)
			fmt.Printf("   Protocol: %s\n", proto.name)
			fmt.Printf("   JA4: %s\n", result.TLS.JA4)
			fmt.Printf("   User-Agent: %s\n", result.UserAgent)
			fmt.Println("---")
		}
	}
}









































JA4 value is different for each of below combinations :
1. browser ( chrome )
2. browser version ( chrome 155 )
3. platform ( windows , android , ios )
4. http version ( first ALPN value : h2 or http1.1 )
5. presence of SNI Header ( connecting with domain or ip )
6. session resumption ( browser refresh )

normal and grpc connection use http alpn 2 and 1.1
websockets use http alpn 1.1


Since Azar 1404

Chrome versions :

desktop : 143 - 155
android : 143 - 148 , 150 -155
ios     : 143 - 148 , 150 - 152 , 155


chrome-latest-windows
chrome-latest-android
chrome-latest-ios

chrome_preset_name="chrome-${chrome_version}-${chrome_platform}"





--- Specify Source IP :

IPv4 :

httpcloak.NewSession( "chrome-latest", httpcloak.WithLocalAddress("192.168.1.100"),)
WithSessionPreferIPv4()

IPv6 :

httpcloak.NewSession( "chrome-latest", httpcloak.WithLocalAddress("2001:db8::1234"),)


--- Browser Refresh 0-RTT :

After closing response :

sess.Refresh()
resp, err := sess.Get(ctx, "https://tls.peet.ws/api/all")
if err != nil {
	panic(err)
}
defer resp.Close()

--- Preset Loop :

func main() {
    for _, name := range []string{ "chrome-latest" , "android-chrome-latest" , "chrome-latest-ios" } {
        s := httpcloak.NewSession(name)
        resp, _ := s.Get(context.Background(), "https://tls.peet.ws/api/all")
        body, _ := io.ReadAll(resp.Body)
        resp.Body.Close()
        s.Close()
        fmt.Println(name, string(body))
    }
}













go get github.com/sardanioss/httpcloak









package main

import (
	"context"
	"fmt"
	"time"
	"github.com/sardanioss/httpcloak"
)




func main() {

    preset_name='chrome-latest-windows'

	sess := httpcloak.NewSession(
        preset_name ,
		httpcloak.WithSessionTimeout(30*time.Second),
	)
	defer sess.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	resp, err := sess.Get(ctx, "https://tls.peet.ws/api/all")
	if err != nil {
		panic(err)
	}
	defer resp.Close()

	fmt.Println("status:", resp.StatusCode)

	body, _ := resp.Text()
	fmt.Println(body)
}























return json object with below sturecture in nginx :

.tls.ja4

.user_agent










```bash
apt install brotli
```

Create `compress-extensions-brotli.sh` : 

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
(( $# == 1 ))
target_directory_path=$1
[[ -d $target_directory_path ]]
command -v brotli >/dev/null
path_delimiter=$'\x1f'
target_file_paths=$(find $target_directory_path -type f \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.svg' -o -name '*.json' -o -name '*.xml' \) -printf "%p${path_delimiter}")
readarray -d "$path_delimiter" -t target_file_path_list < <(printf '%s' "$target_file_paths")
for target_file_path in "${target_file_path_list[@]}"
do
    compressed_file_path="${target_file_path}.br"
    [[ -f $compressed_file_path && $compressed_file_path -nt $target_file_path ]] || {
        rm --recursive --force $compressed_file_path
        brotli --quality=11 --stdout $target_file_path > $compressed_file_path
    }
done
```

```bash
bash compress-files-brotli.sh /var/www/html/
```





apt-get --only-source --yes build-dep nginx !!!! dont !!!!



```bash
apt update
apt install build-essential fakeroot xz-utils
apt-get --only-source source nginx
```


```bash
apt install curl
```

Create `download-github-repo.sh` :

```bash
github_repo_name=$1
github_repo_branch=$2
command -v curl >/dev/null
temp_path="$(mktemp --directory)/"
```


```bash
apt install ca-certificates
apt install --no-install-recommends git
```

Create `download-github-repo-recursive.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
(( $# >= 3 ))
repo_name=$1
repo_github_path=$2
repo_github_branch=$3
command -v git >/dev/null
[[ -s /etc/ssl/certs/ca-certificates.crt ]]
temp_path="$(mktemp --directory)/"
repo_github_url="https://github.com/${repo_github_path}"
git --quiet --single-branch --recurse-submodules clone --branch $repo_github_branch $repo_github_url $temp_path
find $temp_path -name .git -type d -prune -exec rm --recursive --force -- {} +
find $temp_path -name .git -type f -delete
repo_archive_timestamp=$(date --utc '+%Y-%m-%d_%H:%M_UTC')
repo_archive_name="${repo_name}_${repo_archive_timestamp}.tar.zst"
tar --create --zstd --file $repo_archive_name $temp_path
rm --force --recursive $temp_path
```

```bash
bash download-github-repo-recursive.sh nginx-brotli google/ngx_brotli master
```











tar --directory=DIR







#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
script_path=$(pwd)


github_repo_owner
github_repo_name
github_repo_branch

"https://github.com/${github_repo_owner}/${github_repo_name}/archive/refs/heads/${github_repo_branch}.tar.gz"

tar --extract -z --strip-components=1 -C "$dest"






ktls ????




git clone --quiet --branch master https://github.com/myguard-labs/nginx-zstd-module.git zstd
git clone --quiet --branch main https://github.com/HanadaLee/ngx_ssl_fingerprint_module ja4















nginx_path/debian/rules :

--with-stream_ssl_module and --with-http_ssl_module

--with-stream_ssl_preread_module --add-module=/literal_brotli_abs_path --add-module=/literal_zstd_abs_path --add-module=/literal_ja4_abs_path

--without-





http {
    gzip_vary on;
    map $ssl_fingerprint_ja4 $ja4_allowed {
        default 0;
        "t13d1516h2_8daaf6152771_b186095e22b6" 1;
    }
}

location /api/ {
    zstd on;
    ssl_fingerprint on;
    if ($ja4_allowed = 0) { return 403; }
}

location /static/ {
    brotli_static on;
}























patch --quiet --batch --strip=1 --directory=nginx_path < ja4_path/patches/*.patch


compile dependencies :

patch
libbrotli-dev
libzstd-dev

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

--with-http_xslt_module
--with-http_perl_module
--with-http_image_filter_module
--with-http_acme_module



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


