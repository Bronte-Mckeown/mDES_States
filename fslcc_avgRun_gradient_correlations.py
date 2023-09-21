#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 20:14:28 2020

@author: Meichao

Modified by Bronte on 28/09/22

"""

import os
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

# set directory to where gradient maps are
gradient_path = '/scratch/groups/Projects/P1389/Bronte/reference_images/1st_revision_images'

# set directory to individual-level maps 
individual_paths = glob.glob('/scratch/groups/Projects/P1389/fmri_results/R*/2nd_level.gfeat/cope*.feat/stats/zstat1.nii.gz')# get all contrast maps
assert len(individual_paths) == 590 


#%% Run correlations
   
sub_list =[]
run_list=[]
gradient_list =[]
spatial_correlation_list = []
cope_list = []
   
for individual_path in individual_paths: # loop over first level stat maps

    for gradient_ID in range(1,6):

        #add string
        gradient_name = 'gradient' + str(gradient_ID)
       
        # this is the spatial correlation
        fslcc = f'fslcc --noabs -m {gradient_path}/gradient_mask.nii.gz -t -1 {gradient_path}/{gradient_name}.nii.gz {individual_path}'
       
        # this runs the fsl command above
        correlation = subprocess.run(fslcc,shell=True, capture_output=True, text = True)
        print(f'raw output: {correlation}')
        
        spatial_correlation = correlation.stdout.split(' ')[6].strip('\n') 
        print(spatial_correlation)

        # add subject ID, Gradient number, z-stat number, and spatial correlation value to respective lists
        sub_list.append(subidcopeid(individual_path)[0])
        gradient_list.append(gradient_name)
        spatial_correlation_list.append(spatial_correlation)
        cope_list.append(subidcopeid(individual_path)[1])

#cope_list = [c.replace('.feat', '') for c in cope_list]       
#%% saving output
#    # merge multiple arrays to data frame
# putting together all lists created in loop above
data = pd.DataFrame({'sub_ID': sub_list,'cope': cope_list, "gradient": gradient_list, "spatial_correlation": spatial_correlation_list})

replace_dict = {'cope1.feat':'pca1_up',
                'cope2.feat': 'pca2_up',
                'cope3.feat': 'pca3_up',
                'cope4.feat': 'pca1_down',
                'cope5.feat': 'pca2_down',
                'cope6.feat': 'pca3_down',
                'cope7.feat': 'target_up',
                'cope8.feat': 'target_down',
                'cope9.feat': 'non_target_up',
                'cope10.feat': 'non_target_down'
                }

data = data.replace({'cope': replace_dict})

# transpose data
data['spatial_correlation'] = data['spatial_correlation'].apply(pd.to_numeric)
data_trans = data.pivot_table(index=['sub_ID'], columns=['cope','gradient'], values=['spatial_correlation']) 
data_trans = data_trans.reset_index()

# sort out column names
data_trans.columns = ['_'.join(map(str, c)).strip('_') for c in data_trans]
data_trans.columns = data_trans.columns.str.replace(r'spatial_correlation_','')

# save non-tranposed and transposed version 
data.to_csv('/scratch/groups/Projects/P1389/Bronte/results/spatial_correlations/P1389_gradSim_avgRun_long_grads4_5_1strevision.csv', index = False)
data_trans.to_csv('/scratch/groups/Projects/P1389/Bronte/results/spatial_correlations/P1389_gradSim_avgRun_wide_grads4_5_1strevision.csv', index = False)
