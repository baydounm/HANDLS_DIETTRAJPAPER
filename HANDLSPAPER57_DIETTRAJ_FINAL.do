cd "E:\HANDLS_PAPER57_FRAILTYDIET\DATA_PAPER1"

capture log close
log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DATA_MANAGEMENT.smcl",replace

********************************************DIET SCORES AND AGE AT WAVES 1, 3 AND 4******************

***STEP 1: CREATE WIDE AGE DATASET FOR WAVES 1, 3 AND 4*******

**Agew1**

use 2022-06-21, clear
capture rename HNDid HNDID
save,replace

keep if HNDwave==1
keep HNDID Age
capture rename Age w1Age
save Agew1, replace
sort HNDID
save, replace


**Agew3**

use 2022-06-21, clear
capture rename HNDid HNDID
save,replace

keep if HNDwave==3
keep HNDID Age
capture rename Age w3Age
save Agew3, replace
sort HNDID
save , replace



**Agew4**

use 2022-06-21, clear
capture rename HNDid HNDID
save,replace

keep if HNDwave==4
keep HNDID Age
capture rename Age w4Age
save Agew4, replace
sort HNDID
save , replace

**Agew1w3w4**

use Agew1,clear
merge HNDID using Agew3
capture drop _merge
sort HNDID
merge HNDID using Agew4
capture drop _merge
sort HNDID
save Agew1w3w4, replace




***STEP 2: CREATE WIDE DIET DATASET FOR WAVES 1, 3 AND 4*******



**DATAw1**

use 2022-06-21, clear
capture rename HNDid HNDID
save HANDLS_PAPER57_DIETTRAJ, replace


capture rename DIIavg DIETDII 
capture rename hei2010_total_score DIETHEI
capture rename MeanAdequacyRatio DIETMAR
save,replace

keep if HNDwave==1
keep HNDID HNDwave Race-Age LiveAlone-allostatic_load
addstub Race-Age LiveAlone-allostatic_load, stub(w1)
save DATAw1, replace
sort HNDID
save, replace


**DATAw3**

use HANDLS_PAPER57_DIETTRAJ, clear
capture rename HNDid HNDID
save,replace

keep if HNDwave==3
keep HNDID HNDwave Age-Houston LiveAlone-allostatic_load
addstub Age-Houston LiveAlone-allostatic_load, stub(w3)
save DATAw3, replace
sort HNDID
save, replace



**DATAw4**
use HANDLS_PAPER57_DIETTRAJ, clear
capture rename HNDid HNDID
save,replace
keep if HNDwave==4
keep HNDID HNDwave Age BPAQwork1-sportvig LiveAlone-allostatic_load
addstub Age BPAQwork1-sportvig LiveAlone-allostatic_loa, stub(w4)
save DATAw4, replace
sort HNDID
save, replace

**DATAw1w3w4**
use DATAw1,clear
merge HNDID using DATAw3
capture drop _merge
sort HNDID
merge HNDID using DATAw4
capture drop _merge
sort HNDID
save DATAw1w3w4, replace



***********STEP 3: MERGE WIDE AGE WITH WIDE DIET****************

use DATAw1w3w4,clear
sort HNDID
capture drop _merge
save, replace


use Agew1w3w4,clear
sort HNDID
capture drop _merge
save, replace

use DATAw1w3w4,clear
merge HNDID using  Agew1w3w4
tab _merge
capture drop _merge
sort HNDID
save DATAAGEw1w3w4wide, replace


********STEP 4: CREATE LONGITUDINAL DATA FOR DIET WITH AGE AT WAVES 1, 3 AND 4*****

use HANDLS_PAPER57_DIETTRAJ, clear


save DATAw1w3w4long, replace


*****STEP 5: MERGE WIDE WITH LONG DATA FOR DIET SCORES and AGE*************************


use DATAw1w3w4long,clear
capture drop _merge
sort HNDID
save, replace


use DATAAGEw1w3w4wide, clear
capture drop _merge
sort HNDID
save, replace

use DATAw1w3w4long,clear
merge HNDID using DATAAGEw1w3w4wide
tab _merge
capture drop _merge
sort HNDID

save HANDLS_PAPER57_DIETTRAJ, replace

***********************************************GENERATE FINAL SAMPLE FOR LONGITUDINAL DATA**************************************************************


capture drop sample_final_long
gen sample_final_long=1 if (DIETHEI~=. & HNDwave==1 | DIETHEI~=. & HNDwave==3 | DIETHEI~=. & HNDwave==4) 
replace sample_final_long=0 if sample_final_long~=1

tab sample_final_long


capture drop sample_final_wideDIET
gen sample_final_wideDIET=1 if (w1DIETHEI~=. |  w3DIETHEI~=. | w4DIETHEI~=.)
replace sample_final_wideDIET=0 if sample_final_wideDIET~=1

capture drop sample_final_wideFINAL
gen sample_final_wideFINAL=1 if sample_final_wideDIET==1 
replace sample_final_wideFINAL=0 if sample_final_wideFINAL~=1

tab sample_final_wideFINAL if HNDwave==1

save, replace


collapse (sum) sample_final_long  (mean) sample_final_wideFINAL, by(HNDID)

capture rename sample_final_long sample_final_long_coll
capture rename sample_final_wideFINAL sample_final_wide_coll

save DATAcollapsed, replace
sort HNDID
capture drop _merge
save, replace


use HANDLS_PAPER57_DIETTRAJ,clear
sort HNDID
capture drop _merge
save, replace

merge HNDID using DATAcollapsed
tab _merge
sort HNDwave HNDID
save, replace

capture drop sample_final
gen sample_final=sample_final_wideFINAL

save,replace

************************************STEPS 7 THROUGH 11: MIXED MODELS**************************************************************

use HANDLS_PAPER57_DIETTRAJ,clear

capture drop timew1w3w4
gen timew1w3w4=.
replace timew1w3w4=0 if HNDwave==1
replace timew1w3w4=(w3Age-w1Age) if HNDwave==3
replace timew1w3w4=(w4Age-w1Age) if HNDwave==4


