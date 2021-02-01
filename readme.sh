#!/dev/null
# Copy and paste into terminal manually
# No sourcing or executing

# WARNING - Do not clear screen before successful output

# WARNING - Steps before mkarchiso are invoked as "darren" instead of "root"

#   Type     Default w/o mask  Mask       Mask applied
# ---------  ----------------  ----  ------------------------
#   File      0666=rwxrwxrwx   0022  0666-0022=0644=rw-r--r--
# Directory   0777=rwxrwxrwx   0022  0777-0022=0755=rwxr-xr-x
#
# Distro mask in /etc/profile: 0022
#
{
  [[ "$(umask)" = "0022" ]] &&
  [[ "$(umask -S)" = "u=rwx,g=rx,o=rx" ]];
} || echo "error"

# Variables & functions
PROJ="$HOME/archiso"
#
LIVE0="/usr/share/archiso/configs/releng"
LIVE="$PROJ/archlive"
#
ARFS="$LIVE/airootfs"
# shellcheck disable=SC2034
ARFS0="$LIVE0/airootfs"
#
source packages.bashrc
source misc.bashrc

# Prepare a custom profile
if [ -e "$LIVE" ]; then
  read -rp "Remove archlive? "
  rm -rf "$LIVE"
  cp -r "$LIVE0" "$LIVE"
else
  cp -r "$LIVE0" "$LIVE"
fi

# Packcages
parse_packages_conf "packages.conf" "$LIVE/packages.x86_64"

# motd(5) issue(5)
{ echo "/etc/motd"; echo; cat "$ARFS/etc/motd"; } | sponge "$ARFS/etc/motd"

# https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/README.profile.rst#efiboot
# https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/docs/README.bootparams#L26
sed \
  -e 's|^\(title.*\)$|\1 (copytoram)|g' \
  -e 's|^\(options.*\)$|\1 copytoram=y copytoram_size=75%|g' \
   "$LIVE/efiboot/loader/entries/archiso-x86_64-linux.conf" \
  >"$LIVE/efiboot/loader/entries/archiso-x86_64-copytoram-linux.conf"

# Adding files to image - mount points
mkdir -v "$ARFS/mnt.nvme" "$ARFS/mnt.usb"

# Adding files to image - mksquashfs.sh
# Add to "file_permissions" array in "$LIVE/profiledef.sh" if 755 fails
# https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/README.profile.rst#airootfs
install -m755 -v mksquashfs.sh "$ARFS/usr/local/bin/mksquashfs.sh"
sed --expression='/^file_permissions=(/a \ \ ["/usr/local/bin/mksquashfs.sh"]="0:0:755"' --in-place "$LIVE/profiledef.sh"
# shellcheck disable=SC2086
diff -u $LIVE{0,}/profiledef.sh

disable_waiting_for_network

# Stop using Chromium!
# Close other apps to free up some RAM
free -h
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
free -h

# Mount snapshot
# shellcheck disable=SC2024
sudo findmnt -A >/tmp/findmnt0

# Build ISO as root
sudo \
  /usr/bin/time --format="\n  wall clock time - %E\n" \
  mkarchiso -v -w "/tmp/archiso-tmp/" -o "$PROJ" "$LIVE"
sudo chown -v darren:darren archlinux-????.??.??-x86_64.iso

# Log
# Scroll to the beginning w/ Shift+Home
# Left click
# Scroll to the end w/ Shift+End
# Right click
# Copy
# Paste to archlinux-<TAB><TAB>.log

# Initial checksum record
# sha256sum archlinux-????.??.??-x86_64.iso >>sha256sum.txt
# Further checksum verifications
# sha256sum -c sha256sum.txt

# Removal of work directory
# WARNING - make sure there are no mount binds before deleting /tmp/archiso-tmp
sudo sh -c 'diff -u /tmp/findmnt0 <(findmnt -A)'
#
sudo rm -r /tmp/archiso-tmp
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
free -h
