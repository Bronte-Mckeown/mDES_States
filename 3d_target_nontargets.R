######################### 3D plots #############################################

library(ggplot2)
library(plotly)
library(dplyr)
library(ggridges)

#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data")
dfplots1 <- read.csv("deriv/P1389_avgRun_allCon_gradSimWide_pcaWide_demo.csv", na.strings=c(""," ","NA", "nan"))

# select subset
dfplots2 <- subset(dfplots1, (cope %in% c('target_up', 'non_target_up')))

means2 <- aggregate(dfplots2[, 4:6], list(dfplots2$cope), mean)
means2 <- setNames(means2,  
                  c("cope","gradient1", "gradient2", "gradient3"))

means2$cope[which(means2$cope == 'non_target_up')] <- 'Vigilance'
means2$cope[which(means2$cope == 'target_up')] <- 'Target'

means2$cope <- factor(means2$cope, levels = c('Target','Vigilance'))
levels(means2$cope)

# individual points
dfplots2$cope[which(dfplots2$cope == 'non_target_up')] <- 'Vigilance'
dfplots2$cope[which(dfplots2$cope == 'target_up')] <- 'Target'

dfplots2$cope <- factor(dfplots2$cope, levels = c('Target','Vigilance'))
levels(dfplots2$cope)

fig <- plot_ly(dfplots2, x = ~gradient1, y = ~gradient2, z = ~gradient3,  
                    color = ~cope,symbol = ~cope,
               marker = list(size = 10), opacity = 0.6, colors = c("black", "black"),
               symbols = c("circle-open", "circle"))
fig <- fig %>% add_markers()
fig <- fig %>% layout(showlegend = TRUE,
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


fig <- fig %>% 
  add_trace(data = means2, x = ~gradient1, y = ~gradient2, z = ~gradient3,  
            color = ~cope, symbol = ~cope,mode = "marker",opacity = 1,
            inherit = F, showlegend = FALSE, marker = list(size = 20)) 

#fig <- fig %>% layout(legend = list(x = 0.3, y = 0.1,z =0.4))

fig