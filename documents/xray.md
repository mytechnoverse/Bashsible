
# Xray :

### Xray Install :

- <https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip>

```bash
dpkg-query --show --showformat='${Status}\n' socat
apt install socat
dpkg-query --show --showformat='${Status}\n' unzip
apt install unzip
```

```bash
mkdir -p /root/downloads/
unzip /root/downloads/xray.zip xray -d /root/downloads/
cp /root/downloads/xray /usr/bin/xray
```

```bash
mkdir -p /etc/xray/conf.d/
```

Create `/etc/xray/conf.d/00-log.json` :

```json
{
    "log": {
        "loglevel": "warning" ,
        "dnsLog": true
    }
}
```

Create `/etc/systemd/system/xray.service` :

```ini
[Unit]
Description=xray
After=network.target nss-lookup.target

[Service]
User=nobody
NoNewPrivileges=true
ExecStart=/usr/bin/xray run --confdir /etc/xray/conf.d/
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
```

### Xray Server :

```bash
mkdir -p /usr/share/xray/nginx/
```

Create `/usr/share/xray/nginx/nginx-xray-websocket.conf` :

```nginx
location = /xray_path/websocket {
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass http://127.0.0.1:xray_port;
}
```

Create `/usr/share/xray/nginx/nginx-xray-httpupgrade.conf` :

```nginx
location = /xray_path/httpupgrade {
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass http://127.0.0.1:xray_port;
}
```

Create `/usr/share/xray/nginx/nginx-xray-grpc.conf` :

```nginx
location /xray_path/grpc/ {
    grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    client_max_body_size 0;
    client_body_timeout 3600s;
    grpc_read_timeout 3600s;
    grpc_send_timeout 3600s;
    grpc_pass grpc://127.0.0.1:xray_port;
}
```

Create `/usr/share/xray/nginx/nginx-xray-xhttp-stream-one.conf` :

```nginx
location /xray_path/xhttp-stream-one/ {
    grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    client_max_body_size 0;
    client_body_timeout 3600s;
    grpc_read_timeout 3600s;
    grpc_send_timeout 3600s;
    grpc_pass grpc://127.0.0.1:xray_port;
}
```

Create `/usr/share/xray/nginx/nginx-xray-xhttp-stream-up.conf` :

```nginx
location /xray_path/xhttp-stream-up/ {
    grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    client_max_body_size 0;
    client_body_timeout 3600s;
    grpc_read_timeout 3600s;
    grpc_send_timeout 3600s;
    grpc_pass grpc://127.0.0.1:xray_port;
}
```

Create `/usr/share/xray/nginx/nginx-xray-xhttp-packet-up.conf` :

```nginx
location /xray_path/xhttp-packet-up/ {
    grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    client_max_body_size 0;
    client_body_timeout 3600s;
    grpc_read_timeout 3600s;
    grpc_send_timeout 3600s;
    grpc_pass grpc://127.0.0.1:xray_port;
}
```

```bash
cp /usr/share/xray/nginx/nginx-xray-xhttp-stream-up.conf /etc/nginx/server_name/
xray_path=$(openssl rand -hex 16)
```

Edit `/etc/nginx/server_name/conf.d/xray-xhttp-stream-up.conf` :

- `xray_path`
- `xray_port`

```bash
systemctl restart nginx
systemctl status nginx
```

Create `/etc/xray/conf.d/10-dns-server.json` :

```json
{
    "dns": {
        "disableCache": true ,
        "servers": [
            {
                "address": "127.0.0.1",
                "port": dnscrypt_port
            }
        ]
    }
}
```

- `dnscrypt_port`

Create `/etc/xray/conf.d/30-outbound-server.json` :

```json
{
    "outbounds": [
        {
            "tag": "direct",
            "protocol": "freedom",
            "streamSettings": {
                "sockopt": {
                    "domainStrategy": "UseIP"
                }
            }
        },
        {
            "tag": "block",
            "protocol": "blackhole",
            "settings": {
                "response": {
                    "type": "none"
                }
            }
        }
    ]
}
```

Create `/etc/xray/conf.d/40-routing-server.json` :

```json
{
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "outboundTag": "direct" ,
                "inboundTag": "tunnel"
            }
        ]
    }
}
```

