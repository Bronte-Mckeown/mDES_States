#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script calculates spatial correlations between:
- each of their zstat maps (PCAs 1-3, target + non-targets)

"""

import pandas as pd
import subprocess
import glob

def subidcopeid(pth):
    """
    Function to extract subid from path
    """
    splits = pth.split('/')[:-1] # extract every part of path except filename
    subid = [i for i in splits if 'R' in i]
    copeid = [i for i in splits if 'cope' in i]
    #assert len(subid) != 0
    #assert len(copeid) != 0
    return subid[0], copeid[0]

#%% Set up data

# set directory to individual-level maps 
individual_paths = glob.glob('/scratch/groups/Projects/P1389/fmri_results/R*/2nd_level.gfeat/cope*.feat/stats/zstat1.nii.gz')# get all contrast maps
assert len(individual_paths) == 590 

#%% Run correlations

sub_list =[]

for pth in individual_paths:
    splits = pth.split('/')[:-1]
    subid = [i for i in splits if 'R' in i]
    if subid[0] not in sub_list:
        print(subid)
        sub_list.append(subid[0])
        
cope_lists = []
for sub in sub_list:
    copes = [i for i in individual_paths if sub in i]
    cope_lists.append(copes)
    
    
sub_list = []
spatial_correlation_list = []
cope_list = []

for sub in cope_lists:
    PCA1 = [i for i in sub if 'cope1' in i and 'cope10' not in i]
    PCA2 = [i for i in sub if 'cope2' in i]
    PCA3 = [i for i in sub if 'cope3' in i]
    PCA_list = [PCA1, PCA2, PCA3]
    
    target = [i for i in sub if 'cope7' in i]
    nontarget = [i for i in sub if 'cope9' in i]
    event_list = [target, nontarget]
    
    fslcc = f'fslcc --noabs -t -1 {PCA1[0]} {PCA2[0]}'
    pca1pca2 = subprocess.run(fslcc,shell=True, capture_output=True, text = True)
    pca1pca2 = pca1pca2.stdout.split(' ')[6].strip('\n')
    sub_list.append(subidcopeid(sub[0])[0])
    spatial_correlation_list.append(pca1pca2)
    cope_list.append("cope1cope2")
    
    fslcc = f'fslcc --noabs -t -1 {PCA1[0]} {PCA3[0]}'
    pca1pca3 = subprocess.run(fslcc,shell=True, capture_output=True, text = True)
    pca1pca3 = pca1pca3.stdout.split(' ')[6].strip('\n')
    sub_list.append(subidcopeid(sub[0])[0])
    spatial_correlation_list.append(pca1pca3)
    cope_list.append("cope1cope3")
    
    fslcc = f'fslcc --noabs -t -1 {PCA2[0]} {PCA3[0]}'
    pca2pca3 = subprocess.run(fslcc,shell=True, capture_output=True, text = True)
    print(pca2pca3)
    pca2pca3 = pca2pca3.stdout.split(' ')[6].strip('\n')
    #print(pca2pca3)
    sub_list.append(subidcopeid(sub[0])[0])
    spatial_correlation_list.append(pca2pca3)
    cope_list.append("cope2cope3")
    
    fslcc = f'fslcc --noabs -t -1 {target[0]} {nontarget[0]}'
    targetnontarget = subprocess.run(fslcc,shell=True, capture_output=True, text = True)
    print(targetnontarget)
    targetnontarget = targetnontarget.stdout.split(' ')[6].strip('\n')
    sub_list.append(subidcopeid(sub[0])[0])
    spatial_correlation_list.append(targetnontarget)
    cope_list.append("cope7cope9")
    
    for pca in PCA_list:
        for event in event_list:
            fslcc = f'fslcc --noabs -t -1 {pca[0]} {event[0]}'
            correlation = subprocess.run(fslcc,shell=True, capture_output=True, text = True)
            corr = correlation.stdout.split(' ')[6].strip('\n')
            sub_list.append(subidcopeid(sub[0])[0])
            spatial_correlation_list.append(corr)

            split1 = pca[0].split('/')[:-1]
            split2 = event[0].split('/')[:-1]
            map1 = [i for i in split1 if 'cope' in i]
            map2= [i for i in split2 if 'cope' in i]
            split1 = map1[0].split('.')[:-1]
            map1 = [i for i in split1 if 'cope' in i]
            split2 = map2[0].split('.')[:-1]
            map2 = [i for i in split2 if 'cope' in i]
            name = map1[0]+map2[0]
            cope_list.append(name)
   
#%% saving output
#    # merge multiple arrays to data frame
# putting together all lists created in loop above
data = pd.DataFrame({'sub_ID': sub_list,'corPair': cope_list, "spatial_correlation": spatial_correlation_list})

replace_dict = {'cope1cope2':'pca1pca2',
                'cope1cope3':'pca1pca3',
                'cope2cope3':'pca2pca3',
                'cope7cope9':'targetnontarget',
                'cope1cope7':'pca1target',
                'cope1cope9':'pca1nontarget',
                'cope2cope7':'pca2target',
                'cope2cope9':'pca2nontarget',
                'cope3cope7':'pca3target',
                'cope3cope9':'pca3nontarget'

                }

data = data.replace({'corPair': replace_dict})

# transpose data
data['spatial_correlation'] = data['spatial_correlation'].apply(pd.to_numeric)
data_trans = data.pivot_table(index=['sub_ID'], columns=['corPair'], values=['spatial_correlation']) 
data_trans = data_trans.reset_index()

# sort out column names
data_trans.columns = ['_'.join(map(str, c)).strip('_') for c in data_trans]
data_trans.columns = data_trans.columns.str.replace(r'spatial_correlation_','')

# save non-tranposed and transposed version 
data.to_csv('/scratch/groups/Projects/P1389/Bronte/results/spatial_correlations/P1389_taskMapSim_avgRun_long.csv', index = False)
data_trans.to_csv('/scratch/groups/Projects/P1389/Bronte/results/spatial_correlations/P1389_taskMapSim_avgRun_wide.csv', index = False)