capture drop timew1w3w4sq
gen timew1w3w4sq=timew1w3w4*timew1w3w4

capture drop timew1w3w4cb
gen timew1w3w4cb=timew1w3w4*timew1w3w4*timew1w3w4

su timew1w3w4 if HNDwave==3
su timew1w3w4 if HNDwave==4

save, replace

 
*******STEP 7 : RUN MIXED EFFECTS REGRESSION MODELS ON DIET SCORES AND OBTAIN EMPIRICAL BAYES ESTIMATORS FOR INTERCEPT AND SLOPE***************************


**DIETHEI TOTAL SCORE**

**Cubic model**
xtmixed DIETHEI c.timew1w3w4##c.timew1w3w4##c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4 
estat ic

**Quadratic model**
xtmixed DIETHEI c.timew1w3w4##c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4 
estat ic

**Linear model**
xtmixed DIETHEI c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Selected model: Linear**
xtmixed DIETHEI c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4


capture drop e_TIMEDIETHEI e_consDIETHEI
predict  e_TIMEDIETHEI e_consDIETHEI, reffects level(HNDID)


***bayes0: empirical bayes estimator of level-1 intercept**

capture drop bayes0DIETHEI
gen bayes0DIETHEI=        42.80021    + e_consDIETHEI

corr bayes0DIETHEI DIETHEI if HNDwave==1

save, replace

***bayes1: empirical bayes estimator of level-1 coefficient**

capture drop bayes1DIETHEI
gen bayes1DIETHEI=        .6613709    + e_TIMEDIETHEI


save, replace




*************************************DIETDII*******************************************
**Cubic model**
xtmixed DIETDII c.timew1w3w4##c.timew1w3w4##c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Quadratic model**
xtmixed DIETDII c.timew1w3w4##c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Linear model**
xtmixed DIETDII c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Selected model: Linear**
xtmixed DIETDII c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4


capture drop e_TIMEDIETDII e_consDIETDII
predict  e_TIMEDIETDII e_consDIETDII, reffects level(HNDID)


***bayes0: empirical bayes estimator of level-1 intercept**

capture drop bayes0DIETDII
gen bayes0DIETDII=          3.302904   + e_consDIETDII

corr bayes0DIETDII DIETDII if HNDwave==1

save, replace

***bayes1: empirical bayes estimator of level-1 coefficient**

capture drop bayes1DIETDII
gen bayes1DIETDII=       -.0801566    + e_TIMEDIETDII



save, replace


************************************ DIETMAR*******************************************
**Cubic model**
xtmixed DIETMAR c.timew1w3w4##c.timew1w3w4##c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Quadratic model**
xtmixed DIETMAR c.timew1w3w4##c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Linear model**
xtmixed DIETMAR c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4
estat ic

**Selected model:  linear**
xtmixed DIETMAR c.timew1w3w4 if sample_final==1 || HNDID: timew1w3w4


capture drop e_TIMEDIETMAR e_consDIETMAR
predict  e_TIMEDIETMAR e_consDIETMAR, reffects level(HNDID)


***bayes0: empirical bayes estimator of level-1 intercept**

capture drop bayes0DIETMAR
gen bayes0DIETMAR=       77.13529    + e_consDIETMAR

corr bayes0DIETMAR DIETMAR if HNDwave==1

save, replace

***bayes1: empirical bayes estimator of level-1 coefficient**

capture drop bayes1DIETMAR
gen bayes1DIETMAR=      -.0843195     + e_TIMEDIETMAR



save, replace




***************CHANGE SCHEME******

set scheme s2gcolor, permanently


*******STEP 8: RUN TRAJ AND TRAJPLOT COMMAND (GBTM) FOR DIET SCORES (WIDE FORMAT) BY AGE, CUBIC MODEL, FIND THE MODEL WITH SMALLEST BIC***************************

capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\TRAJDIET.smcl",replace


***************DIETHEI TOTAL SCORE***************

use HANDLS_PAPER57_DIETTRAJ,clear

keep if HNDwave==1
save HANDLS_PAPER57_DIETTRAJ_wide, replace

tab sample_final
tab sample_final if HNDwave==1


su w1Age if sample_final==1 & HNDwave==1
su w3Age if sample_final==1 & HNDwave==1
su w4Age if sample_final==1 & HNDwave==1


su w1DIETHEI if sample_final==1 & HNDwave==1
su w3DIETHEI if sample_final==1 & HNDwave==1
su w4DIETHEI if sample_final==1 & HNDwave==1



**w1w3w4DIETHEI_TRAJ**
**Cubic**
traj if sample_final==1, var(w1DIETHEI w3DIETHEI w4DIETHEI) indep(w1Age w3Age w4Age) model(cnorm) min(0) max(100) order(3 3 3) sigmabygroup detail
trajplot, xtitle(Age (years)) ytitle(HEI) ci


**Quadratic
traj if sample_final==1, var(w1DIETHEI w3DIETHEI w4DIETHEI) indep(w1Age w3Age w4Age) model(cnorm) min(0) max(100) order(2 2 2) sigmabygroup detail
trajplot, xtitle(Age (years)) ytitle(HEI) ci



**Linear**
traj if sample_final==1, var(w1DIETHEI w3DIETHEI w4DIETHEI) indep(w1Age w3Age w4Age) model(cnorm) min(0) max(100) order(1 1 1) sigmabygroup detail
trajplot, xtitle(Age (years)) ytitle(HEI) ci

graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEI_TOTAL_FINAL.gph",replace

capture rename _traj_Group R_traj_Group_DIETHEI 
capture rename _traj_ProbG1 R_traj_ProbG1_DIETHEI 
capture rename _traj_ProbG2  R_traj_ProbG2_DIETHEI
capture rename _traj_ProbG3  R_traj_ProbG3_DIETHEI

save, replace

corr R_traj_ProbG1_DIETHEI w1DIETHEI w3DIETHEI w4DIETHEI if sample_final==1
corr R_traj_ProbG2_DIETHEI w1DIETHEI w3DIETHEI w4DIETHEI if sample_final==1

bysort R_traj_Group_DIETHEI: su w1DIETHEI w3DIETHEI w4DIETHEI if (sample_final==1 & HNDwave==1)


