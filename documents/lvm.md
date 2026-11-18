
### ubuntu 26 :

```bash
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```








UEFI : Unified Extensible Firmware Interface
GPT : GUID Partition Table
ESP : EFI System Partition
gdisk : Graphical GPT Editor
sgdisk : CLI GPT Editor
LVM : Logical Volume Management













set partition types with gdisk :

ESP : EF00
LVM : 8e00



sgdisk -t 2:8e00 /dev/sdX





file system manager ???


/boot/efi , 1 GB FAT32 , ESP

/ : drive c equivalent

/var/ : logs , wazuh , nginx , postgresql , ...





mount /tmp as a tmpfs in RAM







etc ???

root ???





use ( /var/tmp/ ) in build scripts
and create the temp dir manually instead of mktemp -d



.config/go/env

golang GOTMPDIR ???


wazuh no exec temp ??? 




/etc/systemd/system/tmp.mount :

[Unit]
ConditionPathIsSymbolicLink=!/tmp
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target
After=swap.target

[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,noatime,nosuid,nodev,nr_inodes=1m,noexec,size=tmpfs_memory_share

[Install]
WantedBy=local-fs.target


- `tmpfs_memory_share` : 2G , 50% , ...



sudo systemctl daemon-reload
sudo systemctl enable --now tmp.mount






/usr/local ???



/etc/ ???


swap : ????




parted





gdisk
sgdisk





