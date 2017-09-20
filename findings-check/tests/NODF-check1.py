from __future__ import division
import matplotlib.pyplot as plt
import pyximport; pyximport.install()
import pandas as pd
import numpy as np
import sys
import os

mydir = os.path.expanduser("~/")
sys.path.append(mydir + "GitHub/emp_macroeco/findings-check/nodf")
import nodf
sys.path.append(mydir + "GitHub/emp_macroeco/findings-check/SiteByTaxa")
import SiteByTaxa

GenPath = mydir + 'GitHub/emp_macroeco/findings-check/'

OUT = open(GenPath + 'nestedness_null_model_results_Locey.csv','w')
print>>OUT,'EMPO_SUBSET,TAXONOMIC_LEVEL,NODF_NULL_MEAN,NODF_NULL_STDEV,NODF_OBSERVED'
OUT.close()


gfiles = ['Animal', 'allsamples', 'Non-saline', 'Plant', 'Saline']
for fname in gfiles:

    df = pd.read_csv(GenPath + 'graphs/graphs.phylum.' + fname + '.csv')
    m = SiteByTaxa.SBT(df)

    obsRC, obsR, obsC = nodf.NODF(m)
    print obsRC, obsR, obsC

    nullNODFs_C = []
    nullNODFs_R = []
    nullNODFs_RC = []

    for i in range(10):
        #np.random.shuffle(m)
        #m = m[:, np.random.permutation(m.shape[1])]
        for j in range(m.shape[1]):
            np.random.shuffle(m[:,j])

        RC, R, C = nodf.NODF(m)
        nullNODFs_R.append(R)
        nullNODFs_C.append(C)
        nullNODFs_RC.append(RC)

    MEAN_C = np.mean(nullNODFs_C)
    STDEV_C = np.std(nullNODFs_C)
    MEAN_R = np.mean(nullNODFs_R)
    STDEV_R = np.std(nullNODFs_R)
    MEAN_RC = np.mean(nullNODFs_RC)
    STDEV_RC = np.std(nullNODFs_RC)

    n = 'All'
    if fname == 'Animal': n = 'Animal'
    elif fname == 'Plant': n = 'Plant'
    elif fname == 'Saline': n = 'Saline'
    elif fname == 'Non-saline': n = 'Nonsaline'

    outlist = [n, 'phylum', MEAN_C, STDEV_C, obsC]
    outlist = str(outlist).strip('[]')
    outlist = outlist.replace(" ", "")
    outlist = outlist.replace("'", "")

    OUT = open(GenPath + 'nestedness_null_model_results_Locey.csv','a+')
    print>>OUT,outlist
    OUT.close()

    print n, 'rows:', MEAN_R, STDEV_R, obsR
    print n, 'cols:', MEAN_C, STDEV_C, obsC
    print n, 'both:', MEAN_RC, STDEV_RC, obsRC,'\n'