save, replace




capture drop w1w3w4DIETHEI_TRAJ
gen w1w3w4DIETHEI_TRAJ=R_traj_ProbG2_DIETHEI

save, replace

keep HNDID R_traj* w1w3w4DIETHEI_TRAJ sample_final*

save DIETHEI_TRAJ, replace
sort HNDID
save, replace

use HANDLS_PAPER57_DIETTRAJ,clear
capture drop _merge
sort HNDID
save, replace

merge HNDID using DIETHEI_TRAJ
save, replace

*******************DIETDII************************

use HANDLS_PAPER57_DIETTRAJ,clear

keep if HNDwave==1
save HANDLS_PAPER57_DIETTRAJ_wide, replace

tab sample_final
tab sample_final if HNDwave==1


su w1Age if sample_final==1 & HNDwave==1
su w3Age if sample_final==1 & HNDwave==1
su w4Age if sample_final==1 & HNDwave==1


su w1DIETDII if sample_final==1 & HNDwave==1
su w3DIETDII if sample_final==1 & HNDwave==1
su w4DIETDII if sample_final==1 & HNDwave==1



**w1w3w4DIETDIID_TRAJ**

**Cubic**
traj if sample_final==1, var(w1DIETDII w3DIETDII w4DIETDII) indep(w1Age w3Age w4Age) model(cnorm) min(-10) max(10) order(3 3 3) sigmabygroup detail
trajplot, xtitle(Age (years)) ytitle(DII) ci


**Quadratic**
traj if sample_final==1, var(w1DIETDII w3DIETDII w4DIETDII) indep(w1Age w3Age w4Age) model(cnorm) min(-10) max(10) order(2 2 2) sigmabygroup detail
trajplot, xtitle(Age (years)) ytitle(DII) ci


**Linear**
traj if sample_final==1, var(w1DIETDII w3DIETDII w4DIETDII) indep(w1Age w3Age w4Age) model(cnorm) min(-10) max(10) order(1 1 1) sigmabygroup detail

trajplot, xtitle(Age (years)) ytitle(DII) ci

graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDII_FINAL.gph",replace

capture rename _traj_Group R_traj_Group_DIETDII
capture rename _traj_ProbG1 R_traj_ProbG1_DIETDII 
capture rename _traj_ProbG2  R_traj_ProbG2_DIETDII
capture rename _traj_ProbG3  R_traj_ProbG3_DIETDII

save, replace

corr R_traj_ProbG1_DIETDII w1DIETDII w3DIETDII w4DIETDII if sample_final==1
corr R_traj_ProbG2_DIETDII w1DIETDII w3DIETDII w4DIETDII if sample_final==1






bysort R_traj_Group_DIETDII: su w1DIETDII w3DIETDII w4DIETDII if (sample_final==1 & HNDwave==1)

capture drop w1w3w4DIETDII_TRAJ
gen w1w3w4DIETDII_TRAJ=R_traj_ProbG3_DIETDII

save, replace

keep HNDID R_traj* w1w3w4DIETDII_TRAJ sample_final*

save DIETDII_TRAJ, replace
sort HNDID
save, replace

use HANDLS_PAPER57_DIETTRAJ,clear
capture drop _merge
sort HNDID
save, replace

merge HNDID using DIETDII_TRAJ
save, replace






*****************DIETMAR**********************
use HANDLS_PAPER57_DIETTRAJ,clear

keep if HNDwave==1
save HANDLS_PAPER57_DIETTRAJ_wide, replace


tab sample_final
tab sample_final if HNDwave==1


su w1Age if sample_final==1 & HNDwave==1
su w3Age if sample_final==1 & HNDwave==1
su w4Age if sample_final==1 & HNDwave==1


su w1DIETMAR if sample_final==1 & HNDwave==1
su w3DIETMAR if sample_final==1 & HNDwave==1
su w4DIETMAR if sample_final==1 & HNDwave==1



**w1w34DIETMARD_TRAJ**
**Cubic**
traj if sample_final==1, var(w1DIETMAR w3DIETMAR w4DIETMAR) indep(w1Age w3Age w4Age) model(cnorm) min(0) max(100) order(3 3 3) sigmabygroup detail

trajplot, xtitle(Age (years)) ytitle(MAR) ci

**Quadratic**
traj if sample_final==1, var(w1DIETMAR w3DIETMAR w4DIETMAR) indep(w1Age w3Age w4Age) model(cnorm) min(0) max(100) order(2 2 2) sigmabygroup detail

trajplot, xtitle(Age (years)) ytitle(MAR) ci

**Linear**
traj if sample_final==1, var(w1DIETMAR w3DIETMAR w4DIETMAR) indep(w1Age w3Age w4Age) model(cnorm) min(0) max(100) order(1 1 1) sigmabygroup detail

trajplot, xtitle(Age (years)) ytitle(MAR) ci


graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMAR_FINAL.gph",replace

capture rename _traj_Group R_traj_Group_DIETMAR
capture rename _traj_ProbG1 R_traj_ProbG1_DIETMAR 
capture rename _traj_ProbG2  R_traj_ProbG2_DIETMAR
capture rename _traj_ProbG3  R_traj_ProbG3_DIETMAR

save, replace

corr R_traj_ProbG1_DIETMAR w1DIETMAR w3DIETMAR w4DIETMAR if sample_final==1
corr R_traj_ProbG2_DIETMAR w1DIETMAR w3DIETMAR w4DIETMAR if sample_final==1
corr R_traj_ProbG3_DIETMAR w1DIETMAR w3DIETMAR w4DIETMAR if sample_final==1

bysort R_traj_Group_DIETMAR: su w1DIETMAR w3DIETMAR w4DIETMAR if (sample_final==1 & HNDwave==1)

capture drop w1w3w4DIETMAR_TRAJ
gen w1w3w4DIETMAR_TRAJ=R_traj_ProbG1_DIETMAR

save, replace

keep HNDID R_traj* w1w3w4DIETMAR_TRAJ sample_final*

save DIET_TRAJMAR, replace
sort HNDID
save, replace

