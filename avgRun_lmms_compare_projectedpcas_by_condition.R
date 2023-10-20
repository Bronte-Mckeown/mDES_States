" x3 mixed LMMs to compare conditions in n70 york task battery dataset
using projected PCAs.
"
####################### Load libraries #########################################

library(emmeans) # saving predicted values for graphs and post-hoc contrasts
library(data.table) # data manipulation
library(ggthemes) # formatting graphs
library(ggpubr) # formatting graphs
library(patchwork) # putting plots together in one figure
library(report) # use to get written summary of results if required
library(sjPlot) # creating supplementary tables
library(effectsize)# calculate standardized parameters for models if required
library(dplyr)# data manipulation
library(interactions)# easy-view of interactions
library(performance) # diagnostics
library(lme4) # lmer
library(DescTools) # for R-to-Z Fishers transform
library(easystats) # for bootstrapping
library(rstatix) # for neatening tables

########################## Read in data ########################################
#set current working directory
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data")

#read in csv file [task battery data available if you contact corresponding author Delali Konu]
df1 <- read.csv("deriv\\All_exp_N70_probe_level_data_9Feb_taskbatterywith_projectedPCAs.csv", na.strings=c(""," ","NA", "nan"))

######################### Data prep ############################################
## Set fixed factors: Condition 
df1$Condition <- factor(df1$Condition,levels = c('Go','No-Go','Verbal Semantics' ,'Visual Semantics' ,
                                                 'Self Reference', 'Friend Reference' ,'Working Memory', 'Task Switching' ,'Gambling',
                                                 'Emotion Recognition', 'Video: Suspense' ,'Video: Action' ,'Documentary' ,'Audiobook', 'Inscapes'),
                         ordered = FALSE) #set order to False.
#to check it's worked, run this command and see print out.
levels(df1$Condition)

# Participant_number (participant)
df1$Participant_number <- as.factor(df1$Participant_number)

# Day, order, and probe number as factors
df1$ProbeNumber <- as.factor(df1$ProbeNumber)
levels(df1$ProbeNumber)

df1$Day <- as.factor(df1$Day)
levels(df1$Day)

df1$Order <- as.factor(df1$Order)
levels(df1$Order)

##################### Setting up for linear mixed models #######################
# set contrasts to contr.sum

options(contrasts = c("contr.sum","contr.poly"))
options("contrasts")

########################## Saving results ######################################
# set file name for lmer text output
fp = "LMM_compare_projectedPCAs.txt"

# set current directory to results folder
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\projectedpcas")

results_dir <- "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\projectedpcas"

############################# Models ###########################################
# set up list of dependent variables
dv <- c('projected_PCA1','projected_PCA2','projected_PCA3')

# set col index for creating bootstrap tables in loop below
col_index <- c(2,3,4)

