"This script makes distribution plots for supplementary materials to show spread of
gradient value data for each map type"

######################## Libraries #############################################

library(plotly)
library(dplyr)
library(ggplot2)
library(ggridges)
library(patchwork)
library(DescTools) # r to z transform

########################## Data prep ###########################################
#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data")
dfplots <- read.csv("deriv/P1389_avgRun_allCon_gradSimWide_pcaWide_demo.csv", na.strings=c(""," ","NA", "nan"))

dfplots <- subset(dfplots, (cope %in% c('target_up', 'non_target_up',
                                        'pca1_up', 'pca2_up', 'pca3_up')))

## Set fixed factors: Cope + Gender
dfplots$cope <- factor(dfplots$cope, levels = c("non_target_up", 
                                                "target_up",
                                                'pca1_up',
                                                'pca2_up',
                                                'pca3_up'
), 
ordered = FALSE) #set order to False.

#to check it's worked, run this command and see print out.
levels(dfplots$cope)

cope.labs <- c("Vigilance","Target Detection", "Off-task", "Deliberate", "Verbal, Self-relevant")

# R-to-Z Fishers transform
dfplots$Zgradient1<- FisherZ(dfplots$gradient1)
dfplots$Zgradient2 <- FisherZ(dfplots$gradient2)
dfplots$Zgradient3 <- FisherZ(dfplots$gradient3)

######################### Ridge plots ##########################################
ridge1 <- ggplot(dfplots, aes(x=Zgradient1, y=cope, fill = factor(stat(quantile)))) +
  stat_density_ridges(
    geom = "density_ridges_gradient", calc_ecdf = TRUE,
    quantiles = 4, quantile_lines = TRUE
  ) +
  scale_fill_viridis_d(name = "Quartiles")+ 
  scale_y_discrete(labels= cope.labs)+labs(x = "Dimension 1 (neg = sensory-motor, pos = association)", y = "",
                                                 title = '')+xlim(-0.8, 0.8)+theme_classic(base_size = 10)

ridge2 <- ggplot(dfplots, aes(x=Zgradient2, y=cope, fill = factor(stat(quantile)))) +
  stat_density_ridges(
    geom = "density_ridges_gradient", calc_ecdf = TRUE,
    quantiles = 4, quantile_lines = TRUE
  ) +
  scale_fill_viridis_d(name = "Quartiles")+ 
  scale_y_discrete(labels= cope.labs)+labs(x = "Dimension 2 (neg = motor, pos = visual)", y = "",
                                           title = '')+xlim(-0.8, 0.8)+theme_classic(base_size = 10)


ridge3 <- ggplot(dfplots, aes(x=Zgradient3, y=cope, fill = factor(stat(quantile)))) +
  stat_density_ridges(
    geom = "density_ridges_gradient", calc_ecdf = TRUE,
    quantiles = 4, quantile_lines = TRUE
  ) +
  scale_fill_viridis_d(name = "Quartiles")+ 
  scale_y_discrete(labels= cope.labs)+labs(x = "Dimension 3 (neg = DMN, pos = FPN)", y = "",
                                           title = '')+xlim(-0.8, 0.8)+theme_classic(base_size = 10)


allridge <- ridge1/ridge2/ridge3  + plot_layout(guides = 'collect')
allridge

# set current directory to results folder
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results")

# save
ggsave(
  "ridgeplots.tiff",
  allridge, units = "cm",
  width = 15,
  height = 15,
  dpi = 1000, 
)
