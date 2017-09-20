from __future__ import division
import sys
import os
import numpy as np
from scipy import stats

mydir = os.path.expanduser("~/GitHub/emp_nested")

sys.path.append(mydir + "/tools/DiversityTools/metrics")
import metrics

def import_obs_pred_data(input_filename):
    # TAKEN FROM THE mete_sads.py script used for White et al. (2012)
    data = np.genfromtxt(input_filename, dtype = "S15, f8",
    names = ['site','obs'], delimiter = " ")
    return data

########### END FUNCTIONS ######################################################

RADs = []

filename = mydir+'/data/emp_sads.txt'
data = import_obs_pred_data(filename)
site = np.asarray(list(((data["site"])))).tolist()
obs = np.asarray(list(((data["obs"])))).tolist()

val = site[0]
rad = []
for i, s in enumerate(site):
    if s == val:
        rad.append(obs[i])
    else:
        val = s
        RADs.append(rad)
        rad = []

print len(RADs)

filename = mydir+'/data/SADs/SAD_metric_data/SAD_metric_data.txt'
OUT = open(filename,'w+')

ct = 0
numRADs = len(RADs)
for RAD in RADs:

    RAD = list([x for x in RAD if x > 0]) # greater than 1 means singletons are excluded

    N = sum(RAD)
    S = len(RAD)

    #if N > 10**4: continue

    # Evenness
    Evar = metrics.e_var(RAD)
    ESimp = metrics.e_simpson(RAD)

    # Dominance
    Nmax = max(RAD)

    # Rarity
    # log-modulo transformation of skewnness
    skew = stats.skew(RAD)
    lms = np.log10(np.abs(float(skew)) + 1)
    if skew < 0: lms = lms * -1

    # Preston's alpha and richness, from Curtis and Sloan (2002).
    # Estimating prokaryotic diversity and its limits. PNAS.
    #chao1, ace, jknife1, jknife2 = metrics.EstimateS1(RAD)
    #preston_a, preston_S = metrics.Preston(RAD)

    # Richness estimators
    margalef = metrics.Margalef(RAD)
    menhinick = metrics.Menhinick(RAD)

    ct+=1
    print>>OUT, N, S, Evar, ESimp, Nmax, lms, margalef, menhinick
    print numRADs - ct

OUT.close()