# first run all 3 models without lmertest and use bootstrapping to calcualte
# parameter estimates
for(i in 1:length(dv)){
  model <- paste("model",i, sep="") # create model name
  
  # run model
  m <- lmer(as.formula(paste(dv[i],"~ Condition + ProbeNumber + Day + Order +
                             (1|Participant_number)")),
            data=df1)
  assign(model,m) # assign name to model
  
  # using easy stats
  # bootstrapped parameter estimates
  paramboot <- paste("paramboot",i, sep="")
  pb <- bootstrap_parameters(m, iterations = 1000)
  pb <- as.data.frame(pb)
  
  # change decimal places in specific columns + remove leading zeros from p-values
  pb[, col_index] <- round(pb[, col_index], 2)
  pb <- p_format(pb, digits = 3,leading.zero = FALSE, trailing.zero = TRUE, accuracy = .001)
  
  assign(paramboot, pb)
  
}

###########################  Summary tables ####################################
# combine all parameter estimates into one table
# done before using lmertest to prevent conflict with satterthwaite
myfile2 <- file.path(results_dir,"LMM_projectedpcas_summary")
tab_model(model1,model2,model3, file = myfile2, df.method = "satterthwaite",
          p.val = "satterthwaite",show.df = FALSE,
          show.r2 = FALSE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)

# save summary tables for bootstrapped estimates
boot_list <- list(paramboot1, paramboot2, paramboot3)
myfile3 <- file.path(results_dir,"LMM_projectedpcas_bootstrap")
tab_dfs(boot_list, file = myfile3, show.rownames = FALSE)

##################### re-run models with lmertest ##############################
library(lmerTest) # for regular p-values for LMMs (f-tests)
# globally set lmertest.limit to 2302 to calculate df
# also set to sattherthwaite
emm_options(lmerTest.limit = 2302, lmer.df = "satterthwaite")

# run all 3 models using each DV from list using loop
for(i in 1:length(dv)){
  model <- paste("model",i, sep="") # create names of models
  summ <- paste("summary",i, sep = "") # create names of summaries
  an <- paste("anova",i, sep = "") #  create names of anovas
  emmean <- paste("emmean",i, sep = "") # create name of emmeans
  
  # run model
  m <- lmer(as.formula(paste(dv[i],"~ Condition + ProbeNumber + Day + Order +
                             (1|Participant_number)")),
            data=df1) 
  
  s <- summary(m) # create summary
  a <- anova(m) # create anova
  e <- emmeans(m, ~ Condition, type = "response")
  
  
  # format anova tables
  a = subset(a, select = -c(`Sum Sq`,`Mean Sq`) )
  a = as.data.frame(a)
  
  a[, c(2)] <- round(a[, c(2)], 0)
  
  a[, c(3)] <- round(a[, c(3)], 2)
  
  colnames(a)[4]  <- "p" 
  
  a <- p_format(a, digits = 2, leading.zero = FALSE, trailing.zero = TRUE, accuracy = .001)
  
  assign(model,m) # assign model to model name
  assign(summ,s) # assign summary to summary name
  assign(an, a) # assign anova to anova name
  assign(emmean, e) #assign emmean to emmean name
  
  #save outputs to txt file
  capture.output(s,file = fp, append = TRUE)
  cat("\n\n\n", file = fp, append = TRUE)
  capture.output(a,file = fp, append = TRUE)
  cat("\n\n\n", file = fp, append = TRUE)
  capture.output(e,file = fp, append = TRUE)
  cat("\n\n\n", file = fp, append = TRUE)
  
} 

############################ ANOVA tables ######################################
# save anova tables
anova_list <- list(anova1, anova2, anova3)
myfile3 <- file.path(results_dir,"LMM_projectedpcas_anova")
tab_dfs(anova_list, file = myfile3,show.rownames = TRUE)

######################## Probe main effect of 'Condition' ########################
# create new txt file for post hoc comparisons
fp2 <- "LMM_projectedpcas_posthoc.txt"

# compare Conditions
Condition1.contrasts <- pairs(emmean1, adjust = "bonferroni", infer = TRUE)
Condition1.contrasts
emmean1

Condition2.contrasts <- pairs(emmean2, adjust = "bonferroni", infer = TRUE)
Condition2.contrasts
emmean2

Condition3.contrasts <- pairs(emmean3, adjust = "bonferroni", infer = TRUE)
Condition3.contrasts
emmean3

# save to txt file
cat("Comparing condition for PCA1:\n", file = fp2, append = TRUE)
capture.output(Condition1.contrasts,file = fp2, append = TRUE)
cat("\n\n\n", file = fp2, append = TRUE)

cat("Comparing condition for PCA2:\n", file = fp2, append = TRUE)
capture.output(Condition2.contrasts,file = fp2, append = TRUE)
cat("\n\n\n", file = fp2, append = TRUE)

cat("Comparing condition for PCA3:\n", file = fp2, append = TRUE)
capture.output(Condition3.contrasts,file = fp2, append = TRUE)
cat("\n\n\n", file = fp2, append = TRUE)

# save as csvs for making word clouds (fig 2)
emmean1_df <- as.data.frame(emmean1)
emmean2_df <- as.data.frame(emmean2)
emmean3_df <- as.data.frame(emmean3)

emmean1_df <- emmean1_df[c('Condition','response')]
emmean2_df <- emmean2_df[c('Condition','response')]
emmean3_df <- emmean3_df[c('Condition','response')]

# Merge response columns from different dataframes based on the 'Condition' column
combined_df <- merge(merge(emmean1_df, emmean2_df, by = 'Condition'), emmean3_df, by = 'Condition')

# Write the combined dataframe to a CSV file
write.table(combined_df, "combined_emmeans.csv", sep=",", col.names=FALSE, row.names=FALSE)

########################## Bar charts Horizontal ###############################
# set up list with names of emmeans (predicted means)
list <- c("emmean1", "emmean2", "emmean3")
titles <- c("Off-task Social Episodic", "Deliberate Task Focus", "Verbal Self")

fontsize <- 6

# function for making plots
myplot <- function(data, title) {
  # y axis = Condition, x axis = emmean, bars = gradient
  ggplot(summary(data), aes(x = Condition, y = response)) +
    theme_light() +
    geom_bar(stat = "identity", width = 0.9/.pt, position = "dodge", color = "black", size = 0.5/.pt) +
    xlim(-5, 7) +
    theme(
      plot.title = element_text(hjust = 0.5, size = fontsize),
      axis.text.x = element_text(size = fontsize, color = "black"),
      axis.text.y = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.ticks.y = element_blank(),
      plot.margin = margin(0, 0.5, 0.5, 0.5, "cm")
    ) +
    # add error bars
    geom_errorbar(position = position_dodge(.6/.pt), width = 0.25/.pt, size = 0.5/.pt, 
                  aes(xmin = lower.CL, xmax = upper.CL), alpha = 1) +
    labs(title = title)
}

# call function for list of emmeans set above and store each one (bar1, bar2, etc)
for (i in seq_along(list)) {
  bar <- paste("bar", i, sep = "")
  b <- myplot(get(list[i]), titles[i])
  assign(bar, b)
}

# add y-axis labels to bar1
Condition.labs <- c(
  'Go', 'No-Go', 'Verbal Semantics', 'Visual Semantics',
  'Self Reference', 'Friend Reference', 'Working Memory', 'Task Switching', 'Gambling',
  'Emotion Recognition', 'Video: Suspense', 'Video: Action', 'Documentary', 'Audiobook', 'Inscapes'
)
bar3 <- bar1 + theme(axis.text.y = element_text(size = fontsize, color = "black")) +
  scale_x_discrete(labels = Condition.labs) +
  theme(plot.margin = margin(0, 0.5, 0.5, 0.5, "cm"),
        axis.ticks.length.x = unit(3/.pt, "pt"),
        axis.ticks.x = element_line(linewidth = 1.5/.pt))

# put together
all_plots <- (bar1) / (bar2) / (bar3) &
  geom_hline(yintercept = 0, size = 0.2/.pt)
all_plots

# save plots
ggsave(
  "LMM_projectedpcas_h.tiff",
  all_plots, units = "cm",
  width = 15,
  height = 10,
  dpi = 1000, 
)

ggsave(
  "LMM_projectedpcas_h.png",
  all_plots, units = "cm",
  width = 15,
  height = 10,
  dpi = 1000, 
)

############################# Assumptions ######################################
models = c(model1, model2, model3)
#QQ plots
for (i in seq_along(models)) {
  jpeg(paste("qq_plot", i, ".png", sep = ""))
  qq <- qqnorm(resid(models[[i]]))
  dev.off()
}

#histograms
for (i in seq_along(models)) {
  jpeg(paste("hist_plot", i, ".png", sep = ""))
  hist <- hist(resid(models[[i]]))
  dev.off()
}

#residual plots
for (i in seq_along(models)) {
  jpeg(paste("fitted_residual_plot", i, ".png", sep = ""))
  fitted.resid <- plot(fitted(models[[i]]),resid(models[[i]]),xlim=c(-0.5,0.5), ylim=c(-0.5,0.5))
  dev.off()
}