use HANDLS_PAPER57_DIETTRAJ,clear
capture drop _merge
sort HNDID
save, replace

merge HNDID using DIET_TRAJMAR
save, replace


label var w1DIETHEI "HEIv1"
label var w3DIETHEI "HEIv2"
label var w4DIETHEI "HEIv3"
label var w1w3w4DIETHEI_TRAJ "Prob low-quality HEI"

save, replace

set scheme s2gcolor, permanently


graph matrix w1w3w4DIETHEI_TRAJ w1DIETHEI w3DIETHEI w4DIETHEI if sample_final==1 & HNDwave==1, half msymbol(t) 
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEI_FINALIZED2.gph",replace


label var w1DIETDII "DIIv1"
label var w3DIETDII "DIIv2"
label var w4DIETDII "DIIv3"
label var w1w3w4DIETDII_TRAJ "Prob high-quality DII"

save, replace

set scheme s2gcolor, permanently


graph matrix w1w3w4DIETDII_TRAJ w1DIETDII w3DIETDII w4DIETDII if sample_final==1 & HNDwave==1, half msymbol(t)  
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDII_FINALIZED2.gph", replace


label var w1DIETMAR "MARv1"
label var w3DIETMAR "MARv2"
label var w4DIETMAR "MARv3"
label var w1w3w4DIETMAR_TRAJ "Prob low-quality MAR"

save, replace

set scheme s2gcolor, permanently


graph matrix w1w3w4DIETMAR_TRAJ w1DIETMAR w3DIETMAR w4DIETMAR if sample_final==1 & HNDwave==1, half msymbol(t) 
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMAR_FINALIZED2.gph",replace


set scheme s2gcolor, permanently


graph combine "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEI_TOTAL_FINAL.gph"  "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDII_FINAL.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMAR_FINAL.gph"  "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEI_FINALIZED2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDII_FINALIZED2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMAR_FINALIZED2.gph", scheme(s2gcolor)
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIET_TOTAL_FINALIZED.gph",replace



graph combine "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEI_FINALIZED2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDII_FINALIZED2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMAR_FINALIZED2.gph", scheme(s2gcolor)
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\FIGURE_GBTM_DIET_SCATTER.gph",replace

graph combine "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEI_TOTAL_FINAL.gph"  "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDII_FINAL.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMAR_FINAL.gph"  
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\FIGURE_GBTM_DIET_FINAL.gph",replace



graph use "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIET_TOTAL_FINALIZED.gph"
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\FIGURE1.gph", replace

capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\GBTM_EMPIRICALBAYES_OBSERVED.smcl",replace


*******STEP 9: OBTAIN MEAN AND SD OF INTERCEPT AND SLOPE FOR EACH GROUP FROM GBTM MODEL*****************************

use HANDLS_PAPER57_DIETTRAJ,clear
capture drop _merge
sort HNDID
save, replace

su bayes0DIET* bayes1DIET*  

collapse (mean) bayes0DIETHEI bayes1DIETHEI  bayes0DIETDII bayes1DIETDII bayes0DIETMAR bayes1DIETMAR , by(HNDID)

save DIETD_BAYES_collapse, replace
sort HNDID
save, replace

capture rename bayes0* w1w3w4bayes0*
capture rename bayes1* w1w3w4bayes1*

sort HNDID

save, replace


use HANDLS_PAPER57_DIETTRAJ,clear
merge HNDID using DIETD_BAYES_collapse
save, replace


bysort R_traj_Group_DIETHEI: su w1w3w4bayes0DIETHEI w1w3w4bayes1DIETHEI if sample_final==1 & HNDwave==1
bysort R_traj_Group_DIETDII: su w1w3w4bayes0DIETDII w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1
bysort R_traj_Group_DIETMAR: su w1w3w4bayes0DIETMAR w1w3w4bayes1DIETMAR  if sample_final==1 & HNDwave==1

save, replace


*********STEP 9B: RECODE THE TRAJ GROUP VARIABLES AND DII IN THE DIRECTION OF HIGHER SCORE, BETTER DIET QUALITY**********************************


****Note that these are recoded based on the Figure from low diet quality to high diet quality*********************

capture drop R_traj_Group_DIETHEIrec
gen R_traj_Group_DIETHEIrec=.
replace R_traj_Group_DIETHEIrec=1 if R_traj_Group_DIETHEI==2
replace R_traj_Group_DIETHEIrec=2 if R_traj_Group_DIETHEI==1
replace R_traj_Group_DIETHEIrec=3 if R_traj_Group_DIETHEI==3



capture drop R_traj_Group_DIETDIIrec
gen R_traj_Group_DIETDIIrec=.
replace R_traj_Group_DIETDIIrec=1 if R_traj_Group_DIETDII==2
replace R_traj_Group_DIETDIIrec=2 if R_traj_Group_DIETDII==1
replace R_traj_Group_DIETDIIrec=3 if R_traj_Group_DIETDII==3


capture drop R_traj_Group_DIETMARrec
gen R_traj_Group_DIETMARrec=.
replace R_traj_Group_DIETMARrec=1 if R_traj_Group_DIETMAR==1
replace R_traj_Group_DIETMARrec=2 if R_traj_Group_DIETMAR==3
replace R_traj_Group_DIETMARrec=3 if R_traj_Group_DIETMAR==2

capture drop DIETDIIrec
gen DIETDIIrec=DIETDII*-1

save, replace


capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\MIXEDMODELS.smcl",replace


********STEP 10: RUN MIXED EFFECTS REGRESSION MODELS FOR DIET SCORES BY AGE, SEX, RACE AND POVERTY STATUS. ADD SQUARE AND CUBIC TERMS AND COMPARE AIC/BIC****

use HANDLS_PAPER57_DIETTRAJ,clear


capture drop w1Agecenter
gen w1Agecenter=w1Age-50

mixed DIETHEI c.timew1w3w4##c.w1Agecenter c.timew1w3w4##Sex c.timew1w3w4##Race c.timew1w3w4##PovStat if sample_final==1 || HNDID: timew1w3w4, cov(un)
estat ic

