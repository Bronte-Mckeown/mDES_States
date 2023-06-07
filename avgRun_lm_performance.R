"
This script runs multiple regressions to predict RT based on:
- PCA scores
- state-space positions of targets and non-targets
"

############################### Load Libraries #################################

library(dplyr)# data manipulation
library(ggplot2)
library(ggcorrplot)
library(tidyverse)
library(ggpubr)
library(rstatix)
library(patchwork)
library(DescTools) # for R-to-Z Fishers transform
library(report)
library(sjPlot)
library(easystats)
library(stats)

############################### Data ###########################################

#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data\\deriv")

#read in csv file
df <- read.csv("P1389_avgRun_allCon_gradSimPcaWide_demo_acc.csv", na.strings=c(""," ","NA", "nan"))

# set contrasts to contr.sum
options(contrasts = c("contr.sum","contr.poly"))
options("contrasts")

########################## Thought Scores ######################################

# z-score response time
df$Z_RT <- scale(df$RT, center = TRUE, scale = TRUE)

# Identify cases with z-score above 2.5
df$outlier <- ifelse(df$Z_RT > 2.5, "Outlier", "Not Outlier")

# set these cases to zero
df$Z_RT_outliers <- ifelse(df$outlier == "Outlier", 0, df$Z_RT)

# multiple regression
thoughts_scanner <- lm(data = df,Z_RT_outliers ~ FAC1 + FAC2 + FAC3 + Age + Gender + MeanMovement)
summary(thoughts_scanner)
Anova(thoughts_scanner, type = 3)

# bootstrap
pb2 <- bootstrap_parameters(thoughts_scanner , iterations = 1000)
pb2 <- as.data.frame(pb2)

# change decimal places in specific columns + remove leading zeros from p-values
pb2[, col_index] <- round(pb2[, col_index], 2)
pb2 <- p_format(pb2, digits = 3,leading.zero = FALSE, trailing.zero = TRUE, accuracy = .001)
pb2

results_dir <- "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\reactionTime"

#save summary tables for bootstrapped estimates
myfile1 <- file.path(results_dir, "bootstrapped_thoughts_rt")
tab_df(pb2, file = myfile1, show.rownames = FALSE)

tab_model(thoughts_scanner, file = "thoughts_scanner_rt",
          show.df = FALSE,
          show.r2 = TRUE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)


###################### Target + Non-targets ####################################
# R-to-Z Fishers transform
df$Znon_target_up_gradient1<- FisherZ(df$non_target_up_gradient1)
df$Znon_target_up_gradient2<- FisherZ(df$non_target_up_gradient2)
df$Znon_target_up_gradient3<- FisherZ(df$non_target_up_gradient3)

df$Ztarget_up_gradient1<- FisherZ(df$target_up_gradient1)
df$Ztarget_up_gradient2<- FisherZ(df$target_up_gradient2)
df$Ztarget_up_gradient3<- FisherZ(df$target_up_gradient3)

targetandnontarget_RT <- lm(data = df, Z_RT_outliers ~ Znon_target_up_gradient1 + Znon_target_up_gradient2 + Znon_target_up_gradient3 +
                           Ztarget_up_gradient1 + Ztarget_up_gradient2 + Ztarget_up_gradient3+ 
                           Age + Gender + MeanMovement)
summary(targetandnontarget_RT)
Anova(targetandnontarget_RT, type = 3)

# bootstrapping
pb <- bootstrap_parameters(targetandnontarget_RT , iterations = 1000)
pb <- as.data.frame(pb)

# select col indexes for formatting
col_index <- c(2,3,4)

# change decimal places in specific columns + remove leading zeros from p-values
pb[, col_index] <- round(pb[, col_index], 2)
pb <- p_format(pb, digits = 3,leading.zero = FALSE, trailing.zero = TRUE, accuracy = .001)
pb

# save summary tables for bootstrapped estimates
myfile3 <- file.path(results_dir,"bootstrapped_task_rt")
tab_df(pb, file = myfile3, show.rownames = FALSE)

# set current directory to results folder
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\reactionTime")
tab_model(targetandnontarget_RT, file = "targetnontarget_rt",
           show.df = FALSE,
          show.r2 = TRUE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)

###################### Plots ###################################################
fontsize = 6 # 6 points; not quite the same as powerpoint points but that's fine

target_grad2_rt <- ggplot(df ,aes(y= Z_RT_outliers, x= target_up_gradient2)) + geom_point(size = 2/.pt) +
  labs(y = "Response Time (z-score)",
       x = "Target Detection position along Dimension 2")+ theme_classic()+ ylim(-2.10,1.6)+xlim(-.45,.3)+ 
  theme(axis.text.y = element_text(size = fontsize,color = "black"),
        axis.text.x = element_text(size = fontsize,color = "black"),
        axis.line = element_line(colour = 'black', linewidth = .5/.pt),
        axis.ticks = element_line(colour = "black", linewidth  = .5/.pt),
        axis.title.y = element_text(size = fontsize, color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)),
        axis.title.x = element_text(size = fontsize,color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)))+
  geom_smooth(method=lm, color = "black")+ 
  annotate("text", x = -0.4, y = -2, label = "Motor", size = fontsize/.pt,fontface =2 )+ 
  annotate("text", x = 0.25, y = -2, label = "Visual",size = fontsize/.pt,fontface =2 )
target_grad2_rt


ggsave(
  "target_grad2_rt.tiff",
  target_grad2_rt, units = "cm",
  width = 5,
  height = 5,
  dpi = 1000,
)

delib_rt <- ggplot(df ,aes(y= Z_RT_outliers, x= FAC2)) + geom_point(size = 2/.pt) +
  labs(y = "Response Time (z-score)",
       x = "Deliberate Task Focus")+ theme_classic()+ ylim(-2.10,1.6)+xlim(-1.5,2.5)+ 
  theme(axis.text.y = element_text(size = fontsize,color = "black"),
        axis.text.x = element_text(size = fontsize,color = "black"),
        axis.line = element_line(colour = 'black', linewidth = .5/.pt),
        axis.ticks = element_line(colour = "black", linewidth  = .5/.pt),
        axis.title.y = element_text(size = fontsize, color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)),
        axis.title.x = element_text(size = fontsize,color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)))+
  geom_smooth(method=lm, color = "black")
delib_rt

ggsave(
  "deliberate_rt.tiff",
  delib_rt, units = "cm",
  width = 5,
  height = 5,
  dpi = 1000, 
)
