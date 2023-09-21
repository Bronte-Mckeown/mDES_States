#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 13 20:27:28 2023

@author: blam500
"""
import pandas as pd
import glob
import os

# read in statespace coords to wrangle
inputfiles = glob.glob('/scratch/groups/Projects/P1389/Bronte/results/StateSpace/gradscores_*.csv')

for file in inputfiles:
    df = pd.read_csv(file)

    # replace cope numbers with meaningful labels
    
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
    
    df = df.replace({'Task_name': replace_dict})


    # change col names so scripts will work
    col_mapping = {'Task_name': 'cope',
                    'subid': 'sub_ID',
                    'Gradient': 'gradient',
                    'Correlation': 'spatial_correlation'}
    
    df = df.rename(columns = col_mapping)
    
    filename , _ = os.path.splitext(os.path.basename(file))

    df.to_csv(f'/scratch/groups/Projects/P1389/Bronte/results/StateSpace/wrangled/{filename}_p1389.csv')