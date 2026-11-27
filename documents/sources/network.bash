
network_scan_timeout=3

network::check_tcp_port() {
    network_tcp_scan_ip=$1
    network_tcp_scan_port=$2
    bash_tcp_path="/dev/tcp/${network_tcp_scan_ip}/${network_tcp_scan_port}"
    bash::run_cmd_timeout $network_scan_timeout bash::run_drop_output : > $bash_tcp_path
}



