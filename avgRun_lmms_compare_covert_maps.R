"x3 mixed LMs (IVs = which map+ age + gender + movement) to compare
thought maps along each gradient dimension of state space (1-5).
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

#read in csv file
df1 <- read.csv("deriv\\P1389_avgRun_gradSimMid_pcaWide_demo_acc.csv", na.strings=c(""," ","NA", "nan"))

######################### Data prep ############################################
# select pca contrasts only
df1 <- subset(df1, (cope %in% c('pca1_up', 'pca2_up', 'pca3_up')))

## Set fixed factors: Cope 
df1$cope <- factor(df1$cope, levels = c('pca1_up', 'pca2_up', 'pca3_up'),
                         ordered = FALSE) #set order to False.
#to check it's worked, run this command and see print out.
levels(df1$cope)

# Gender as factor
df1$Gender <- as.factor(df1$Gender)
levels(df1$Gender)

# SubjectID (participant) as factor
df1$SubjectID <- as.factor(df1$SubjectID)

##################### Setting up for linear mixed models #######################
# set contrasts to contr.sum

options(contrasts = c("contr.sum","contr.poly"))
options("contrasts")

########################## Saving results ######################################
# set file name for lmer text output
fp = "LMM_avgRun_thoughtMaps.txt"

# set current directory to results folder
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\lmm_thought_maps")

results_dir <- "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\lmm_thought_maps"

############################# Models ###########################################
# set up list of dependent variables
dv <- c("gradient1",
        "gradient2",
        "gradient3",
        'gradient4',
        'gradient5')

# set col index for creating bootstrap tables in loop below
col_index <- c(2,3,4)

# first run all 3 models without lmertest and use bootstrapping to calcualte
# parameter estimates
for(i in 1:length(dv)){
  model <- paste("model",i, sep="") # create model name
  
  # run model
  m <- lmer(as.formula(paste(dv[i],"~ cope + MeanMovement + Gender +  Age +
                             (1|SubjectID)")),
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
myfile2 <- file.path(results_dir,"LMM_avgRun_thoughtmaps_summary")
tab_model(model1,model2,model3,model4, model5, file = myfile2, df.method = "satterthwaite",
          p.val = "satterthwaite",show.df = FALSE,
          show.r2 = FALSE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)

# save summary tables for bootstrapped estimates
boot_list <- list(paramboot1, paramboot2, paramboot3, paramboot4, paramboot5)
myfile3 <- file.path(results_dir,"LMM_avgRun_thoughtmaps_bootstrap")
tab_dfs(boot_list, file = myfile3, show.rownames = FALSE)

##################### re-run models with lmertest ##############################
library(lmerTest) # for regular p-values for LMMs (f-tests)
# globally set lmertest.limit to 171 to calculate df
# also set to sattherthwaite
emm_options(lmerTest.limit = 171, lmer.df = "satterthwaite")

# run all 3 models using each DV from list using loop
for(i in 1:length(dv)){
  model <- paste("model",i, sep="") # create names of models
  summ <- paste("summary",i, sep = "") # create names of summaries
  an <- paste("anova",i, sep = "") #  create names of anovas
  emmean <- paste("emmean",i, sep = "") # create name of emmeans
  
  print (model)
  # run model
  m <- lmer(as.formula(paste(dv[i],"~ cope + MeanMovement + Gender +  Age +
                             (1|SubjectID)")),
            data=df1) 
  
  s <- summary(m) # create summary
  a <- anova(m) # create anova
  e <- emmeans(m, ~ cope, type = "response")
  
  
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
anova_list <- list(anova1, anova2, anova3, anova4, anova5)
myfile3 <- file.path(results_dir,"LMM_avgRun_thought_maps_anovaAll")
tab_dfs(anova_list, file = myfile3,show.rownames = TRUE)

######################## Probe main effect of 'cope' ###########################
# create new txt file for post hoc comparisons
fp2 <- "LMM_avgRun_thoughtmaps_posthoc.txt"

# compare copes along each gradient (target + non-target maps)
cope1.contrasts <- pairs(emmean1, adjust = "bonferroni", infer = TRUE)
cope1.contrasts
emmean1
cope2.contrasts <- pairs(emmean2, adjust = "bonferroni", infer = TRUE)
cope2.contrasts
emmean2
cope3.contrasts <- pairs(emmean3, adjust = "bonferroni", infer = TRUE)
cope3.contrasts
emmean3

# save to txt file
cat("Comparing maps along gradient 1:\n", file = fp2, append = TRUE)
capture.output(cope1.contrasts,file = fp2, append = TRUE)
cat("\n\n\n", file = fp2, append = TRUE)

cat("Comparing maps along gradient 2:\n", file = fp2, append = TRUE)
capture.output(cope2.contrasts,file = fp2, append = TRUE)
cat("\n\n\n", file = fp2, append = TRUE)

cat("Comparing maps along gradient 3:\n", file = fp2, append = TRUE)
capture.output(cope3.contrasts,file = fp2, append = TRUE)
cat("\n\n\n", file = fp2, append = TRUE)

########################## Bar charts ##########################################
# set up list with names of emmeans (predicted means)
list <- c("emmean1", "emmean2","emmean3", "emmean4", "emmean5")
# titles <- c("Dimension 1", "Dimension 2","Dimension 3", 'Dimension 4', 'Dimension 5')

fontsize = 6

# function for making plots
myplot <- function(data){
  # x axis = cope, y axis = emmean, bars = gradient
  ggplot(summary(data), aes(x = cope, y = emmean)) +
    theme_light() +
    geom_bar(stat="identity",width = 1.5/.pt, position="dodge",color = "black" ,size = 0.5/.pt) +
    ylim(-.1, .1)+
    theme(axis.text.y = element_text(size = fontsize,color = "black"),
          axis.text.x=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y = element_blank(),
          axis.ticks.x = element_blank(),
          plot.margin = margin(0, 0, 0, 0, "cm"))+
    # add error bars
    geom_errorbar(position=position_dodge(.6/.pt),width=0.25/.pt,size = 0.5/.pt, 
                  aes(ymax=upper.CL, ymin=lower.CL),alpha=1)+
    scale_y_continuous(
      breaks = c(-0.1,0,0.1),
      label = c("-.1", "0", ".1"),
      limits = c(-.1,.1))
}

# call function for list of emmeans set above and store each one (bar1, bar2 etc)
for(i in seq_along(list)){
  bar <- paste("bar",i, sep="")
  b <- myplot(get(list[i]))
  assign(bar, b)
}

bar3

# save gradient 3 on it's own
ggsave(
  "LMM_avgRun_compare_thought_maps_grad3.tiff",
  bar3, units = "cm",
  width = 5,
  height = 3,
  dpi = 1000, 
)

ggsave(
  "LMM_avgRun_compare_thought_maps_grad3.png",
  bar3, units = "cm",
  width = 5,
  height = 3,
  dpi = 1000, 
)
############################# Assumptions ######################################
models = c(model1, model2, model3, model4, model5)
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
