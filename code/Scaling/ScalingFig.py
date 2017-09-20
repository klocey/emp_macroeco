from __future__ import division
import  matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os
import sys

import random
import scipy as sc
from scipy import stats

import statsmodels.stats.api as sms
import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.stats.outliers_influence import summary_table

mydir = os.path.expanduser("~/GitHub/emp_nested")
sys.path.append(mydir+'/tools')

filename = mydir+'/data/SADs/SAD_metric_data/SAD_metric_data.txt'
DATA = open(filename,'r')

Ns1 = []
Ss = []
Evs = []
Nmaxs = []
Rs = []

for data in DATA:

    data = data.split()
    N, S, Evar, ESimp, Nmax, lms, margalef, menhinick = data

    if np.log10(float(lms)) > -1:

        Ns1.append(float(N))
        Ss.append(float(S))
        Nmaxs.append(float(Nmax))
        Evs.append(float(ESimp))
        Rs.append(float(lms))


Ns1   = np.log10(Ns1).tolist()
Ss    = np.log10(Ss).tolist()
Evs   = np.log10(Evs).tolist()
Nmaxs = np.log10(Nmaxs).tolist()
Rs    = np.log10(Rs).tolist()


metrics = ['Rarity, '+r'$log_{10}$',
        'Dominance, '+r'$log_{10}$',
        'Evenness, ' +r'$log_{10}$',
        'Richness, ' +r'$log_{10}$']


fig = plt.figure()
fs = 12 # font size used across figures
for index, metric in enumerate(metrics):

    Ns = list(Ns1)

    fig.add_subplot(2, 2, index+1)

    metlist = []
    if index == 0: metlist = list(Rs)
    elif index == 1: metlist = list(Nmaxs)
    elif index == 2: metlist = list(Evs)
    elif index == 3: metlist = list(Ss)

    print len(Ns), len(metlist)

    d = pd.DataFrame({'N': list(Ns)})
    d['y'] = list(metlist)
    f = smf.ols('y ~ N', d).fit()

    r2 = round(f.rsquared,2)
    Int = f.params[0]
    Coef = f.params[1]

    st, data, ss2 = summary_table(f, alpha=0.05)
    # ss2: Obs, Dep Var Population, Predicted Value, Std Error Mean Predict,
    # Mean ci 95% low, Mean ci 95% upp, Predict ci 95% low, Predict ci 95% upp,
    # Residual, Std Error Residual, Student Residual, Cook's D

    fitted = data[:,2]
    #predict_mean_se = data[:,3]
    mean_ci_low, mean_ci_upp = data[:,4:6].T
    ci_low, ci_upp = data[:,6:8].T
    ci_Ns = data[:,0]

    Ns, metlist, fitted, ci_low, ci_upp = zip(*sorted(zip(Ns, metlist, fitted, ci_low, ci_upp)))

    plt.scatter(Ns, metlist, color = 'LightCoral', alpha= 1 , s = 8, linewidths=0.5, edgecolor='Crimson')
    plt.fill_between(Ns, ci_upp, ci_low, color='r', lw=0.1, alpha=0.2)
    plt.plot(Ns, fitted,  color='r', ls='--', lw=1.0, alpha=0.9)

    plt.xlim(1.5, 5.8)

    if index == 0:
        plt.text(1.7, 0.2, r'$rarity$'+ ' = '+str(round(10**Int,2))+'*'+r'$N$'+'$^{'+str(round(Coef,2))+'}$', fontsize=fs-2, color='k')
        plt.text(1.7, 0.02,  r'$r^2$' + '=' +str(r2), fontsize=fs-2, color='k')
        pass

    elif index == 1:

        plt.text(1.7, 5.0, r'$Nmax$'+ ' = '+str(round(10**Int,2))+'*'+r'$N$'+'$^{'+str(round(Coef,2))+'}$', fontsize=fs-2, color='k')
        plt.text(1.7, 4.1,  r'$r^2$' + '=' +str(r2), fontsize=fs-2, color='k')
        pass

    elif index == 2:

        plt.text(1.7, -2.5, r'$Ev$'+ ' = '+str(round(10**Int,2))+'*'+r'$N$'+'$^{'+str(round(Coef,2))+'}$', fontsize=fs-2, color='k')
        plt.text(1.7, -3.0,  r'$r^2$' + '=' +str(r2), fontsize=fs-2, color='k')
        pass

    elif index == 3:

        plt.text(1.7, 4.0, r'$S$'+ ' = '+str(round(10**Int,2))+'*'+r'$N$'+'$^{'+str(round(Coef,2))+'}$', fontsize=fs-2, color='k')
        plt.text(1.7, 3.2,  r'$r^2$' + '=' +str(r2), fontsize=fs-2, color='k')
        pass

    plt.xlabel('$log$'+r'$_{10}$'+'($N$)', fontsize=fs)
    plt.ylabel(metric, fontsize=fs)
    plt.tick_params(axis='both', which='major', labelsize=fs-3)


#### Final Format and Save #####################################################
plt.subplots_adjust(wspace=0.4, hspace=0.4)
plt.savefig(mydir + '/figures/Scaling/scaling-fig.png', dpi=600, bbox_inches = "tight")
#plt.show()
plt.close()