mixed DIETDIIrec c.timew1w3w4##c.w1Agecenter c.timew1w3w4##Sex c.timew1w3w4##Race c.timew1w3w4##PovStat if sample_final==1 || HNDID: timew1w3w4, cov(un)
estat ic


mixed DIETMAR c.timew1w3w4##c.w1Agecenter c.timew1w3w4##Sex c.timew1w3w4##Race c.timew1w3w4##PovStat if sample_final==1 || HNDID: timew1w3w4, cov(un)
estat ic


save, replace



capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\MLOGIT_GBTM_SOCIODEMOGRAPHICS.smcl",replace

********STEP 11: COMPARE GBTM GROUPS BY AGE, SEX, RACE AND POVERTY STATUS USING MLOGIT MODELS************************************

use HANDLS_PAPER57_DIETTRAJ,clear


**HEI total score: **
capture drop R_traj_Group_DIETHEIrec_bin*
tab R_traj_Group_DIETHEIrec, gen(R_traj_Group_DIETHEIrec_bin)
bysort R_traj_Group_DIETHEIrec: su  w1DIETHEI w3DIETHEI w4DIETHEI if HNDwave==1 & sample_final==1
bysort R_traj_Group_DIETHEIrec: su  w1DIETHEI w3DIETHEI w4DIETHEI if HNDwave==1 & sample_final==1
bysort R_traj_Group_DIETHEIrec: su  w1DIETHEI w3DIETHEI w4DIETHEI if HNDwave==1 & sample_final==1


mlogit R_traj_Group_DIETHEI w1Age Sex Race PovStat if HNDwave==1 & sample_final==1, baseoutcome(1) rrr



**DII total score: **
capture drop R_traj_Group_DIETDIIrec_bin*
tab R_traj_Group_DIETDIIrec, gen(R_traj_Group_DIETDIIrec_bin)
bysort R_traj_Group_DIETDIIrec: su  w1DIETDII w3DIETDII w4DIETDII if HNDwave==1 & sample_final==1
bysort R_traj_Group_DIETDIIrec: su  w1DIETDII w3DIETDII w4DIETDII if HNDwave==1 & sample_final==1
bysort R_traj_Group_DIETDIIrec: su  w1DIETDII w3DIETDII w4DIETDII if HNDwave==1 & sample_final==1

mlogit R_traj_Group_DIETDIIrec w1Age Sex Race PovStat if HNDwave==1 & sample_final==1, baseoutcome(1) rrr



**MAR total score: **
capture drop R_traj_Group_DIETMARrec_bin*
tab R_traj_Group_DIETMARrec, gen(R_traj_Group_DIETMARrec_bin)
bysort R_traj_Group_DIETMARrec: su  w1DIETMAR w3DIETMAR w4DIETMAR if HNDwave==1 & sample_final==1
bysort R_traj_Group_DIETMARrec: su  w1DIETMAR w3DIETMAR w4DIETMAR if HNDwave==1 & sample_final==1
bysort R_traj_Group_DIETMARrec: su  w1DIETMAR w3DIETMAR w4DIETMAR if HNDwave==1 & sample_final==1


mlogit R_traj_Group_DIETMARrec w1Age Sex Race PovStat if HNDwave==1 & sample_final==1, baseoutcome(1) rrr


save, replace

capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\SAMPLESELECTIVITY.smcl",replace


********STEP 12: DETERMINE FINAL SAMPLE WITH DIET DATA*****************************************

use HANDLS_PAPER57_DIETTRAJ,clear


////SAMPLE 1: FULL HANDLS DATA AT BASELINE//////

capture drop sample1
gen sample1=1 if Age~=.
replace sample1=0 if sample1~=1

////SAMPLE 2: HANDLS SAMPLE WITH COMPLETE DIET SCORES AT EITHER WAVES 1, 3 OR 4/////
capture drop sample2
gen sample2=1 if sample1==1 & w1DIETHEI~=. | w3DIETHEI~=. | w4DIETHEI~=.
replace sample2=0 if sample2~=1

tab sample2 if HNDwave==1



capture drop sample_final
gen sample_final=sample2

tab sample_final if HNDwave==1

save HANDLS_PAPER57_DIETTRAJ, replace


****INVERSE MILLS RATIO****

xi:probit sample_final w1Age Race PovStat Sex

capture drop p1final
predict p1final, xb

capture drop phifinal
capture drop caphifinal
capture drop invmillsfinal

gen phifinal=(1/sqrt(2*_pi))*exp(-(p1final^2/2))

egen caphifinal=std(p1final)

capture drop invmillsfinal
gen invmillsfinal=phifinal/caphifinal


su invmillsfinal

save, replace



capture log close
log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\COVARIATES.smcl",replace

***************************************************STEP 14: GENERATE COVARIATES********************************************************
use HANDLS_PAPER57_DIETTRAJ,clear

**Education**

tab w1Education if HNDwave==1

capture drop w1edubr
gen w1edubr=.
replace w1edubr=1 if w1Education>=1 & w1Education<=8
replace w1edubr=2 if w1Education>=9 & w1Education<=12
replace w1edubr=3 if w1Education>=13 & w1Education~=.

tab w1edubr if HNDwave==1
tab w1edubr w1Education

**Live alone**

tab w1LiveAlone, miss


**Current smoking status**

tab  w1CigaretteStatus
su w1CigaretteStatus

capture drop w1smoke
gen w1smoke=.
replace w1smoke=1 if w1CigaretteStatus==4 
replace w1smoke=0 if w1CigaretteStatus~=4 & w1CigaretteStatus~=.
replace w1smoke=9 if w1smoke==.

tab1 w1smoke w1CigaretteStatus 

capture drop w1smoke1 w1smoke9
gen w1smoke1=1 if w1smoke==1
replace w1smoke1=0 if w1smoke~=1

gen w1smoke9=1 if w1smoke==9
replace w1smoke9=0 if w1smoke~=9

sort HNDID

save, replace


**Current drug use**

tab1 w1MarijStatus w1CokeStatus w1OpiateStatus

