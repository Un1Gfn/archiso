#!/bin/python3

import pathlib  # https://docs.python.org/3/library/pathlib.html
import prettytable  # https://github.com/jazzband/prettytable
import shutil
import termcolor
import stat
import posix

ox = lambda b: termcolor.colored("O", 'green') if b else termcolor.colored("X", 'red')


class table_oo:

    def __init__(self):

        self.x = prettytable.PrettyTable()
        self.j = [
            ("oo", ),
            ("d", "is_dir"),
            ("c", "is_char_device"),
            ("b", "is_block_device"),
            ("f", "is_file"),
            ("e", "exists"),
            ("s", "is_symlink"),
        ]
        self.x.field_names = [t[0] for t in self.j]
        self.x.align[self.j[0][0]] = 'r'

    def append(self, s, pobj):

        self.x.add_row([s] + [ox(getattr(pobj, self.j[i + 1][1])()) for i in range(len(self.j) - 1)])


class table_stat:

    def __init__(self, follow_symlinks):

        self.follow_symlinks = follow_symlinks
        self.x = prettytable.PrettyTable()
        self.j = [
            ("stat_F" if follow_symlinks else "stat_NF", ),
            ("d", "S_ISDIR"),
            ("c", "S_ISCHR"),
            ("b", "S_ISBLK"),
            ("f", "S_ISREG"),
            ("s", "S_ISLNK"),
        ]
        self.x.field_names = [t[0] for t in self.j]
        self.x.align[self.j[0][0]] = 'r'

    def append(self, s, path):

        try:
            r = [s] + [ox(getattr(stat, self.j[i + 1][1])(posix.stat(path, follow_symlinks=self.follow_symlinks).st_mode)) for i in range(len(self.j) - 1)]
        # except RuntimeError:
        except FileNotFoundError:
            r = [s] + ["E"] * (len(self.j)-1)
        self.x.add_row(r)


def main():

    print()

    _ = pathlib.PosixPath("/path/to/nonexist")
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

    p.mkdir()
    D.mkdir()
    F.touch()
    L_.symlink_to(_)
    LD.symlink_to(D)
    LC.symlink_to(C)
    LB.symlink_to(B)
    LF.symlink_to(F)

    l = [table_oo(), table_stat(True), table_stat(False)]
    for tb in l:
        tb.append("dead", _)
        tb.append("symlink_dead", L_)
        tb.append("symlink_dir", LD)
        tb.append("symlink_cdev", LC)
        tb.append("symlink_bdev", LB)
        tb.append("symlink_file", LF)
        tb.append("dir", D)
        tb.append("cdev", C)
        tb.append("bdev", B)
        tb.append("file", F)
        print(tb.x)
        print()

    shutil.rmtree(p)


if __name__ == '__main__':
    main()
