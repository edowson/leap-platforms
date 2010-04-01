############################################################################
############################################################################
##
## Utility functions used in this module and in submodules
##
############################################################################
############################################################################

import os
import re
import sys
import string

##
## clean_split --
##     Split a string into a list using specified separator (default ':'),
##     dropping empty entries.
##
def clean_split(list, sep=':'):
    return [x for x in list.split(sep) if x != '' ]

##
## rebase_directory --
##     Rebase directory (d) that is a reference relative to the root build
##     directory, returning a result relative to cwd.  cwd must also be
##     relative to the root build directory.
##
def rebase_directory(d, cwd):
    d = clean_split(d, sep='/')
    cwd = clean_split(cwd, sep='/')

    for x in cwd:
        if (len(d) == 0 or d[0] != x):
            d.insert(0, '..')
        else:
            d.pop(0)

    if (len(d) == 0): d = [ '.' ]
    return '/'.join(d)

##
## transform_string_list --
##     Interpret incoming string (str) as a list of substrings separated by (sep).
##     Add (prefix) and (suffix) to each substring and return a modified string.
##
def transform_string_list(str, sep, prefix, suffix):
    if (sep == None):
        sep = ' '
    t = [ prefix + a + suffix for a in clean_split(str, sep) ]
    return string.join(t, sep)


##
## As of Bluespec 2008.11.C the -bdir target is put at the head of the search path
## and the compiler complains about duplicate path entries.
##
## This code removes the local build target from the search path.
##
def bsc_bdir_prune(env, str, sep, match):
    t = clean_split(str, sep)
    if (env['DEFS']['BSC_VERSION'] >= 15480):
        try:
            while 1:
                i = t.index(match)
                del t[i]
        except ValueError:
            pass
    return string.join(t, sep)
    
##
## one_line_cmd --
##     Issue a shell command and return the first line of output
##
def one_line_cmd(cmd):
    p = os.popen(cmd)
    r = p.read().rstrip()
    p.close()
    return r


##
## awb_resolver --
##     Ask awb-resolver for some info.  Return the first line.
##
def awb_resolver(arg):
    return one_line_cmd("awb-resolver " + arg)

