
# TLS Certificate Authority :

```bash
dpkg-query --show --showformat='${Status}\n' ca-certificates
apt install ca-certificates
dpkg-query --show --showformat='${Status}\n' openssl
apt install openssl
mkdir -p /etc/tls/
```

Create `/root/create-tls-ca.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
ca_name=$1
ca_tld=$2
ca_tls_path="/etc/tls/${ca_name}/"
mkdir $ca_tls_path
ca_key_path="${ca_tls_path}${ca_name}.key"
ca_crt_path="${ca_tls_path}${ca_name}.crt"
crt_cn="/CN=${ca_name}"
crt_serial="0x$(openssl rand -hex 16)"
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $ca_key_path
openssl req -new -sha256 -x509 -days 365 -key $ca_key_path -out $ca_crt_path -subj $crt_cn -set_serial $crt_serial -addext 'keyUsage=critical,keyCertSign,cRLSign' \
-addext 'basicConstraints=critical,CA:TRUE,pathlen:0' -addext "nameConstraints=critical,permitted;DNS:${ca_tld}" -addext 'subjectKeyIdentifier=hash'
```

Create `/root/create-tls-cert.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
ca_name=$1
server_name=$2
ca_tls_path="/etc/tls/${ca_name}/"
ca_key_path="${ca_tls_path}${ca_name}.key"
ca_crt_path="${ca_tls_path}${ca_name}.crt"
server_tls_path="/etc/tls/${server_name}/"
mkdir $server_tls_path
server_key_path="${server_tls_path}${server_name}.key"
server_key_pass_path="${server_tls_path}${server_name}.pass"
server_key_enc_path="${server_tls_path}${server_name}.enc.key"
server_key_cred_path="${server_tls_path}${server_name}.cred"
server_csr_path="${server_tls_path}${server_name}.csr"
server_crt_path="${server_tls_path}${server_name}.crt"
server_crt_chain_path="${server_tls_path}${server_name}-fullchain.crt"
crt_cn="/CN=${server_name}"
crt_serial="0x$(openssl rand -hex 16)"
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $server_key_path
openssl rand -hex 32 > $server_key_pass_path
openssl pkcs8 -topk8 -v2 aes-256-cbc -v2prf hmacWithSHA256 -saltlen 16 -iter 600000 -in $server_key_path -out $server_key_enc_path -passout file:$server_key_pass_path
systemd-creds encrypt --name=$server_name $server_key_pass_path $server_key_cred_path
shred -u $server_key_pass_path
openssl req -new -sha256 -key $server_key_path -out $server_csr_path -subj $crt_cn
shred -u $server_key_path
crt_exts=$(cat <<EOF
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
extendedKeyUsage=serverAuth
subjectAltName=DNS:$server_name
EOF
)
openssl x509 -req -sha256 -days 365 -CA $ca_crt_path -CAkey $ca_key_path -in $server_csr_path -out $server_crt_path -set_serial $crt_serial -extfile <(printf '%s' "$crt_exts")
rm $server_csr_path
cat $server_crt_path $ca_crt_path > $server_crt_chain_path
```

```bash
bash /root/create-tls-ca.sh internal-ca internal
bash /root/create-tls-cert.sh internal-ca server_name
openssl verify -CAfile /etc/tls/internal-ca/internal-ca.crt -purpose sslserver /etc/tls/server_name/server_name.crt
```

```bash
cp /etc/tls/internal-ca/internal-ca.crt /usr/local/share/ca-certificates/
update-ca-certificates
```

