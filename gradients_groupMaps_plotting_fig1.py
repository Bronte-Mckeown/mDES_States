# -*- coding: utf-8 -*-
"""

@author: Bronte Mckeown

This script creates brain map images of:
1) Gradients
2) Task + Experience Group maps
    
Separate color scale for each map, determined by its own vmax value.

Therefore, cannot compare colors across plots, but allows for better
visualisation of spatial PATTERNS across maps since this approach shows
differences in each map. 

If we created common scale (e.g., 10), then we wouldn't be able to discern
differences in some maps with smaller ranges, therefore, impeding ability to see
overall spatial pattern.

"""

# import libraries
import os
from nilearn import plotting, datasets, surface
import nibabel as nib

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
        bg_map=bg_map, 
        bg_on_data = True,
        darkness = .7,
        alpha = .9,
        cmap = cmap)
    fig.show()
    base_name = os.path.splitext(os.path.basename(mni_image_path))[0].replace(".nii","")
    output_file_path = os.path.join(output_dir, f'{base_name}_{hemisphere}_{view}_colorbar={colorbar}_{cmap}_vminvmax.png')
    fig.savefig(output_file_path, dpi =1000)
    
# Read in gradient and group maps
    
grad1 = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\Gradient1.nii.gz"
grad2 = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\Gradient2.nii.gz"
grad3 = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\Gradient3.nii.gz"

nontarget = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\nontarget_group.nii.gz"
target = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\target_group.nii.gz"

pca1 = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\pca1_group.nii.gz"
pca2 = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\pca2_group.nii.gz"
pca3 = "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\pca3_group.nii.gz"

# store in list to loop over
mni_image_paths = [grad1, grad2, grad3, target, nontarget, pca1, pca2, pca3]

# plot without colour bars for figure 1 (analysis pipeline)

for mni_image_path in mni_image_paths:
    project_mni_on_surface(mni_image_path,
                           "right" ,
                           "lateral",
                           "Spectral_r",
                           False,
                           "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_pngs")
