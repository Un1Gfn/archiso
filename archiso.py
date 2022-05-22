#!/bin/python3

import code
import textwrap
import glob
import time
import colorama
import difflib
import os
import pathlib
import posix
import posixpath
import pyalpm
import re
import shutil
import subprocess
import sys
import termcolor
from archiso_conf import *
from pprint import pprint


validpkgname = lambda s: bool(re.match(r'^[0-9a-z@_+][0-9a-z@._+-]*\Z', s))


def filelight2():

    if len(sys.argv) == 2 and sys.argv[1] == '--filelight':
        print()
        filelight()
        exit()

    subprocess.run(['sudo', sys.argv[0], '--filelight'])


def filelight():

    assert posix.getuid() == 0 and posix.getgid() == 0

    with open(FILELIGHTRC, 'r') as f:
        orig = f.readlines()

    new = [re.sub(r'^skipList.*$', 'skipList[$e]=' + ','.join(sorted(IGN_FILELIGHT)), l) for l in orig]
    d = list(difflib.unified_diff(orig, new, FILELIGHTRC, FILELIGHTRC, n=1))
    if d:
        sys.stdout.writelines(d)
        with open(FILELIGHTRC, 'w') as f:
            f.writelines(new)
        # input(f'apply with 'sudo patch --verbose {FILELIGHTRC}' (^D) ')
    else:
        print(f'no need to modify {pathlib.PurePath(FILELIGHTRC).name}')
    print()

    input('please remove redundant data with filelight ')

    exit()


def check_umask():

    # https://docs.python.org/3/reference/lexical_analysis.html#integer-literals
    assert 0o0022 == os.umask(0o0022)


def check_bootstrap_pkg():

    for C in (BASELINE, RELENG):
        with open(posixpath.join(C, BTPKG), 'r') as f:
            assert 'arch-install-scripts\nbase\n' == f.read()


def pkglistfile2set(path):

    with open(path, 'r') as f:
        l = f.readlines()
        assert l
        # https://docs.python.org/3/library/functions.html#all
        # https://wiki.archlinux.org/title/Arch_package_guidelines#Package_naming
        l = [s.rstrip('\n') for s in l]
        assert all(validpkgname(s) for s in l)
        assert all(l[i] < l[i + 1] for i in range(len(l) - 1))
    r = set(l)
    assert len(l) == len(r)
    return r


def check_pkg():

    # baseline and releng are sorted and newline-terminated
    # baseline is a proper subset of releng
    baselineset = pkglistfile2set(posixpath.join(BASELINE, PKG))
    relengset = pkglistfile2set(posixpath.join(RELENG, PKG))
    assert baselineset < relengset

    assert MYPKG
    assert all(validpkgname(s) for s in MYPKG)

    # all of MYPKG exist in sync db
    assert '13.0.1' == pyalpm.alpmversion()
    h = pyalpm.Handle('/', '/var/lib/pacman')
    for i in ['core', 'extra', 'community', 'multilib']:
        h.register_syncdb(i, pyalpm.SIG_DATABASE_MARGINAL_OK)  # https://www.gnupg.org/gph/en/manual/x334.html#AEN345
    if missing := [i for i in MYPKG if not any(db.get_pkg(i) for db in h.get_syncdbs())]:
        raise RuntimeError(f'{sorted(missing)} not found')

    print(colorama.Fore.RED, '---', sorted(relengset - MYPKG), colorama.Style.RESET_ALL, '\n')
    print(colorama.Fore.GREEN, '+++', sorted(MYPKG - relengset), colorama.Style.RESET_ALL, '\n')


