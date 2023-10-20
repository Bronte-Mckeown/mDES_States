"This script plots individual and group-average covert state locations in 3d scatter
for figure 5."

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
dfplots2 <- subset(dfplots1, (cope %in% c('pca1_up', 'pca2_up','pca3_up')))

# calculate means
means2 <- aggregate(dfplots2[, 4:6], list(dfplots2$cope), mean)
means2 <- setNames(means2,  
                  c("cope","gradient1", "gradient2", "gradient3"))

means2$cope[which(means2$cope == 'pca1_up')] <- 'Off-task'
means2$cope[which(means2$cope == 'pca2_up')] <- 'Deliberate'
means2$cope[which(means2$cope == 'pca3_up')] <- 'Verbal Self-relevant'

means2$cope <- factor(means2$cope, levels = c('Off-task','Deliberate','Verbal Self-relevant'))
levels(means2$cope)

# prepare individual
dfplots2$cope[which(dfplots2$cope == 'pca1_up')] <- 'Off-task'
dfplots2$cope[which(dfplots2$cope == 'pca2_up')] <- 'Deliberate'
dfplots2$cope[which(dfplots2$cope == 'pca3_up')] <- 'Verbal Self-relevant'

dfplots2$cope <- factor(dfplots2$cope, c('Off-task','Deliberate','Verbal Self-relevant'))
levels(dfplots2$cope)

######################### Make plot ############################################
# individual points
fig <- plot_ly(dfplots2, x = ~gradient1, y = ~gradient2, z = ~gradient3,  
                    color = ~cope,symbol = ~cope,
               marker = list(size = 7), opacity = 0.2, colors = c("black", "black","black"),
               symbols = c("square", "circle","circle-open"))
fig <- fig %>% add_markers()
fig <- fig %>% layout(showlegend = TRUE,legend = list(itemsizing = 'constant',
                                                      
                                                      opacity = 1,
                                                      symbolsize = 20),
                      scene = list(xaxis = list(title = '',
                                                range=c(-0.5,0.5),
                                                tickvals = c(-0.4,0,0.4), 
                                                ticktext = c("Sensory-Motor", "", "Association"),
                                                tickfont=list(size=18)),
                                                yaxis = list(title = '',
                                                             range=c(-0.5,0.5),
                                                             tickvals = c(-0.4,0,0.4),
                                                             ticktext = c("Motor", "", "Visual"),
                                                             tickfont=list(size=18)),
                                                zaxis = list(title = '', 
                                                             range=c(-0.5,0.5),
                                                             tickvals = c(-0.4,0,0.4), 
                                                             ticktext = c("DMN", "", "FPN"),
                                                             tickfont=list(size=18))))

# add mean points
fig <- fig %>% 
  add_trace(data = means2, x = ~gradient1, y = ~gradient2, z = ~gradient3,  
            color = ~cope, symbol = ~cope,mode = "marker",opacity = 1,
            colors = c("black", "black","black"),
            inherit = F, showlegend = FALSE, marker = list(size = 12)) 

fig