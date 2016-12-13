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


GenPath = mydir + 'GitHub/emp_nested/data/bootstrap/'
'''
OUT = open(GenPath + 'bootstrap.csv','w')
print>>OUT,'RowID,plevel,taxa_level,cols_or_rows,n,nodf,ses'
OUT.close()
'''


fig = plt.figure()
ax = fig.add_subplot(1,1,1)

tlevels = ['Phylum', 'Class', 'Order', 'Family', 'Genus']
plevels = ['1'] #['1', '5', '10']

rowID = 755
by = 'cols'
iteration = 1

for i in range(10000):
    iteration += 1
    for j, plevel in enumerate(plevels):
        for k, tlevel in enumerate(tlevels):

            df = pd.read_csv(mydir + 'GitHub/emp_nested/data/EMP'+plevel+'_ForNested/EMP'+tlevel+'-'+plevel+'-ForNested.csv')
            df.columns = ['SAMPLE_RANK', 'OBSERVATION_RANK', 'SAMPLE_ID', 'OBSERVATION_ID', 'empo_3', 'METADATA_NUMERIC_CODE']

            m = SiteByTaxa.SBT(df)
            rows = m.shape[0]
            cols = m.shape[1]

            subsets = []
            if by == 'rows':
                subsets = (10.0**np.linspace(np.log10(20), np.log10(rows-1), num=10, endpoint=True, dtype=np.dtype('f8'))).astype(int).tolist()
            elif by == 'cols':
                subsets = (10.0**np.linspace(np.log10(50), np.log10(cols-100), num=10, endpoint=True, dtype=np.dtype('f8'))).astype(int).tolist()

            for n in subsets:
                for ii in range(10):

                    if by == 'cols':
                        m_sub = m[: , np.random.choice(cols, n, replace=False)] # randomly sample columns

                    if by == 'rows':
                        m_sub = m[np.random.choice(rows, n, replace=False), :] # randomly sample rows

                    m_sub = np.asarray(sorted(m_sub, key=sum, reverse=True)) # sort by rows
                    m_sub = np.asmatrix(m_sub)
                    m_sub = m_sub.transpose()

                    m_sub = np.asarray(m_sub)
                    m_sub = np.asarray(sorted(m_sub, key=sum, reverse=True)) # sort by columns
                    m_sub = np.asmatrix(m_sub)
                    m_sub = m_sub.transpose()
                    m_sub = np.asarray(m_sub)

                    NODF, ses = nodf.SES_NODF_Cols(m_sub)

                    outlist = [rowID, plevel, tlevel, by, n, NODF, ses]
                    outlist = str(outlist).strip('[]')
                    outlist = outlist.replace(" ", "")

                    OUT = open(GenPath + 'bootstrap.csv','a+')
                    print>>OUT, outlist
                    OUT.close()
                    rowID += 1

                    print iteration, rowID, plevel, tlevel, by, n, NODF, ses
