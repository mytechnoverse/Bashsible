
```bash
dpkg-query --show --showformat='${Status}\n' openssh-server
apt install openssh-server
```

Create `/etc/ssh/sshd_config.d/00-sshd-hardening.conf` :

```sshd_config
AddressFamily inet
AllowGroups ssh_users
AuthenticationMethods password
PermitRootLogin no
DisableForwarding yes
DebianBanner no
PrintMotd no
ChannelTimeout session=15m
UnusedConnectionTimeout 1m
ClientAliveInterval 20
ClientAliveCountMax 3
Ciphers aes128-gcm@openssh.com
HostKeyAlgorithms ssh-ed25519
KexAlgorithms curve25519-sha256
MACs hmac-sha2-256-etm@openssh.com
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 1
MaxStartups 100:100:100
PerSourceMaxStartups 1
PerSourcePenalties authfail:10m noauth:10m grace-exceeded:10m refuseconnection:10m
Match Group *,!ssh_users
    RefuseConnection yes
```





https://wiki.nftables.org/wiki-nftables/index.php/Synproxy



tcp flooding , icmp flooding , http flooding



Create `/etc/sysctl.d/10-syn-proxy-ipv4.conf` :

```ini
net.netfilter.nf_conntrack_tcp_loose = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
```

```bash
sysctl --system
```

Create `/root/downloads/syn-proxy.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
interface_name=$1
display_values() {
    printf '%s\n' "ipv4 tcp mss : $ipv4_tcp_mss" "ipv6 tcp mss : $ipv6_tcp_mss" "wscale value : $wscale_value"
    exit 0
}
interface_mtu_path="/sys/class/net/${interface_name}/mtu"
interface_mtu=$( < "$interface_mtu_path" )
ipv4_headers_length=20
ipv6_headers_length=40
tcp_headers_length=20
ipv4_tcp_headers_length=$((ipv4_headers_length + tcp_headers_length))
ipv6_tcp_headers_length=$((ipv6_headers_length + tcp_headers_length))
ipv4_tcp_mss=$((interface_mtu - ipv4_tcp_headers_length))
ipv6_tcp_mss=$((interface_mtu - ipv6_tcp_headers_length))
wscale_enabled=$(sysctl --values net.ipv4.tcp_window_scaling)

(( wscale_enabled )) || display_values
tcp_max_buffer_auto=$(sysctl --values net.ipv4.tcp_rmem | awk '{print $3}')
tcp_max_buffer_system=$(sysctl --values net.core.rmem_max)
python_script=$(cat <<'EOF'
import sys
import math
buffer_limit_1 = int( sys.argv[1] )
buffer_limit_2 = int( sys.argv[2] )
tcp_effective_buffer = max( buffer_limit_1 , buffer_limit_2 )
wscale_value = math.floor( math.log2( tcp_effective_buffer ) ) - 15
wscale_value = max( 0 , min( wscale_value , 14 ) )
print( wscale_value )
EOF
)
wscale_value=$(python3 <(printf '%s\n' "$python_script") $tcp_max_buffer_auto $tcp_max_buffer_system)
display_values







wscale_value=0
effective_buffer=0
if (( tcp_max_autotuned_receive_buffer > system_max_socket_receive_buffer ))
then
    effective_buffer=$tcp_max_autotuned_receive_buffer
else
    effective_buffer=$system_max_socket_receive_buffer
fi
while [[ $effective_buffer -gt 65535 ]] && [[ $wscale_value -lt 14 ]]
do
    effective_buffer=$(( effective_buffer / 2 ))
    wscale_value=$(( wscale_value + 1 ))
done
display_values
```

```bash
bash /root/downloads/syn-proxy.sh eth0

```



















tcpdump -ni eth0 -vv 'tcp src port 22 and tcp[tcpflags] & (tcp-syn|tcp-ack) == (tcp-syn|tcp-ack)'


meta nfproto ipv4
meta nfproto ipv6











mss
wscale
timestamp
sack-perm







syn proxy for 22 , 80 , 443

table ip syn_proxy {
    chain prerouting {
        type filter hook prerouting priority -300; policy accept;
        tcp dport 22 tcp flags syn notrack
    }
    chain input {
        type filter hook input priority 0; policy accept;
        tcp dport 22 ct state invalid,untracked synproxy mss 1460 wscale 7 timestamp sack-perm
        ct state invalid drop
    }
}


use ( ct count ) with per source limiting new connections
limit number of simultaneous tcp connenctions from each source ip to port 22 , 80 , 443 tcp
1 simultaneous tcp connection to ssh
8 simultaneous connections to same http Host header for http
8 simultaneous connections to same sni for https

also define per source limit for icmp and icmpv6

tcp flags '& (fin|syn|rst|psh|ack|urg) == fin|psh|urg' drop



tcp flags & (fin|syn) == (fin|syn) drop
tcp flags & (syn|rst) == (syn|rst) drop
tcp flags & (fin|rst) == (fin|rst) drop
tcp flags & (fin|syn|rst|ack) == 0 drop







sshd -t
systemctl restart ssh










