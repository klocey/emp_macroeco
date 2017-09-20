from __future__ import division
from biom import load_table
import os
import sys
import numpy as np
import scipy as sc

mydir = os.path.expanduser("~/GitHub/emp_nested")

mydir2 = os.path.expanduser("~/")
table = load_table(mydir2 + 'Desktop/emp-data/emp_deblur_90bp.subset_2k.biom')
rows, cols = table.shape

rads = []

for i in range(cols):
    rad = table[:, i]
    #print i, rad
    #sys.exit()

    rad = sc.sparse.find(rad)
    print rad
    #sys.exit()

    rad = rad[2].tolist()
    print rad
    sys.exit()

    rad = [int(j) for j in rad]
    rad.sort()
    rad.reverse()

    rads.append(rad)
    print i

########### PATHS ##############################################################

for i, obs in enumerate(rads):

    N = int(sum(obs))
    S = int(len(obs))
    print i, 'N:', N, ' S:', S

    OUT = open(mydir+'/data/emp_sads.txt','a+')
    for j, ab in enumerate(obs):
        print>> OUT, i, ab
    OUT.close()
