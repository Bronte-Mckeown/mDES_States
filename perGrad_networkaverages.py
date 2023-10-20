############################## import libraries ###############################
import nibabel as nib
from nilearn import datasets,  maskers
import pandas as pd
import glob
import os
from scipy.stats import zscore

################################ read in data  ################################
# read in gradient paths
gradient_paths = glob.glob('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\gradient*_cortical_subcortical.nii.gz')
# read in and load mask
mask_map = nib.load('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\gradientmask_cortical_subcortical_fromstatespace.nii.gz')

################################## Yeo networks ###############################
# Define Yeo Networks
yeo = datasets.fetch_atlas_yeo_2011()

# Create a masker to extract data within Yeo networks
masker = maskers.NiftiLabelsMasker(labels_img=yeo.thick_7,mask_img = mask_map,
                                       standardize=False)
# set network labels
network_labels = [
    "Visuospatial",
    "Somatomotor",
    "Dorsal Attention",
    "Ventral Attention",
    "Limbic",
    "Frontoparietal",
    "Default Mode"
]

grad_dict = {} # empty dict for adding to below

for path in gradient_paths:
    # Get the filename from the filepath
    filename = os.path.basename(path)
    parts = filename.split('_')
    grad_name = parts[0]

    # load grad image
    grad = nib.load(path)
    
    # use yeo mask to extract values
    mean_values = masker.fit_transform(grad)
    mean_values = mean_values.mean(axis = 0)
    
    # z-score (for comparison purposes across gradients)
    zmean_values = zscore(mean_values)
    
    # save as dataframe with labels
    mean_values_df = pd.DataFrame({
        'Network': network_labels,
        'Stat_Value': mean_values,
        'ZStat_Value': zmean_values
    })
    
    # add dataframe to dictionary
    grad_dict[grad_name] = mean_values_df
    
############################### Save results ##################################
    
# Concatenate all DataFrames in grad_dict into a single DataFrame
result_df = pd.concat(grad_dict.values(), keys=grad_dict.keys()).reset_index(level=1, drop=True).reset_index()

# Rename the columns if needed
result_df.columns = ['gradient','yeo_network', 'mean_value', 'zmean_value']

result_df.to_csv('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\gradient_yeo_avgs.csv')
