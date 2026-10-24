
# Package Managment :

---

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

---

### Debian 13 :

Version Release Date :

- <https://www.debian.org/releases/stable/>


https://snapshot.debian.org/archive/debian/
https://snapshot.debian.org/archive/debian-security/

/dists/trixie/InRelease -> ( Version: )

/dists/trixie/main/binary-amd64/Packages.xz

search ( Package: gpgv ) -> ( Filename: ) 

https://deb.debian.org/debian/ + ( Filename: )
https://security.debian.org/debian-security/ + ( Filename: )

- <https://deb.debian.org/debian/pool/main/libg/libgpg-error/libgpg-error0_1.51-4_amd64.deb>
- <https://deb.debian.org/debian/pool/main/libg/libgcrypt20/libgcrypt20_1.11.0-7+deb13u1_amd64.deb>
- <https://deb.debian.org/debian/pool/main/g/gnupg2/gpgv_2.4.7-21+deb13u1+b5_amd64.deb>
- <https://deb.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2025.1_all.deb>
- <https://security.debian.org/debian-security/pool/updates/main/o/openssl/openssl_3.5.7-1~deb13u3_amd64.deb>
- <https://security.debian.org/debian-security/pool/updates/main/c/ca-certificates/ca-certificates_20250419+deb13u1_all.deb>

```bash
rm -f /etc/apt/sources.list
dpkg-query --show --showformat='${Status}\n' libgpg-error0
dpkg --install libgpg-error0
dpkg-query --show --showformat='${Status}\n' libgcrypt20
dpkg --install libgcrypt20
dpkg-query --show --showformat='${Status}\n' gpgv
dpkg --install gpgv
dpkg-query --show --showformat='${Status}\n' debian-archive-keyring
dpkg --install debian-archive-keyring
dpkg-query --show --showformat='${Status}\n' openssl
dpkg --install openssl
dpkg-query --show --showformat='${Status}\n' ca-certificates
dpkg --install ca-certificates
```

Check `/etc/apt/sources.list.d/debian.sources` :

```text
Types: deb
URIs: https://deb.debian.org/debian/
Suites: trixie trixie-updates trixie-backports
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security/
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
```

---

```bash
apt update
apt upgrade
```
