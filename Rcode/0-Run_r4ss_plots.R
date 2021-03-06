### Run r4ss and notes for making model comparison plots and editing plots
### Originally developed for the 2015 China Rockfish assessment document, 
### which had three independent assessment models (South of 40-10, 
### 40-10 through OR, and WA). Written for up to 3 assessment models
### Even if you only have 1 assessment model, it will be called mod1 throughout
### 
### Section 1: run r4ss and create plots
###
### Section 2: has the code for multiple model plot comparisons 
### Edit Section 2 script based on your needs
### Don't source this code, unless you've made all necessary edits
###
### Section 3: save the entire myreplist and mod_structure files from r4ss as csv's
# =============================================================================

stop("\n  This file should not be sourced!") # note to stop from accidental sourcing

# start fresh here - this script is separate from the script for the assessment
# document
rm(list=ls(all=TRUE))

# define directory on a specific computer
if (system("hostname", intern=TRUE) %in% c("NWCLW04223033") ){ #Ian's computer
  setwd("C:/SS/Yellowtail/Yellowtail2017/YTRK_doc")
}

# SECTION1: Run r4ss, parse plotInfoTable.csv file, & add linebreaks to SS files

# Here we're going to make sure you have all the required packages for the template
# Check for installtion and make sure all R libraries can be loaded
# xtable for creating tables, ggplot2 for plotting, reshape2 for melting
# dataframes, scales for printing percents
# You may have to manually install knitr - reason unknown!

requiredPackages = c('xtable', 'ggplot2', 'reshape2', 'scales', 
                     'rmarkdown', 'knitr', 'devtools')

