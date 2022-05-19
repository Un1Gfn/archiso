#!/bin/python3

import os
import pydoc
from inspect import *


def list_functions(module):
    l = getmembers(module, lambda x: ismethod(x) or isfunction(x) or isbuiltin(x) or isroutine(x))
    s = ""
    for _, f in l:
        s += f.__name__
        s += "\n"
    pydoc.pager(s)
    for _, f in l:
        print(f.__name__ + "()")


def main():

    list_functions(os)


if __name__ == '__main__':
    main()
