#!/bin/python3

import pathlib  # https://docs.python.org/3/library/pathlib.html
import prettytable
import shutil
import termcolor

x = None


def table_init():

    global x
    x = prettytable.PrettyTable()
    x.fns0 = [
        ("type", ),
        ("d", "is_dir"),
        ("c", "is_char_device"),
        ("b", "is_block_device"),
        ("f", "is_file"),
        ("e", "exists"),
        ("l", "is_symlink"),
    ]
    x.field_names = [t[0] for t in x.fns0]
    x.align['type'] = 'l'


def table_append(s, pp):

    global x
    ox = lambda b: termcolor.colored("O", 'green') if b else termcolor.colored("X", 'red')
    x.add_row([s] + [ox(getattr(pp, x.fns0[i + 1][1])()) for i in range(len(x.fns0) - 1)])


def main():

    _ = pathlib.PosixPath("/pp/to/nonexist")
    p = pathlib.PosixPath("/tmp/test_oo")
    D = p / "dir"
    C = pathlib.PosixPath("/dev/zero")
    B = pathlib.PosixPath("/dev/nvme0n1")
    F = p / "file"
    L_ = p / "link2dead"
    LD = p / "link2dir"
    LC = p / "link2cdev"
    LB = p / "link2bdev"
    LF = p / "link2file"

    try:
        shutil.rmtree(p)
    except FileNotFoundError:
        pass
    # exit()

    p.mkdir()
    D.mkdir()
    F.touch()
    L_.symlink_to(_)
    LD.symlink_to(D)
    LC.symlink_to(C)
    LB.symlink_to(B)
    LF.symlink_to(F)

    table_init()
    table_append("nonexist", _)
    table_append("symlink2dead", L_)
    table_append("symlink2dir",  LD)
    table_append("symlink2cdev", LC)
    table_append("symlink2bdev", LB)
    table_append("symlink2file", LF)
    table_append("dir",  D)
    table_append("cdev", C)
    table_append("bdev", B)
    table_append("file", F)
    print(x)


if __name__ == '__main__':
    main()
