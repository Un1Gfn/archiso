#!/dev/null

# function create_user {
#   # Users and passwords
#   # QUOTING & HISTORY EXPANSION '!''
#   set +H
#   # diff -u <(cat $AIROOTFS/etc/shadow) <(sudo grep root /etc/shadow)
#   # Groups
#   echo "darren:x:1000:"  >>"$AIROOTFS/etc/group"
#   echo   "root:!!::root" >>"$AIROOTFS/etc/gshadow"
#   echo "darren:!!::"     >>"$AIROOTFS/etc/gshadow"
#   # Users
#   echo  "darren:x:1000:1000:darren:/home/darren:/usr/bin/zsh"                    >>"$AIROOTFS/etc/passwd"
#   sed -i "s|root::14871::::::|root:$(openssl passwd -6 "archiso"):14871::::::|g"   "$AIROOTFS/etc/shadow"
#   echo                     "darren:$(openssl passwd -6 "archiso"):14871::::::"   >>"$AIROOTFS/etc/shadow"
#   #
#   diff -uN $AIROOTFS{0,}/etc/group
#   diff -uN $AIROOTFS{0,}/etc/gshadow
#   diff -uN $AIROOTFS{0,}/etc/passwd
#   diff -uN $AIROOTFS{0,}/etc/shadow
# }

# function enable_sshd {
#   https://wiki.archlinux.org/index.php/Archiso#Prepare_an_ISO_for_an_installation_via_SSH
#   ln -sfv \
#     "$AIROOTFS/usr/lib/systemd/system/sshd.service" \
#     "$AIROOTFS/etc/systemd/system/multi-user.target.wants/sshd.service"
# }

# function serial_connection_no_efi {
#   # https://wiki.archlinux.org/index.php/Working_with_the_serial_console#Installing_Arch_Linux_using_the_serial_console
#   # https://wiki.archlinux.org/index.php/Syslinux#Kernel_parameters
#   # https://wiki.syslinux.org/wiki/index.php?title=Config#APPEND
#   sed -e '/APPEND/ s/$/ console=ttyS0,38400/' /root/archlive/syslinux/archiso_sys.cfg >tmp.cfg
#   diff -u /root/archlive/syslinux/archiso_sys.cfg tmp.cfg --color=always
#   mv -iv tmp.cfg /root/archlive/syslinux/archiso_sys.cfg # Press 'y' before Enter!
# }

# function download_mirrorlist_and_tianocore {
#   cd /root/archlive
#   proxychains -q wget -O mirrorlist 'https://www.archlinux.org/mirrorlist/?country=all&protocol=http&use_mirror_status=on'
#   # proxychains -q wget 'https://raw.githubusercontent.com/tianocore/edk2/UDK2018/ShellBinPkg/UefiShell/X64/Shell.efi'
#   # proxychains -q wget 'https://raw.githubusercontent.com/tianocore/edk2/UDK2018/EdkShellBinPkg/FullShell/X64/Shell_Full.efi'
#   sed -E \
#     -e 's#curl.*mirrorlist.*#cp /etc/pacman.d/mirrorlist ${work_dir}/x86_64/airootfs/etc/pacman.d/mirrorlist#g' \
#     -e 's#curl.*shellx64_v2.*#mv Shell.efi ${work_dir}/iso/EFI/shellx64_v2.efi#g' \
#     -e 's#curl.*shellx64_v1.*#mv Shell_Full.efi ${work_dir}/iso/EFI/shellx64_v1.efi#g' \
#     build.sh \
#     >tmp.sh
#   diff --color=always -u build.sh tmp.sh
#   mv tmp.sh build.sh
# }

# function qemu_iso {
#   # -display gtk \
#   # -vga std \
#   # -vga qxl \
#   # -machine type=kvm64 \
#   # -cpu host \
#   qemu-system-x86_64 \
#     -accel kvm \
#     -boot order=d,menu=on,reboot-timeout=5000 \
#     -m size=3072,slots=0,maxmem=$((3072*1024*1024)) \
#     -k en \
#     -name archiso,process=archiso_0 \
#     -drive file=/home/darren/archlinux-2020.04.30-x86_64.iso,media=cdrom,readonly=on \
#     -display sdl \
#     -vga virtio \
#     -no-reboot \
#     -no-shutdown \
#     #
# }