```bash
mkdir -p /usr/share/xray/transports/
```

Create `/usr/share/xray/transports/20-inbound-server-websocket.json` :

```json
{
    "inbounds": [
        {
            "tag": "tunnel",
            "listen": "127.0.0.1",
            "port": xray_port ,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/xray_path/websocket"
                },
                "sockopt": {
                    "trustedXForwardedFor": [
                        "127.0.0.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/20-inbound-server-httpupgrade.json` :

```json
{
    "inbounds": [
        {
            "tag": "tunnel",
            "listen": "127.0.0.1",
            "port": xray_port ,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "httpupgrade",
                "security": "none",
                "httpupgradeSettings": {
                    "path": "/xray_path/httpupgrade"
                },
                "sockopt": {
                    "trustedXForwardedFor": [
                        "127.0.0.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/20-inbound-server-grpc.json` :

```json
{
    "inbounds": [
        {
            "tag": "tunnel",
            "listen": "127.0.0.1",
            "port": xray_port ,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "grpc",
                "security": "none",
                "grpcSettings": {
                    "serviceName": "xray_path/grpc"
                },
                "sockopt": {
                    "trustedXForwardedFor": [
                        "127.0.0.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/20-inbound-server-xhttp-stream-one.json` :

```json
{
    "inbounds": [
        {
            "tag": "tunnel",
            "listen": "127.0.0.1",
            "port": xray_port ,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "xhttp",
                "security": "none",
                "xhttpSettings": {
                    "path": "/xray_path/xhttp-stream-one",
                    "mode": "stream-one"
                },
                "sockopt": {
                    "trustedXForwardedFor": [
                        "127.0.0.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/20-inbound-server-xhttp-stream-up.json` :

```json
{
    "inbounds": [
        {
            "tag": "tunnel",
            "listen": "127.0.0.1",
            "port": xray_port ,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "xhttp",
                "security": "none",
                "xhttpSettings": {
                    "path": "/xray_path/xhttp-stream-up",
                    "mode": "stream-up"
                },
                "sockopt": {
                    "trustedXForwardedFor": [
                        "127.0.0.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/20-inbound-server-xhttp-packet-up.json` :

```json
{
    "inbounds": [
        {
            "tag": "tunnel",
            "listen": "127.0.0.1",
            "port": xray_port ,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": ""
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "xhttp",
                "security": "none",
                "xhttpSettings": {
                    "path": "/xray_path/xhttp-packet-up",
                    "mode": "packet-up"
                },
                "sockopt": {
                    "trustedXForwardedFor": [
                        "127.0.0.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/30-outbound-client-websocket.json` :

```json
{
    "outbounds": [
        {
            "tag": "tunnel",
            "protocol": "vless",
            "targetStrategy": "AsIs",
            "settings": {
                "address": "server_name",
                "port": 443,
                "id": "",
                "encryption": "none"
            },
            "streamSettings": {
                "network": "websocket",
                "wsSettings": {
                    "path": "/xray_path/websocket"
                },
                "security": "tls",
                "tlsSettings": {
                    "serverName": "server_name",
                    "fingerprint": "chrome",
                    "allowInsecure": false ,
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "alpn": [
                        "http/1.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/30-outbound-client-httpupgrade.json` :

```json
{
    "outbounds": [
        {
            "tag": "tunnel",
            "protocol": "vless",
            "targetStrategy": "AsIs",
            "settings": {
                "address": "server_name",
                "port": 443,
                "id": "",
                "encryption": "none"
            },
            "streamSettings": {
                "network": "httpupgrade",
                "httpupgradeSettings": {
                    "path": "/xray_path/httpupgrade"
                },
                "security": "tls",
                "tlsSettings": {
                    "serverName": "server_name",
                    "fingerprint": "chrome",
                    "allowInsecure": false ,
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "alpn": [
                        "http/1.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/30-outbound-client-grpc.json` :

