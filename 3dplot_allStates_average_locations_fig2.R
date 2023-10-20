"This script plots group-average state locations in 3d scatter
for figure 2."

######################### Libraries ############################################

library(ggplot2)
library(plotly)
library(dplyr)
library(ggridges)

######################### Load data ############################################
#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data")
dfplots1 <- read.csv("deriv/P1389_avgRun_gradSimMid_pcaWide_demo_acc.csv", na.strings=c(""," ","NA", "nan"))

######################### Data Prep ############################################
# select subset
dfplots1 <- subset(dfplots1, (cope %in% c('target_up', 'non_target_up', 
                                          'pca1_up', 'pca2_up', 'pca3_up')))


# calculate means
means2 <- aggregate(dfplots1[, 4:6], list(dfplots1$cope), mean)
means2 <- setNames(means2,  
                  c("cope","gradient1", "gradient2", "gradient3"))

means2$cope[which(means2$cope == 'non_target_up')] <- 'Vigilance'
means2$cope[which(means2$cope == 'target_up')] <- 'Target'
means2$cope[which(means2$cope == 'pca1_up')] <- 'Off-task'
means2$cope[which(means2$cope == 'pca2_up')] <- 'Deliberate'
means2$cope[which(means2$cope == 'pca3_up')] <- 'Verbal Self'

# set cope as factor
means2$cope <- factor(means2$cope, levels = c('Vigilance', 'Target','Off-task',
                                              'Deliberate', 'Verbal Self'))
levels(means2$cope)

# plot means
fig <- plot_ly(means2, x = ~gradient1, y = ~gradient2, z = ~gradient3,  
                    color = ~cope,symbol = ~cope,
               marker = list(size = 10), opacity = 0.6, colors = c("black", "black"),
               symbols = c("circle-open", "diamond-open",
                           "circle", "diamond", "square"))
fig <- fig %>% add_markers()
fig <- fig %>% layout(showlegend = TRUE,
                      scene = list(xaxis = list(title = '',
                                                range=c(-0.3,0.3),
                                                tickvals = c(-0.2,0,0.2), 
                                                ticktext = c("Sensory-Motor", "", "Association"),
                                                tickfont=list(size=18)),
                                                yaxis = list(title = '',
                                                             range=c(-0.3,0.3),
                                                             tickvals = c(-0.2,0,0.2), 
                                                             ticktext = c("Motor", "", "Visual"),
                                                             tickfont=list(size=18)),
                                                zaxis = list(title = '', 
                                                             range=c(-0.3,0.3),
                                                             tickvals = c(-0.2,0,0.2), 
                                                             ticktext = c("DMN", "", "FPN"),
                                                             tickfont=list(size=18))))


fig