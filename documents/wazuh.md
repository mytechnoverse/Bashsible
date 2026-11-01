
- <https://packages.wazuh.com/key/GPG-KEY-WAZUH>

Create `/etc/sysctl.d/60-loopback-dnat.conf` :

```text
net.ipv4.conf.ethernet_interface_name.route_localnet = 1
```

- `ethernet_interface_name`

```bash
sysctl --system
```

Create `/etc/nftables.conf` :

```text
#!/usr/sbin/nft -f
table inet firewall
delete table inet firewall
table inet firewall {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        iifname ethernet_interface_name udp dport 514 dnat to 127.0.0.1:514
    }
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        ct state invalid drop
        ct state established,related meta nfproto ipv4 accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        ip protocol icmp icmp type echo-request limit rate 1/second burst 5 packets accept
        meta nfproto ipv4 tcp dport 22 accept
        meta nfproto ipv4 tcp dport 443 accept
        meta nfproto ipv4 udp sport 67 udp dport 68 accept
        ip daddr 127.0.0.1 udp dport 514 accept
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

- `ethernet_interface_name`


```bash
nft flush ruleset
nft --check --file /etc/nftables.conf
nft --file /etc/nftables.conf
nft list ruleset
```

Create `/etc/nginx/nginx.conf` :

```nginx
server {
    listen 80;
    server_name wazuh-dashboard.internal;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;
    http2 on;
    server_name wazuh-dashboard.internal;
    ssl_certificate /etc/nginx/ssl/wazuh-dashboard.internal.crt;
    ssl_certificate_key /etc/nginx/ssl/wazuh-dashboard.internal.key;
    ssl_protocols TLSv1.3;
    ssl_conf_command Curves X25519;
    ssl_conf_command Ciphersuites TLS_AES_128_GCM_SHA256;
    location / {
        proxy_pass http://127.0.0.1:5601;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_set_header Authorization $http_authorization;
        proxy_set_header securitytenant $http_securitytenant;
    }
}
```


securityadmin.sh script applies config files under ( /etc/wazuh-indexer/opensearch-security/ ) using admin certificate to the indexer http .
the indexer http should be operating with ssl to be able to recieve the admin cert to apply the config files under ( /etc/wazuh-indexer/opensearch-security/ ) .
indexer's ( opensearch.yml ) is applied directly by indexer service restart .
i should generate the indexer-http-1.internal cert
run indexer with that cert
apply the config using securityadmin.sh
then disable indexer http ssl using ( opensearch.yml ) and restart its service
this way indexer http can work without ssl until next time that i need to apply another config . 

















certificate pairs :

root-ca


1 --- 

subjectAltName = IP:127.0.0.1


2 --- indexer-transport :

indexer config :

plugins.security.nodes_dn : CN=wazuh-indexer-transport-1.internal 

certificate properties :

CN=wazuh-indexer-transport-1.internal 

basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth, serverAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = DNS:wazuh-indexer-transport-1.internal

openssl verify -CAfile ca.crt -purpose sslserver indexer-transport.crt
openssl verify -CAfile ca.crt -purpose sslclient indexer-transport.crt

3 --- indexer-admin :

indexer config :

plugins.security.authcz.admin_dn : CN=wazuh-indexer-admin.internal

certificate properties :

CN = wazuh-indexer-admin.internal

basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

openssl verify -CAfile ca.crt -purpose sslclient indexer-admin.crt


















```bash
apt install --no-install-recommends gpg
gpg --dearmor --output wazuh-archive-keyring.pgp wazuh.key
cp wazuh-archive-keyring.pgp /etc/apt/keyrings/
```

Create `/etc/apt/sources.list.d/wazuh.sources` :

```text
Types: deb
URIs: https://packages.wazuh.com/4.x/apt
Suites: stable
Components: main
Signed-By: /etc/apt/keyrings/wazuh-archive-keyring.pgp
```

```bash
apt update
apt install wazuh-indexer
```

systemctl daemon-reload
systemctl enable wazuh-indexer.service
systemctl start wazuh-indexer.service




















plugins/opensearch-security/tools/hash.sh

config/opensearch-security/internal_users.yml :

plugins/opensearch-security/tools/securityadmin.sh -cd "config/opensearch-security" -icl -key "../kirk-key.pem" -cert "../kirk.pem" -cacert "../root-ca.pem" -nhnv









Edit `/etc/wazuh-indexer/opensearch.yml` :

discovery.type: single-node
plugins.security.ssl.http.enabled: false


systemctl restart wazuh-indexer











curl -u admin:admin_password http://localhost:9200 

curl http://localhost:5601/


filebeat.yml :

output.elasticsearch:
  hosts: ["http://127.0.0.1:9200"]

/etc/wazuh-dashboard/opensearch_dashboards.yml :

server.host: "127.0.0.1"
server.port: 5601
server.ssl.enabled: false
opensearch.hosts: http://127.0.0.1:9200
opensearch.ssl.verificationMode: none
opensearch_security.cookie.secure: true
opensearch.requestHeadersWhitelist: ["securitytenant","Authorization"]
opensearch_security.multitenancy.enabled: false
opensearch_security.readonly_mode.roles: ["kibana_read_only"]


systemctl restart wazuh-dashboard



wazuh manager required services :

wazuh-remoted
wazuh-analysisd
wazuh-db
wazuh-apid

/var/ossec/etc/ossec.conf :

remove below blocks :

<agentless></agentless>
<localfile>
<wodle>
<syslog_output>

edit or add below blocks :

<auth>
  <disabled>yes</disabled>
</auth>
<cluster>
  <disabled>yes</disabled>
</cluster>
<integrator>
  <disabled>yes</disabled>
</integrator>
<syscheck>
  <disabled>yes</disabled>
</syscheck>
<global>
  <email_notification>no</email_notification>
</global>
<active-response>
  <disabled>yes</disabled>
</active-response>
<monitord>
  <monitor_agents>0</monitor_agents>
</monitord>

<remote>
  <connection>syslog</connection>
  <port>514</port>
  <protocol>udp</protocol>
  <allowed-ips>0.0.0.0/0</allowed-ips>
  <ipv6>no</ipv6>
</remote>

systemctl restart wazuh-manager

/var/ossec/bin/wazuh-control status





















































===============================================================================================

https://docs.opensearch.org/2.19/about/
https://github.com/wazuh/wazuh/issues/32640#1

opensearch dashboard reverse proxy :

if dashboard didnt set the ( Secure ) in response , set cookie manually in nginx .
Network Tab -> Response Headers -> Set-Cookie
else in nginx : ( proxy_cookie_flags security_authentication secure; )

#!/usr/sbin/nft -f
table inet firewall
delete table inet firewall
table inet firewall {
    chain input {
        type filter hook input priority filter;
        policy drop;
        iifname "lo" accept
        ct state invalid drop
        ct state established,related meta nfproto ipv4 accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        ip protocol icmp icmp type echo-request limit rate 1/second burst 5 packets accept
        meta nfproto ipv4 tcp dport 22 accept
        meta nfproto ipv4 udp sport 67 udp dport 68 accept
    }
    chain output {
        type filter hook output priority filter;
        policy accept;
        oifname "lo" accept
        meta nfproto ipv6 drop
    }
    chain forward {
        type filter hook forward priority filter;
        policy drop;
    }
}

opensearch indexer reverse proxy :

config.yml :

_meta:
  type: "config"
  config_version: 2

config:
  dynamic:
    http:
      anonymous_auth_enabled: false
      xff:
        enabled: true
        internalProxies: '127.0.0.1'
        remoteIpHeader: 'x-forwarded-for'

server {
    listen 443 ssl;
    server_name wazuh-indexer.internal;
    ssl_certificate     /etc/nginx/ssl/wazuh-indexer.internal.crt;
    ssl_certificate_key /etc/nginx/ssl/wazuh-indexer.internal.key;
    location / {
        proxy_pass http://127.0.0.1:9200;
        proxy_set_header Host              $host;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header Authorization $http_authorization;
    }
}

