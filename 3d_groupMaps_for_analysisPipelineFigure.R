######################### 3D plots #############################################

library(ggplot2)
library(plotly)
library(dplyr)
library(ggridges)
library(processx)

#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data")
dfplots1 <- read.csv("deriv/P1389_avgRun_allCon_gradSimWide_pcaWide_demo.csv", na.strings=c(""," ","NA", "nan"))

# select subset
dfplots2 <- subset(dfplots1, (cope %in% c('target_up', 'non_target_up','pca1_up',
                                          'pca2_up', 'pca3_up')))


# individual points
dfplots2$cope[which(dfplots2$cope == 'non_target_up')] <- 'Vigilance'
dfplots2$cope[which(dfplots2$cope == 'target_up')] <- 'Target Detection'
dfplots2$cope[which(dfplots2$cope == 'pca1_up')] <- 'Off-task'
dfplots2$cope[which(dfplots2$cope == 'pca2_up')] <- 'Deliberate'
dfplots2$cope[which(dfplots2$cope == 'pca3_up')] <- 'Verbal Self-relevant'

dfplots2$cope <- factor(dfplots2$cope, levels = c('Vigilance', 'Target Detection',
                                                  'Off-task', 'Deliberate',
                                                  'Verbal Self-relevant'))
levels(dfplots2$cope)

fig <- plot_ly(dfplots2, x = ~gradient2, y = ~gradient1, z = ~gradient3,  
                    color = ~cope,
               marker = list(size = 8), opacity = 0.8, colors = c("red", "green",
                                                                  "blue", "orange",
                                                                  "pink")
               )
fig <- fig %>% add_markers()
fig <- fig %>% layout(showlegend = TRUE,font=list(size = 20, color = "black"),
                      scene = list(xaxis = list(title = '',
                                                range=c(-0.5,0.5),
                                                tickvals = c(-0.4,0,0.4), 
                                                ticktext = c("Motor", "", "Visual"),
                                                tickfont=list(size=16)),
                                                yaxis = list(title = '',
                                                             range=c(-0.5,0.5),
                                                             tickvals = c(-0.4,0,0.4),
                                                             ticktext = c("Sensory-Motor", "", "Association"),
                                                             tickfont=list(size=16)),
                                                zaxis = list(title = '', 
                                                             range=c(-0.5,0.5),
                                                             tickvals = c(-0.4,0,0.4), 
                                                             ticktext = c("DMN", "", "FPN"),
                                                             tickfont=list(size=16))))
fig