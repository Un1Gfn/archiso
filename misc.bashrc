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

# function serial_connection_no_efi {
#   # https://wiki.archlinux.org/index.php/Working_with_the_serial_console#Installing_Arch_Linux_using_the_serial_console
#   # https://wiki.archlinux.org/index.php/Syslinux#Kernel_parameters
#   # https://wiki.syslinux.org/wiki/index.php?title=Config#APPEND
#   sed -e '/APPEND/ s/$/ console=ttyS0,38400/' /root/archlive/syslinux/archiso_sys.cfg >tmp.cfg
#   diff -u /root/archlive/syslinux/archiso_sys.cfg tmp.cfg --color=always
#   mv -iv tmp.cfg /root/archlive/syslinux/archiso_sys.cfg # Press 'y' before Enter!
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
