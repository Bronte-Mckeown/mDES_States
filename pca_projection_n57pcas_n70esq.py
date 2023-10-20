########################## Import #############################################
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
import seaborn as sns

############################ Read data ########################################

# set folder where all data is stored
folder = Path("C:/Users/bront/Documents/CanadaPostdoc/GradientSpace/data")

# set file paths of two datasets
n70_f = folder / "deriv/All_exp_N70_probe_level_data_9Feb_taskbattery.csv"
n57_f = folder / "deriv/P1389_avgRun_57_esq_pca_demo.csv"

# and PCA loadings from go/nogo dataset (N = 57)
n57_loadings_f = folder / "deriv/component_loadings_for_scanner_pca_for_projection.csv"

# read in datafiles
n70 = pd.read_csv(n70_f)
n57 = pd.read_csv(n57_f)
n57_loadings = pd.read_csv(n57_loadings_f, header=None)

########################## Wrangle data #######################################
# made labels the index in n57_loadings
n57_loadings.set_index(0, inplace=True)

# Rename the columns from integers to strings
n57_loadings.rename(columns={1: 'PC1', 2: 'PC2', 3: 'PC3'}, inplace=True)

# select esq columns
n57_esq = n57.loc[:, "Deliberate":"Task"]
n70_esq = n70.loc[:, "Focus":"Source"]

# rename focus to task after selection 
n70_esq.rename(columns={'Focus': 'Task'}, inplace=True)

# store subject id as index
n57.set_index('SubjectID', inplace=True)
n57_index = n57.index

n70.set_index('Participant_number', inplace=True)
n70_index = n70.index

# reordering
desired_order = n57_esq.columns.intersection(n70_esq.columns)
n70_esq = n70_esq[desired_order]

############################ Scaling data #####################################
# Scale york battery data according to go/no-go data.

# Create an instance of StandardScaler and fit it on the original data
scaler = StandardScaler()
scaler.fit(n57_esq)

# Transform (standardize) the new data using the original data's statistics
n70_zscored = scaler.transform(n70_esq)

############################# Project ########################################

# use np.dot to project n57 loadings onto n70 task battery data
projected_data = np.dot(n70_zscored, n57_loadings)

# Convert the projected_data numpy array back to a DataFrame
projected_df = pd.DataFrame(projected_data, columns=['projected_PCA1','projected_PCA2','projected_PCA3'], index=n70_index)

# Add the projected columns to the n57 DataFrame
n70_with_projection = pd.concat([n70, projected_df], axis=1)

########################## Sanity checking ####################################

# to manually check projection, save out z-scored data
n70_zscored_df = pd.DataFrame(n70_zscored)
n70_zscored_df.to_csv(folder /"deriv/n70_yorktaskbattery_esq_zscored_by_P1389.csv")

############################# Save out ########################################

# select columns of interest
n70_projection_cols = n70_with_projection[['Condition','ProbeNumber','Day','Order','projected_PCA1','projected_PCA2','projected_PCA3']]

# collapse go/no-go in n70 dataset and rename conditions
replacement_dict = {'Go': 'Go',
                    'NoGo': 'No-Go',
                    'Word' : 'Verbal Semantics',
                    'Pictur': 'Visual Semantics',
                    'You':'Self Reference',
                     'Friend': 'Friend Reference',
              'SWM': 'Working Memory',
                'IED': 'Task Switching',
                'CGT': 'Gambling',
 'ERT': 'Emotion Recognition',
   'uncert': 'Video: Suspense',
   'cert': 'Video: Action',
   'video': 'Documentary',
   'audio': 'Audiobook',
     'inscap' :'Inscapes'}

# Use the replace method to replace values 
n70_projection_cols['Condition'] = n70_projection_cols['Condition'].replace(replacement_dict)

# Save the updated n70 DataFrame as a CSV file
output_file = folder / "deriv/All_exp_N70_probe_level_data_9Feb_taskbatterywith_projectedPCAs.csv"
n70_projection_cols.to_csv(output_file, index=True)
