
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







write a golang app that adds the username and password header to golang http proxy request










printf 'user:pass' | base64














































```bash
mkdir -p /root/.config/go
```

Create `/root/.config/go/env` :

```ini
CGO_ENABLED=0
GOPROXY=https://proxy.golang.org
GOSUMDB=sum.golang.org
GOTOOLCHAIN=local
GOPRIVATE=""
```








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