def copy_releng():

    assert not posix.access(ARCHLIVE, os.F_OK, follow_symlinks=False)
    shutil.copytree(RELENG, ARCHLIVE, symlinks=True, dirs_exist_ok=False)  # https://wiki.archlinux.org/title/Talk:Archiso#cp_-r_drops_dead_links

    g = os.walk(ARCHLIVE, followlinks=False)
    links = set()
    for (root, dirs, files) in g:
        for file in files:
            fullpath = posixpath.join(root,file)
            if posixpath.islink(fullpath):
                links.add((fullpath, posix.readlink(fullpath)))

    global SYMLINK_KEEP
    global SYMLINK_DROP
    # global SYMLINK_ADD
    p = lambda x: set((posixpath.join(AIROOTFS, t[0]), t[1]) for t in x)
    SYMLINK_KEEP = p(SYMLINK_KEEP)
    SYMLINK_DROP = p(SYMLINK_DROP)
    # SYMLINK_ADD = p(SYMLINK_ADD)

    # print('to keep')
    # pprint(sorted(SYMLINK_KEEP))
    # print()
    assert links >= SYMLINK_KEEP
    links -= SYMLINK_KEEP

    # print('to drop')
    # pprint(sorted(SYMLINK_DROP))
    # print()
    assert links >= SYMLINK_DROP
    links -= SYMLINK_DROP

    for i in SYMLINK_DROP:
        posix.remove(posixpath.join(AIROOTFS, i[0]))

    # print('unresolved')
    # pprint(sorted(links))
    # print()
    assert not links


def emit_pkg():

    with open(posixpath.join(ARCHLIVE, PKG), 'w') as pkg:
        pkg.write('\n'.join(sorted(MYPKG))+'\n')


def convenience_mountpoints():

    for i in ('nvme','usb','usb2'):
        posix.mkdir(posixpath.join(AIROOTFS, f"mnt.{i}"))


def timezone():

    # rm -fv $AIROOTFS/etc/localtime
    posix.symlink('/usr/share/zoneinfo/Asia/Makassar', posixpath.join(AIROOTFS, 'etc/localtime'))


def motd():

    with open(posixpath.join(AIROOTFS, 'etc/motd'), 'r') as f:
        tail = f.read()
    with open(posixpath.join(AIROOTFS, 'etc/motd'), 'w') as f:
        f.write(f'/etc/motd\n\n{tail}')


def authorized_keys():

    posix.mkdir(posixpath.join(AIROOTFS, 'root/.ssh'))

    with open('/home/darren/.ssh/id_rsa.pub', 'r') as r:
        with open(posixpath.join(AIROOTFS, 'root/.ssh/authorized_keys'), 'w') as w:
            w.write(r.read())

    return ['["/root"]="0:0:0750"',
            '["/root/.ssh"]="0:0:0700"',
            '["/root/.ssh/authorized_keys"]="0:0:0600"',]


def backup_script():

    with open(posixpath.join(AIROOTFS, 'exclude_file'), 'w') as f:
        f.write('\n'.join(sorted(IGN_MKSQUASHFS))+'\n')
    shutil.copy(posixpath.join(PROJ, 'mksquashfs.sh'), AIROOTFS)
    posix.symlink('/mksquashfs.sh', posixpath.join(AIROOTFS, 'usr/local/bin/mksquashfs.sh'))
    return ['["/mksquashfs.sh"]="0:0:0755"']


def collect_perms(ps):

    # print(ps)
    # return

    with open(posixpath.join(ARCHLIVE, 'profiledef.sh'), 'r') as f:
        l0 = f.readlines()

    s = ""
    for i in l0:
        s += i
        if i == 'file_permissions=(\n':
            found = True
            for p in ps:
                s += f'  {p}\n'
    assert found

    # print(s, end='')

    with open(posixpath.join(ARCHLIVE, 'profiledef.sh'), 'w') as f:
        f.write(s)


def drop_caches():

    assert subprocess.run(['free', '-h']).returncode == 0
    print('droping caches ...')
    assert subprocess.run(['sudo', 'tee', '/proc/sys/vm/drop_caches'], input=b'3', stdout=subprocess.DEVNULL).returncode == 0
    assert subprocess.run(['free', '-h']).returncode == 0
    print()


def readmnt():

    with open('/proc/mounts', 'r') as f:
        r = f.readlines()
    return r


