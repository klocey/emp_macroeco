from __future__ import division
import matplotlib.pyplot as plt
import pyximport; pyximport.install()
import pandas as pd
import numpy as np
#import sys
import os

mydir = os.path.expanduser("~/")

GenPath = mydir + 'GitHub/emp_nested/data/bootstrap'
dat = pd.read_csv(GenPath + '/bootstrap.csv')

#taxa_level,n,nodf,ses

fig = plt.figure()
ax = fig.add_subplot(2,2,1)

tlevels = ['Phylum', 'Class', 'Order', 'Family', 'Genus']
colors = ['olive', 'm', '0.4', 'cornflowerblue', 'c']

ses97 = []
ses2 = []

for i, tlevel in enumerate(tlevels):

    df = dat[dat['taxa_level'].str.contains(tlevel)]
    ns = dat['n'].unique().tolist()
    nodf97 = []
    nodf2 = []

    for n in ns:
        df2 = df[df['n'] == n]
        nodfs = df2['nodf']

        p97 = np.percentile(nodfs, 97.5)
        nodf97.append(p97)
        p2 = np.percentile(nodfs, 2.5)
        nodf2.append(p2)

        print n, np.mean(nodfs)

    plt.fill_between(np.log10(ns), nodf2, nodf97, interpolate=True, alpha=0.6, color = colors[i], label=tlevel)

plt.tick_params(axis='both', which='major', labelsize=8)
plt.xlabel('# of randomly selected columns, '+'$log$'+r'$_{10}$', fontsize=10)
plt.ylabel('NODF', fontsize=16)

plt.legend(bbox_to_anchor=(-0.04, 1.05, 2.48, .2), loc=10, ncol=5, mode="expand",prop={'size':10})

ax = fig.add_subplot(2,2,2)
for i, tlevel in enumerate(tlevels):

    df = dat[dat['taxa_level'].str.contains(tlevel)]
    ns = dat['n'].unique().tolist()

    ses97 = []
    ses2 = []

    for n in ns:
        df2 = df[df['n'] == n]
        sess = df2['ses']

        p97 = np.percentile(sess, 97.5)
        ses97.append(p97)
        p2 = np.percentile(sess, 2.5)
        ses2.append(p2)

        print n, np.mean(sess)

    plt.fill_between(np.log10(ns), ses2, ses97, interpolate=True, alpha=0.6, color = colors[i], label=tlevel)

plt.tick_params(axis='both', which='major', labelsize=8)
plt.xlabel('# of randomly selected columns, '+'$log$'+r'$_{10}$', fontsize=10)
plt.ylabel('SES', fontsize=16)

plt.subplots_adjust(wspace=0.4, hspace=0.4)
plt.savefig(mydir + 'GitHub/emp_nested/figures/EMP_scaling.png', dpi=600, bbox_inches = "tight")
plt.close()
