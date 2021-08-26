#!/dev/null
# ~/beaglebone/Documentation/Archiso.rst

# Duplication is allowed and will be automatically removed

# Sublime Text -> Edit -> Code Folding ->
#   Unfold All   <Ctrl+K,Ctrl+J>
#   Fold Level 2 <Ctrl+K,Ctrl+2>
#   Fold All     <Ctrl+K,Ctrl+1>

PKGARR=(

  # Base/Boot/EFI/Init
    base
    edk2-shell
    efibootmgr
    grub
    linux
    mkinitcpio         # https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/docs/README.profile.rst#packages-arch
    mkinitcpio-archiso # https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/docs/README.profile.rst#packages-arch
    mkinitcpio-nfs-utils
    refind
    syslinux           # install: cannot stat '/tmp/archiso-tmp/x86_64/airootfs/usr/lib/syslinux/bios/*.c32': No such file or directory

  # Firmware
    amd-ucode # Required by archlive/efiboot/loader/entries/archiso-x86_64-linux.conf
    intel-ucode # Required by archlive/efiboot/loader/entries/archiso-x86_64-linux.conf
    # ipw2100-fw
    # ipw2200-fw
    linux-firmware
    # b43-fwcutter
    # broadcom-wl

  # Hardware
    pciutils  # lspci
    usbutils  # lsusb
    lsscsi    # SCSI
    sg3_utils # SCSI
    dmidecode
    lshw
    usb_modeswitch
    flashrom  # ThinkPad X200 BIOS

  # Battery/Power
    acpi
    tlp
    upower # upower -d

  # Disk
    ddrescue
    hdparm
    nvme-cli      # community
    sdparm
    smartmontools
    testdisk
    udisks2       # udisksctl -b /dev/sda power-off

  # FS/Partition
    dosfstools # mkfs.fat fsck.fat fsck.vfat
    e2fsprogs
    fatresize
    gpart
    gptfdisk
    mtools
    nfs-utils
    ntfs-3g
    parted
    squashfs-tools # mksquashfs

  # Network - OSI_Layer_7
    # https://en.wikipedia.org/wiki/List_of_network_protocols_(OSI_model)
    dhcpcd             # DHCP
    bind               # DNS
    ldns               # DNS
    systemd-resolvconf # DNS
    busybox            # HTTP (httpd)
    curl               # HTTP
    wget               # HTTP FTP
    # cloud-init       # SSH

  # Network - Wireless
    # broadcom-wl
    crda
    iw
    iwd
    wireless-regdb
    wireless_tools # iwconfig iwlsit
    wpa_supplicant

  # Network - Misc
    # broadcom-wl
    ethtool
    gnu-netcat
    iproute2 # bridge ip ss tc
    macchanger
    nbd # ERROR: file not found: `nbd-client'
    ndisc6 # IPv6
    net-tools # arp ifconfig netstat route
    nfs-utils
    nmap
    openssh
    rp-pppoe
    rsync
    wvdial

  # Console/Man/Pager/Pipe/Serial/Text
    busybox         # microcom
    diffutils       # diff
    gpm
    grml-zsh-config
    less
    lrzsz           # minicom+lrzsz
    man-db
    man-pages
    minicom         # minicom+lrzsz
    nano
    pv
    sed
    terminus-font
    tmux
    vbetool         # vbetool dpms off; read -r; vbetool dpms on
    vi
    vim
    zsh

  # Misc
    # mc # error: mc: key "Jakob Gruber <jakob.gruber@gmail.com>" is disabled
    # use nnn instead of mc
    nnn
    arch-install-scripts # arch-chroot genfstab pacstrap
    archinstall
    memtest86+
    sudo
    tree
    time                 # /usr/bin/time

)