```json
{
    "outbounds": [
        {
            "tag": "tunnel",
            "protocol": "vless",
            "targetStrategy": "AsIs",
            "settings": {
                "address": "server_name",
                "port": 443,
                "id": "",
                "encryption": "none"
            },
            "streamSettings": {
                "network": "grpc",
                "grpcSettings": {
                    "serviceName": "xray_path/grpc"
                },
                "security": "tls",
                "tlsSettings": {
                    "serverName": "server_name",
                    "fingerprint": "chrome",
                    "allowInsecure": false ,
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "alpn": [
                        "h2" ,
                        "http/1.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/30-outbound-client-xhttp-stream-one.json` :

```json
{
    "outbounds": [
        {
            "tag": "tunnel",
            "protocol": "vless",
            "targetStrategy": "AsIs",
            "settings": {
                "address": "server_name",
                "port": 443,
                "id": "",
                "encryption": "none"
            },
            "streamSettings": {
                "network": "xhttp",
                "xhttpSettings": {
                    "path": "/xray_path/xhttp-stream-one",
                    "mode": "stream-one"
                },
                "security": "tls",
                "tlsSettings": {
                    "serverName": "server_name",
                    "fingerprint": "chrome",
                    "allowInsecure": false ,
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "alpn": [
                        "h2" ,
                        "http/1.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/30-outbound-client-xhttp-stream-up.json` :

```json
{
    "outbounds": [
        {
            "tag": "tunnel",
            "protocol": "vless",
            "targetStrategy": "AsIs",
            "settings": {
                "address": "server_name",
                "port": 443,
                "id": "",
                "encryption": "none"
            },
            "streamSettings": {
                "network": "xhttp",
                "xhttpSettings": {
                    "path": "/xray_path/xhttp-stream-up",
                    "mode": "stream-up"
                },
                "security": "tls",
                "tlsSettings": {
                    "serverName": "server_name",
                    "fingerprint": "chrome",
                    "allowInsecure": false ,
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "alpn": [
                        "h2" ,
                        "http/1.1"
                    ]
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/transports/30-outbound-client-xhttp-packet-up.json` :

```json
{
    "outbounds": [
        {
            "tag": "tunnel",
            "protocol": "vless",
            "targetStrategy": "AsIs",
            "settings": {
                "address": "server_name",
                "port": 443,
                "id": "",
                "encryption": "none"
            },
            "streamSettings": {
                "network": "xhttp",
                "xhttpSettings": {
                    "path": "/xray_path/xhttp-packet-up",
                    "mode": "packet-up"
                },
                "security": "tls",
                "tlsSettings": {
                    "serverName": "server_name",
                    "fingerprint": "chrome",
                    "allowInsecure": false ,
                    "minVersion": "1.2",
                    "maxVersion": "1.3",
                    "alpn": [
                        "h2" ,
                        "http/1.1"
                    ]
                }
            }
        }
    ]
}
```




```bash
cp /usr/share/xray/transports/20-inbound-server-xhttp-stream-up.json /etc/xray/conf.d/
xray_id=$(xray uuid)

cp /usr/share/xray/transports/30-outbound-client-xhttp-stream-up.json /var/www/server_name/



```

Edit `/etc/xray/conf.d/20-inbound-server-xhttp-stream-up.json` :

- `xray_port`
- `settings.clients.id`
- `xray_path`


Edit `/etc/xray/conf.d/30-outbound-client-xhttp-stream-up.json` :

- `settings.id`
- `xray_path`
- `server_name`












```bash
xray run --confdir /etc/xray/conf.d/ --test
systemctl status xray 
systemctl start xray
systemctl status xray 
systemctl enable xray
ss -lntup
tar -c -f /root/xray-client.tar -C /root/xray-client/ xray-id.txt -C /root/tls/internal-ca/ internal-ca.crt
```

# Xray Client :

Create `/etc/nftables/conf.d/11-xray-client.nft` :

```text
add rule inet filter input tcp dport 8080 accept
```

Append `/etc/hosts` :

```text
xray_server_ip xyz.internal
```

Replace :

- `xray_server_ip`

```bash
ping xyz.internal
sftp root@xyz.internal
get xray-client.tar
mkdir /root/xray-client/
tar -x -f xray-client.tar -C /root/xray-client/

curl https://xyz.internal/index.html
```

Create `/etc/xray/conf.d/31-outbound-client-direct.json` :