def syslinux_no_lvds1():

    s = '''
    # Copy to RAM boot option
    LABEL arch64ram
    TEXT HELP
    Boot the Arch Linux install medium on BIOS with Copy-to-RAM option
    It allows you to install Arch Linux or perform system maintenance.
    ENDTEXT
    MENU LABEL Arch Linux install medium (x86_64, BIOS, Copy to RAM)
    LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux
    INITRD /%INSTALL_DIR%/boot/intel-ucode.img,/%INSTALL_DIR%/boot/amd-ucode.img,/%INSTALL_DIR%/boot/x86_64/initramfs-linux.img
    APPEND archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL% copytoram
    '''

    # https://superuser.com/questions/636617/
    # https://unix.stackexchange.com/questions/526608
    # https://www.kernel.org/doc/html/v5.17/fb/modedb.html
    m = 'LVDS-1'
    s2 = f'''
    # Copy to RAM boot option
    LABEL arch64nolvds
    TEXT HELP
    Copy-to-RAM, {m} disabled
    ENDTEXT
    MENU LABEL Arch Linux install medium (x86_64, BIOS, Copy to RAM, {m} disabled)
    LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux
    INITRD /%INSTALL_DIR%/boot/intel-ucode.img,/%INSTALL_DIR%/boot/amd-ucode.img,/%INSTALL_DIR%/boot/x86_64/initramfs-linux.img
    APPEND archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL% copytoram video={m}:d
    '''

    # https://stackoverflow.com/a/47417848/8243991
    s = textwrap.dedent(s).strip() + '\n'
    s2 = textwrap.dedent(s2).strip() + '\n'
    # print(s, end="")

    sys.stdout.writelines(difflib.unified_diff(s.splitlines(keepends=True), s2.splitlines(keepends=True), n=999))
    print()

    with open(posixpath.join(ARCHLIVE, 'syslinux/archiso_sys-linux.cfg'), 'r') as f:
        orig = f.read()
    assert s in orig
    assert s2 not in orig
    with open(posixpath.join(ARCHLIVE, 'syslinux/archiso_sys-linux.cfg'), 'w') as f:
        f.write(f'{orig}\n{s}\n{s2}')


    # ./efiboot/loader/entries/03-archiso-x86_64-ram-linux.conf


def build():

    l = readmnt()

    try:
        input('build iso? ')
        print()
        subprocess.run(['sudo', 'mkarchiso', '-v', '-w', WORK_DIR, '-o', PROJ, ARCHLIVE])
    except KeyboardInterrupt:
        print(' abort\n')

    d = list(difflib.unified_diff(l, readmnt(), n=999))
    if d:
        sys.stdout.writelines(d)
        input('please clean up bind mounts to avoid data loss ')
        print()

    subprocess.run(['sudo', 'chown', '-v', 'darren:darren'] + glob.glob(posixpath.join(PROJ, 'archlinux-*.iso')))
    print()

    input('please sha1sum the newly generated iso and append to /home/darren/sphinx.public/archiso.rst ')
    print()


def main():

    filelight2()

    print()

    assert 'TMUX' in os.environ
    assert posix.getuid() == 1000 and posix.getgid() == 1000

    input('please \'pacman -Syuu\' '); print()

    check_umask()

    copy_releng()
    check_bootstrap_pkg()
    check_pkg()
    emit_pkg()

    convenience_mountpoints()
    timezone()
    motd()
    syslinux_no_lvds1()

    perms = []
    perms += authorized_keys()
    perms += backup_script()
    collect_perms(perms)

    input('please close browser '); print()

    drop_caches()

    if TRIM:
        input('trim? ')
        assert subprocess.run(['sudo', 'systemctl', 'start', 'fstrim.service']).returncode == 0
    else:
        print('trim skipped')
    print()

    build()

    drop_caches()
    print(f'please manually remove {WORK_DIR}\n')




if __name__ == '__main__':
    main()
