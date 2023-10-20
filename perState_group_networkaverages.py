############################## import libraries ###############################
import nibabel as nib
from nilearn import datasets,  maskers
import pandas as pd
import glob
import os
from scipy.stats import zscore

################################ read in data  ################################
# collect all inputfiles using glob
inputfiles = glob.glob('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\*_group.nii.gz')
# read in gradient mask
mask_map = nib.load('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\gradientmask_cortical_subcortical_fromstatespace.nii.gz')

################################## Yeo networks ###############################
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

# create dictionary to add results to
results_dict = {}

for path in inputfiles:
    # extract task id
    splits = path.split('\\')
    taskid = [i for i in splits if 'group' in i][0]
    splits = taskid.split('.')
    taskid = [i for i in splits if 'group' in i][0]

    # load image
    state = nib.load(path)
    
    # use yeo mask to extract values
    mean_values = masker.fit_transform(state)
    mean_values = mean_values.mean(axis = 0)
    
    # z-score [not used]
    zmean_values = zscore(mean_values)
    
    # save as dataframe with labels
    mean_values_df = pd.DataFrame({
        'yeo_network': network_labels,
        'mean_value': mean_values,
        'zmean_value': zmean_values
    })
    
    # add dataframe to dictionary
    results_dict[taskid] = mean_values_df
    
############################### Save results ##################################

# Concatenate all DataFrames in grad_dict into a single DataFrame
result_df = pd.concat(results_dict.values(), keys=results_dict.keys()).reset_index(level=1, drop=True).reset_index()

# Rename the columns if needed
result_df.columns = ['state','yeo_network', 'mean_value', 'zmean_value']

result_df.to_csv('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\state_yeo_avgs.csv')
