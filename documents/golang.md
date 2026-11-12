
```bash
bash ensure-packages-installed.sh curl jq
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









Create `download-golang-modules.sh` :

```bash
go_app_name=$1
go_app_source_path="${2%/}"
[[ ! $go_app_name =~ [./A-Z] ]]
command -v go >/dev/null
[[ ! -d $go_app_source_path ]]
[[ ! -f "${go_app_source_path}/go.mod" ]]
[[ ! -f "${go_app_source_path}/go.sum" ]]
[[ ! -n "$(find $go_app_source_path -type f -name '*.go' -print -quit)" ]]
go -C $go_app_source_path mod init $go_app_name
go -C $go_app_source_path mod tidy
go -C $go_app_source_path mod vendor
```


```bash
Download-Golang-Modules.sh tls-ja4-generator ./tls-ja4-generator
```

golang needs a https proxy . it does not support http proxy



chmod 600 /root/.netrc

Create `/root/.netrc` :


machine proxy.internal:8080
login http_proxy_username
password http_proxy_password



then delete .netrc file






manual :

go list -m -f '{{.Version}}' github.com/sardanioss/httpcloak


script :

read -r _ _ go_version _ < <(printf '%s\n' "$(go version)")
go_version="${go_version#go}"


httpcloak_version=$(go list -m -f '{{.Version}}' github.com/sardanioss/httpcloak)
httpcloak_version="${httpcloak_version#v}"








go_app_source_path=$1
go_modules_resolution_mode=$2
go_app_binary_name=$3
go_app_build_options=(
    -C $go_app_source_path
    -compiler=gc
    -buildmode=pie
    -trimpath
    -buildvcs=false
    -ldflags="-s -w -buildid="
)
case $go_modules_resolution_mode in
    dynamic-version-online)
        go_app_build_options+=( '-mod=mod' )
        ;;
    static-version-online)
        go_app_build_options+=( '-mod=readonly' )
        ;;
    static-version-offline)
        go_app_build_options+=( '-mod=vendor' )
        ;;
    *) false ;;
esac
go build "${go_app_build_options[@]}" -o $go_app_binary_name .






















go list -mod=vendor ./...





















golang domains whitelist :

proxy.golang.org
storage.googleapis.com
sum.golang.org
index.golang.org

if url filtering is available :

storage.googleapis.com/proxy-golang-org-prod/*




golang registry index user interface : https://pkg.go.dev/







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



go version

go help command_name

go telemetry





go list

go get

go mod vendor

go vet

go test

CGO_ENABLED=1 go test -race !!!!!!

-race -cover ???


go tool

go build







verbose : -v -x 












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

go env -w CGO_ENABLED=0
go env CGO_ENABLED
go env -changed