capture drop w1currdrugs
gen w1currdrugs=.
replace w1currdrugs=1 if w1MarijStatus==4 | w1CokeStatus==4 | w1OpiateStatus==4
replace w1currdrugs=0 if w1currdrugs~=1 & w1MarijStatus~=. & w1CokeStatus~=. & w1OpiateStatus~=.
replace w1currdrugs=9 if w1currdrugs==.

tab w1currdrugs

tab w1currdrugs w1MarijStatus
tab w1currdrugs w1CokeStatus
tab w1currdrugs w1OpiateStatus

save, replace


*****************w1allostatic load**************************


tab  w1allostatic if sample_final==1, miss




//STEP 15: MULTIPLE IMPUTATIONS FOR COVARIATES////////

use HANDLS_PAPER57_DIETTRAJ,clear

sort HNDwave HNDID


save finaldata_imputed,replace


capture set matsize 11000

capture mi set flong

capture mi xtset, clear

capture mi stset, clear

save, replace

su HNDwave w1w3w4bayes*  w1Age Sex Race PovStat w1edubr w1currdrugs w1smoke  w1allostatic if HNDwave==1


replace w1smoke=. if w1smoke==9
save, replace

replace w1currdrugs=. if w1currdrugs==9
save, replace


mi unregister HNDID HNDwave w1w3w4bayes*  w1Age Sex Race PovStat w1edubr w1currdrugs w1smoke w1allostatic 

mi register imputed  w1edubr w1currdrugs w1smoke w1allostatic  


mi register passive w1w3w4bayes*  


mi impute chained (ologit) w1edubr w1currdrugs w1smoke w1allostatic=w1Age Sex Race PovStat if w1Age~=., force augment noisily  add(5) rseed(1234) savetrace(tracefile, replace) 


save finaldata_imputed, replace

save finaldata_imputed_FINAL, replace

////STEP 16: SAMPLE SELECTIVITY//////////



mi estimate: logistic sample_final w1Age Sex PovStat Race if HNDwave==1 

mi estimate: logistic sample_final w1Age  if HNDwave==1
mi estimate: logistic sample_final Sex  if HNDwave==1
mi estimate: logistic sample_final PovStat  if HNDwave==1
mi estimate: logistic sample_final Race  if HNDwave==1

save finaldata_imputed_FINAL, replace


capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\TABLE1.smcl",replace


///////////////////////////////////////////////STEP 17: MAIN ANALYSIS//////////////////////////////////////////

use finaldata_imputed_FINAL,clear

///////////////////////TABLE 1: DESCRIPTIVES, OVERALL, BY SEX AND BY RACE/////////////////////////////////////////////

*********OVERALL********

mi estimate: prop Sex  if sample_final==1 & HNDwave==1
mi estimate: mean w1Age  if sample_final==1 & HNDwave==1
mi estimate: prop Race  if sample_final==1 & HNDwave==1
mi estimate: prop PovStat  if sample_final==1 & HNDwave==1
mi estimate: prop w1edubr  if sample_final==1 & HNDwave==1
mi estimate: prop w1currdrugs if sample_final==1 & HNDwave==1
mi estimate: prop w1smoke if sample_final==1 & HNDwave==1
mi estimate: mean w1allostatic_load if sample_final==1 & HNDwave==1

mi estimate: prop R_traj_Group_DIETHEIrec  if sample_final==1 & HNDwave==1
mi estimate: prop R_traj_Group_DIETDIIrec  if sample_final==1 & HNDwave==1
mi estimate: prop R_traj_Group_DIETMARrec  if sample_final==1 & HNDwave==1

mi estimate: mean w1w3w4bayes0DIETHEI  if sample_final==1 & HNDwave==1
mi estimate: mean w1w3w4bayes0DIETDII  if sample_final==1 & HNDwave==1
mi estimate: mean w1w3w4bayes0DIETMAR  if sample_final==1 & HNDwave==1

mi estimate: mean w1w3w4bayes1DIETHEI  if sample_final==1 & HNDwave==1
mi estimate: mean w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1
mi estimate: mean w1w3w4bayes0DIETMAR  if sample_final==1 & HNDwave==1




********************WOMEN***************

mi estimate: mean w1Age  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop Race  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop PovStat  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop w1edubr  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop w1currdrugs if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop w1smoke if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: mean w1allostatic_load if sample_final==1 & HNDwave==1 & Sex==1

mi estimate: prop R_traj_Group_DIETHEIrec  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop R_traj_Group_DIETDIIrec  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: prop R_traj_Group_DIETMARrec  if sample_final==1 & HNDwave==1 & Sex==1

mi estimate: mean w1w3w4bayes0DIETHEI  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: mean w1w3w4bayes0DIETDII  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: mean w1w3w4bayes0DIETMAR  if sample_final==1 & HNDwave==1 & Sex==1

mi estimate: mean w1w3w4bayes1DIETHEI  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: mean w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1 & Sex==1
mi estimate: mean w1w3w4bayes1DIETMAR  if sample_final==1 & HNDwave==1 & Sex==1


**********************MEN****************************


mi estimate: mean w1Age  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop Race  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop PovStat  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop w1edubr  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop w1currdrugs if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop w1smoke if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: mean w1allostatic_load if sample_final==1 & HNDwave==1 & Sex==2

mi estimate: prop R_traj_Group_DIETHEIrec  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop R_traj_Group_DIETDIIrec  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: prop R_traj_Group_DIETMARrec  if sample_final==1 & HNDwave==1 & Sex==2

mi estimate: mean w1w3w4bayes0DIETHEI  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: mean w1w3w4bayes0DIETDII  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: mean w1w3w4bayes0DIETMAR  if sample_final==1 & HNDwave==1 & Sex==2

mi estimate: mean w1w3w4bayes1DIETHEI  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: mean w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1 & Sex==2
mi estimate: mean w1w3w4bayes1DIETMAR  if sample_final==1 & HNDwave==1 & Sex==2



*******************WHITE*********************************

mi estimate: prop Sex  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: mean w1Age  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: prop PovStat  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: prop w1edubr  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: prop w1currdrugs if sample_final==1 & HNDwave==1 & Race==1
mi estimate: prop w1smoke if sample_final==1 & HNDwave==1 & Race==1
mi estimate: mean w1allostatic_load if sample_final==1 & HNDwave==1 & Race==1

