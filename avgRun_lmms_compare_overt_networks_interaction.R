"x1 mixed LMs (IVs = which map + which network +age + gender + movement)
to compare networks between overt task states.
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
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\data\\deriv")

#read in csv file
df1 <- read.csv("P1389_avgRun_networkLong_pcaWide_demo_acc.csv", na.strings=c(""," ","NA", "nan"))

######################### Data prep ############################################

# select overt states only
df1 <- subset(df1, (cope %in% c('target_up', 'non_target_up')))

## Set fixed factors: task_id 
df1$task_id <- factor(df1$task_id, levels = c("nontarget",
                                        "target"),
                         ordered = FALSE) #set order to False.
#to check it's worked, run this command and see print out.
levels(df1$task_id)

# network as factor
df1$yeo_network <- factor(df1$yeo_network,levels = c("Visuospatial", "Somatomotor",
                                                     "Dorsal Attention",
                                                     "Ventral Attention",
                                                     "Limbic",
                                                     "Frontoparietal",
                                                     "Default Mode"),
                          ordered = FALSE) #set order to False.
#to check it's worked, run this command and see print out.
levels(df1$yeo_network)

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
fp = "LMM_avgRun_allMaps_networks.txt"

# set current directory to results folder
setwd("C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\networks\\target_nontarget")

results_dir <- "C:\\Users\\bront\\Documents\\CanadaPostdoc\\GradientSpace\\results\\scientificreports\\1st_revision\\networks\\target_nontarget"

############################# Models ###########################################
# set up list of dependent variables (only 1)
dv <- c("mean_value")

# set col index for creating bootstrap tables in loop below
col_index <- c(2,3,4)

# first run all 3 models without lmertest and use bootstrapping to calcualte
# parameter estimates
for(i in 1:length(dv)){
  model <- paste("model",i, sep="") # create model name
  
  # run model
  m <- lmer(as.formula(paste(dv[i],"~ task_id + yeo_network + Gender +  Age + MeanMovement +
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
# combine parameter estimates into one table
# done before using lmertest to prevent conflict with satterthwaite
myfile2 <- file.path(results_dir,"LMM_avgRun_overt_network_interaction_summary")
tab_model(model1, file = myfile2, df.method = "satterthwaite",
          p.val = "satterthwaite",show.df = FALSE,
          show.r2 = FALSE,
          show.stat = TRUE, show.icc = FALSE,
          show.re.var = TRUE)

# save summary tables for bootstrapped estimates
boot_list <- list(paramboot1)
myfile3 <- file.path(results_dir,"LMM_avgRun_overt_network_interaction_bootstrap")
tab_dfs(boot_list, file = myfile3, show.rownames = FALSE)

##################### re-run models with lmertest ##############################
library(lmerTest) # for regular p-values for LMMs (f-tests)
# globally set lmertest.limit to 2000 to calculate df
# also set to sattherthwaite
emm_options(lmerTest.limit = 2000, lmer.df = "satterthwaite")

# run all 3 models using each DV from list using loop
for(i in 1:length(dv)){
  model <- paste("model",i, sep="") # create names of models
  summ <- paste("summary",i, sep = "") # create names of summaries
  an <- paste("anova",i, sep = "") #  create names of anovas
  emmean <- paste("emmean",i, sep = "") # create name of emmeans
  
  # run model
  m <- lmer(as.formula(paste(dv[i],"~ task_id * yeo_network +  MeanMovement +
                                      Gender +  Age +
                             (1|SubjectID)")),
            data=df1) 
  
  s <- summary(m) # create summary
  a <- anova(m) # create anova
  e <- emmeans(m, ~ task_id, type = "response")
  
  
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
# save anova table
anova_list <- list(anova1)
myfile3 <- file.path(results_dir,"LMM_avgRun_overtmaps_network_interaction")
tab_dfs(anova_list, file = myfile3,show.rownames = TRUE)

######################## Probe main effect of 'task_id' ########################

# for quick plot
cat_plot(model1, pred = task_id, modx = yeo_network)

# emmeans of each network for each state
emmeans_output <- emmeans(model1, specs = ~ task_id | yeo_network, type = "response")
emmeans_df <- as.data.frame(emmeans_output) # for saving to csv below
# save as csv
write.csv(emmeans_df, file = "emmeans_output.csv", row.names = FALSE)

# contrasts
emm1= emmeans(model1, specs = pairwise ~ task_id|yeo_network, type = "response")
emm1.contrasts <- emm1$contrasts %>%
  rbind()%>% summary(infer = TRUE)
contrasts_df <- as.data.frame(emm1.contrasts) # for saving to csv below
# save as csv
write.csv(contrasts_df, file = "contrasts_output.csv", row.names = FALSE)

############################# Assumptions ######################################
models = c(model1)
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
