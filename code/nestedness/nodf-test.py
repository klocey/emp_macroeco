from __future__ import division
import numpy as np
from numpy import array, mean

def NODF(m):
    m1=array(m).copy()
    R_nes=[]

    for i in range(len(m1)):
        for j in range(len(m1)):
	   if i<j:
	       try: R_nes.append((sum(m1[i]*m1[j])/float(sum(m1[j])))*(sum(m1[i])>sum(m1[j])))
	       except: pass

    m2=m1.transpose()
    C_nes=[]

    for i in range(len(m2)):
	for j in range(len(m2)):
            if i<j:
		try:
                    C_nes.append((sum(m2[i]*m2[j])/float(sum(m2[j])))*(sum(m2[i])>sum(m2[j])))
                except: pass

    if C_nes==[] or R_nes==[]:
	print m

    return (mean(R_nes+C_nes)*100,mean(R_nes)*100,mean(C_nes)*100)



row, col = 50, 50
m = np.random.randint(2, size=(row,col))
print m

m = sorted(m, key=sum, reverse=True) # sort by rows
m = np.asmatrix(m)
print m

m = m.transpose()
print m

m = np.asarray(m)
m = sorted(m, key=sum, reverse=True) # sort by columns
m = np.asmatrix(m)
print m

m = m.transpose()

print m
print NODF(m)
