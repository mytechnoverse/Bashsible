


```bash
dpkg-query --show --showformat='${Status}\n' systemd
apt install systemd
dpkg-query --show --showformat='${Status}\n' rsyslog
apt install rsyslog
```

systemctl status systemd-journald
systemctl start systemd-journald
systemctl status systemd-journald
systemctl enable systemd-journald

Create `/etc/systemd/journald.conf.d/00-persistent-logs.conf` :

[Journal]
Storage=persistent
SystemMaxUse=1G
SystemMaxFileSize=128M
SplitMode=none
MaxFileSec=0
SystemKeepFree=0
ForwardToWall=no

mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
systemctl restart systemd-journald
journalctl --flush

ls -lha /var/log/journal/
journalctl --disk-usage


https://manpages.debian.org/trixie/systemd/journalctl.1.en.html#FORWARD_SECURE_SEALING_(FSS)_OPTIONS
https://manpages.debian.org/trixie/systemd/journald@.conf.5.en.html ( Seal= )


















use rsyslog to send encrypted logs ( syslog over tcp over tls ) or ( RELP over TLS )
xray forwards them to the rsyslog server . rsyslog server pushes them to loki and wazuh manager

generate a CA and sign a certificate for rsyslog server for connection between client and rsyslog be encrypted 

each application like ssh , nginx , ... should be checked for log collection
either through specific file , ...
check that a single log is not sent twice through both systemd and rsyslog 

remote vps sending tcp logs through http proxy :





















/etc/rsyslog.d/00-remote-forward.conf :

global(
workDirectory="/var/spool/rsyslog"
)

action(
type="omfwd"
target="127.0.0.1"
port="6514"
protocol="tcp"

```
StreamDriver="ossl"
StreamDriverMode="1"
StreamDriverAuthMode="x509/name"
StreamDriverPermittedPeers="rsyslog.internal"
StreamDriver.CAFile="/etc/ssl/certs/ca-certificates.crt"

action.resumeRetryCount="-1"
action.resumeInterval="10"

queue.type="LinkedList"
queue.filename="remote-syslog"
queue.maxDiskSpace="1g"
queue.saveOnShutdown="on"
```

)

rsyslogd -N1
systemctl restart rsyslog
logger -t tunnel-test "Testing remote syslog forwarding"









socks is more efficient maybe ???




systemctl status rsyslog
systemctl start rsyslog
systemctl status rsyslog
systemctl enable rsyslog









Forward Secure Sealing (FSS) ???