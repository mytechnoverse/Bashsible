

```bash
dpkg-query --show --showformat='${Status}\n' sudo
apt install sudo
dpkg-query --show --showformat='${Status}\n' whois
apt install whois
```

---

### Debian 13 :

```bash
su --login root
usermod --lock root
echo $PATH
```

Create `/etc/sudoers.d/10-local-path` :

```text
Defaults secure_path += /usr/local/bin/
```

```bash
chmod 440 /etc/sudoers.d/10-sudo-path
visudo --check
sudo -V
```

---

Create `/etc/security/limits.d/10-single-session.conf` :

```text
@ssh_users - maxlogins 1
```

```bash
getent group
groupadd ssh_users
getent group ssh_users
```

```bash
mkpasswd -m yescrypt
useradd --create-home --shell /usr/bin/bash --user-group new_username
echo 'new_username:password_hash' | chpasswd --encrypted
groups new_username
usermod --append --groups sudo new_username
usermod --append --groups ssh_users new_username
usermod --append --groups systemd-journal new_username
```

sudo --login

