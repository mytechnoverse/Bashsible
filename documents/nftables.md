
# Nftables :


- <https://github.com/firehol/iprange/releases>
- <https://github.com/firehol/iprange/releases/download/v2.1.1/iprange-2.1.1.tar.xz>



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
dpkg-query --show --showformat='${Status}\n' iproute2
apt install iproute2
dpkg-query --show --showformat='${Status}\n' jc
apt install jc
mkdir -p /etc/nftables/conf.d/
```





apt update
apt install build-essential

Create `build-auto-tools.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
script_path=$(pwd)
(( $# >= 3 ))
binary_name=$1
source_path=$2
binary_subdir=$3
configure_options=("${@:4}")
[[ -f $source_path ]]
[[ ! -f "${script_path}/${binary_name}" ]]
temp_path="$(mktemp --directory)/"
tar --extract --strip-components=1 --directory $temp_path --file $source_path
( cd $temp_path && ./configure "${configure_options[@]}" )
cpu_core_count=$(nproc)
make --jobs $cpu_core_count --directory $temp_path
build_path="${temp_path}${binary_subdir}/${binary_name}"
strip --strip-unneeded $build_path
cp $build_path $script_path
rm --force --recursive $temp_path
```

```bash
build-auto-tools.sh iprange iprange.tar.xz src --disable-man
install --mode 0755 --owner root --group root -- ./iprange /usr/local/bin/iprange
command -v iprange >/dev/null
```






iprange --version
iprange --has-ipv6

iprange --ipv4 google-ipv4.txt cloudflare-ipv4.txt > dns-servers.ipv4
iprange --ipv6 google-ipv6.txt cloudflare-ipv6.txt > dns-servers-ipv6






apt update

Create `check-iprange-ipv6-support.sh` : 

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
package_name='iprange'
package_required_version='2.1.1'
apt-cache show $package_name &>/dev/null
package_candidate_version=''
while read -r line_key line_value
do
    [[ $line_key == 'Candidate:' ]] && {
        package_candidate_version=$line_value
        break
    }
done < <(apt-cache policy $package_name)
[[ $package_candidate_version != '(none)' ]]
dpkg --compare-versions $package_candidate_version ge $package_required_version
```

```bash
bash check-iprange-ipv6-support.sh || printf '%s\n' "IPRanges IPv6 Support NOT Provided By APT Repository !"
dpkg-query --show --showformat='${Status}\n' iprange
apt install iprange
apt purge iprange
apt autoremove --purge
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

table netdev ingress_guard {
    set per_ip_bandwidth {
        type ipv4_addr
        flags dynamic
        timeout 10m
        size 65536
    }
    chain ingress_filter {
        type filter hook ingress device eth0 priority -500; policy accept;
        ip frag-off & 0x1fff != 0 counter drop
        ip saddr @per_ip_bandwidth update @per_ip_bandwidth { ip saddr limit rate over 100mbit/s burst 100kbytes } counter drop
    }
}


suggest a reasonable concurrent tcp limit for public resolvers based on their documnetation ( google , cloudflare , ... ) following the ssh pattern .
also implement a global limit for concurrent tcp connections to port 53 tcp . also how do i create a requests per second limit for port 53 udp .
drop fragments at ingress , also think about dnssec fragmentation of udp





table inet firewall {
    counter input-ssh-block-list-counter-ipv4 {}
    counter input-dns-block-list-counter-ipv4 {} 
    counter input-dns-proxy-list-counter-ipv4 {}
    set input-ssh-block-list-ipv4 {
        type ipv4_addr
        flags dynamic
        size 65536
        timeout 10m
    }
    set input-dns-block-list-ipv4 {
        type ipv4_addr
        flags dynamic
        size 65536
        timeout 10m
    }
    set dns-servers-list-ipv4 {
        type ipv4_addr
        flags dynamic
        size 65536
        timeout 10m
    }
    chain tcp_proxy {
        type filter hook prerouting priority -300; policy accept;
        meta nfproto ipv4 tcp dport 22 tcp flags & ( fin | syn | rst | ack ) == syn notrack
        meta nfproto ipv4 tcp dport 53 tcp flags & ( fin | syn | rst | ack ) == syn notrack
    }
    chain udp_proxy {
        type nat hook prerouting priority -100; policy accept;
        meta nfproto ipv4 udp dport 53 ip saddr != @dns-servers-list-ipv4 counter name input-dns-proxy-list-counter-ipv4 redirect to :5353
    }
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        meta nfproto ipv6 drop
        meta nfproto ipv4 tcp dport 22 ct state untracked ip saddr @input-ssh-block-list-ipv4 update @input-ssh-block-list-ipv4 { ip saddr } drop
        meta nfproto ipv4 tcp dport 53 ct state untracked ip saddr @input-dns-block-list-ipv4 drop
        meta nfproto ipv4 tcp dport 22 ct state invalid,untracked synproxy mss tcp_ipv4_mss wscale tcp_window_scale timestamp sack-perm
        meta nfproto ipv4 tcp dport 53 ct state invalid,untracked synproxy mss tcp_ipv4_mss wscale tcp_window_scale timestamp sack-perm
        ct state invalid drop
        meta nfproto ipv4 tcp dport 53 ct state established add @dns-servers-list-ipv4 { ip saddr }
        ct state established accept
        icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
        icmp type echo-request limit rate 5/second burst 10 packets accept
        icmp type echo-request drop
        meta nfproto ipv4 tcp dport 22 ct state new ct count over 128 drop
        meta nfproto ipv4 tcp dport 22 ct state new ip saddr != @input-ssh-block-list-ipv4 add @input-ssh-block-list-ipv4 { ip saddr ct count over 2 } counter name input-ssh-block-list-counter-ipv4 limit rate 10/second burst 20 log prefix "nft-input-ssh-block-list-ipv4 : " level warn drop
        meta nfproto ipv4 tcp dport 22 ip saddr @input-ssh-block-list-ipv4 drop
        meta nfproto ipv4 tcp dport 22 ct state new accept
        meta nfproto ipv4 tcp dport 53 ct state new ip saddr != @input-dns-block-list-ipv4 add @input-dns-block-list-ipv4 { ip saddr ct count over 2 } counter name input-dns-block-list-counter-ipv4 limit rate 10/second burst 20 log prefix "nft-input-dns-block-list-ipv4 : " level warn drop
        meta nfproto ipv4 tcp dport 53 ip saddr @input-dns-block-list-ipv4 drop
        meta nfproto ipv4 tcp dport 53 ct state new accept
        meta nfproto ipv4 udp dport 53 accept
        meta nfproto ipv4 udp dport 5353 ct status dnat accept
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

google :

https://developers.google.com/speed/public-dns/faq

- <https://www.gstatic.com/ipranges/publicdns.json>



curl https://www.gstatic.com/ipranges/publicdns.json | jq 





Create `create_nft_set.sh` : 

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
create_set() {
    local nft_table_name=$1
    local nft_set_name=$2
    local nft_set_type=$3
    local -n ip_ranges_list_ref=$4
    local -a ip_ranges_list
    readarray -t ip_ranges_list < <(printf '%s\n' "${ip_ranges_list_ref[@]}" | iprange --optimize)
    printf 'add set inet %s %s { type %s; flags interval; }\n' $nft_table_name $nft_set_name $nft_set_type
    printf 'flush set inet %s %s\n' $nft_table_name $nft_set_name
    printf 'add element inet %s %s {\n' $nft_table_name $nft_set_name
    local ip_range_index_last=$(( ${#ip_ranges_list_ref[@]} - 1 ))
    for (( ip_range_index = 0; ip_range_index <= ip_range_index_last; ip_range_index++ ))
    do
        if (( ip_range_index < ip_range_index_last ))
        then
            printf '%s,\n' "    ${ip_ranges_list[$ip_range_index]}"
        else
            printf '%s\n' "    ${ip_ranges_list[$ip_range_index]}"
        fi
    done
    printf '}\n'
}
command -v jq >/dev/null
command -v jc >/dev/null
command -v iprange >/dev/null 
(( $# == 3 ))
nft_table_name=$1
nft_set_name=$2
ip_ranges_list_file_path=$3
nft_set_name_ipv4="${nft_set_name}_ipv4"
nft_set_name_ipv6="${nft_set_name}_ipv6"
[[ -f $ip_ranges_list_file_path ]]
ip_ranges_list_file=$(< $ip_ranges_list_file_path)
readarray -t ip_ranges_list < <(printf '%s\n' "$ip_ranges_list_file")
ip_ranges_count="${#ip_ranges_list[@]}"
(( ip_ranges_count ))
declare -a ip_ranges_list_ipv4
declare -a ip_ranges_list_ipv6
for (( ip_range_index = 0; ip_range_index < ip_ranges_count; ip_range_index++ ))
do
    ip_range=${ip_ranges_list[$ip_range_index]}
    ip_range_info=$(printf '%s' $ip_range | jc --ip-address)
    ip_address=$(printf '%s' "$ip_range_info" | jq --raw-output '.ip')
    ip_network=$(printf '%s' "$ip_range_info" | jq --raw-output '.network')
    [[ $ip_address == $ip_network ]]
    ip_range_version=$(printf '%s' "$ip_range_info" | jq --raw-output '.version')
    if (( ip_range_version == 4 ))
    then
        ip_ranges_list_ipv4+=($ip_range)
    else
        ip_ranges_list_ipv6+=($ip_range)
    fi
done
(( ${#ip_ranges_list_ipv4[@]} )) || {
    nft_set_ipv4=$(create_set $nft_table_name $nft_set_name_ipv4 ipv4_addr ip_ranges_list_ipv4)
    printf '%s\n' "$nft_set_ipv4" > "${nft_set_name_ipv4}.nft"
}
(( ${#ip_ranges_list_ipv6[@]} )) || {
    nft_set_ipv6=$(create_set $nft_table_name $nft_set_name_ipv6 ipv6_addr ip_ranges_list_ipv6)
    printf '%s\n' "$nft_set_ipv6" > "${nft_set_name_ipv6}.nft"
}
```



sort from lower cidr to higher


```bash
create_nft_set.sh table_name dns_servers_set dns_servers.txt
```


jq '.prefixes[]  | .ipv4Prefix // .ipv6Prefix'




#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
create_set() {
    local table_name=$1
    local set_name=$2
    local ip_version=$3
    local -n ip_ranges_list_ref=$4
    set_name_ipv4="${set_name}_ipv4"
set_name_ipv6="${set_name}_ipv6"
    printf 'add set inet %s %s \'{ type ipv4_addr; flags interval; }\'' $table_name $set_name
    (( ${#ip_ranges_list_ref[@]} )) || return 0
    printf 'add element inet %s %s {\n' $table_name $set_name
    local ip_range_index_last=$(( ${#ip_ranges_list_ref[@]} - 1 ))

    printf '}\n'
}
table_name=$1
set_name=$2
json_path=$3
script_path=$4

json_file=$(< $json_path)
ip_ranges_ipv4=$(printf '%s\n' "$json_file" | jq --raw-output '.prefixes[] | select(.ipv4Prefix != null) | .ipv4Prefix')
ip_ranges_ipv6=$(printf '%s\n' "$json_file" | jq --raw-output '.prefixes[] | select(.ipv6Prefix != null) | .ipv6Prefix')




google_dns_servers_ipv4 google-ipv4.nft


cloudflare :

https://www.cloudflare.com/ips-v4/#
https://www.cloudflare.com/ips-v6/#




forward chain :

meta nfproto ipv4 tcp flags syn tcp option maxseg size set tcp_ipv4_mss

table netdev early_filter {
    chain wan_ingress {
        type filter hook ingress device "eth0" priority filter; policy accept;
        ip frag-off & 0x3fff != 0 drop
    }
}

- `tcp_ipv4_mss`
- `tcp_window_scale`
- `ssh_global_limit`

Create `/etc/nftables/conf.d/00-server-static-dual.nft` :

```text
table inet firewall {
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
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
        iif lo accept
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
        iif lo accept
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
systemctl --quiet is-enabled nftables || systemctl enable nftables
nft list ruleset
watch --color --differences --interval 1 'nft list counters table inet firewall'
```

```bash
journalctl --dmesg --follow
journalctl --dmesg --grep='nftables_log_prefix' --lines=10
```









sudo journalctl -b -o short-monotonic   -u systemd-modules-load.service   -u systemd-sysctl.service
[sudo: authenticate] Password:
[    9.901230] XXX systemd[1]: systemd-sysctl.service: Deactivated successfully.
[    9.901401] XXX systemd[1]: Stopped systemd-sysctl.service - Apply Kernel Variables.
[    9.902060] XXX systemd[1]: systemd-modules-load.service: Deactivated successfully.
[    9.902250] XXX systemd[1]: Stopped systemd-modules-load.service - Load Kernel Modules.
[   12.144427] XXX systemd[1]: Starting systemd-sysctl.service - Apply Kernel Variables...
[   12.209525] XXX systemd[1]: Finished systemd-sysctl.service - Apply Kernel Variables.
XXX@XXX:~$ sudo grep -E 'CONFIG_NF_CONNTRACK=' /boot/config-$(uname -r)
CONFIG_NF_CONNTRACK=m
XXX@XXX:~$ sudo journalctl -b -k -o short-monotonic   | grep -iE 'nf_conntrack|nft_ct'
XXX@XXX:~$ sudo systemd-analyze critical-chain systemd-sysctl.service
The time when unit became active or started is printed after the "@" character.
The time the unit took to start is printed after the "+" character.

systemd-sysctl.service +65ms
└─systemd-modules-load.service @1.592s +115ms
  └─systemd-journald.socket
    └─system.slice
      └─-.slice
















kernel tuning : ( always start at 60 )

net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30
net.netfilter.nf_conntrack_tcp_timeout_established = 600







mkdir /etc/modules-load.d/

Create `/etc/modules-load.d/nftables-connection-tracking.conf` :

```text
nf_conntrack
```

Create `/etc/sysctl.d/60-syn-proxy-ipv4.conf` :

```ini
net.netfilter.nf_conntrack_tcp_loose = 0
```

```bash
modprobe nf_conntrack
sysctl --system
```

Create `/root/syn-proxy.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
display_values() {
    printf '%s\n' "TCP over IPv4 MSS : $tcp_over_ipv4_mss" "TCP over IPv6 MSS : $tcp_over_ipv6_mss" "TCP Window Scale : $tcp_window_scale"
    exit 0
}
min_path_mtu=1400
ipv4_headers=20
ipv6_headers=40
tcp_headers=20
tcp_over_ipv4_headers=$((ipv4_headers + tcp_headers))
tcp_over_ipv6_headers=$((ipv6_headers + tcp_headers))
tcp_over_ipv4_mss=$((min_path_mtu - tcp_over_ipv4_headers))
tcp_over_ipv6_mss=$((min_path_mtu - tcp_over_ipv6_headers))
tcp_window_scaling_enabled=$(sysctl --values net.ipv4.tcp_window_scaling)
tcp_window_scale=0
(( tcp_window_scaling_enabled )) || display_values
read -r _ _ tcp_max_buffer_auto < <(sysctl --values net.ipv4.tcp_rmem)
tcp_max_buffer_system=$(sysctl --values net.core.rmem_max)
declare tcp_raw_buffer
if (( tcp_max_buffer_auto > tcp_max_buffer_system ))
then
    tcp_raw_buffer=$tcp_max_buffer_auto
else
    tcp_raw_buffer=$tcp_max_buffer_system
fi
tcp_effective_buffer=$(( tcp_raw_buffer / 2 ))
while [[ $tcp_effective_buffer -gt 65535 ]] && [[ $tcp_window_scale -lt 14 ]]
do
    tcp_effective_buffer=$(( tcp_effective_buffer / 2 ))
    tcp_window_scale=$(( tcp_window_scale + 1 ))
done
display_values
```

```bash
bash /root/syn-proxy.sh
```

```bash
tcp_port_number=22
ss --ipv4 --tcp --info state established "sport = :${tcp_port_number}"
ss --ipv6 --tcp --info state established "sport = :${tcp_port_number}"
```

- `advmss`
- `wscale[ 0 ]`












======= Nginx Global Limit :

nginx max tcp connections by default :

systemctl show --property=DefaultLimitNOFILE ( 1024 by default )

config file defaults :

worker_processes : auto
worker_connections : 512
worker_rlimit_nofile : unset

auto means ( nproc )

/etc/systemd/system/nginx.service.d/override.conf :

LimitNOFILE=65535

nginx static hosting max connections :

min( worker_processes * ( min( worker_connections , worker_rlimit_nofile ) ) , LimitNOFILE )

nginx reverse proxy max connections :

min( worker_processes * ( min( worker_connections , worker_rlimit_nofile ) ) , LimitNOFILE ) / 2

--------------------------------------------------------------------------------------------------

====== Nginx Per source limit :

each user creates 2 tcp connections simultaneously ( xyz.com , api.xyz.com ) for each website
8 user , 16 concurrent tcp connections

--------------------------------------------------------------------------------------------

tcp connection logging : log flags tcp options
tcp flooding , icmp flooding , http flooding


