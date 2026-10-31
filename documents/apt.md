
# Package Managment :





apt_packages_files_path_list=$(apt-get indextargets --format '$(FILENAME)' 'Created-By: Packages')
apt_packages_files_present=1
for this_packages_file_path in "$apt_packages_files_path_list[@]"
do
    [[ -s $this_packages_file_path ]] || {
        apt_packages_files_present=0
        break
    }
done
(( apt_packages_files_present ))
rm --recursive --force /var/cache/apt/archives/partial/*



Create `ensure-packages-installed.sh` :

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
for this_package_name in "$@"
do
    [[ $(dpkg-query --show --showformat='${db:Status-Status}' $this_package_name 2>/dev/null || true) == 'installed' ]] || DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes -o Dpkg::Use-Pty=0 -o Acquire::Retries=0 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 install $this_package_name
done
```

Create `ensure-packages-absent.sh` :

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
for this_package_name in "$@"
do
    if dpkg-query --show $this_package_name &>/dev/null
    then
        DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes -o Dpkg::Use-Pty=0 purge $this_package_name
    fi
done
DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes -o Dpkg::Use-Pty=0 autopurge
```

Create `check-package-availability.sh` : 

```bash
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}
trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
(( $# == 1 || $# == 2 ))
package_name=$1
available_packages=$(apt-cache pkgnames)
readarray -t available_packages_list < <(printf '%s' "$available_packages")
package_available=0
for this_package_name in "${available_packages_list[@]}"
do
    [[ $this_package_name == "$package_name" ]] && {
        package_available=1
        break
    }
done
(( package_available ))
if (( $# == 2 ))
then
    package_min_version=$2
    package_query=$(apt-cache policy "$package_name")
    readarray -t package_query_list < <(printf '%s' "$package_query")
    package_version_available=0
    for this_package_query in "${package_query_list[@]}"
    do
        read -r this_query_key this_query_value < <(printf '%s\n' "$this_package_query")
        [[ $this_query_key == 'Candidate:' ]] && {
            [[ -n $this_query_value && $this_query_value != '(none)' ]] && {
                if dpkg --compare-versions "$this_query_value" ge $package_min_version
                then
                    package_version_available=1
                fi
            }
            break
        }
    done
    (( package_version_available ))
fi
```

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
