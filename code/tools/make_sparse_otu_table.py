from __future__ import division
from biom import load_table
import os
import sys
import numpy as np
import scipy as sc
from scipy.stats.kde import gaussian_kde
from numpy import empty
from scipy.stats import nbinom
import time

mydir = os.path.expanduser("~/GitHub/emp_nested")
tools = os.path.expanduser(mydir + "/tools/DiversityTools")

sys.path.append(tools + "/macroeco_distributions")
import macroeco_distributions as md
sys.path.append(tools + "/distributions")
import distributions as dist
sys.path.append(tools + "/macroecotools")
import macroecotools as mct
sys.path.append(tools + "/metrics")
import metrics
sys.path.append(tools + "/mete")
import mete

from macroeco_distributions import pln, pln_solver

mydir2 = os.path.expanduser("~/")
table = load_table(mydir2 + 'Desktop/emp_deblur_90bp.subset_2k.biom')
rows, cols = table.shape

rads = []

for i in range(cols):
    rad = table[:, i]
    rad = sc.sparse.find(rad)
    rad = rad[2].tolist()

    rad = [int(j) for j in rad]
    rad.sort()
    rad.reverse()

    rads.append(rad)
    print i

########### PATHS ##############################################################


def get_kdens_choose_kernel(_list,kernel):
    """ Finds the kernel density function across a sample of SADs """
    density = gaussian_kde(_list)
    n = len(_list)
    xs = np.linspace(min(_list),max(_list),n)
    #xs = np.linspace(0.0,1.0,n)
    density.covariance_factor = lambda : kernel
    density._compute_covariance()
    D = [xs,density(xs)]
    return D


def get_rad_pln(S, mu, sigma, lower_trunc = True):
    """Obtain the predicted RAD from a Poisson lognormal distribution"""
    abundance = list(empty([S]))
    rank = range(1, int(S) + 1)
    cdf_obs = [(rank[i]-0.5) / S for i in range(0, int(S))]
    j = 0
    cdf_cum = 0
    i = 1
    while j < S:
        cdf_cum += pln.pmf(i, mu, sigma, lower_trunc)
        while cdf_cum >= cdf_obs[j]:
            abundance[j] = i
            j += 1
            if j == S:
                abundance.reverse()
                return abundance
        i += 1


def get_rad_negbin(S, n, p):
    """Obtain the predicted RAD from a negative binomial distribution"""
    abundance = list(empty([S]))
    rank = range(1, int(S) + 1)
    cdf_obs = [(rank[i]-0.5) / S for i in range(0, int(S))]
    j = 0
    cdf_cum = 0
    i = 1
    while j < S:
        cdf_cum += nbinom.pmf(i, n, p) / (1 - nbinom.pmf(0, n, p))
        while cdf_cum >= cdf_obs[j]:
            abundance[j] = i
            j += 1
            if j == S:
                abundance.reverse()
                return abundance
        i += 1

def get_rad_from_obs(ab, dist):
    mu, sigma = pln_solver(ab)
    pred_rad = get_rad_pln(len(ab), mu, sigma)
    return pred_rad


for i, obs in enumerate(rads):

    N = int(sum(obs))
    S = int(len(obs))
    print i, 'N:', N, ' S:', S

    t = time.clock()
    result = mete.get_mete_rad(S, N)
    predRAD = result[0]
    OUT = open(mydir+'/data/emp_mete_obs_pred.txt','a+')
    for j, ab in enumerate(obs):
        print>> OUT, i, ab, predRAD[j]
    OUT.close()
    print i, 'mete done in ', round(time.clock() - t, 1)

    '''
    zipf_pred = dist.zipf(obs)
    predRAD = zipf_pred.from_cdf()
    OUT = open(mydir+'/data/emp_zipf_obs_pred.txt','a+')
    for j, ab in enumerate(obs):
        print>> OUT, i, ab, predRAD[j]
    OUT.close()
    print i, 'zipf done'
    '''

    t = time.clock()
    plnrad = get_rad_from_obs(obs, 'pln')
    OUT = open(mydir+'/data/emp_pln_obs_pred.txt','a+')
    for j, ab in enumerate(obs):
        print>> OUT, i, ab, plnrad[j]
    OUT.close()
    print i, 'pln done in ', round(time.clock() - t, 1)
