from __future__ import division
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys
import os

# http://www.nature.com/articles/srep08182?WT.ec_id=SREP-631-20150203&spMailingID=47943602&spUserID=MzcwNDE0MDA3MTMS1&spJobID=620335661&spReportId=NjIwMzM1NjYxS0

def SBT(df):

    maxs = df.max(axis=0)
    mins = df.min(axis=0)

    cmax = maxs[0]
    rmax = maxs[1]

    m = np.zeros((rmax, cmax-1))
    for i, row in df.iterrows():
        c = row['SAMPLE_RANK']
        r = row['OBSERVATION_RANK']
        m[r-1][c-2] = 1

    #print 'line 26:', np.where(~m.any(axis=0))[0]
    m = sorted(m, key=sum, reverse=True) # sort by rows
    m = np.asmatrix(m)
    m = m.transpose()

    m = np.asarray(m)
    #print 'line 30:', np.where(~m.any(axis=1))[0]
    m = sorted(m, key=sum, reverse=True) # sort by columns
    m = np.asmatrix(m)
    m = m.transpose()
    m = np.asarray(m)

    return m