for(p in requiredPackages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

# Install the latest version of r4ss using devtools
devtools::install_github("r4ss/r4ss")
library(r4ss)

# CHANGE values in this section ===============================================

# number of assessment models - this is run before the R_preamble.R, which also
# contains this value
 n_models = 2
 

# By default, you can only work in the directory containing the project
# Set the directory here if you're getting errors
# setwd('C:/Assessment_template')


# =============================================================================

# set input and output directories
input.dir = file.path(getwd(), 'SS')
output.dir = file.path(getwd(), 'r4ss')

# IF the r4SS subdirectories don't exist, create them
# Once you have your own SS files and want to save these plots
# Uncomment the /r4SS/ in the .gitignore file
dir.create(file.path(output.dir,'plots_mod1'))
dir.create(file.path(output.dir,'plots_mod2'))


# BEGIN r4ss===================================================================
# REMOVE OLD r4SS OUTPUT!!!!! -------------------------------------------------
# Run this deliberately - it deletes the r4SS output plots files
do.call(file.remove, list(list.files(file.path(output.dir, 'plots_mod1'),    full.names=TRUE)))
do.call(file.remove, list(list.files(file.path(output.dir, 'plots_mod2'),    full.names=TRUE)))
do.call(file.remove, list(list.files(file.path(output.dir, 'plots_compare'), full.names=TRUE)))

# Run r4ss for each model - **CHANGE DIRECTORY if necessary**
               mod1 = SS_output(dir = file.path(input.dir,'Base_model1'), forecast=T, covar=T, ncol=1000)
if(n_models>1){mod2 = SS_output(dir = file.path(input.dir,'Base_model2'), forecast=T, covar=T, ncol=1000)}

# Save the workspace an image
save.image('./r4ss/SS_output.RData')



# =============================================================================
# RUN r4ss plots for each model

# output directories
out.dir.mod1 = file.path(output.dir,'plots_mod1')
out.dir.mod2 = file.path(output.dir,'plots_mod2')
out.dir.mod3 = file.path(output.dir,'plots_mod3')

# long fleetnames for potential use in r4ss plots
fleetnames1 <- c("Commercial Fishery",
                 "At-Sea Hake Fishery",
                 "Recreational OR+CA",
                 "Recreational WA",
                 "Triennial Survey",
                 "NWFSC Combo Survey")
fleetnames2 <- c("Recreational Fishery",
                 "Commercial Fishery",
                 "Rec. Onboard Survey Early",
                 "Rec. Onboard Survey Late",
                 "Hook & Line Survey",
                 "Pelagic Juvenile Survey",       
                 "Small Fish Study")
# vector of colors for each fleet of fleet_type==3 for Southern model
# required to avoid change in default colors
# caused by fleet 6 "Small Fish Study" looking like a catch fleet
fleetcols2 <- c(rich.colors.short(2),'yellow')

# Model 1
SS_plots(mod1, fleetnames=fleetnames1,
         png = TRUE, html = FALSE, datplot = TRUE, uncertainty = TRUE,
         maxrows = 6, maxcols = 6, maxrows2 = 4, maxcols2 = 4, 
         printfolder = '', dir = out.dir.mod1,
         SSplotDatMargin=13) # avoid cropping fleet names in data presence/absence plot

# Model 2
SS_plots(mod2, fleetnames=fleetnames2,
         png = TRUE, html = FALSE, datplot = TRUE, uncertainty = TRUE,
         maxrows = 6, maxcols = 6, maxrows2 = 4, maxcols2 = 4, 
         printfolder = '', dir = out.dir.mod2,
         fleetcols=fleetcols2,
         SSplotDatMargin=13) # avoid cropping fleet names in data presence/absence plot

# simple function to write streamline writing PNG for specialized plots
pngfun <- function(file,mod=1,w=6.5,h=5,pt=10){
  if(mod > 0){
    out.dir <- get(paste0("out.dir.mod",mod))
  }else{
    out.dir <- dir.compare.plots
  }
  file <- file.path(out.dir, file)
  cat('writing PNG to',file,'\n')
  png(filename=file,
      width=w,height=h,
      units='in',res=300,pointsize=pt)
}

# multi-fleet comparisons with taller files NORTH
for(datonly in c(FALSE,TRUE)){
  for(kind in c("LEN","AGE")){
    SSplotComps(mod1, subplot=24, kind=kind, datonly=datonly, maxrows=4, pheight=7.5,
                cexZ1 = ifelse(datonly, 5, 1.5),
                plot=FALSE, print=TRUE, fleetnames=fleetnames1,
                plotdir=out.dir.mod1)
  }
}
# multi-fleet comparisons with taller files SOUTH
for(datonly in c(FALSE,TRUE)){
  for(kind in c("LEN","AGE")){
    SSplotComps(mod2, subplot=24, kind=kind, datonly=datonly, maxrows=5, pheight=ifelse(kind=="LEN",7.5,5),
                cexZ1 = ifelse(datonly, 5, 1.5),
                plot=FALSE, print=TRUE, fleetnames=fleetnames2,
                plotdir=out.dir.mod2)
  }
}

# plot showing discards for Northern model
pngfun('catch_with_discards.png', mod=1)
SSplotCatch(mod1, subplot=5, ymax=11000, fleetcols='lightblue', addmax=FALSE,
            showlegend=FALSE)
SSplotCatch(mod1, subplot=2, ymax=11000, add=TRUE, addmax=FALSE,
            showlegend=FALSE, labels=rep("",10))
legend('topleft', bty='n', legend=c('Commercial Fishery discards', fleetnames1[1:4]),
       fill=c('lightblue', rich.colors.short(5)[-1]))
dev.off()

pngfun('catch_with_discards_zoom.png', mod=1)
SSplotCatch(mod1, subplot=5, ymax=2000, fleetcols='lightblue', addmax=FALSE,
            showlegend=FALSE)
SSplotCatch(mod1, subplot=2, ymax=2000, add=TRUE, addmax=FALSE,
            showlegend=FALSE, labels=rep("",10))
axis(2)
abline(h=seq(0,2000,500), lty=3)
legend('topleft', bty='n', legend=c('Commercial Fishery discards', fleetnames1[1:4]),
       fill=c('lightblue', rich.colors.short(5)[-1]))
dev.off()


# Francis plot of mean length data for all fleets North
pngfun("comp_lendat_data_weighting_TA1.8_fleets1-3.png", mod=1)
par(mfrow=c(2,2), mar=c(2,2,1,1)+0.1, mgp=c(0,0.5,0), oma=c(1.2,1.2,0,0), las=1)
SSMethod.TA1.8(fit=mod1, type='len', fleet=1, part=2, datonly=TRUE,
               fleetnames=fleetnames1, set.pars=FALSE)
SSMethod.TA1.8(fit=mod1, type='len', fleet=1, part=1, pick.sex=0, datonly=TRUE,
               fleetnames=fleetnames1, set.pars=FALSE)
SSMethod.TA1.8(fit=mod1, type='len', fleet=2, datonly=TRUE, label.part=FALSE,
               fleetnames=fleetnames1, set.pars=FALSE)
SSMethod.TA1.8(fit=mod1, type='len', fleet=3, datonly=TRUE, label.part=FALSE,
               fleetnames=fleetnames1, set.pars=FALSE)
dev.off()
pngfun("comp_lendat_data_weighting_TA1.8_fleets1-4.png", mod=1)
par(mfrow=c(2,2), mar=c(2,2,1,1)+0.1, mgp=c(0,0.5,0), oma=c(1.2,1.2,0,0), las=1)
for(fleet in 4:6){
  SSMethod.TA1.8(fit=mod1, type='len', fleet=fleet, datonly=TRUE, label.part=FALSE,
                 fleetnames=fleetnames1, set.pars=FALSE)
}
dev.off()

# Francis plot of mean length data for all fleets South
pngfun("comp_lendat_data_weighting_TA1.8_all_fleets.png", mod=2)
SSMethod.TA1.8(fit=mod2, type='len', fleet=1:6, datonly=TRUE, fleetnames=fleetnames2)
dev.off()

# Francis plot of mean age data for all fleets South
pngfun("comp_condAALdat_bubflt2mkt2_page1B.png", mod=2)
dev.off()


# forecasts of relative spawning output
SSplotTimeseries(mod1, subplot=9, forecast=TRUE, print=TRUE, plot=FALSE,
                 plotdir=out.dir.mod1)
SSplotTimeseries(mod2, subplot=9, forecast=TRUE, print=TRUE, plot=FALSE,
                 plotdir=out.dir.mod2)

# time-varying retention for fleet 1 in model 1
pngfun('time-varying_retention.png', mod=1)
source('Rcode/time-varying_retention.R')
dev.off()

# fit to indices for model 1
pngfun('index0_all_indices.png', mod=1)
par(mfrow=c(2,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
SSplotIndices(mod1,subplot=1,datplot=TRUE) #,fleetnames=fleets)
mtext(side=1,line=1,outer=TRUE,'Year')
mtext(side=2,line=1,outer=TRUE,'Index')
dev.off()

pngfun('index0_all_indices_fit.png', mod=1)
par(mfrow=c(2,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
SSplotIndices(mod1,subplot=2,datplot=FALSE) #,fleetnames=fleets)
mtext(side=1,line=1,outer=TRUE,'Year')
mtext(side=2,line=1,outer=TRUE,'Index')
dev.off()


# fit to indices for model 2
pngfun('index0_all_indices.png', mod=2, h=6.5)
par(mfrow=c(3,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
SSplotIndices(mod2,subplot=1,datplot=TRUE, maximum_ymax_ratio=3) #,fleetnames=fleets)
mtext(side=1,line=1,outer=TRUE,'Year')
mtext(side=2,line=1,outer=TRUE,'Index')
dev.off()

pngfun('index0_all_indices_fit.png', mod=2, h=6.5)
par(mfrow=c(3,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
SSplotIndices(mod2,subplot=2,datplot=FALSE, maximum_ymax_ratio=3) #,fleetnames=fleets)
mtext(side=1,line=1,outer=TRUE,'Year')
mtext(side=2,line=1,outer=TRUE,'Index')
dev.off()
# -----------------------------------------------------------------------------

# Run the code to parse the plotInfoTable files
source('./Rcode/Parse_r4ss_plotInfoTable.R')

# -----------------------------------------------------------------------------

# Create the SS files for the appendices
source('./Rcode/SS_files_linebreaks.R')

# =============================================================================
# END SECTION 1================================================================
# =============================================================================
# =============================================================================



# SECTION 2: COMPARISON PLOTS ACROSS MODELS ===================================
# IT it not recommended to blindly run this section.  You'll need to change names,
# possibly margins, etc!!!


if(n_models > 1){

 # if you need to reload the workspace
 load("./r4ss/SS_output.RData")
  
 # create base model summary list
 out.mod1 = mod1
 out.mod2 = mod2
if(n_models==3) {out.mod3 = mod3}
     
 
# base.summary <-  SSsummarize(list(out.mod1, out.mod2))
 
 
 base.summary <-  if (n_models==2) {SSsummarize(list(out.mod1, out.mod2))} else
                   {SSsummarize(list(out.mod1, out.mod2 , out.mod3))}
    
 # save results to this comparison directory  
 dir.create(file.path(output.dir,'plots_compare'))
 dir.compare.plots <- file.path(getwd(),'/r4ss/plots_compare') 
    
 # vector of names and colors models as defined
 mod.names <- c("Northern","Southern")
 mod.cols  <- c("blue", "red")
} # end n_models if




# Time series comparison plots for exec summary -------------------------------
# These plots are repeated with regular plots
SSplotComparisons(base.summary, 
                  plot = FALSE, 
                  print = TRUE, 
                  plotdir = dir.compare.plots,
                  spacepoints = 20,  # years between points on each line
                  initpoint = 0,     # "first" year of points (modular arithmetic)
                  staggerpoints = 0, # points aligned across models
                  endyrvec = 2017,   # final year to show in time series
                  legendlabels = mod.names, 
                  filenameprefix = "base_", 
                  col = mod.cols)

# extra function for other stuff in timeseries (Bio_smry or Bio_all)
compare_timeseries <- function(mod1, mod2, column="Bio_smry", forecast=FALSE,
                               legendlabels=c("Northern","Southern"),
                               cols=c("blue", "red"), end=2017,
                               ylab="Age 4+ biomass (x 1000 mt)", scale=1e-3){
  yrs <- mod1$timeseries$Yr
  show <- yrs <= mod1$endyr+1
  y1 <- scale*mod1$timeseries[[column]][show]
  y2 <- scale*mod2$timeseries[[column]][show]
  yrs <- yrs[show]
  plot(0, xlim=range(yrs), ylim=c(0, 1.05*max(y1,y2)),
       xlab="Year", ylab=ylab, type='n', las=1)
  lines(yrs, y1, lwd=3, col=cols[1])
  lines(yrs, y2, lwd=3, col=cols[2])
  legend('topright', legendlabels, lwd=3, col=cols, bty='n')
  abline(h=0, col='grey')
}
# compare summary and total biomass
pngfun('base_compare_Summary_bio.png', mod=0)
compare_timeseries(mod1, mod2)
dev.off()
pngfun('base_compare_Total_bio.png', mod=0)
compare_timeseries(mod1, mod2, column="Bio_all")
dev.off()

## # repeat comparison for recruitment with adjusted y-limit
## # to crop the really big uncertainty intervals
## SSplotComparisons(base.summary,
##                   subplot = 8, ylimAdj=1.0, # recruitment only, adjusted ylim
##                   plot = FALSE, 
##                   print = TRUE, 
##                   plotdir = dir.compare.plots,
##                   spacepoints = 20,  # years between points on each line
##                   initpoint = 0,     # "first" year of points (modular arithmetic)
##                   staggerpoints = 0, # points aligned across models
##                   endyrvec = 2017,   # final year to show in time series
##                   legendlabels = mod.names, 
##                   filenameprefix = "base_", 
##                   col = mod.cols)


SSplotComparisons(base.summary, 
                  plot = FALSE, 
                  print = TRUE, 
                  plotdir = dir.compare.plots,
                  subplot = 1:10,
                  spacepoints = 20,  # years between points on each line
                  initpoint = 0,     # "first" year of points (modular arithmetic)
                  staggerpoints = 0, # points aligned across models
                  endyrvec = 2027,   # final year to show in time series
                  legendlabels = mod.names, 
                  filenameprefix = "forecast_", 
                  col = mod.cols)


  
  
# Plot comparison of growth curves --------------------------------------------
png(file.path(dir.compare.plots, 'growth_comparison.png'),
    width = 6.5, 
    height = 4, 
    res = 300, 
    units = 'in')

### make 2-panel plot to compare growth across models
par(mfrow=c(1,2), mar=c(0,0,0,1), oma=c(4,4,1,0), las=1)

# empty plot for 1st model with axis labels in outer margins
plot(0, type='n', xlim=c(0,40), ylim=c(0,65), xaxs='i', yaxs='i')
mtext(side=1, line=2.5, outer=TRUE, text="Age (yr)")
mtext(side=2, line=2.5, outer=TRUE, text="Length (cm)", las=0)
# add growth curves
SSplotBiology(mod1, subplot=1, add=TRUE, legendloc="bottomright")
# add legend, grid, and outer box
legend('topleft', title="Northern", legend=NA, bty="n", text.font=2)
grid()
box()

# empty plot for 2nd model
plot(0, type='n', xlim=c(0,40), ylim=c(0,65), axes=FALSE, xaxs='i', yaxs='i')
# add growth curves 
SSplotBiology(mod2, subplot=1, legendloc=NA, add=TRUE)
# add legend, grid, and outer box
legend('topleft', title="Southern", legend=NA, bty="n", text.font=2)
axis(1)
grid()
box()
# close PNG file
dev.off()


# Plot comparison of yield curves ---------------------------------------------
png(file.path(dir.compare.plots, 'yield_comparison_n_models.png'),
    width = 6.5, 
    height = 6.5, 
    res = 300, 
    units = 'in', 
    pointsize = 10)
par(las = 1)

SSplotYield(out.mod1, col = mod.cols[1], subplot = 1)
SSplotYield(out.mod2, col = mod.cols[2], subplot = 1, add = TRUE)
legend('topright', col=mod.cols, legend=mod.names, lwd=2, bty='n')
grid()
# close PNG file
dev.off()

# =============================================================================
# END SECTION 2================================================================
# =============================================================================

# =============================================================================
# Section 2B: extra plots for presentations (maybe also for post-STAR document)

# compare total catch across N & S models
pngfun("catch_comparison.png", mod=0)
par(mar=c(4,4,.1,.1))
plot(mod1$sprseries$Yr, mod1$sprseries$Dead_Catch_B,
     type='h', col=rgb(0,0,1,.7), lend=3, lwd=2,
     xlab='Year', ylab='Total catch (mt)', ylim=c(0, 11000), yaxs='i')
points(mod2$sprseries$Yr, mod2$sprseries$Dead_Catch_B,
       type='h', lend=3, lwd=3, col=rgb(1,0,0,.5))
legend('topleft', fill=mod.cols, legend=paste(mod.names, "area"), bty='n')
dev.off()


if(FALSE){
  # maturity, fecundity, growth
  pngfun("maturity_curves.png", mod=0)
  plot(0, xlim=c(20, 60), ylim=c(0, 1), xlab="Length (cm)", ylab="Maturity", las=1)
  abline(h=0, col='grey')
  par(lwd=3)
  SSplotBiology(mod1, subplot=6, colvec=4, add=TRUE)
  SSplotBiology(out.sens.GundersonMaturity.N, subplot=6, add=TRUE, colvec=2)
  SSplotBiology(out.sens.EcheverriaMaturity.N, subplot=6, add=TRUE, colvec=3)
  legend('topleft', col=c(4,3,2), lwd=3, bty='n',
         legend=c("Base model relationship using 2016 data",
             "Echeverria (1987)", "Gunderson et al. (1980)"))
  par(lwd=1)
  dev.off()

  # fecundity and spawning output
  pngfun("fecundity.png", mod=0)
  plot(0, xlim=c(20, 60), ylim=c(0, 0.002), xlab="Length (cm)", ylab="Eggs (millions)",
       axes=FALSE)
  abline(h=0, col='grey')
  par(lwd=3)
  ## SSplotBiology(out.sens.GundersonMaturity.N, subplot=10, add=TRUE, colvec=2,
  ##               labels=rep("", 14))
  ## SSplotBiology(out.sens.EcheverriaMaturity.N, subplot=10, add=TRUE, colvec=3,
  ##               labels=rep("", 14))
  SSplotBiology(mod1, subplot=9, colvec=1, add=TRUE, labels=rep("", 14))
  SSplotBiology(mod1, subplot=10, colvec=4, add=TRUE, labels=rep("", 14))
  par(lwd=1)
  axis(1)
  yvec <- seq(0,2,.5)
  axis(2, at=yvec/1000, label=yvec, las=1)
  legend('topleft', col=c(1,4), lwd=3, bty='n',
         legend=c("Fecundity (Dick, 2017)",
             "Fecundity x Maturity"))
  box()
  dev.off()

  # comparing 
  yrs <- mod1$catch$Yr[mod1$catch$Name=="RecWA"]
  bio <- mod1$catch$kill_bio[mod1$catch$Name=="RecWA"]
  num <- mod1$catch$kill_num[mod1$catch$Name=="RecWA"]
  plot(yrs, bio/num,
       xlim=range(yrs[num>0]),
       ylim=c(0, max(bio/num, na.rm=TRUE)))
}



# =============================================================================
# END SECTION 2B================================================================
# =============================================================================

if(FALSE){
# =============================================================================
# plots for old southern model in document sent out for review
# =============================================================================

mod2.old <- SS_output('c:/SS/Yellowtail/Yellowtail2017/Models/South/18_New_South_Base')
fleetnames2.old <- c("Recreational Fishery",
                 "Commercial Fishery",
                 "Recreational Onboard Survey",
                 "Hook & Line Survey",
                 "Recreational Study")
SS_plots(mod2.old, fleetnames=fleetnames2.old,
         png = TRUE, html = FALSE, datplot = TRUE, uncertainty = TRUE,
         maxrows = 6, maxcols = 6, maxrows2 = 4, maxcols2 = 4, 
         printfolder = '', dir = file.path(output.dir,'plots_mod2_old_model18'),
         SSplotDatMargin=13) # avoid cropping fleet names in data presence/absence plot

# North vs. old South
old.base.summary <- SSsummarize(list(out.mod1, mod2.old))
SSplotComparisons(old.base.summary, 
                  plot = FALSE, 
                  print = TRUE, 
                  plotdir = 'r4ss/plots_compare_North_vs_Old_South',
                  spacepoints = 20,  # years between points on each line
                  initpoint = 0,     # "first" year of points (modular arithmetic)
                  staggerpoints = 0, # points aligned across models
                  endyrvec = 2017,   # final year to show in time series
                  legendlabels = c("Northern","Southern (old)"), 
                  filenameprefix = "old_base_", 
                  col = mod.cols)

# compare summary biomass
png(file.path('r4ss/plots_compare_North_vs_Old_South',
              'old_base_compare_Summary_bio.png'),
    width = 6.5, height = 5, res = 300, units = 'in')
compare_timeseries(mod1, mod2.old, legendlabels=c("Northern","Southern (old)"))
dev.off()


# Old South vs. New South
new.vs.old.summary <- SSsummarize(list(mod2.old, out.mod2))
SSplotComparisons(new.vs.old.summary, 
                  plot = FALSE, 
                  print = TRUE, 
                  plotdir = 'r4ss/plots_compare_Old_South_vs_New_South',
                  spacepoints = 20,  # years between points on each line
                  initpoint = 0,     # "first" year of points (modular arithmetic)
                  staggerpoints = 0, # points aligned across models
                  endyrvec = 2017,   # final year to show in time series
                  legendlabels = c("Southern (old)", "Southern (new)"), 
                  filenameprefix = "old_vs_new_base_", 
                  col = mod.cols)

# compare summary biomass
png(file.path('r4ss/plots_compare_Old_South_vs_New_South',
              'old_base_compare_Summary_bio.png'),
    width = 6.5, height = 5, res = 300, units = 'in')
compare_timeseries(mod2.old, mod2, legendlabels=c("Southern (old)", "Southern (new)"))
dev.off()


} # end if(FALSE) to avoid accidental running this section
