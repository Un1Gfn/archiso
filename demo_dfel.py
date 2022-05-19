#!/bin/python3

import posix
import posixpath
import prettytable
import pydoc
import shutil
import termcolor
from inspect import *

x = None

# def list_functions(module):
#     l = getmembers(
#         module,
#         lambda x: ismethod(x) or isfunction(x) or isbuiltin(x) or isroutine(x))
#     s = ""
#     for _, f in l:
#         s += f.__name__
#         s += "\n"
#     pydoc.pager(s)
#     for _, f in l:
#         print(f.__name__ + "()")

# def clean(path):
#     posix.system(f"rm -rf {path}")
#     # os.unlink()
#     # try:
#     #     shutil.rmtree(TARGET)
#     # except FileNotFoundError as e:
#     #     print(e)


def table_init():

    global x
    x = prettytable.PrettyTable()
    x.fns0 = [
        ("type", None),
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

    # list_functions(os)
    # list_functions(posixpath)
    # list_functions(posix)
    # list_functions(shutil)

    TESTDIR = "/tmp/test"
    L_ = f"{TESTDIR}/link2dead"
    LD = f"{TESTDIR}/link2dir"
    LF = f"{TESTDIR}/link2file"
    D = f"{TESTDIR}/dir"
    F = f"{TESTDIR}/file"
    table_init()

    try:
        shutil.rmtree(TESTDIR)
    except:
        FileNotFoundError
    posix.mkdir(TESTDIR)

    posix.symlink("/path/to/nonexist", L_)
    posix.mkdir(D)
    posix.symlink(D, LD)
    open(F, 'w').close()
    posix.symlink(F, LF)

    table_append("nonexist", "/NONEXIST")
    table_append("symlink2dead", L_)
    table_append("symlink2dir", LD)
    table_append("symlink2file", LF)
    table_append("dir", D)
    table_append("file", F)
    print(x)

    try:
        shutil.rmtree(TESTDIR)
    except:
        FileNotFoundError


if __name__ == '__main__':
    main()
