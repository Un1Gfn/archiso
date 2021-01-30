#!/dev/null

# WARNING - Do not clear screen before successful output

# WARNING - Steps before mkarchiso are invoked as "darren" instead of "root"

# umask
umask 0022
umask -S

# Prepare a custom profile
cd /home/darren/archiso
rm -rf archlive
cp -r /usr/share/archiso/configs/releng archlive


# Adding files to image - mount points
mkdir -v /home/darren/archiso/archlive/airootfs/mnt.ext4/
mkdir -v /home/darren/archiso/archlive/airootfs/mnt.ntfs/

# Adding files to image - mksquashfs.sh
# https://wiki.archlinux.org/index.php/Full_system_backup_with_SquashFS
install -m755 -v /dev/null /home/darren/archiso/archlive/airootfs/usr/local/bin/mksquashfs.sh
cat <<"EOF" >>/home/darren/archiso/archlive/airootfs/usr/local/bin/mksquashfs.sh
#!/bin/bash
if [ $# -ne 2 ] || [ ! -d "$1" ] || [ ! -d "$2" ]; then
  echo
  echo "  mksquashfs.sh <SOURCE_DIRECTORY> <BACKUP_ARCHIVE_DIRECTORY>"
  echo
  exit 1
fi
echo -ne "\n  Have you fsck'd? "
read -r
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
EOF

# systemd units - disable waiting for network
# env SYSTEMD_COLORS=1 systemctl --no-pager list-dependencies | less -SRM +%
# systemd-networkd-wait-online.service
# /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service → /usr/lib/systemd/system/systemd-networkd-wait-online.service
# systemd-resolved.service
# Created symlink /etc/systemd/system/dbus-org.freedesktop.resolve1.service → /usr/lib/systemd/system/systemd-resolved.service.
# Created symlink /etc/systemd/system/multi-user.target.wants/systemd-resolved.service → /usr/lib/systemd/system/systemd-resolved.service.
# systemd-networkd.service
# Created symlink /etc/systemd/system/dbus-org.freedesktop.network1.service → /usr/lib/systemd/system/systemd-networkd.service.
# Created symlink /etc/systemd/system/multi-user.target.wants/systemd-networkd.service → /usr/lib/systemd/system/systemd-networkd.service.
# Created symlink /etc/systemd/system/sockets.target.wants/systemd-networkd.socket → /usr/lib/systemd/system/systemd-networkd.socket.
# Created symlink /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service → /usr/lib/systemd/system/systemd-networkd-wait-online.service.
# rm -fv /root/archlive/airootfs/etc/udev/rules.d/81-dhcpcd.rules
rm    -v  /home/darren/archiso/archlive/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service
rm    -v  /home/darren/archiso/archlive/airootfs/etc/systemd/system/multi-user.target.wants/reflector.service
rm    -v  /home/darren/archiso/archlive/airootfs/etc/systemd/system/multi-user.target.wants/systemd-networkd.service
rm    -v  /home/darren/archiso/archlive/airootfs/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
rmdir -v  /home/darren/archiso/archlive/airootfs/etc/systemd/system/network-online.target.wants/

# Users and passwords
# QUOTING & HISTORY EXPANSION '!''
set +H
# diff -u <(cat /home/darren/archiso/archlive/airootfs/etc/shadow) <(sudo grep root /etc/shadow)
# Groups
echo "darren:x:1000:"  >>/home/darren/archiso/archlive/airootfs/etc/group
echo   "root:!!::root" >>/home/darren/archiso/archlive/airootfs/etc/gshadow
echo "darren:!!::"     >>/home/darren/archiso/archlive/airootfs/etc/gshadow
# Users
echo "darren:x:1000:1000:darren:/home/darren:/usr/bin/zsh"               >>/home/darren/archiso/archlive/airootfs/etc/passwd
sed -i "s|root::14871::::::|root:$(openssl passwd -6 "archiso"):14871::::::|g"   /home/darren/archiso/archlive/airootfs/etc/shadow
echo                     "darren:$(openssl passwd -6 "archiso"):14871::::::"   >>/home/darren/archiso/archlive/airootfs/etc/shadow
#
diff -uN {/usr/share/archiso/configs/releng,/home/darren/archiso/archlive}/airootfs/etc/group
diff -uN {/usr/share/archiso/configs/releng,/home/darren/archiso/archlive}/airootfs/etc/gshadow
diff -uN {/usr/share/archiso/configs/releng,/home/darren/archiso/archlive}/airootfs/etc/passwd
diff -uN {/usr/share/archiso/configs/releng,/home/darren/archiso/archlive}/airootfs/etc/shadow

# Build the ISO
# Close apps to free up some RAM
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
free -h
#
sudo \
  /usr/bin/time --format="\n  wall clock time - %E\n" \
  mkarchiso -c xz -o /home/darren/archiso/ -s sfs -v -w /tmp/archiso-tmp/ /home/darren/archiso/archlive/
#
sudo chown -v darren:darren /home/darren/archiso/archlinux-????.??.??-x86_64.iso

# Removal of work directory
# WARNING - make sure there are no mount binds before deleting /tmp/archiso-tmp
sudo findmnt -A
#
sudo rm -r /tmp/archiso-tmp
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
free -h

# Share ISO
# install -v -gdarren -odarren /root/archlive/out/*.iso /FOO/BAR

# Test ISO
# qemu-system-x86_64 \
#   -accel kvm \
#   -boot order=d,menu=on,reboot-timeout=5000 \
#   -m size=3072,slots=0,maxmem=$((3072*1024*1024)) \
#   -k en \
#   -name archiso,process=archiso_0 \
#   -drive file=/home/darren/archlinux-2020.04.30-x86_64.iso,media=cdrom,readonly=on \
#   -display sdl \
#   -vga virtio \
#   -no-reboot \
#   -no-shutdown \
# #
#   -display gtk \
#   -vga std \
#   -vga qxl \
#   -machine type=kvm64 \
#   -cpu host \

# Changing files in image - enable sshd.service
# https://wiki.archlinux.org/index.php/Archiso#Prepare_an_ISO_for_an_installation_via_SSH
# ln -sfv \
#   /home/darren/archiso/archlive/airootfs/usr/lib/systemd/system/sshd.service \
#   /home/darren/archiso/archlive/airootfs/etc/systemd/system/multi-user.target.wants/sshd.service

# Serial connection (non-EFI only)
# https://wiki.archlinux.org/index.php/Working_with_the_serial_console#Installing_Arch_Linux_using_the_serial_console
# https://wiki.archlinux.org/index.php/Syslinux#Kernel_parameters
# https://wiki.syslinux.org/wiki/index.php?title=Config#APPEND
# sed -e '/APPEND/ s/$/ console=ttyS0,38400/' /root/archlive/syslinux/archiso_sys.cfg >tmp.cfg
# diff -u /root/archlive/syslinux/archiso_sys.cfg tmp.cfg --color=always
# mv -iv tmp.cfg /root/archlive/syslinux/archiso_sys.cfg # Press 'y' before Enter!

# Pre-download mirrorlist and efi binary
# cd /root/archlive
# proxychains -q wget -O mirrorlist 'https://www.archlinux.org/mirrorlist/?country=all&protocol=http&use_mirror_status=on'
# # proxychains -q wget 'https://raw.githubusercontent.com/tianocore/edk2/UDK2018/ShellBinPkg/UefiShell/X64/Shell.efi'
# # proxychains -q wget 'https://raw.githubusercontent.com/tianocore/edk2/UDK2018/EdkShellBinPkg/FullShell/X64/Shell_Full.efi'
# sed -E \
#   -e 's#curl.*mirrorlist.*#cp /etc/pacman.d/mirrorlist ${work_dir}/x86_64/airootfs/etc/pacman.d/mirrorlist#g' \
#   -e 's#curl.*shellx64_v2.*#mv Shell.efi ${work_dir}/iso/EFI/shellx64_v2.efi#g' \
#   -e 's#curl.*shellx64_v1.*#mv Shell_Full.efi ${work_dir}/iso/EFI/shellx64_v1.efi#g' \
#   build.sh \
#   >tmp.sh
# diff --color=always -u build.sh tmp.sh
# mv tmp.sh build.sh
