
```bash
bash ensure-packages-installed.sh curl jc jq
```



--proxy http://proxy.internal:80 --proxy-basic --config < <(printf 'proxy-user = "%s:%s"\n' $http_proxy_username $http_proxy_password )


Create `Call-API.sh`

1. url ( get )
2. url ... ( post )




Create `Download-File.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
(( $# >= 1 ))



command -v curl , jc 


file_URL=$1
curl_file_download_options=(
    --ipv4
    --http2
    --silent
    --show-error
    --fail-with-body
    --connect-timeout 5
    --location
)
if [[ $file_URL == https://* ]]
then
    curl_file_download_options+=( "--tlsv1.3" )
fi
curl_file_download_options+=( "--url $file_URL" )



file_name=''
if (( $# >= 2 ))
then
    file_name=$2
    if (( $# >= 3 ))
    then
    fi
else
    readarray -t -d '/' file_URL_part_list < <(printf '%s' $file_URL)
    file_name="${file_URL_part_list[-1]}"
    [[ $file_name != '' ]]
fi
[[ ! -f $file_name ]]







check if it is ip with jc --ip-address then  

if not ip , lookup with getent

getent ahosts example.com 1>/dev/null

port being 0 - 65535



http_proxy_address=$3
http_proxy_port=$4
http_proxy_username=$5
http_proxy_password=$6




curl_options+=( "new_element" )



curl "${curl_options[@]}"






```


api : --location-trusted
--compressed : include only if file does not have .zip , .gz , .xz , .zst , ... extensions .

