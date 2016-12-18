from __future__ import division
import functools
#import sys
import os

mydir = os.path.expanduser("~/")
Path = mydir + 'GitHub/emp_nested/'

OUT = open(Path + 'data/EMP_SSADs/emp_deblur_90bp.subset_2k.txt','w+')

SSADs = []
IN = mydir + 'Desktop/emp_deblur_90bp.subset_2k.biom'

c1 = '{'

row = str()
switch = 'off'

clist = ['1','2','3','4','5','6','7','8','9','0','.']

with open(IN) as f:

    f_read_ch = functools.partial(f.read, 1)
    for c in iter(f_read_ch, ''):

        if switch == 'on':

            if c == ']' and c1 == ']':
                print>> OUT, row
                break

            if c in clist: row+=c

            elif c == ',': row+=' '

            elif c == '[': row = str()

            elif c == ']':
                print>> OUT, row
                row = str()

        elif c == '0' and c1 == '[' and switch == 'off':
            row+=c
            switch = 'on'

        c1 = c

OUT.close()
