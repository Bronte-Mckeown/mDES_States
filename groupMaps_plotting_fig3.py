# -*- coding: utf-8 -*-
"""

@author: Bronte Mckeown

This script creates brain map images of:
1) Task Group Maps
    
Common color scales to match scatterplots.

"""

# import libraries
import os
from nilearn import plotting, datasets, surface
import nibabel as nib
import matplotlib as plt

plt.rcParams.update({'font.size': 15})

# function to plot volumetric on surface
def project_mni_on_surface(mni_image_path, hemisphere, view, cmap, colorbar, output_dir):


    fsaverage = datasets.fetch_surf_fsaverage('fsaverage')
    if hemisphere == 'left':
        mesh = surface.load_surf_mesh(fsaverage.pial_left)
        bg_map = fsaverage.sulc_left
    else:
        mesh = surface.load_surf_mesh(fsaverage.pial_right)
        bg_map = fsaverage.sulc_right
    stat_img = nib.load(mni_image_path)
    volmap = surface.vol_to_surf(stat_img, mesh)
    fig = plotting.plot_surf_stat_map(mesh, volmap, hemi=hemisphere,
        view= view, colorbar=colorbar,
        figsize = (0.5, 1),
        bg_map=bg_map, 
        bg_on_data = True,
        darkness = .7,
        alpha = .9,
        cmap = cmap,
        vmax = 10)
    fig.show()
    base_name = os.path.splitext(os.path.basename(mni_image_path))[0].replace(".nii","")
    output_file_path = os.path.join(output_dir, f'{base_name}_{hemisphere}_{view}_colorbar={colorbar}_{cmap}_vminvmax.png')
    fig.savefig(output_file_path, dpi =1000)
    
# Read in gradient and group maps
    
nontarget = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\nontarget_group.nii.gz"
target = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\target_group.nii.gz"

# store in list to loop over

task_paths = [nontarget, target]
# plot with & without color bars for figures 3 & 5

for mni_image_path in task_paths:
    project_mni_on_surface(mni_image_path,
                           "right" ,
                           "lateral",
                           "Spectral_r",
                           True,
                           "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_pngs")
    project_mni_on_surface(mni_image_path,
                           "left" ,
                           "lateral",
                           "Spectral_r",
                           True,
                           "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_pngs")
    project_mni_on_surface(mni_image_path,
                           "right" ,
                           "medial",
                           "Spectral_r",
                           True,
                           "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_pngs")
    project_mni_on_surface(mni_image_path,
                           "left" ,
                           "medial",
                           "Spectral_r",
                          True,
                           "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_pngs")
    
