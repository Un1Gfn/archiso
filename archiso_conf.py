#!/dev/null

STRICT_MYPKG = False

FILELIGHTRC = "/root/.config/filelightrc"

BASELINE = "/usr/share/archiso/configs/baseline"
RELENG = "/usr/share/archiso/configs/releng"
BTPKG = "bootstrap_packages.x86_64"
PKG = "packages.x86_64"

PROJ = "$HOME/archiso"
ARCHLIVE = f"{PROJ}/archlive"
AIROOTFS = f"{ARCHLIVE}/airootfs"

IGN_BOTH = [
    "var/cache/pacman/pkg",
    "var/lib/pacman/sync",
    "home/darren/pmos/[BAK1]",
]

# https://docs.python.org/3/reference/expressions.html#list-displays
IGN_FILELIGHT = ["/"+s for s in IGN_BOTH + [
    "dev",
    "proc",
    "sys",
    "var/log/journal",
] ]

IGN_MKSQUASHFS = IGN_BOTH + [
    "boot/EFI",
    "boot/initramfs-linux*.img",
    "boot/shellx64.efi",
    "boot/vmlinuz-linux*",
]

# duplication allowed?
MYPKG = [

    # VM
    # "hyperv",
    # "open-vm-tools",  # vmware
    # "qemu-guest-agent",
    # "virtualbox-guest-utils-nox",

    # base/boot/efi/init
    "base",
    "edk2-shell",
    "efibootmgr",
    "grub",
    "linux",
    "mkinitcpio",            # https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/docs/README.profile.rst#packages-arch
    "mkinitcpio-archiso",    # https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/docs/README.profile.rst#packages-arch
    "mkinitcpio-nfs-utils",
    "moreutils",             # sponge vidir
    "refind",
    "syslinux",              # install: cannot stat '/tmp/archiso-tmp/x86_64/airootfs/usr/lib/syslinux/bios/*.c32': No such file or directory

    # blob/firmware
    "amd-ucode",       # Required by archlive/efiboot/loader/entries/archiso-x86_64-linux.conf
    "intel-ucode",     # Required by archlive/efiboot/loader/entries/archiso-x86_64-linux.conf
    "linux-firmware",
    # "b43-fwcutter",
    # "broadcom-wl",
    # "broadcom-wl",
    # "ipw2100-fw",
    # "ipw2200-fw",

    # hardware
    "dmidecode",
    "flashrom",        # ThinkPad X200 BIOS
    "lshw",
    "lsscsi",          # scsi
    "open-iscsi",      # scsi.remote
    "pciutils",        # lspci
    "sg3_utils",       # scsi
    "usb_modeswitch",
    "usbutils",        # lsusb

    # battery/power
    "acpi",
    "tlp",
    "upower",  # upower -d

    # disk
    "ddrescue",
    "hdparm",
    "nvme-cli",       # community
    "sdparm",
    "smartmontools",
    "testdisk",
    "udisks2",        # udisksctl -b /dev/sda power-off

    # filesystem/partition
    "dosfstools",      # mkfs.fat fsck.fat fsck.vfat
    "e2fsprogs",       # backup.e2image
    "fatresize",
    "fsarchiver",      # backup.fsa
    "gpart",
    "gptfdisk",
    "mtools",          # mdir
    "ntfs-3g",
    "partclone",       # backup.pcl
    "parted",
    "partimage",       # backup.img
    "squashfs-tools",  # backup.sfs

    # Network - OSI_Layer_7
    # http://suckless.org/rocks/
    "bind",                # dns
    "busybox",             # httpd.busybox
    "cloud-init",          # ssh
    "curl",                # http
    "darkhttpd",           # httpd.darkhttpd (range request)
    "dhcpcd",              # dhcp
    "ldns",                # dns
    "sthttpd",             # httpd.thttpd
    "systemd-resolvconf",  # dns
    "wget",                # openssh OOTB sftp
    "lftp",

    # Network - Wireless
    "iw",
    "iwd",
    "wireless-regdb",  # replacing crda
    "wireless_tools",  # iwconfig iwlsit
    "wpa_supplicant",

    # Network - Misc
    "ethtool",
    "gnu-netcat",
    "iproute2",    # bridge ip ss tc
    "macchanger",
    "nbd",         # ERROR: file not found: `nbd-client'
    "ndisc6",      # IPv6
    "net-tools",   # arp ifconfig netstat route
    "nfs-utils",
    "nmap",
    "openssh",
    "rp-pppoe",
    "rsync",
    "wvdial",      # modem ppp

    # Console/Man/Pager/Pipe/Serial/Text
    "busybox",         # microcom
    "diffutils",       # diff
    "gpm",
    "grml-zsh-config",
    "less",
    "lrzsz",           # serial
    "man-db",
    "man-pages",
    "minicom",         # serial
    "nano",
    "nnn",             # mc alternative
    "pv",
    "sed",
    "terminus-font",
    "tmux",
    "vbetool",         # vbetool dpms off; read -r; vbetool dpms on
    "vi",
    "vim",
    "zsh",

    # Misc
    # mc # error: mc: key "Jakob Gruber <jakob.gruber@gmail.com>" is disabled
    # use nnn instead of mc
    "arch-install-scripts",  # arch-chroot genfstab pacstrap
    "archinstall",
    "memtest86+",
    "sudo",
    "time",                  # /usr/bin/time
    "tpm2-tss",
    "tree",

]
