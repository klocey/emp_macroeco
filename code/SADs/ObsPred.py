from __future__ import division
import  matplotlib.pyplot as plt
import sys
import os
import random
import numpy as np
from scipy import stats

########### PATHS ##############################################################
mydir = os.path.expanduser("~/GitHub/emp_nested")
tools = os.path.expanduser(mydir + "/tools/DiversityTools")

sys.path.append(tools + "/macroecotools")
import macroecotools as mct

data = os.path.expanduser("~/data")
mydir = os.path.expanduser("~/GitHub/emp_nested")

def import_obs_pred_data(input_filename):
    # TAKEN FROM THE mete_sads.py script used for White et al. (2012)
    data = np.genfromtxt(input_filename, dtype = "S15, f8, f8",
    names = ['site','obs','pred'], delimiter = " ")
    return data

########### END FUNCTIONS ######################################################


# TAKEN FROM THE mete_sads.py script used for White et al. (2012)
# Used for Figure 3 Locey and White (2013)
"""Multiple obs-predicted plotter"""
fig = plt.figure()

ax1 = fig.add_subplot(2, 2, 1)

filename = mydir+'/data/emp_mete_obs_pred.txt'
data = import_obs_pred_data(filename)
site = np.asarray(list(((data["site"]))))
obs = np.asarray(list(((data["obs"]))))
pred = np.asarray(list(((data["pred"]))))

axis_min = 0
axis_max = 2 * max(obs)

radius=2
mct.plot_color_by_pt_dens(pred, obs, radius, loglog=1, plot_obj=ax1)

plt.plot([axis_min, axis_max],[axis_min, axis_max], 'k-')

plt.xlim(0, axis_max)
plt.ylim(0, axis_max)

r2_all = mct.obs_pred_rsquare(np.log10(obs), np.log10(pred))
r2text = r"${}^{{2}} = {:.{p}f} $".format('r',r2_all , p=2)

plt.text(2, 30000, r2text,  fontsize=14)
plt.text(28, 800000, 'Log-series',  fontsize=14)
plt.text(5, 0.1, 'Predicted rank-abundance', fontsize=10)
plt.text(0.1, 60000, 'Observed rank-abundance', rotation='vertical', fontsize=10)

plt.tick_params(axis='both', which='major', labelsize=7)
#plt.subplots_adjust(wspace=0.5, hspace=0.3)
#axins = inset_axes(ax, width="30%", height="30%", loc=4)
#plt.setp(axins, xticks=[], yticks=[])



ax2 = fig.add_subplot(2, 2, 2)

filename = mydir+'/data/emp_pln_obs_pred.txt'
data = import_obs_pred_data(filename)
site = np.asarray(list(((data["site"]))))
obs = np.asarray(list(((data["obs"]))))
pred = np.asarray(list(((data["pred"]))))

axis_min = 0
axis_max = 2 * max(obs)

radius=2
mct.plot_color_by_pt_dens(pred, obs, radius, loglog=1, plot_obj=ax2)
plt.plot([axis_min, axis_max],[axis_min, axis_max], 'k-')

plt.xlim(0, axis_max)
plt.ylim(0, axis_max)

r2_all = mct.obs_pred_rsquare(np.log10(obs), np.log10(pred))

r2text = r"${}^{{2}} = {:.{p}f} $".format('r',r2_all , p=2)

plt.text(2, 30000, r2text,  fontsize=14)
plt.text(28, 800000, 'Lognormal',  fontsize=14)
plt.text(5, 0.1, 'Predicted rank-abundance', fontsize=10)
plt.text(0.1, 60000, 'Observed rank-abundance', rotation='vertical', fontsize=10)

plt.tick_params(axis='both', which='major', labelsize=7)
plt.subplots_adjust(wspace=0.4, hspace=0.4)

#axins = inset_axes(ax, width="30%", height="30%", loc=4)
plt.savefig(mydir + '/figures/SADs.png', dpi=600, bbox_inches = 'tight')#, pad_inches=0)
plt.close()
