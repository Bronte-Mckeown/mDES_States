# -*- coding: utf-8 -*-
"""

@author: Bronte Mckeown

This script creates wordclouds from component loadings. 

Data from google drive archive sav file.

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

def wordclouder(coefficients_dict, display, savefile=False):
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
            df_v_color.to_csv("{}_colour_codes_for_wordclouds.csv".format(key), index = False, header = False)
        else:
            pass

        # loops over coefficients 
        for col_index in df:
            absolute = df[col_index].abs() # make absolute 
            integer = 100 * absolute # make interger 
            integer = integer.astype(int) 
            concat = pd.concat([integer, df_v_color[col_index]], axis=1) # concatanate loadings and colours 
            concat.columns = ['freq', 'colours']
            concat.insert(1, 'labels', display) # add labels (items) from display list 
            if savefile:
                concat.to_csv("{}_loadings_and_colour_codes_factor_{}.csv".format(key, col_index+1), index = False, header = True)
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
            wc.to_file('{}_wordcloud_factor_{}.png'.format(key, col_index+1))
            

# %% Read in data
# read in coefficients data
folder_path = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data\\deriv\\"

loadings_file = "component_loadings_for_scanner_pca_wordclouds.csv"
labels_file = "pca_labels.csv"

loadings_path = folder_path + loadings_file
df = pd.read_csv(loadings_path, header=None)

# read in display labels
label_path = folder_path + labels_file
labels = pd.read_csv(label_path)

# store display labels in list for creating wordclouds
display = labels['labels'].tolist()

# transform to dictionary for word cloud function 
coefficients_dict = {}
coefficients_dict['scanner_pca'] = df

# change directory for saving results
os.chdir("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results")

# call word cloud function 
wordclouder(coefficients_dict, display, savefile=True)