mi estimate: prop R_traj_Group_DIETHEIrec  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: prop R_traj_Group_DIETDIIrec  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: prop R_traj_Group_DIETMARrec  if sample_final==1 & HNDwave==1 & Race==1

mi estimate: mean w1w3w4bayes0DIETHEI  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: mean w1w3w4bayes0DIETDII  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: mean w1w3w4bayes0DIETMAR  if sample_final==1 & HNDwave==1 & Race==1

mi estimate: mean w1w3w4bayes1DIETHEI  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: mean w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1 & Race==1
mi estimate: mean w1w3w4bayes1DIETMAR  if sample_final==1 & HNDwave==1 & Race==1


*****************AFRICAN AMERICAN****************************

mi estimate: prop Sex  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: mean w1Age  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: prop PovStat  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: prop w1edubr  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: prop w1currdrugs if sample_final==1 & HNDwave==1 & Race==2
mi estimate: prop w1smoke if sample_final==1 & HNDwave==1 & Race==2
mi estimate: mean w1allostatic_load if sample_final==1 & HNDwave==1 & Race==2

mi estimate: prop R_traj_Group_DIETHEIrec  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: prop R_traj_Group_DIETDIIrec  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: prop R_traj_Group_DIETMARrec  if sample_final==1 & HNDwave==1 & Race==2

mi estimate: mean w1w3w4bayes0DIETHEI  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: mean w1w3w4bayes0DIETDII  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: mean w1w3w4bayes0DIETMAR  if sample_final==1 & HNDwave==1 & Race==2

mi estimate: mean w1w3w4bayes1DIETHEI  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: mean w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1 & Race==2
mi estimate: mean w1w3w4bayes1DIETMAR  if sample_final==1 & HNDwave==1 & Race==2


******************DIFFERENCE BY SEX***********************


mi estimate: reg w1Age  Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit Race  Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit PovStat  Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit w1edubr  Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit w1currdrugs Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit w1smoke Sex if sample_final==1 & HNDwave==1
mi estimate: reg w1allostatic_load Sex if sample_final==1 & HNDwave==1

mi estimate: mlogit R_traj_Group_DIETHEI  Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit R_traj_Group_DIETDII  Sex if sample_final==1 & HNDwave==1
mi estimate: mlogit R_traj_Group_DIETMAR  Sex if sample_final==1 & HNDwave==1

mi estimate: reg w1w3w4bayes0DIETHEI Sex if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes0DIETDII Sex if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes0DIETMAR  Sex if sample_final==1 & HNDwave==1

mi estimate: reg w1w3w4bayes1DIETHEI Sex if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes1DIETDII  Sex if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes1DIETMAR  Sex if sample_final==1 & HNDwave==1


*****************DIFERENCE BY RACE*************************

mi estimate: reg w1Age  Race if sample_final==1 & HNDwave==1
mi estimate: mlogit Sex Race if sample_final==1 & HNDwave==1
mi estimate: mlogit PovStat  Race if sample_final==1 & HNDwave==1
mi estimate: mlogit w1edubr  Race if sample_final==1 & HNDwave==1
mi estimate: mlogit w1currdrugs Race if sample_final==1 & HNDwave==1
mi estimate: mlogit w1smoke Race if sample_final==1 & HNDwave==1
mi estimate: reg w1allostatic_load Race if sample_final==1 & HNDwave==1

mi estimate: mlogit R_traj_Group_DIETHEIrec  Race if sample_final==1 & HNDwave==1
mi estimate: mlogit R_traj_Group_DIETDIIrec  Race if sample_final==1 & HNDwave==1
mi estimate: mlogit R_traj_Group_DIETMARrec  Race if sample_final==1 & HNDwave==1

mi estimate: reg w1w3w4bayes0DIETHEI  Race if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes0DIETDII  Race if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes0DIETMAR  Race if sample_final==1 & HNDwave==1

mi estimate: reg w1w3w4bayes1DIETHEI  Race if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes1DIETDII  Race if sample_final==1 & HNDwave==1
mi estimate: reg w1w3w4bayes0DIETMAR  Race if sample_final==1 & HNDwave==1


save, replace

capture log close


log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\GROUPDESCRIPTION.smcl",replace

******************DESCRIPTION OF GROUPED TRAJECTORIES BY EMPIRICAL BAYES ESTIMATORS AND OBSERVED VALUES***************************


bysort R_traj_Group_DIETHEIrec: su w1w3w4bayes0DIETHEI w1w3w4bayes1DIETHEI if sample_final==1 & HNDwave==1 & _mi_m==0
bysort R_traj_Group_DIETDIIrec: su w1w3w4bayes0DIETDII w1w3w4bayes1DIETDII  if sample_final==1 & HNDwave==1 & _mi_m==0
bysort R_traj_Group_DIETMARrec: su w1w3w4bayes0DIETMAR w1w3w4bayes1DIETMAR  if sample_final==1 & HNDwave==1 & _mi_m==0

bysort R_traj_Group_DIETHEIrec: su w1DIETHEI w3DIETHEI w4DIETHEI if sample_final==1 & HNDwave==1 & _mi_m==0
bysort R_traj_Group_DIETDIIrec: su w1DIETDII w3DIETDII w4DIETDII if sample_final==1 & HNDwave==1 & _mi_m==0
bysort R_traj_Group_DIETMARrec: su w1DIETMAR w3DIETMAR w4DIETMAR if sample_final==1 & HNDwave==1 & _mi_m==0



capture log close

**********************************KAPPA statistics for overall agreement and cross-tabulations between diet quality indices**************************************

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\KAPPA.smcl",replace


tab1 R_traj_Group_DIETHEIrec R_traj_Group_DIETDIIrec R_traj_Group_DIETMARrec if sample_final==1 & HNDwave==1 & _mi_m==0

