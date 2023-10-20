"Makes radar plot of 5 gradient dimensions (fig 2) "

############################ Libraries #########################################

library(ggplot2)
library(ggradar)
library(scales)
library(tidyr)
library(patchwork)

########################## Read in data ########################################
#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\networks")

#read in csv file
d <- read.csv("gradient_yeo_avgs.csv", na.strings=c(""," ","NA", "nan"))

############################# Data prep ########################################
d$gradient <- sub("gradient1", "Dim 1", d$gradient)
d$gradient <- sub("gradient2", "Dim 2", d$gradient)
d$gradient <- sub("gradient3", "Dim 3", d$gradient)
d$gradient <- sub("gradient4", "Dim 4", d$gradient)
d$gradient <- sub("gradient5",  "Dim 5", d$gradient)

d$yeo_network <- sub("Dorsal Attention", "DAN", d$yeo_network)
d$yeo_network <- sub("Ventral Attention", "VAN", d$yeo_network)
d$yeo_network <- sub("Frontoparietal", "FPN", d$yeo_network)
d$yeo_network <- sub("Default Mode", "DMN", d$yeo_network)

########################## Radar plots ########################################

# Pivot the dataframe to wide format
df <- pivot_wider(d, names_from = yeo_network, values_from = zmean_value)

# together

allradar <- ggradar(df, grid.min = -2.5, grid.max = 2.5,grid.mid = 0,
                    values.radar = c("Low", "0", "High"),
                  legend.position = "bottom", fill = FALSE,base.size = 10,
                  group.line.width = 0.8,
                  group.point.size = 5,
                  grid.line.width = 0.2)
allradar

# save
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\networks\\radarplots")

ggsave(
  "gradients_radar.tiff",
  allradar, units = "cm",
  width = 20,
  height = 20,
  dpi = 1000, 
)
