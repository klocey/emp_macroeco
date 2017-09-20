from __future__ import division
import numpy as np
import sys
from numpy import array, mean


def NODF(m):

    m1=array(m).copy()

    R_nes=[]
    inds1 = range(0, len(m1), 10) # int(round(len(m1)/20))

    for i in inds1:
        for j in inds1:
            if i<j:
                if sum(m1[i]) == 0 or sum(m1[j]) == 0: continue

                z = (sum(m1[i]*m1[j])/float(sum(m1[j]))) * (sum(m1[i])>sum(m1[j]))
                R_nes.append(z)

    m2 = m1.transpose()

    C_nes=[]
    inds2 = range(0, len(m2), 10)

    for i in inds2:
        for j in inds2:
            if i<j:
                if sum(m2[i]) == 0 or sum(m2[j]) == 0: continue

                z = (sum(m2[i]*m2[j])/float(sum(m2[j]))) * (sum(m2[i])>sum(m2[j]))
                C_nes.append(z)

    return (mean(R_nes+C_nes), mean(R_nes), mean(C_nes))



def SES_NODF(m):

    m1 = array(m).copy()

    R_nes = []
    inds = range(0, len(m1), int(round(len(m1)/20)))

    for i in inds:
        for j in inds:
            if i < j:
                if sum(m1[i]) == 0 or sum(m1[j]) == 0:
                    continue

                else:
                    z = (sum(m1[i]*m1[j])/float(sum(m1[j]))) * (sum(m1[i])>sum(m1[j]))
                    R_nes.append(z)

    m2 = m1.transpose()

    C_nes=[]
    inds2 = range(0, len(m2), int(round(len(m2)/20)))

    for i in inds2:
        for j in inds2:
            if i<j:
                if sum(m2[i]) == 0 or sum(m2[j]) == 0: continue

                z = (sum(m2[i]*m2[j])/float(sum(m2[j]))) * (sum(m2[i])>sum(m2[j]))
                C_nes.append(z)


    avgRC = mean(R_nes+C_nes)
    avgR = mean(R_nes)
    avgC = mean(C_nes)

    avgRC_nulls = []
    avgR_nulls = []
    avgC_nulls = []

    m1 = array(m).copy()

    for it in range(100):
        m1 = m1[:, np.random.permutation(m1.shape[1])]

        R_nes=[]
        inds = range(0, len(m1), int(round(len(m1)/20)))

        for i in inds:
            for j in inds:
                if i<j:
                    if sum(m1[i]) == 0 or sum(m1[j]) == 0:
                        continue

                    else:
                        z = (sum(m1[i]*m1[j])/float(sum(m1[j]))) * (sum(m1[i])>sum(m1[j]))
                        R_nes.append(z)

        m2 = m1.transpose()

        C_nes = []
        inds = range(0, len(m2), int(round(len(m2)/20)))

        for i in inds:
            for j in inds:
                if i<j:
                    if sum(m2[i]) == 0 or sum(m2[j]) == 0: continue

                    z = (sum(m2[i]*m2[j])/float(sum(m2[j]))) * (sum(m2[i])>sum(m2[j]))
                    C_nes.append(z)

        C_nes = filter(lambda a: a != 0, C_nes)

        avgRC_nulls.append(mean(R_nes) + mean(C_nes))
        avgR_nulls.append(mean(R_nes))
        avgC_nulls.append(mean(C_nes))

    Exp = mean(avgRC_nulls)
    Std = np.std(avgRC_nulls, ddof=0)
    z = (avgRC - Exp)/Std

    return [avgRC, z]




def SES_NODF_Cols(m):

    m1=array(m).copy()
    m2 = m1.transpose()

    C_nes=[]
    inds = range(0, len(m2), int(round(len(m2)/20)))

    for i in inds:
        for j in inds:
            if i<j:
                if float(sum(m2[i])) == 0 or float(sum(m2[j])) == 0:
                    continue

                else:
                    z = (sum(m2[i]*m2[j])/float(sum(m2[j]))) * (sum(m2[i])>sum(m2[j]))
                    C_nes.append(z)

    C_nes = filter(lambda a: a != 0, C_nes)

    avgC = mean(C_nes)
    avgC_nulls = []


    m1=array(m).copy()
    for it in range(100):

        m1 = m1[:, np.random.permutation(m1.shape[1])]
        m2 = m1.transpose()

        C_nes=[]

        for i in inds:
            for j in inds:
                if i<j:
                    if float(sum(m2[i])) == 0 or float(sum(m2[j])) == 0:
                        continue

                    else:
                        z = (sum(m2[i]*m2[j])/float(sum(m2[j]))) * (sum(m2[i])>sum(m2[j]))
                        C_nes.append(z)

        C_nes = filter(lambda a: a != 0, C_nes)
        avgC_nulls.append(mean(C_nes))

    Exp = mean(avgC_nulls)
    Std = np.std(avgC_nulls, ddof=0)
    z = (avgC - Exp)/Std

    return [avgC, z]
