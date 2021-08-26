#!/dev/null

IGNARR_FILELIGHT=(
  # misc
  /dev/
  /proc/
  /sys/
  # Don't calculate, but include in backup
  /var/log/journal
  # don't calculate, don't include in backup
  /var/cache/pacman/pkg/
  /var/lib/pacman/sync/
  "/home/darren/pmos/[BAK1]"
)

IGNARR_MKSQUASHFS=(
  # misc
  boot/EFI
  boot/initramfs-linux"*".img
  boot/shellx64.efi
  boot/vmlinuz-linux"*"
  # don't calculate, don't include in backup
  var/cache/pacman/pkg
  var/lib/pacman/sync
  "home/darren/pmos/[BAK1]"
)
