#!/bin/bash

SFS="$(date +%Y%m%d_%a).sfs"

echo

if [ "$(whoami)" = "root" ] && (($#==2)) && [ -d "$1" ] && [[ -d "$2" ]]; then
  :
else
  echo "$(basename "$0") <dir1> <dir2>"
  echo "  dir1 - directory to back up"
  echo "  dir2 - directory to put '${SFS}' and its checksum"
  echo
  exit
fi

# findmnt --invert --types proc,autofs,sysfs,efivarfs,securityfs,tmpfs,cgroup2,cgroup,pstore,bpf,debugfs,tracefs,fusectl,configfs,devtmpfs,devpts,hugetlbfs,mqueue,fuse.gvfsd-fuse
lsblk -f
echo

read -erp "  have you fsck'd devices behind '$1' ? "
echo

read -erp "  are you sure to write '$2/$SFS' ? "
echo

/usr/bin/time --format="\n  wall clock time - %E\n" \
  mksquashfs "$1" "$2/$SFS" \
    -not-reproducible \
    -xattrs \
    -wildcards \
    -noappend \
    -progress \
    -mem 5G \
    -ef "/exclude_file"
echo

ls -lh "$2/$SFS"
echo

echo "  performing checksum ..."
/usr/bin/time --format="\n  wall clock time - %E\n" \
  sha256sum "$2/$SFS" | tee | cut -d' ' -f1 >"$2/$SFS.sha256sum"
echo

printf "  \e[32m%s\e[0m\n" "ok"
echo
