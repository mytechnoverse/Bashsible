
# Package Managment :

dpkg-query --show --showformat='${Status}\n' ca-certificates
apt install ca-certificates

dpkg-query --show --showformat='${Status}\n' gpgv
apt install --no-install-recommends gpgv

### Ubuntu 26 :

dpkg-query --show --showformat='${Status}\n' ubuntu-keyring
apt install ubuntu-keyring

Check `/etc/apt/sources.list.d/ubuntu.sources` :

```text
Types: deb
URIs: https://archive.ubuntu.com/ubuntu/
Suites: resolute resolute-updates
Components: main universe
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://security.ubuntu.com/ubuntu/
Suites: resolute-security
Components: main universe
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

### Debian 13 :

dpkg-query --show --showformat='${Status}\n' debian-archive-keyring
apt install debian-archive-keyring

Check `/etc/apt/sources.list.d/debian.sources` :

```text
Types: deb
URIs: https://deb.debian.org/debian/
Suites: trixie trixie-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security/
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
```

```bash
apt update
apt upgrade
```
