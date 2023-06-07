# -*- coding: utf-8 -*-
"""

@author: Bronte Mckeown

This script creates wordclouds from neurosynth terms for all maps for P1389.

Data from YNIC group analysis results.

Target = cope 7
Non-target = cope 9

Reads in: 
1) 1 csv file with component loadings (1 column for each component and 1 row for each item)
2) 1 csv file with labels for each item in the same order as the first csv file

Outputs:
1) 1 png word cloud image for each component 
    Optional:
2) 1 csv file for each component that shows the information used to create each word cloud
"""

# %% Import libraries

import os
import pandas as pd
import numpy as np

from wordcloud import WordCloud
import matplotlib.cm as cm
import matplotlib.colors as mcolor

# used if wordcloud import won't work 
#import sys
#print(sys.executable)

# %% Wordcloud function

def wordclouder(coefficients_dict, display_dict, savefile=False):
    """
    Function to return 1) wordclouds.pngs (saved by default) 2) .csvs containg colour codes & weightings used to make wordclouds 
    """
    for key, value in coefficients_dict.items(): # Loop over loading dictionaries - 1 dataframe per iteration
        df = pd.DataFrame(value) # transpose dataframe
        principle_vector = np.array(df, dtype =float) # turn df into array
        pv_in_hex= [] # create empty list
        vmax = np.abs(principle_vector).max() # get the maximum absolute value in array
        vmin = -vmax # minimu 
        for i in range(principle_vector.shape[1]): # loop through each column
            rescale = (principle_vector  [:,i] - vmin) / (vmax - vmin) # rescale scores 
            colors_hex = [] # create empty list
            for c in cm.RdBu_r(rescale): # loops over RdBu_r colours
                colors_hex.append(mcolor.to_hex(c)) # adds colour codes (hex) to list
            pv_in_hex.append(colors_hex) # add all colour codes for each item 
        colors_hex = np.array(pv_in_hex ).T # transpose
        df_v_color = pd.DataFrame(colors_hex)
        if savefile:
		# if savefile is true, saves csvs containg colour codes & weightings used to make wordclouds
            df_v_color.to_csv("{}_neuro_colour_codes_for_wordclouds.csv".format(key), index = False, header = False)
        else:
            pass

        
        absolute = df.abs() # make absolute 
        integer = 100 * absolute # make interger 
        integer = integer.astype(int) 
        concat = pd.concat([integer, df_v_color], axis=1) # concatanate loadings and colours 
        concat.columns = ['freq', 'colours']
        concat.insert(1, 'labels', display_dict[key]) # add labels (items) from display list 
        if savefile:
            concat.to_csv("{}_neuro_loadings_and_colour_codes.csv".format(key), index = False, header = True)
        else:
            pass

        freq_dict = dict(zip(concat.labels, concat.freq)) # where key: item and value: weighting
        colour_dict = dict(zip(concat.labels, concat.colours))# where key: itemm and value: colour
        def color_func(word, *args, **kwargs): #colour function to supply to wordcloud function
            try:
                color = colour_dict[word]
            except KeyError:
                color = '#000000' # black
            return color
        # create wordcloud object
        wc = WordCloud(background_color="white", color_func=color_func, 
                    width=400, height=400, prefer_horizontal=1, 
                    min_font_size=8, max_font_size=200
                    )
        # generate wordcloud from loadings in frequency dict
        wc = wc.generate_from_frequencies(freq_dict)
        wc.to_file('{}_neurosyth_wordcloud.png'.format(key))
            

# %% Read in data
# read in coefficients data
os.chdir("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data\\deriv\\")

pca1_file = "pca1_neurosynth_terms_forWordClouds.csv"
pca2_file = "pca2_neurosynth_terms_forWordClouds.csv"
pca3_file = "pca3_neurosynth_terms_forWordClouds.csv"
target_file = "target_neurosynth_terms_forWordClouds.csv"
nontarget_file = "nontarget_neurosynth_terms_forWordClouds.csv"

pca1 = pd.read_csv(pca1_file, header = None)
pca2 = pd.read_csv(pca2_file, header = None)
pca3 = pd.read_csv(pca3_file, header = None)
target = pd.read_csv(target_file, header = None)
nontarget = pd.read_csv(nontarget_file, header = None)

# store display labels in list for creating wordclouds
pca1_display = pca1[0].tolist()
pca2_display = pca2[0].tolist()
pca3_display = pca3[0].tolist()
target_display = target[0].tolist()
nontarget_display = nontarget[0].tolist()

# transform to dictionary for word cloud function 
coefficients_dict = {}
coefficients_dict['pca1'] = pca1[1]
coefficients_dict['pca2'] = pca2[1]
coefficients_dict['pca3'] = pca3[1]
coefficients_dict['target'] = target[1]
coefficients_dict['nontarget'] = nontarget[1]

# transform to dictionary for word cloud function 
display_dict = {}
display_dict['pca1'] = pca1_display
display_dict['pca2'] = pca2_display
display_dict['pca3'] = pca3_display
display_dict['target'] = target_display
display_dict['nontarget'] = nontarget_display

# change directory for saving results
os.chdir("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\neurosynth")

# call word cloud function 
wordclouder(coefficients_dict, display_dict, savefile=True)