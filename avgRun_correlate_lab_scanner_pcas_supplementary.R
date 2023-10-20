"This script correlates lab and scanner PCAs with n = 46 sample"

############################# Libraries ########################################
library(ggplot2) #for plots
library(plyr) #for data manipulation
library(tidyverse) #for data manipulation
library(ggpubr) #for plots
library(patchwork) #for putting plots together

########################## Read in data ########################################
#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data\\deriv")

#read in csv file
df1 <- read.csv("P1389_avgRun_allCon_gradSimPcaWide_demo_acc_n46_Labdata.csv", na.strings=c(""," ","NA", "nan"))

############################ Make plots ########################################

fac1 <- ggplot(df1, aes(y=FAC_1_MEAN, x= SCAN_FAC_1_MEAN)) + geom_point(size = 3) +
  labs(y = "Lab Off-task Thought",
       x = "Scanner Off-task Thought")+ theme_classic()+ ylim(-2.5,2.5)+xlim(-2.5,2.5)+ 
  theme(axis.text.y = element_text(size = 10,color = "black"),
        axis.text.x = element_text(size = 10,color = "black"),
        axis.title.y = element_text(size = 10, color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)),
        axis.title.x = element_text(size = 10,color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)))+
geom_smooth(method=lm, color = "black")
fac1

fac2 <- ggplot(df1, aes(y=FAC_2_MEAN, x= SCAN_FAC_2_MEAN)) + geom_point(size = 3) +
  labs(y = "Lab Deliberate Thought",
       x = "Scanner Deliberate Thought")+ theme_classic()+ ylim(-2.5,2.5)+xlim(-2.5,2.5)+ 
  theme(axis.text.y = element_text(size = 10,color = "black"),
        axis.text.x = element_text(size = 10,color = "black"),
        axis.title.y = element_text(size = 10, color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)),
        axis.title.x = element_text(size = 10,color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)))+
  geom_smooth(method=lm, color = "black")
fac2

fac3 <- ggplot(df1, aes(y=FAC_3_MEAN, x= SCAN_FAC_3_MEAN)) + geom_point(size = 3) +
  labs(y = "Lab Verbal Self-relevant Thought",
       x = "Scanner Verbal Self-relevant Thought")+ theme_classic()+ ylim(-2.5,2.5)+xlim(-2.5,2.5)+ 
  theme(axis.text.y = element_text(size = 10,color = "black"),
        axis.text.x = element_text(size = 10,color = "black"),
        axis.title.y = element_text(size = 10, color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)),
        axis.title.x = element_text(size = 10,color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)))+
  geom_smooth(method=lm, color = "black")
fac3

## add labels for pearson R and p-values to plots
fac1 <- fac1 +stat_cor(label.x = -2.5, label.y = 2.5, method = "pearson",size=3, p.accuracy = 0.001, r.accuracy = 0.01)
fac1

fac2 <- fac2 +stat_cor(label.x = -2.5, label.y = 2.5, method = "pearson",size=3, p.accuracy = 0.001, r.accuracy = 0.01)
fac2

fac3 <- fac3 +stat_cor(label.x = -2.5, label.y = 2.5, method = "pearson",size=3, p.accuracy = 0.001, r.accuracy = 0.01)
fac3

# put together
all_plots_v <- fac1/fac2/fac3
all_plots_v

# set current directory to results folder for saving
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results")

ggsave(
  "lab_scanner_pca_correlations_v.tiff",
  all_plots_v, units = "cm",
  width = 15,
  height = 15,
  dpi = 1000, 
)
