# -*- coding: utf-8 -*-
"""
Created on Wed Sep 27 12:21:26 2023

@author: bront
"""

import nibabel as nib
from nilearn import datasets,  maskers
import pandas as pd
import glob
from scipy.stats import zscore

def taskid_subid(pth, taskstring, substring):
    """
    Function to extract task id and sub id from file path if running individual level analyses
 
    """
    splits = pth.split('/')

    taskid = [i for i in splits if taskstring in i]
    subid = [i for i in splits if substring in i]

    assert taskid
    assert subid

    return taskid[0], subid[0]

# collect all inputfiles using glob
inputfiles = glob.glob('/scratch/groups/Projects/P1389/fmri_results/R*/2nd_level.gfeat/cope*.feat/stats/zstat1.nii.gz')# get all contrast maps

# inputfiles = ['/scratch/groups/Projects/P1389/fmri_results/R3976_006/2nd_level.gfeat/cope1.feat/stats/zstat1.nii.gz',
#               '/scratch/groups/Projects/P1389/fmri_results/R3976_006/2nd_level.gfeat/cope2.feat/stats/zstat1.nii.gz',
#               '/scratch/groups/Projects/P1389/fmri_results/R4087_057/2nd_level.gfeat/cope1.feat/stats/zstat1.nii.gz',
#               '/scratch/groups/Projects/P1389/fmri_results/R4087_057/2nd_level.gfeat/cope2.feat/stats/zstat1.nii.gz',
#               '/scratch/groups/Projects/P1389/fmri_results/R4087_057/2nd_level.gfeat/cope5.feat/stats/zstat1.nii.gz']

# read in gradient mask
mask_map = nib.load('/home/b/blam500/Documents/repos/StateSpace/StateSpace/data/masks/gradientmask_cortical_subcortical.nii.gz')

# Define Yeo Networks
yeo = datasets.fetch_atlas_yeo_2011()

# Create a masker to extract data within Yeo networks
masker = maskers.NiftiLabelsMasker(labels_img=yeo.thick_7,mask_img = mask_map,
                                       standardize=False)

# set network labels for 7 networks
network_labels = [
    "Visuospatial",
    "Somatomotor",
    "Dorsal Attention",
    "Ventral Attention",
    "Limbic",
    "Frontoparietal",
    "Default Mode"
]

copes_of_interest = ['cope1.feat', 'cope2.feat','cope3.feat','cope7.feat', 'cope9.feat']


# create dictionary to add results to
results_dict = {}

for path in inputfiles:
    # extract task and subject id
    task_id, sub_id = taskid_subid(path, 'cope', 'R')
    
    # only do for copes of interest
    if task_id in copes_of_interest:
        if task_id == 'cope1.feat':
            task_id = 'pca1'
        elif task_id == 'cope2.feat':
            task_id = 'pca2'
        elif task_id == 'cope3.feat':
            task_id = 'pca3'
        elif task_id == 'cope7.feat':
            task_id = 'target'
        elif task_id == 'cope9.feat':
            task_id = 'nontarget'

        # load image
        state = nib.load(path)
        
        # use yeo mask to extract values
        mean_values = masker.fit_transform(state)
        mean_values = mean_values.mean(axis = 0)
        
        # z-score [not sure if needed]
        zmean_values = zscore(mean_values)
        
        # save as dataframe with labels
        mean_values_df = pd.DataFrame({
            'yeo_network': network_labels,
            'mean_value': mean_values,
            'zmean_value': zmean_values
        })
        
        # add dataframe to dictionary
        if sub_id not in results_dict.keys():
            results_dict[sub_id] = {}
        results_dict[sub_id][task_id] = mean_values_df

# Create an empty list to store the individual DataFrames
dataframes_list = []

# Iterate through the dictionary and convert each task_id's data to a DataFrame
for sub_id, task_data in results_dict.items():
    for task_id, task_df in task_data.items():
        # Add 'sub_id' and 'task_id' as columns
        task_df['sub_id'] = sub_id
        task_df['task_id'] = task_id
        dataframes_list.append(task_df)

# Concatenate all DataFrames in the list into a single DataFrame
result_df = pd.concat(dataframes_list, ignore_index=True)

# Optionally, reset the index
result_df.reset_index(drop=True, inplace=True)
    
# save as csv
result_df.to_csv('/scratch/groups/Projects/P1389/Bronte/results/perSub_perState_networkaverages.csv')