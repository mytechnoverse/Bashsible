
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
        DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes -o Dpkg::Use-Pty=0 autopurge
    fi
done
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
























$HOME/.profile or /etc/profile :

export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:$(go env GOPATH)/bin"          ( $HOME/go/bin )

source $HOME/.profile

go version





tar -C /usr/local -xzf go1.27.3.linux-amd64.tar.gz































```go
package main
import (
    "os"
    "flag"
    "fmt"
    "net"
    "context"
    "time"
    "strings"
    "strconv"
    "encoding/json"
    "github.com/sardanioss/httpcloak"
)
const chromeMinAllowedVersion = 143
var chromeAllowedPlatformsList = []string{ "windows" , "macos" , "android" , "ios" }
type endpointSchema struct {
    TLS struct {
        JA4 string
    }
}
var fingerprintsDictionary = make( map[string]string )
var fingerprintsList []string
func getSessionFingerprint( sessionObj *httpcloak.Session , endpointURL string ) error {
    requestContext , requestCancel := context.WithTimeout( context.Background() , 1 * time.Second )
    defer requestCancel()
    ResponseObj , requestError := sessionObj.Get( requestContext , endpointURL )
    if requestError != nil { return fmt.Errorf( "%w" , requestError ) }
    defer ResponseObj.Close()
    var ResponseJSON endpointSchema
    ResponseSchemaError := ResponseObj.JSON( &ResponseJSON )
    if ResponseSchemaError != nil { return fmt.Errorf( "error" ) }
    if ResponseJSON.TLS.JA4 == "" { return fmt.Errorf( "error" ) }
    sessionFingerprint := ResponseJSON.TLS.JA4
    _ , ok := fingerprintsDictionary[ sessionFingerprint ]
    if !ok {
        fingerprintsDictionary[ sessionFingerprint ] = ""
        fingerprintsList = append( fingerprintsList , sessionFingerprint )
    }
    return nil
}
func getDefaultFingerprint( presetName string , endpointURL string ) error {
    defaultSessionsOptionsList := []httpcloak.SessionOption{
        httpcloak.WithSessionPreferIPv4() ,
        httpcloak.WithSessionTimeout( 1 * time.Second )
    }
    defaultSession := httpcloak.NewSession( presetName , defaultSessionsOptionsList... )
    defer defaultSession.Close()
    defaultSessionFreshError := getSessionFingerprint( defaultSession , endpointURL )
    if defaultSessionFreshError != nil { return fmt.Errorf( "%w" , defaultSessionFreshError ) }
    defaultSession.Refresh()
    defaultSessionRefreshError := getSessionFingerprint( defaultSession , endpointURL )
    if defaultSessionRefreshError != nil { return fmt.Errorf( "%w" , defaultSessionRefreshError ) }
    return nil
}
func getWebsocketsFingerprint( presetName string , endpointURL string ) error {
    websocketsSessionsOptionsList := []httpcloak.SessionOption{
        httpcloak.WithSessionPreferIPv4() ,
        httpcloak.WithSessionTimeout( 1 * time.Second ),
        httpcloak.WithForceHTTP1()
    }
    websocketsSession := httpcloak.NewSession( presetName , websocketsSessionsOptionsList... )
    defer websocketsSession.Close()
    websocketSessionFreshError := getSessionFingerprint( websocketsSession , endpointURL )
    if websocketSessionFreshError != nil { return fmt.Errorf( "%w" , websocketSessionFreshError ) }
    websocketsSession.Refresh()
    websocketSessionRefreshError := getSessionFingerprint( websocketsSession , endpointURL )
    if websocketSessionRefreshError != nil { return fmt.Errorf( "%w" , websocketSessionRefreshError ) }
    return nil
}
func getPresetFingerprint( presetName string , endpointURL string , withWebsockets bool ) error {
    defaultSessionError := getDefaultFingerprint( presetName , endpointURL )
    if defaultSessionError != nil { return fmt.Errorf( "%s %w" , presetName , defaultSessionError ) }
    if withWebsockets {
        websocketsSessionError := getWebsocketsFingerprint( presetName , endpointURL )
        if websocketsSessionError != nil { return fmt.Errorf( "%s %w" , presetName , websocketsSessionError ) }
    }
    return nil
}
func applicationMain( endpointDomain string , endpointPath string , withWebsockets bool ) error {
    if net.ParseIP( endpointDomain ) != nil { return fmt.Errorf( "error" ) }
    dnsLookupContext , dnsLookupCancel := context.WithTimeout( context.Background() , 1 * time.Second )
    defer dnsLookupCancel()
    _ , dnsLookupError := net.DefaultResolver.LookupIP( dnsLookupContext , "ip4" , endpointDomain )
    if dnsLookupError != nil { return fmt.Errorf( "%w" , dnsLookupError ) }
    endpointURL := "https://" + endpointDomain + endpointPath
    presetsList := httpcloak.Presets()
    var targetPresetsList []string
    for _ , thisPreset := range presetsList {
        thisPresetPartsList := strings.Split( thisPreset , "-" )
        if len( thisPresetPartsList ) < 2 { continue }
        thisPresetBrowser := thisPresetPartsList[ 0 ]
        thisPresetVersion , thisPresetVersionError := strconv.Atoi( thisPresetPartsList[ 1 ] )
        if thisPresetVersionError != nil { continue }
        if thisPresetBrowser == "safari" {
            targetPresetsList = append( targetPresetsList , thisPreset )
        }
        if thisPresetBrowser == "chrome" {
            if thisPresetVersion >= chromeMinAllowedVersion {
                if len( thisPresetPartsList ) == 3 {
                    thisPresetPlatform := thisPresetPartsList[ 2 ]
                    for _ , thisAllowedPlatform := range chromeAllowedPlatformsList {
                        if thisPresetPlatform == thisAllowedPlatform {
                            targetPresetsList = append( targetPresetsList , thisPreset )
                            break
                        }
                    }
                }
            }
        }
    }
    for _ , thisPreset := range targetPresetsList {
        presetFingerprintError := getPresetFingerprint( thisPreset , endpointURL , withWebsockets )
        if presetFingerprintError != nil { return fmt.Errorf( "%w" , presetFingerprintError ) }
    }
    return nil
}
func main() {
    endpointDomain := flag.String( "domain" , "" , "" )
    endpointPath := flag.String( "path" , "" , "" )
    withWebsockets := flag.Bool( "with-websockets" , false , "" )
    flag.Parse()
    requiredArgumentsList := []string{ *endpointDomain , *endpointPath }
    requiredArgumentsCount := len( requiredArgumentsList )
    for requiredArgumentsIndex := 0 ; requiredArgumentsIndex < requiredArgumentsCount ; requiredArgumentsIndex++ {
        if requiredArgumentsList[ requiredArgumentsIndex ] == "" {
            os.Exit( 1 )
        }
    }
    applicationError := applicationMain(
        *endpointDomain ,
        *endpointPath ,
        *withWebsockets
    )
    if applicationError != nil {
        fmt.Fprintf( os.Stderr , "Error : %v\n" , applicationError )
        os.Exit( 1 )
    }
    for _ , outputLine := range fingerprintsList { fmt.Fprintln( os.Stdout , outputLine ) }
}
```