```json
{
    "outbounds": [
        {
            "tag": "direct" ,
            "protocol": "freedom",
            "streamSettings": {
                "sockopt": {
                    "domainStrategy": "AsIs"
                }
            }
        },
        {
            "tag": "block",
            "protocol": "blackhole",
            "settings": {
                "response": {
                    "type": "none"
                }
            }
        }
    ]
}
```

Create `/usr/share/xray/conf.d/20-inbound-client.json` :

```json
{
    "inbounds": [
        {
            "tag": "http-proxy",
            "protocol": "http",
            "port": 8080 ,
            "settings": {
                "allowTransparent": false ,
                "accounts": [
                    {
                        "user": "user2",
                        "pass": "222"
                    }
                ]
            }
        }
    ]
}
```

Create `/usr/share/xray/conf.d/40-routing-client-split-tunneling.json` :

```json
{
    "routing": {
        "domainStrategy": "AsIs" ,
        "rules": [
            {
                "outboundTag": "direct" ,
                "domain": [
                    "domain:abc.com",
                    "full:api.abc.com"
                ]
            },
            {
                "outboundTag": "direct" ,
                "ip": [
                    "10.0.0.0/8" ,
                    "172.16.0.0/12" ,
                    "192.168.0.0/16" ,
                    "100.64.0.0/10" ,
                    "169.254.0.0/16"
                ]
            },
            {
                "outboundTag": "tunnel" ,
                "inboundTag": "http-proxy"
            }
        ]
    }
}
```

cp /usr/share/xray/conf.d/40-routing-client-split-tunneling.json /etc/xray/conf.d/

- `domain`
- `ip`

cp /usr/share/xray/conf.d/20-inbound-client.json /etc/xray/conf.d/

- `settings.accounts`

```bash
cp /usr/share/xray/transports/30-outbound-client-websocket.json /etc/xray/conf.d/
cat /root/xray-client/xray-id.txt
```

Edit `/etc/xray/conf.d/30-outbound-client-websocket.json` :

Place :

- `settings.id`

```bash
xray run --confdir /etc/xray/conf.d/ --test
systemctl status xray 
systemctl start xray
systemctl status xray 
systemctl enable xray
ss -lntup
curl -v -x http://user2:222@127.0.0.1:8080 https://api.ipify.org
```

### Xray Tunneling :

Create `/etc/systemd/system/proxy-tunnel.service` :

```ini
[Unit]
Description=syslog proxy tunnel
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP-LISTEN:6514,bind=127.0.0.1,reuseaddr,fork PROXY:127.0.0.1:rsyslog.internal:6514,proxyport=8080
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl status proxy-tunnel
systemctl start proxy-tunnel
systemctl status proxy-tunnel
systemctl enable proxy-tunnel
```

# Further Reading : 

- <https://github.com/XTLS/Xray-examples/tree/main/VLESS-WSS-Nginx>
- <https://github.com/XTLS/Xray-examples/tree/main/VLESS-TLS-SplitHTTP-CaddyNginx>
- <https://github.com/XTLS/Xray-examples/tree/main/VLESS-XHTTP3-Nginx>
- <https://github.com/XTLS/Xray-examples/tree/main/VLESS-GRPC>
- <https://github.com/XTLS/Xray-examples/tree/main/All-in-One-fallbacks-Nginx>
- <https://github.com/XTLS/Xray-examples/tree/main/Trojan-gRPC-Caddy2%EF%BC%8FNginx>
- <https://github.com/lxhao61/integrated-examples/tree/main/Xray(VLESS%2BXHTTP)%2BNginx%5CCaddy>
- <https://github.com/lxhao61/integrated-examples/tree/main/Xray(M%2BH%2BK%2BA)%2BNginx>
- <https://github.com/lxhao61/integrated-examples/tree/main/Xray(M%2BF%2BH%2BK%2BA)%2BNginx>
- <https://github.com/lxhao61/integrated-examples/blob/main/Xray(E%2BH%2BA)%2BNginx/>
- <https://github.com/lxhao61/integrated-examples/blob/main/Xray(E%2BF%2BH%2BA)%2BNginx/>
- <https://github.com/chika0801/Xray-examples/tree/main/VLESS-WebSocket_or_HTTPUpgrade-TLS>
- <https://github.com/chika0801/Xray-examples/tree/main/VLESS-gRPC-TLS>