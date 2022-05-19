#!/bin/python3

import re
import os
import pyalpm
import termcolor
import colorama
from archiso_conf import *


def hint():

    INDT = "  "
    print(f"{INDT}(1) pacman -Syuu")
    print(f"{INDT}(2) ...")
    print()

def filelightrc():

    with open(FILELIGHTRC, 'r') as rc: orig = rc.readlines()
    new = ""
    # re.sub(r'^skipList.*$', "XXXXXXXXXXXXXXXXXX", line)
    for line in orig: new += re.sub(r'^skipList.*$', "skipList[$e]="+",".join(IGN_FILELIGHT), line)
    print(new,end="")
    with open(FILELIGHTRC, 'w') as rc: assert len(new) == rc.write(new)


def check_umask():

    # https://docs.python.org/3/reference/lexical_analysis.html#integer-literals
    assert 0o0022 == os.umask(0o0022)


def check_bootstrap():

    for C in (BASELINE, RELENG, ):
        # print(C)
        with open(f"{C}/{BTPKG}", 'r') as f:
            assert "arch-install-scripts\nbase\n" == f.read()


def validpkgname(s):

    return bool(re.match(r"^[0-9a-z@_+][0-9a-z@._+-]*\Z", s))


def pkglistfile2set(path):

    with open(path, 'r') as f:
        l = f.readlines()
        assert l
        # https://docs.python.org/3/library/functions.html#all
        # https://wiki.archlinux.org/title/Arch_package_guidelines#Package_naming
        l = [ s.rstrip('\n') for s in l ]
        assert all(validpkgname(s) for s in l)
        assert all(l[i] < l[i+1] for i in range(len(l) - 1))
    r = set(l)
    assert len(l) == len(r)
    return r


def pkg():

    # baseline and releng are sorted and newline-terminated
    # baseline is a proper subset of releng
    baselineset = pkglistfile2set(f"{BASELINE}/{PKG}")
    relengset = pkglistfile2set(f"{RELENG}/{PKG}")
    assert baselineset < relengset

    assert MYPKG
    assert all(validpkgname(s) for s in MYPKG)

    # optionally find duplicates in MYPKG
    # https://stackoverflow.com/a/9835819/
    uniq = set()
    if STRICT_MYPKG:
        dups = [x for x in MYPKG if x in uniq or uniq.add(x)]
        print("duplicates:", dups)
    else:
        uniq = set(MYPKG)

    # all of MYPKG exist in sync db
    assert "13.0.1" == pyalpm.alpmversion()
    h = pyalpm.Handle("/", "/var/lib/pacman")
    for i in ["core", "extra", "community", "multilib"]:
        h.register_syncdb(i, pyalpm.SIG_DATABASE_MARGINAL_OK)  # https://www.gnupg.org/gph/en/manual/x334.html#AEN345
    missing = []
    for i in uniq:
    # for i in relengset:
        if not any(db.get_pkg(i) for db in h.get_syncdbs()):
            missing.append(i)
    if missing:
        raise RuntimeError(f"{missing} not found")

    myset = set(MYPKG)
    print(colorama.Fore.RED,   "---", sorted(relengset-myset), colorama.Style.RESET_ALL, "\n")
    print(colorama.Fore.GREEN, "+++", sorted(myset-relengset), colorama.Style.RESET_ALL, "\n")



    # sorted(myset)


def main():

    print()

    hint()

    # filelightrc()

    # check_umask()

    # check_bootstrap()

    pkg()

    print()


if __name__ == "__main__":
    main()


