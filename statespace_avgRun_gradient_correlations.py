#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 13 19:42:13 2023

@author: blam500
"""

import glob
from StateSpace import CorrelateTasksWithGradients

# set directory to individual-level maps 
inputfiles = glob.glob('/scratch/groups/Projects/P1389/fmri_results/R*/2nd_level.gfeat/cope*.feat/stats/zstat1.nii.gz')# get all contrast maps
assert len(inputfiles) == 590 

outputdir = '/scratch/groups/Projects/P1389/Bronte/results/StateSpace'

CorrelateTasksWithGradients.corrInd('gradientmask_cortical_subcortical', 'all',
                                    inputfiles,outputdir,
                                    'cope','R',
                                    corr_method = 'spearman', verbose = 1)

CorrelateTasksWithGradients.corrInd('gradientmask_cortical_subcortical', 'all',
                                    inputfiles,outputdir,
                                    'cope','R',
                                    corr_method = 'pearson', verbose = 1)

CorrelateTasksWithGradients.corrInd('gradientmask_cortical', 'cortical_only',
                                    inputfiles,outputdir,
                                    'cope','R',
                                    corr_method = 'spearman', verbose = 1)

CorrelateTasksWithGradients.corrInd('gradientmask_cortical', 'cortical_only',
                                    inputfiles,outputdir,
                                    'cope','R',
                                    corr_method = 'pearson', verbose = 1)