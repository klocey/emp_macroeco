from __future__ import division
import matplotlib.pyplot as plt
import pyximport; pyximport.install()
import pandas as pd
import numpy as np
import sys
import os

mydir = os.path.expanduser("~/")
sys.path.append(mydir + "GitHub/emp_nested/code/metrics/nodf")
import nodf

sys.path.append(mydir + "GitHub/emp_nested/code/metrics/SiteByTaxa")
import SiteByTaxa

fig = plt.figure()
ax = fig.add_subplot(1,1,1)

colors = ['c', 'm', '0.4', 'cornflowerblue', 'olive']
tlevels = ['Phylum', 'Class', 'Order', 'Family', 'Genus']
plevels = ['1', '5', '10']


for j, plevel in enumerate(plevels):
    for k, tlevel in enumerate(tlevels):

        print '\n', plevel, tlevel

        df = pd.read_csv(mydir + 'GitHub/emp_nested/data/EMP'+plevel+'_ForNested/EMP'+tlevel+'-'+plevel+'-ForNested.csv')
        df.columns = ['SAMPLE_RANK', 'OBSERVATION_RANK', 'SAMPLE_ID', 'OBSERVATION_ID', 'empo_3', 'METADATA_NUMERIC_CODE']

        m = SiteByTaxa.SBT(df)
        cols = m.shape[1]

        subsets = np.linspace(50, cols, num=20, endpoint=False, dtype=int).tolist()

        print ": adding sites of decreasing S:"
        from_left = []
        for i in subsets:
            m_sub = m[:, 0:i+1]
            RC, R, C = nodf.NODF(m_sub)

            smax = m_sub[:,-1]
            print i, C, int(smax.sum(axis=0))
            from_left.append(C)

        plt.plot(np.log10(subsets), from_left, color=colors[j], linewidth=3, label=tlevel)

    plt.xlabel('# of included columns, '+'$log$'+r'$_{10}$', fontsize=16)
    plt.ylabel('NODF', fontsize=16)
    plt.text(1.5, 0.95, 'Starting from the high richness end of the matrix, NODF\ndecreases as samples of lesser richness are added.', fontsize=16)

    plt.legend(loc='center right', bbox_to_anchor=(1.3, 0.5))

    plt.savefig(mydir + 'GitHub/emp_nested/figures/EMP' + plevel+ '-' + tlevel + '_scaling.png', dpi=600, bbox_inches = "tight")
    plt.close()
