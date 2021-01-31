#!/bin/bash
# https://wiki.archlinux.org/index.php/Full_system_backup_with_SquashFS

trap 'echo' EXIT

{ (($#==2)) && [[ -d "$1" ]] && [[ -d "$2" ]]; } || {
  echo
  echo "  mksquashfs.sh <SOURCE_DIRECTORY> <BACKUP_ARCHIVE_DIRECTORY>"
  exit 1
}

echo
read -erp "  Have you fsck'd? "

echo
mksquashfs \
  "$1" "$2/$(date +%Y%m%d_%a).sfs" \
  -comp gzip \
  -xattrs \
  -progress \
  -mem 5G \
  -wildcards \
  -e \
  var/cache/pacman/pkg \
  var/lib/pacman/sync \
  var/log/journal \
  boot/efi \
  boot/grub \
  boot/initramfs-linux"*".img \
  boot/vmlinuz-linux