kap R_traj_Group_DIETHEIrec R_traj_Group_DIETDIIrec if sample_final==1 & HNDwave==1 & _mi_m==0, wgt(w)
kap R_traj_Group_DIETHEIrec R_traj_Group_DIETMARrec if sample_final==1 & HNDwave==1 & _mi_m==0, wgt(w)
kap R_traj_Group_DIETDIIrec R_traj_Group_DIETMARrec if sample_final==1 & HNDwave==1 & _mi_m==0, wgt(w)


tab R_traj_Group_DIETHEIrec R_traj_Group_DIETDIIrec if sample_final==1 & HNDwave==1 & _mi_m==0, row col chi
tab R_traj_Group_DIETMARrec R_traj_Group_DIETDIIrec if sample_final==1 & HNDwave==1 & _mi_m==0, row col chi
tab R_traj_Group_DIETMARrec R_traj_Group_DIETHEIrec if sample_final==1 & HNDwave==1 & _mi_m==0, row col chi


capture log close

log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\MIXEDMODELS_DIETTRAJGROUPS.smcl",replace

******************************MIXED MODELS BETWEEN DIET QUALITY INDICES AND GROUPS OF THOSE DIET QUALITY INDICES*********************************

*********************************MODEL 1: UNADJUSTED FOR OTHER COVARIATES********************************************************

mi estimate: mixed DIETHEI  c.timew1w3w4##R_traj_Group_DIETHEIrec  if sample_final==1 || HNDID: timew1w3w4

mi estimate: mixed DIETDIIrec  c.timew1w3w4##R_traj_Group_DIETDIIrec   if sample_final==1 || HNDID: timew1w3w4

mi estimate: mixed DIETMAR  c.timew1w3w4##R_traj_Group_DIETMARrec   if sample_final==1 || HNDID: timew1w3w4




*********************************MODEL 1: ADJUSTED FOR SOCIO-DEMOGRAPHIC COVARIATES********************************************************


mi estimate: mixed DIETHEI  c.timew1w3w4##R_traj_Group_DIETHEIrec  c.timew1w3w4##c.w1Agecenter c.timew1w3w4##Sex c.timew1w3w4##Race c.timew1w3w4##PovStat if sample_final==1 || HNDID: timew1w3w4


mi estimate: mixed DIETDIIrec  c.timew1w3w4##R_traj_Group_DIETDIIrec  c.timew1w3w4##c.w1Agecenter c.timew1w3w4##Sex c.timew1w3w4##Race c.timew1w3w4##PovStat if sample_final==1 || HNDID: timew1w3w4


mi estimate: mixed DIETMAR  c.timew1w3w4##R_traj_Group_DIETMARrec  c.timew1w3w4##c.w1Agecenter c.timew1w3w4##Sex c.timew1w3w4##Race c.timew1w3w4##PovStat if sample_final==1 || HNDID: timew1w3w4


save, replace

capture log close
log using "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\SPAGHETTHI.smcl",replace


************************************************************SPAGHETTI PLOTS: GROUPS OF DIET QUALITY TRAJECTORIES AND INDIVIDUAL TRAJECTORIES***********************


**R_traj_Group_DIETMARrec
**R_traj_Group_DIETDIIrec
**R_traj_Group_DIETHEIrec

**DIETHEI
**DIETDIIrec
**DIETMAR


**spagplot yvar xvar [if exp] [in range], id(idvar) [nofit] [noover] [graph options]

use finaldata_imputed_FINAL,clear

mi extract 0

sort HNDwave HNDID

save finaldata_unimputed_FINAL, replace

collapse (mean) HNDwave sample_final, by(HNDID)

save finaldata_unimputed_FINAL_collapsed, replace

set seed 1234

sample 10 if sample_final==1

save finaldata_unimputed_FINAL10sampleHNDID, replace

capture rename sample_final selected
sort HNDID
capture drop HNDwave
save, replace

use finaldata_unimputed_FINAL,clear
sort HNDID
capture drop _merge
save, replace

merge HNDID using finaldata_unimputed_FINAL10sampleHNDID
sort HNDID HNDwave
capture drop _merge
save, replace


sort HNDwave HNDID DIETHEI

capture drop DIETHEIpred
gen DIETHEIpred=w1w3w4bayes0DIETHEI+w1w3w4bayes1DIETHEI*timew1w3w4

capture drop TIMEint
gen TIMEint=int(timew1w3w4)


spagplot DIETHEI timew1w3w4 if R_traj_Group_DIETHEIrec==1 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGGROUP1.gph",replace
spagplot DIETHEI timew1w3w4 if R_traj_Group_DIETHEIrec==2 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit  
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGGROUP2.gph",replace
spagplot DIETHEI timew1w3w4 if R_traj_Group_DIETHEIrec==3 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit 
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGGROUP3.gph",replace



graph combine "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGGROUP1.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGGROUP2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGGROUP3.gph"
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETHEISPAGALLGROUPS.gph",replace




sort HNDwave HNDID DIETDIIrec

spagplot DIETDIIrec timew1w3w4 if R_traj_Group_DIETDIIrec==1 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGGROUP1.gph",replace
spagplot DIETDIIrec timew1w3w4 if R_traj_Group_DIETDIIrec==2 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGGROUP2.gph",replace
spagplot DIETDIIrec timew1w3w4 if R_traj_Group_DIETDIIrec==3 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGGROUP3.gph",replace



graph combine "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGGROUP1.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGGROUP2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGGROUP3.gph"
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETDIIrecSPAGALLGROUPS.gph",replace



sort HNDwave HNDID DIETMAR

spagplot DIETMAR timew1w3w4 if R_traj_Group_DIETMARrec==1 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGGROUP1.gph",replace
spagplot DIETMAR timew1w3w4 if R_traj_Group_DIETMARrec==2 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGGROUP2.gph",replace
spagplot DIETMAR timew1w3w4 if R_traj_Group_DIETMARrec==3 & sample_final==1 & selected==1, id(HNDID) scheme(sj) nofit
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGGROUP3.gph",replace



graph combine "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGGROUP1.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGGROUP2.gph" "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGGROUP3.gph"
graph save "E:\HANDLS_PAPER57_FRAILTYDIET\OUTPUT_PAPER1\DIETMARSPAGALLGROUPS.gph",replace

capture log close