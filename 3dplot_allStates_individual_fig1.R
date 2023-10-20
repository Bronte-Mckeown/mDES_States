# This script makes 3d plot of individual points for all states.
# for analysis figure (figure 1)

######################### Libraries  ###########################################

library(ggplot2)
library(plotly)
library(dplyr)
library(ggridges)
library(processx)

################################################################################

# set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data")

# load data
dfplots1 <- read.csv("deriv/P1389_avgRun_gradSimMid_pcaWide_demo_acc.csv", na.strings=c(""," ","NA", "nan"))

# select subset to just be 'up' copes
dfplots2 <- subset(dfplots1, (cope %in% c('target_up', 'non_target_up','pca1_up',
                                          'pca2_up', 'pca3_up')))


# Change names for plotting
dfplots2$cope[which(dfplots2$cope == 'non_target_up')] <- 'Vigilance'
dfplots2$cope[which(dfplots2$cope == 'target_up')] <- 'Target Detection'
dfplots2$cope[which(dfplots2$cope == 'pca1_up')] <- 'Off-task'
dfplots2$cope[which(dfplots2$cope == 'pca2_up')] <- 'Deliberate'
dfplots2$cope[which(dfplots2$cope == 'pca3_up')] <- 'Verbal Self-relevant'

# set as factor
dfplots2$cope <- factor(dfplots2$cope, levels = c('Vigilance', 'Target Detection',
                                                  'Off-task', 'Deliberate',
                                                  'Verbal Self-relevant'))
levels(dfplots2$cope) # check levels

# plot using plotly
fig <- plot_ly(dfplots2, x = ~gradient2, y = ~gradient1, z = ~gradient3,  
                    color = ~cope,
               marker = list(size = 6), opacity = 0.8, colors = c("red", "green",
                                                                  "blue", "orange",
                                                                  "pink")
               )
fig <- fig %>% add_markers()

# add labels
fig <- fig %>% layout(showlegend = TRUE,font=list(size = 20, color = "black"),
                      scene = list(xaxis = list(title = '',
                                                range=c(-0.4,0.4),
                                                tickvals = c(-0.3,0,0.3), 
                                                ticktext = c("Motor", "", "Visual"),
                                                tickfont=list(size=16)),
                                                yaxis = list(title = '',
                                                             range=c(-0.4,0.4),
                                                             tickvals = c(-0.3,0,0.3),
                                                             ticktext = c("Sensory-Motor", "", "Association"),
                                                             tickfont=list(size=16)),
                                                zaxis = list(title = '', 
                                                             range=c(-0.4,0.4),
                                                             tickvals = c(-0.3,0,0.3), 
                                                             ticktext = c("DMN", "", "FPN"),
                                                             tickfont=list(size=16))))
# show in viewer
fig