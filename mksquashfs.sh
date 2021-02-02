#!/bin/bash
# https://wiki.archlinux.org/index.php/Full_system_backup_with_SquashFS

# Check mkfs timestamp of Partition-as-a-Filesystem (mkfs.ext4 /dev/sda1)
# sudo dumpe2fs /dev/sda1

# Check mkfs timestamp of Whole-Drive-as-a-Filesystem (mksquashfs ... /dev/sda)
# sudo file -sL /dev/sda
# sudo unsquashfs -stat /dev/sda

trap 'echo' EXIT

{ [[ "$(whoami)" = "root" ]] && (($#==2)) && [[ -d "$1" ]] && [[ -b "$2" ]]; } || {
  echo
  echo "  # $0 <rootdir> <whole-drive-as-a-filesystem>" # -noappend
  exit 1
}

echo
lsblk -f
# echo
# findmnt --invert --types proc,autofs,sysfs,efivarfs,securityfs,tmpfs,cgroup2,cgroup,pstore,bpf,debugfs,tracefs,fusectl,configfs,devtmpfs,devpts,hugetlbfs,mqueue,fuse.gvfsd-fuse

echo
read -erp "  Have you fsck'd? "
echo
read -erp "  Are you sure to wipe \"$2\"? "

# "$1" "$2/$(date +%Y%m%d_%a).sfs"
# sudo filelight - Filelight - Settings - Configure Filelight - Scanning - Do not scan these folders
echo
mksquashfs "$1" "$2" \
  -not-reproducible \
  -xattrs \
  -wildcards \
  -noappend \
  -progress \
  -mem 5G \
  -e \
    var/cache/pacman/pkg \
    var/lib/pacman/sync \
    var/log/journal \
    boot/efi \
    boot/grub \
    boot/initramfs-linux"*".img \
    boot/vmlinuz-linux
