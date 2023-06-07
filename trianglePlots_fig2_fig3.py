
# -*- coding: utf-8 -*-
"""

@author: Bronte Mckeown
"""

import nibabel as nib
import matplotlib.pyplot as plt
import matplotlib.ticker as plticker

plt.rcParams.update({'font.size': 6})
# plt.rcParams["font.family"] = "sans-serif"

def scatter_brain_plot(colour_map, title, vmin, vmax, gradientx, gradienty, yaxisticks, figuresize, basesize):
    
    cmap = 'Spectral_r'

    # Load the data from the three nifti files
    data1_nii = nib.load('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\Gradient{}.nii.gz'.format(gradientx))
    data2_nii = nib.load('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\Gradient{}.nii.gz'.format(gradienty))
    
    
    colors_nii = nib.load(colour_map)
    mask_nii = nib.load('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\Gradient_mask.nii.gz')
    
    # Extract the data from the nifti files
    data1 = data1_nii.get_fdata()
    data2 = data2_nii.get_fdata()
    
    colors = colors_nii.get_fdata()
    mask = mask_nii.get_fdata()
    
    # Flatten the data arrays to make them easier to work with
    data1_flat = data1.flatten()
    data2_flat = data2.flatten()
    
    colors_flat = colors.flatten()
    
    # Create a boolean array indicating which elements of the data arrays should be plotted
    plot_mask = mask.flatten() > 0
    
    # Use the boolean array to select only the elements of the data arrays that should be plotted
    data1_plot = data1_flat[plot_mask]
    data2_plot = data2_flat[plot_mask]
    
    colors_plot = colors_flat[plot_mask]
        
    # Create the figure and set the size
    fig1 = plt.figure(figsize=figuresize)
    
    # Add a subplot for the scatterplot
    scatterplot_ax = fig1.add_subplot(1, 1, 1)
    
    # Create the scatterplot using data1 and data2 as the x and y axes
    scatter = scatterplot_ax.scatter(data2_plot,data1_plot,c=colors_plot,
                                     cmap=cmap,vmin = vmin, vmax = vmax, 
                                     s = 0.5
                                     )
    
    loc = plticker.MultipleLocator(base= basesize) # this locator puts ticks at regular intervals 
    scatterplot_ax.xaxis.set_major_locator(loc)
    
    if yaxisticks == False:
        scatterplot_ax.set_yticks([])
        scatterplot_ax.set_xlabel('Dimension {}'.format(gradientx))
    else:
        scatterplot_ax.set_xlabel('Dimension {}'.format(gradientx))   
        # Add axis labels to the scatterplot
        scatterplot_ax.set_ylabel('Dimension {}'.format(gradienty))

    
    fig1.savefig('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\{}_{}_{}_trianglePlot.png'.format(title,
                                                                                                                        gradientx,
                                                                                                                        gradienty),
                dpi = 1000,bbox_inches='tight')
    
    
    #return (fig1)
    
# Call function for all maps
scatter_brain_plot('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\target_group.nii.gz',
                            'target_vminvmax_grad1grad2', -10, 10, '1','2', False, (0.8, 1.7),3)

scatter_brain_plot('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\nontarget_group.nii.gz',
                            'nontarget_vminvmax_grad1grad2',-10, 10,'1','2', True, (0.8, 1.7),3)

scatter_brain_plot('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\pca1_group.nii.gz',
                            'pca1_vminvmax_narrow', -4, 4,'1','3', True,(0.5, 1.7),5)


scatter_brain_plot('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\pca2_group.nii.gz',
                            'pca2_vminvmax_narrow',-4, 4,'1','3', False,(0.5, 1.7),5)


scatter_brain_plot('C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\brain_maps\\pca3_group.nii.gz',
                            'pca3_vminvmax_narrow',-4, 4,'1','3', False,(0.5, 1.7),5)







