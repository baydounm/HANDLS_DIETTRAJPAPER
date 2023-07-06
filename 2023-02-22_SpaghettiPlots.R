############
# Filename:   2023-02-22_SpaghettiPlots.R
# Author:     Nicolle Mode
# Purpose:    create plots over time
#
# Notes:
#
# Revisions:
#
###########

# data from May Baydoun

require(dplyr)
w00Dem<-HNDload()

load('/Users/zRoot/prj/hnd/git/dataMgr/Projects/2022-06-20-NutritionFrailtyLatentClass/dat/finaldata_unimputed_FINAL10per_Feb24.rdata')
diet10<-filter(finaldata_unimputed_FINAL, sample_final==1 & selected==1) #selected already used
diet10$HNDid<-diet10$HNDID

#spagplot DIETHEI timew1w3w4 if R_traj_Group_DIETHEIrec==1 & sample_final==1, 
#  id(HNDID) scheme(sj) nofit
# scheme=theme in STATA
  #bottom,left,top,right

##
# HEI
##

par(mfrow=c(2,2), mar=c(4, 4, 3, 1) + 0.1)
linew<-0.6; linecol<-'grey33'
## Group 1
hei1<-filter(diet10, R_traj_Group_DIETHEIrec==1)
ids1<-unique(hei1$HNDid)
with(hei1, plot(timew1w3w4, DIETHEI, xlim=c(0,12), ylim=c(0,100),cex.axis=0.75,
               type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='HEI score', cex.lab = 1, line=2)
title(main="Group 1", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(hei1[hei1$HNDid==ids1[i],], lines(timew1w3w4, DIETHEI, xlim=c(0,12), col=linecol,
                    ylim=c(0,100), lwd=linew, yaxt="n", xaxt="n"))
}
## Group 2
hei2<-filter(diet10, R_traj_Group_DIETHEIrec==2)
ids2<-unique(hei2$HNDid)
with(hei2, plot(timew1w3w4, DIETHEI, xlim=c(0,12), ylim=c(0,100),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='HEI score', cex.lab = 1, line=2)
title(main="Group 2", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(hei2[hei2$HNDid==ids2[i],], lines(timew1w3w4, DIETHEI, xlim=c(0,12), lwd=linew,
                                         col=linecol,ylim=c(0,100),  yaxt="n", xaxt="n"))
}
## Group 3
hei3<-filter(diet10, R_traj_Group_DIETHEIrec==3)
ids3<-unique(hei3$HNDid)
with(hei3, plot(timew1w3w4, DIETHEI, xlim=c(0,12), ylim=c(0,100),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='HEI score', cex.lab = 1, line=2)
title(main="Group 3", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(hei3[hei3$HNDid==ids3[i],], lines(timew1w3w4, DIETHEI, xlim=c(0,12), lwd=linew,
                                         col=linecol, ylim=c(0,100),  yaxt="n", xaxt="n"))
}


##
# MAR
##

par(mfrow=c(2,2), mar=c(4, 4, 3, 1) + 0.1)
linew<-0.6; linecol<-'grey33'
  ## Group 1
mar1<-filter(diet10, R_traj_Group_DIETMARrec==1)
ids1<-unique(mar1$HNDid)
with(mar1, plot(timew1w3w4, DIETMAR, xlim=c(0,12), ylim=c(0,100),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='MAR score', cex.lab = 1, line=2)
title(main="Group 1", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(mar1[mar1$HNDid==ids1[i],], lines(timew1w3w4, DIETMAR, xlim=c(0,12), col=linecol,
                                         ylim=c(0,100), lwd=linew, yaxt="n", xaxt="n"))
}
## Group 2
mar2<-filter(diet10, R_traj_Group_DIETMARrec==2)
ids2<-unique(mar2$HNDid)
with(mar2, plot(timew1w3w4, DIETMAR, xlim=c(0,12), ylim=c(0,100),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='MAR score', cex.lab = 1, line=2)
title(main="Group 2", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(mar2[mar2$HNDid==ids2[i],], lines(timew1w3w4, DIETMAR, xlim=c(0,12), lwd=linew,
                                         col=linecol,ylim=c(0,100),  yaxt="n", xaxt="n"))
}
## Group 3
mar3<-filter(diet10, R_traj_Group_DIETMARrec==3)
ids3<-unique(mar3$HNDid)
with(mar3, plot(timew1w3w4, DIETMAR, xlim=c(0,12), ylim=c(0,100),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='MAR score', cex.lab = 1, line=2)
title(main="Group 3", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(mar3[mar3$HNDid==ids3[i],], lines(timew1w3w4, DIETMAR, xlim=c(0,12), lwd=linew,
                                         col=linecol, ylim=c(0,100),  yaxt="n", xaxt="n"))
}

##
# DII
##

par(mfrow=c(2,2), mar=c(4, 4, 3, 1) + 0.1)
linew<-0.6; linecol<-'grey33'
  ## Group 1
dii1<-filter(diet10, R_traj_Group_DIETDIIrec==1)
ids1<-unique(dii1$HNDid)
with(dii1, plot(timew1w3w4, DIETDII, xlim=c(0,12), ylim=c(-5,8),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='DII score', cex.lab = 1, line=2)
title(main="Group 1", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(dii1[dii1$HNDid==ids1[i],], lines(timew1w3w4, DIETDII, xlim=c(0,12), col=linecol,
                                         ylim=c(-5,8), lwd=linew, yaxt="n", xaxt="n"))
}
## Group 2
dii2<-filter(diet10, R_traj_Group_DIETDIIrec==2)
ids2<-unique(dii2$HNDid)
with(dii2, plot(timew1w3w4, DIETDII, xlim=c(0,12), ylim=c(-5,8),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='DII score', cex.lab = 1, line=2)
title(main="Group 2", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(dii2[dii2$HNDid==ids2[i],], lines(timew1w3w4, DIETDII, xlim=c(0,12), lwd=linew,
                                         col=linecol,ylim=c(-5,8),  yaxt="n", xaxt="n"))
}
## Group 3
dii3<-filter(diet10, R_traj_Group_DIETDIIrec==3)
ids3<-unique(dii3$HNDid)
with(dii3, plot(timew1w3w4, DIETDII, xlim=c(0,12), ylim=c(-5,8),cex.axis=0.75,
                type="n",xlab="",ylab=""))
title(xlab="Years since enrollment",ylab='DII score', cex.lab = 1, line=2)
title(main="Group 3", cex.lab = 1, line=1)
for (i in 1:length(ids1)){
  with(dii3[dii3$HNDid==ids3[i],], lines(timew1w3w4, DIETDII, xlim=c(0,12), lwd=linew,
                                         col=linecol, ylim=c(-5,8),  yaxt="n", xaxt="n"))
}

