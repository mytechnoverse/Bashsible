
### Golang Public Mirror URL Whitelist :

- <https://proxy.golang.org/>
- <https://sum.golang.org/>
- <https://index.golang.org/>
- <https://storage.googleapis.com/proxy-golang-org-prod/>

### Golang Modules Documentation :

- <https://pkg.go.dev/>

```bash
bash ensure-packages-installed.sh curl jq rsync
```

Create `ensure-debian-golang-absent.sh` : 

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
golang_packages=$(dpkg-query --show --showformat='${Package}\n' golang 'golang-*' 2>/dev/null || true)
readarray -t golang_packages_list < <(printf '%s' "$golang_packages")
(( ${#golang_packages_list[@]} )) || exit 0
for this_package_name in "${golang_packages_list[@]}"
do
    if dpkg-query --show $this_package_name &>/dev/null
    then
        DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes -o Dpkg::Use-Pty=0 purge $this_package_name
    fi
done
DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes -o Dpkg::Use-Pty=0 autopurge
```

```bash
bash ensure-debian-golang-absent.sh
```

Create `download-golang-archive.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
command -v curl >/dev/null
command -v jq >/dev/null
golang_api_url='https://go.dev/dl/?mode=json'
golang_api_response=$(curl --ipv4 --silent --show-error --fail-with-body --location --compressed --connect-timeout 1 --url $golang_api_url)
golang_latest_stable_obj=$(jq --exit-status --compact-output 'first(.[] | select(.stable == true))' < <(printf '%s' "$golang_api_response"))
golang_latest_stable_version=$(jq --exit-status --raw-output '.version' < <(printf '%s' "$golang_latest_stable_obj"))
golang_latest_stable_linux_amd64_filename=$(jq --exit-status --raw-output '(.files[] | select(.os == "linux" and .arch == "amd64")).filename' < <(printf '%s' "$golang_latest_stable_obj"))
golang_latest_stable_linux_amd64_URL="https://go.dev/dl/${golang_latest_stable_linux_amd64_filename}"


curl --ipv4 --silent --show-error --fail-with-body --location --connect-timeout 1 --url $golang_api_url --output 


```





local command_temp_fd command_stderr 


run_silently() {
    (( $# > 0 ))

    local captured rc=0 saved_out
    exec {saved_out}>&1

    # stderr -> pipe (captured); stdout -> caller's stdout.
    # `trap - ERR` keeps the inherited ERR trap from polluting the capture.
    # `|| rc=$?` exempts the assignment from errexit and from the caller's ERR trap.
    captured=$( trap - ERR; "$@" 2>&1 1>&"$saved_out" ) || rc=$?

    exec {saved_out}>&-

    if (( rc != 0 )); then
        [[ -z $captured ]] || printf '%s\n' "$captured" >&2
        return "$rc"
    fi
    # success: `captured` is discarded — never printed, never persisted
}

















exec {saved_out}>&1
captured=$( trap - ERR; "$@" 2>&1 1>&"$saved_out" )
exec {saved_out}>&-



silent_stderr() {
    (( $# > 0 ))
    command_stderr_path=$(mktemp)
    if "$@" 2> $command_stderr_path
    then
        rm $command_stderr_path
    else
        command_return_code=$?
        cat $command_stderr_path >&2
        rm $command_stderr_path
        return $command_return_code
    fi
}







# Runs a command, suppressing its normal stderr output.
# If the command fails, it prints the captured stderr and returns the exit code.
run_quietly() {
    local err_file
    err_file=$(mktemp)
    # Execute the command, redirecting its stderr to a temp file.
    # stdout (if any) is left untouched.
    if ! "$@" 2>"$err_file"; then
        # The command failed. Print the captured error output.
        cat "$err_file" >&2
        rm -f "$err_file"
        return 1
    fi
    # The command succeeded. Discard the normal stderr output.
    rm -f "$err_file"
    return 0
}








go vet -fix 



go env GOTELEMETRY , GOTELEMETRYDIR 




go telemetry off









return a template config file with --default-config

read from a config file

create a json file at build time , make the app read it and return it with --build



Create `build-golang-package.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
script_exit_trap() {
    local script_temp_path=$1
    [[ ! -d $script_temp_path ]] || rm --recursive --force $script_temp_path
}
trap '[[ ! -v temp_path || $temp_path == "" ]] || script_exit_trap $temp_path' EXIT
script_path=$(pwd)
(( $# == 2 ))
app_name=$1
source_path="${2%/}"
[[ -n $app_name ]]
[[ ! $app_name =~ [./A-Z] ]]
[[ -d $source_path ]]
binary_path="${script_path}/${app_name}"
[[ ! -f $binary_path ]]
command -v rsync >/dev/null
command -v go >/dev/null
command -v jq >/dev/null
temp_path="$(mktemp --directory)/"
binary_subdir='bin'
build_relative_path="${binary_subdir}/${app_name}"
build_absolute_path="${temp_path}${build_relative_path}"
rsync --archive --exclude='/go.mod' --exclude='/go.sum' --exclude='/bin/' --exclude='/vendor/' --exclude='/.git/' "${source_path}/" $temp_path
go -C $temp_path mod init $app_name 2>/dev/null
go -C $temp_path mod tidy
go -C $temp_path mod vendor
go -C $temp_path vet ./...
go -C $temp_path build -compiler=gc -buildmode=pie -trimpath -buildvcs=false -ldflags="-s -w -buildid=" -mod=vendor -o "${build_relative_path}" ./...
cp $build_absolute_path $binary_path
app_version=$($build_absolute_path --version)
golang_version=$(go env GOVERSION)
golang_version="${golang_version#go}"
build_timestamp=$(date --utc '+%Y-%m-%dT%H:%M:%SZ')
sha256sum_line=$(sha256sum $build_absolute_path)
read -r binary_hash _ < <(printf '%s\n' "$sha256sum_line")
vendor_modules_txt_path="${temp_path}vendor/modules.txt"
[[ -f $vendor_modules_txt_path ]]
vendor_modules_txt=$(< $vendor_modules_txt_path)
readarray -t vendor_modules_lines_list < <(printf '%s\n' "$vendor_modules_txt")
modules_path_list=()
modules_version_list=()
for this_line in "${vendor_modules_lines_list[@]}"
do
    [[ $this_line != '# '* ]] || {
        read -r _ this_module_path this_module_version < <(printf '%s\n' "$this_line")
        modules_path_list+=( $this_module_path )
        modules_version_list+=( "${this_module_version#v}" )
    }
done
modules_object_list=()
for module_index in "${!modules_path_list[@]}"
do
    this_module_obj=$(jq --null-input --compact-output --arg module_path "${modules_path_list[$module_index]}" --arg module_version "${modules_version_list[$module_index]}" '{module_path: $module_path, module_version: $module_version}')
    modules_object_list+=("$this_module_obj")
done
if (( ${#modules_object_list[@]} ))
then
    dependencies_json=$(printf '%s\n' "${modules_object_list[@]}" | jq --slurp --monochrome-output --compact-output '.')
else
    dependencies_json='[]'
fi
jq --null-input --monochrome-output --arg app_name $app_name --arg app_version $app_version --arg golang_version $golang_version --arg date_utc $build_timestamp --arg digest_sha256 $binary_hash --argjson dependencies_list "$dependencies_json" \
'{app_name: $app_name, app_version: $app_version, golang_version: $golang_version, date_utc: $date_utc, digest_sha256: $digest_sha256, dependencies_list: $dependencies_list}'
```






Golang Local Mirror : Athens

https://github.com/gomods/athens
module caching , checksum proxying

setting http proxy for internet access in athens :

HTTP_PROXY='http://http-proxy.internal:8080'




setting local mirror in client :

/etc/golang/env :

GOPROXY=http://golang-proxy.internal/golang













 



Create `Disable-Golang-Telemetry.sh` :

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
user_name=$1
user_entry=$(getent --service files passwd $user_name)
IFS=: read -r _ _ user_id user_group_id _ user_home_path _ < <(printf '%s\n' $user_entry)
[[ -d $user_home_path ]]
directory_default_mode='755'
config_file_default_mode='644'
user_config_prefix="${user_home_path}/.config"
user_config_golang_prefix="${user_config_prefix}/go"
user_config_golang_telemetry_prefix="${user_config_golang_prefix}/telemetry"
user_config_golang_telemetry_path="${user_config_golang_telemetry_prefix}/mode"
install --owner=$user_id --group=$user_group_id --mode=$directory_default_mode --directory $user_config_prefix
install --owner=$user_id --group=$user_group_id --mode=$directory_default_mode --directory $user_config_golang_prefix
install --owner=$user_id --group=$user_group_id --mode=$directory_default_mode --directory $user_config_golang_telemetry_prefix





[[ -f $user_config_golang_telemetry_path ]] || touch $user_config_golang_telemetry_path
[[ $(stat -c '%U:%G' $user_config_golang_telemetry_path) == "${user_id} ${user_group_id}" ]] || chown root:root $user_config_golang_telemetry_path
[[ $(stat -c '%a' $user_config_golang_telemetry_path) == $config_file_default_mode ]] || chmod $config_file_default_mode $user_config_golang_telemetry_path







printf "%s\n" 'off' > $user_config_golang_telemetry_path
```


```bash
Disable-Golang-Telemetry.sh --user root
```
































Create `/usr/lib/tmpfiles.d/golang.conf` :

```text
d /var/tmp/golang 1777 root root
```

Create `/usr/lib/go/go.env` :

```ini
CGO_ENABLED=0
GOTMPDIR=/var/tmp/golang/
GOTOOLCHAIN=local
GOPROXY=https://proxy.golang.org
GOSUMDB=sum.golang.org
```














Proxy-Authorization header

























_test.go





go help command_name

go telemetry


go test

CGO_ENABLED=1 go test -race !!!!!!

-race -cover ???


go tool












go clean








go help buildjson
go help buildmode
go help cache
go help environment
go help filetype
go help goauth
go help go.mod
go help gopath
go help goproxy
go help importpath
go help modules
go help module-auth
go help packages
go help private
go help testflag
go help testfunc
go help vcs

















/etc/profile.d/go.sh :

export PATH=$PATH:/usr/local/go/bin

chmod 644 /etc/profile.d/go.sh

source /etc/profile.d/go.sh








$HOME/.profile or /etc/profile :

export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:$(go env GOPATH)/bin"          ( $HOME/go/bin )

source $HOME/.profile





tar -C /usr/local -xzf go1.27.3.linux-amd64.tar.gz






==================================================================================================================================

go build -pgo default.pgo 
