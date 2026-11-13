
For each ( Browser , Browser Version , Platform ) combination , there are 4 variations ( JA4 Hashes ) for TLS CLientHello Message :

1. Websockets use different ALPN Extension ( application_layer_protocol_negotiation ) :

ALPN Values :

Default   : [ "h2" , "http/1.1" ]
GRPC      : [ "h2" , "http/1.1" ]
Websocket : [ "http/1.1" ]

2. Resumed ( Refreshed ) TLS Connections include PSK Specific Extensions ( pre_shared_key , psk_key_exchange_modes ) with stateless session tickets .







server {
    ...
    location = /ja4 {
        default_type application/json;
        return 200 '{"tls": {"ja4": "$ssl_fingerprint_ja4"}}';
    }
}












for _ , thisPreset := range latestPresetsList {


}



for aliasPresetName := range versionsDictionary {
    fmt.Println(key)
}









func getAliasPresetVersion( aliasPresetName string ) error {
    presetObject , presetDescriptionError := fingerprint.Describe( aliasPresetName )
    if presetDescriptionError != nil { return fmt.Errorf( "error" ) }
    var presetJSON presetSchema
    presetSchemaError := presetObject.JSON( &presetJSON )
    if presetSchemaError != nil { return fmt.Errorf( "error" ) }
    if presetJSON.PRESET.NAME == "" { return fmt.Errorf( "error" ) }
    resolvedPresetName := presetJSON.PRESET.NAME
    presetPartsList := strings.Split( resolvedPresetName , "-" )
    return 
}

thisPresetVersion , thisPresetVersionError := strconv.Atoi( presetPartsList[ 1 ] )



--browser-version :




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
    "runtime/debug"
    "github.com/sardanioss/httpcloak"
)
const chromeMinAllowedVersion = 143
var chromeAllowedPlatformsList = []string{ "windows" , "macos" , "android" , "ios" }
var versionsDictionary = map[string]string{
    "chrome-latest-android": "" ,
    "chrome-latest-windows": "" ,
    "chrome-latest-ios": "" ,
    "chrome-latest-macos": "" ,
    "safari-latest-ios": "" ,
    "safari-latest": ""
}
type endpointSchema struct {
    TLS struct {
        JA4 string
    }
}
type presetSchema struct {
    PRESET struct {
        NAME string
    }
}
var fingerprintsDictionary = make( map[string]string )
var fingerprintsList []string
func getSessionFingerprint( sessionObj *httpcloak.Session , endpointURL string ) error {
    requestContext , requestCancel := context.WithTimeout( context.Background() , 1 * time.Second )
    defer requestCancel()
    responseObj , requestError := sessionObj.Get( requestContext , endpointURL )
    if requestError != nil { return fmt.Errorf( "%w" , requestError ) }
    defer responseObj.Close()
    var responseJSON endpointSchema
    responseSchemaError := responseObj.JSON( &responseJSON )
    if responseSchemaError != nil { return fmt.Errorf( "error" ) }
    if responseJSON.TLS.JA4 == "" { return fmt.Errorf( "error" ) }
    sessionFingerprint := responseJSON.TLS.JA4
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
    if net.ParseIP( endpointDomain ) == nil { return fmt.Errorf( "error" ) }
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
func getVersion() error {
    buildInfo , ok := debug.ReadBuildInfo()
    if !ok { return fmt.Errorf( "error" ) }
    for _ , thisDependency := range buildInfo.Deps {
        if thisDependency.Path == "github.com/sardanioss/httpcloak" {
                fmt.Fprintln( os.Stdout , thisDependency.Version )
                break
            }
        }
}
func main() {
    printVersion := flag.Bool( "version" , false , "" )
    endpointDomain := flag.String( "domain" , "" , "" )
    endpointPath := flag.String( "path" , "" , "" )
    withWebsockets := flag.Bool( "with-websockets" , false , "" )
    flag.Parse()
    var applicationOutputList []string
    var applicationError error
    if printVersion == true {
        
        if !ok {
            os.Exit( 1 )
        }
        for _ , thisDependency := range buildInfo.Deps {
            if thisDependency.Path == "github.com/sardanioss/httpcloak" {
                fmt.Fprintln( os.Stdout , thisDependency.Version )
                break
            }
        }
        os.Exit( 0 )
    }
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
    applicationOutputList = fingerprintsList
    for _ , outputLine := range applicationOutputList { fmt.Fprintln( os.Stdout , outputLine ) }
}
```

