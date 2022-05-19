#!/bin/python3

import posix
import posixpath
import prettytable
import shutil
import termcolor

x = None


def table_init():

    global x
    x = prettytable.PrettyTable()
    x.fns0 = [
        ("type", ),
        ("d", "isdir"),
        ("f", "isfile"),
        ("e", "exists"),
        ("l", "islink"),
        ("le", "lexists"),
    ]
    x.field_names = [t[0] for t in x.fns0]
    x.align["type"] = "r"
    x.align["le"] = "r"


def table_append(s, path):

    global x
    ox = lambda b: termcolor.colored("O", 'green') if b else termcolor.colored("X", 'red')

    # https://stackoverflow.com/questions/3061
    # x.add_row([s] + [ox(locals()[x.fns0[i+1][1]](path)) for i in range(len(x.fns0) - 1)])
    # x.add_row([s] + [ox(globals()[x.fns0[i+1][1]](path)) for i in range(len(x.fns0) - 1)])
    x.add_row([s] + [ox(getattr(posixpath, x.fns0[i + 1][1])(path)) for i in range(len(x.fns0) - 1)])


def main():


    TESTDIR = "/tmp/test"
    _  = "/path/to/nonexist"
    D  = f"{TESTDIR}/dir"
    F  = f"{TESTDIR}/file"
    L_ = f"{TESTDIR}/link2dead"
    LD = f"{TESTDIR}/link2dir"
    LF = f"{TESTDIR}/link2file"
    table_init()

    try: shutil.rmtree(TESTDIR)
    except FileNotFoundError: pass
    posix.mkdir(TESTDIR)

    posix.symlink(_, L_)
    posix.mkdir(D)
    posix.symlink(D, LD)
    open(F, 'w').close()
    posix.symlink(F, LF)

    table_append("nonexist",     _)
    table_append("symlink2dead", L_)
    table_append("symlink2dir",  LD)
    table_append("symlink2file", LF)
    table_append("dir",           D)
    table_append("file",          F)
    print(x)

    try:
        shutil.rmtree(TESTDIR)
    except:
        FileNotFoundError


if __name__ == '__main__':
    main()
