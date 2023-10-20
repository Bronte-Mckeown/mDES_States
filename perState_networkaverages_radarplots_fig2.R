"Makes radar plot of overt and covert states (fig 2) "

############################ Libraries #########################################
#devtools::install_github("ricardo-bion/ggradar", 
#                         dependencies = TRUE)

library(ggplot2)
library(ggradar)
library(dplyr)
library(scales)
library(tidyr)

########################## Read in data ########################################
#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\networks")

#read in csv file
d <- read.csv("state_yeo_avgs.csv", na.strings=c(""," ","NA", "nan"))

############################# Prep data ########################################

# change names of networks and states for plotting
d$yeo_network <- sub("Dorsal Attention", "DAN", d$yeo_network)
d$yeo_network <- sub("Ventral Attention", "VAN", d$yeo_network)
d$yeo_network <- sub("Frontoparietal", "FPN", d$yeo_network)
d$yeo_network <- sub("Default Mode", "DMN", d$yeo_network)

d$state <- sub("nontarget_group", "Vigilance", d$state)
d$state <- sub("target_group", "Target", d$state)
d$state <- sub("pca1_group", "Off-task", d$state)
d$state <- sub("pca2_group", "Deliberate", d$state)
d$state <- sub("pca3_group", "Verbal Self", d$state)

# set as factors
d$yeo_network <- factor(d$yeo_network, levels = c("Visuospatial", "Somatomotor",
                                                  "DAN",
                                                  "VAN",
                                                  "Limbic",
                                                  "FPN",
                                                  "DMN"),
                        ordered = FALSE)
levels(d$yeo_network) # check

d$state <- factor(d$state , levels = c('Vigilance', 'Target','Off-task',
                                              'Deliberate', 'Verbal Self'))
levels(d$state) # check

# Pivot the data frame to wide format
df <- pivot_wider(d, names_from = yeo_network, values_from = mean_value)

# separate overt and covert data
overt_df <- subset(df, (state %in% c('Target', 'Vigilance')))
overt_df

covert_df <- subset(df, (state %in% c('Off-task', 'Deliberate','Verbal Self')))
covert_df

########################## Radar plots ########################################
## overt
overt <- ggradar(overt_df, grid.min = -4.5, grid.max = 4.5,grid.mid = 0,
                    values.radar = c("Low", "0", "High"),
                    legend.position = "bottom", fill = FALSE,base.size = 10,
                    group.line.width = 0.8,
                    group.point.size = 5,
                    grid.line.width = 0.2)
overt

# save
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\networks\\radarplots")

ggsave(
  "overt_radar.tiff",
  overt, units = "cm",
  width = 20,
  height = 20,
  dpi = 1000, 
)

## covert
covert <- ggradar(covert_df, grid.min = -1.5, grid.max = 1.5,grid.mid = 0,
                 values.radar = c("Low", "0", "High"),
                 legend.position = "bottom", fill = FALSE,base.size = 10,
                 group.line.width = 0.8,
                 group.point.size = 5,
                 grid.line.width = 0.2)
covert

# save
ggsave(
  "covert_radar.tiff",
  covert, units = "cm",
  width = 20,
  height = 20,
  dpi = 1000, 
)
