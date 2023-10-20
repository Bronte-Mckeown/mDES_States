"
This script runs multiple regressions to predict RT based on:
- state-space positions of targets and non-targets
- sate space positions of covert states
- PCA scores
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
df <- read.csv("P1389_avgRun_gradSimWide_pcaWide_demo_acc.csv",
               na.strings=c(""," ","NA", "nan"))

############################### set up #########################################

# set contrasts to contr.sum
options(contrasts = c("contr.sum","contr.poly"))
options("contrasts")

results_dir <- "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\performance"

############################ z-score RT prep ###################################

# z-score response time
df$Z_RT <- scale(df$RT, center = TRUE, scale = TRUE)

# Identify cases with z-score above 2.5
df$outlier <- ifelse(df$Z_RT > 2.5, "Outlier", "Not Outlier")

# set these cases to zero
df$Z_RT_outliers <- ifelse(df$outlier == "Outlier", 0, df$Z_RT)

###################### Target + Non-targets ####################################

targetandnontarget_RT <- lm(data = df, Z_RT_outliers ~ gradient1_non_target_up + gradient2_non_target_up + gradient3_non_target_up + 
                              gradient4_non_target_up+ gradient5_non_target_up +
                              gradient1_target_up + gradient2_target_up + gradient3_target_up+ gradient4_target_up + gradient5_target_up +
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
myfile3 <- file.path(results_dir,"bootstrapped_overt_grad_rt")
tab_df(pb, file = myfile3, show.rownames = FALSE)

setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\performance")

tab_model(targetandnontarget_RT, file = "overt_grad_rt",
           show.df = FALSE,
          show.r2 = TRUE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)

####################### Covert States ##########################################
covert_RT <- lm(data = df, Z_RT_outliers ~ gradient1_pca1_up + gradient2_pca1_up + gradient3_pca1_up+
                  gradient4_pca1_up + gradient5_pca1_up +
                  gradient1_pca2_up + gradient2_pca2_up + gradient3_pca2_up+
                  gradient4_pca2_up + gradient5_pca2_up +
                  gradient1_pca3_up + gradient2_pca3_up + gradient3_pca3_up+
                  gradient4_pca3_up + gradient5_pca3_up + 
                  Age + Gender + MeanMovement)
  
summary(covert_RT)
Anova(covert_RT, type = 3)

# bootstrapping
pb <- bootstrap_parameters(covert_RT , iterations = 1000)
pb <- as.data.frame(pb)

# select col indexes for formatting
col_index <- c(2,3,4)

# change decimal places in specific columns + remove leading zeros from p-values
pb[, col_index] <- round(pb[, col_index], 2)
pb <- p_format(pb, digits = 3,leading.zero = FALSE, trailing.zero = TRUE, accuracy = .001)
pb

# save summary tables for bootstrapped estimates
myfile3 <- file.path(results_dir,"bootstrapped_covert_grad_rt")
tab_df(pb, file = myfile3, show.rownames = FALSE)

tab_model(covert_RT, file = "covert_grad_rt",
          show.df = FALSE,
          show.r2 = TRUE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)

############################## PCA scores ######################################

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

#save summary tables for bootstrapped estimates
myfile1 <- file.path(results_dir, "bootstrapped_thoughts_rt")
tab_df(pb2, file = myfile1, show.rownames = FALSE)

tab_model(thoughts_scanner, file = "thoughts_scanner_rt",
          show.df = FALSE,
          show.r2 = TRUE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)


###################### Plots ###################################################
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\performance")

fontsize = 6 # 6 points; not quite the same as powerpoint points but that's fine

target_grad2_rt <- ggplot(df ,aes(y= Z_RT_outliers, x= gradient2_target_up)) + geom_point(size = 2/.pt) +
  labs(y = "Response Time (z-score)",
       x = "Target Detection position along Dimension 2")+ theme_classic()+ ylim(-2.10,1.6)+xlim(-.45,.4)+ 
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
  annotate("text", x = 0.3, y = -2, label = "Visual",size = fontsize/.pt,fontface =2 )
target_grad2_rt

ggsave(
  "target_grad2_rt.tiff",
  target_grad2_rt, units = "cm",
  width = 5,
  height = 5,
  dpi = 1000
)

nontarget_grad1_rt <- ggplot(df ,aes(y= Z_RT_outliers, x= gradient1_non_target_up)) + geom_point(size = 2/.pt) +
  labs(y = "Response Time (z-score)",
       x = "Vigilance position along Dimension 1")+ theme_classic()+ ylim(-2.10,1.6)+xlim(-.15,.4)+ 
  theme(axis.text.y = element_text(size = fontsize,color = "black"),
        axis.text.x = element_text(size = fontsize,color = "black"),
        axis.line = element_line(colour = 'black', linewidth = .5/.pt),
        axis.ticks = element_line(colour = "black", linewidth  = .5/.pt),
        axis.title.y = element_text(size = fontsize, color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)),
        axis.title.x = element_text(size = fontsize,color = "black",
                                    margin = margin(t = 0, r = 0, b = 0, l = 0)))+
  geom_smooth(method=lm, color = "black")+ 
  annotate("text", x = -0.1, y = -2, label = "", size = fontsize/.pt,fontface =2 )+ 
  annotate("text", x = 0.25, y = -2, label = "",size = fontsize/.pt,fontface =2 )
nontarget_grad1_rt

ggsave(
  "nontarget_grad1_rt.tiff",
  nontarget_grad1_rt, units = "cm",
  width = 5,
  height = 5,
  dpi = 1000
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

