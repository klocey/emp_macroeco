from __future__ import division
from biom import load_table
import os
import sys
import numpy as np
import scipy as sc
import pandas as pd

mydir2 = os.path.expanduser("~/")
mydir = os.path.expanduser("~/GitHub/emp_nested")

df = pd.read_table(mydir + '/data/emp_2000sub_mapping.txt', sep='\t')
print df.shape # rows are sites, columns are metadata
# column headings: SampleID, BarcodeSequence, LinkerPrimerSequence, Description, host_subject_id, study_id, title, principal_investigator
# cont'd: doi, ebi_accession, pcr_primers, read_length_bp, sequences_split_libraries, observations_closed_ref_greengenes,
# cont'd: observations_closed_ref_silva, observations_open_ref_greengenes, observations_deblur_90bp, observations_deblur_100bp
# cont'd: observations_deblur_150bp, all_emp, qc_filtered, subset_10k, subset_5k, subset_2k, sample_taxid, sample_scientific_name
# cont'd: host_taxid, host_common_name_provided, host_common_name, host_scientific_name, host_superkingdom, host_kingdom, host_phylum
# cont'd: host_class, host_order, host_family, host_genus, host_species, collection_timestamp, country, latitude_deg, longitude_deg, depth_m,
# cont'd: altitude_m, elevation_m, env_biome, env_feature, env_material, envo_biome_0, envo_biome_1, envo_biome_2, envo_biome_3, envo_biome_4
# cont'd: envo_biome_5, empo_0, empo_1, empo_2, empo_3, adiv_observed_otus, adiv_chao1, adiv_shannon, adiv_faith_pd, temperature_deg_c, ph
# cont'd: salinity_psum, oxygen_mg_per_l, phosphate_umol_per_l, ammonium_umol_per_l, nitrate_umol_per_l, sulfate_umol_per_l

env_biome = df['env_biome']
env_feature = df['env_feature']
env_material = df['env_material']

table = load_table(mydir2 + 'Desktop/emp-data/emp_deblur_90bp.subset_2k.biom')
rows, cols = table.shape
print table.shape

rads = []
sites = []
splists = []

for i in range(cols):

    dat = table[:, i]
    #print dat.headers
    #print dat
    #sys.exit()

    dat = sc.sparse.find(dat)
    #print dat
    #sys.exit()

    splist = dat[0].tolist()
    site = dat[1].tolist()
    #print site
    #print 'col:', i, site[0]

    rad = dat[2].tolist()
    rad = [int(j) for j in rad]
    rad, splist, site = (list(t) for t in zip(*sorted(zip(rad, splist, site), reverse=True)))

    print splist
    print site
    print rad
    sys.exit()

    rads.append(rad)
    sites.append(site)
    splists.append(splist)


########### PATHS ##############################################################

OUT = open(mydir+'/data/emp_sads.txt','w+')
print>> OUT, 'site', 'species', 'abundance', 'env_biome', 'env_feature', 'env_material'
for i, rad in enumerate(rads):

    site    = sites[i]
    splist = splists[i]
    b = env_biome[i]
    f = env_feature[i]
    m = env_material[i]

    N = int(sum(rad))
    S = int(len(rad))
    print i, 'N:', N, ' S:', S


    for j, ab in enumerate(rad):
        print>> OUT, i, splist[j], ab, b, f, m
        #print i, splist[j], ab, b, f, m

OUT.close()
