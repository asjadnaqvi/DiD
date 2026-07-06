*﻿*Author: Clément de Chaisemartin
**1st version: November 8th 2019
**This version: April 28th 2021

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Program #1: Does sanity checks and time consuming data manipulations, calls did_multiplegt_results, and stores estimates and standard errors in e() and put them on a graph //////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

capture program drop did_multiplegt
program did_multiplegt, eclass
	version 12.0
*NEWW
	*syntax varlist(min=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) weight(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances average_effect(string) save_results(string)]
	syntax varlist(min=4 numeric) [if] [in]  [, RECAt_treatment(varlist numeric) THRESHold_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) weight(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances AVerage_effect SAVe_results(string) robust_dynamic switchers(string) LONGdiff_placebo count_switchers_tot count_switchers_contr graphoptions(string) discount(real 1) seed(integer 0) JOINTtestplacebo if_first_diff(string)]
*END NEWW
qui{

preserve

// Globals determining whether we see the results from all the intermediate regressions 

*global no_header_no_table "vce(ols)"
global no_header_no_table "nohea notab"

*global noisily "noisily"
global noisily ""

// Dropping variables that get created later

capture drop outcome_XX
capture drop group_XX
capture drop time_XX
capture drop treatment_XX
capture drop D_cat_XX
capture drop d_cat_group_XX
capture drop diff_y_XX
capture drop diff_d_XX
capture drop ZZ_*
capture drop lag_d_cat_group_XX

// Performing sanity checks on command requested by user

if "`if'" !=""{
*NEWW
*did_multiplegt_check `varlist' `if', recat_treatment(`recat_treatment') threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') weight(`weight') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') `covariances' average_effect(`average_effect')
did_multiplegt_check `varlist' `if', recat_treatment(`recat_treatment') threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') weight(`weight') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') `covariances' `average_effect' `longdiff_placebo' `robust_dynamic' if_first_diff(`if_first_diff')
*END NEWW
}

if "`if'"==""{
*NEWW
*did_multiplegt_check `varlist', recat_treatment(`recat_treatment') threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') weight(`weight') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') `covariances' average_effect(`average_effect')
did_multiplegt_check `varlist', recat_treatment(`recat_treatment') threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') weight(`weight') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') `covariances' `average_effect' `longdiff_placebo' `robust_dynamic' if_first_diff(`if_first_diff')
*END NEWW
}

if did_multiplegt_check==1 {

// Selecting the sample
	if "`if'" !=""{
	keep `if'
	}
	if "`weight'" !=""{
	drop if `weight'==.
	}	
	tokenize `varlist'
	drop if `2'==.|`3'==.|`4'==.
	if "`controls'" !=""{
	foreach var of varlist `controls'{
	drop if `var'==.
	}
	}
	if "`cluster'" !=""{
	drop if `cluster'==.
	}
	if "`recat_treatment'" !=""{
	drop if `recat_treatment'==.
	}
	if "`weight'" !=""{
	drop if `weight'==.
	}

// If the weight option is not specified, collapse data set at the (g,t) level. 

tempvar counter counter2

*NEWW

bys `2' `3': egen `counter2'=count(`4')
sum `counter2'
scalar aggregated_data=0
if r(max)==1{
scalar aggregated_data=1
}

if "`weight'"==""{
gen `counter'=1
}
if "`weight'"!=""{
gen `counter'=`weight'
}

*if "`weight'" ==""&aggregated_data==0{
if aggregated_data==0{

*RECENT NEWW
replace `counter'=0 if `1'==. 
*END RECENT NEWW

//Collapsing the data, ensuring that group variable is not the clustering or the trend_lin variable

if "`1'"!="`4'"{

if ("`cluster'"!=""&"`cluster'"!="`2'")&("`trends_lin'"!=""&"`trends_lin'"!="`2'"){

*collapse (mean) `1' `4' `controls' `trends_nonparam' `trends_lin' `cluster' `recat_treatment' (count) `counter', by(`2' `3')
*NEWW: Shuo, look at Stata collapse help file to see what collapse is doing for count with pw option, to try to reproduce that in R.
*Note: collapse with mean and pweight equivalent to multiplying `1' and `controls' by `counter', collapsing taking sum of `1', `controls' and `counter', and dividing by `counter'
collapse (mean) `1' `4' `controls' `trends_nonparam' `trends_lin' `cluster' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

if ("`cluster'"==""|"`cluster'"=="`2'")&("`trends_lin'"!=""&"`trends_lin'"!="`2'"){

*collapse (mean) `1' `4' `controls' `trends_nonparam' `trends_lin' `recat_treatment' (count) `counter', by(`2' `3')
collapse (mean) `1' `4' `controls' `trends_nonparam' `trends_lin' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

if ("`cluster'"!=""&"`cluster'"!="`2'")&("`trends_lin'"==""|"`trends_lin'"=="`2'"){

*collapse (mean) `1' `4' `controls' `trends_nonparam' `cluster' `recat_treatment' (count) `counter', by(`2' `3')
collapse (mean) `1' `4' `controls' `trends_nonparam' `cluster' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

if ("`cluster'"==""|"`cluster'"=="`2'")&("`trends_lin'"==""|"`trends_lin'"=="`2'"){

*collapse (mean) `1' `4' `controls' `trends_nonparam' `recat_treatment' (count) `counter', by(`2' `3')
collapse (mean) `1' `4' `controls' `trends_nonparam' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

}

if "`1'"=="`4'"{

if ("`cluster'"!=""&"`cluster'"!="`2'")&("`trends_lin'"!=""&"`trends_lin'"!="`2'"){

collapse (mean) `1' `controls' `trends_nonparam' `trends_lin' `cluster' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

if ("`cluster'"==""|"`cluster'"=="`2'")&("`trends_lin'"!=""&"`trends_lin'"!="`2'"){

collapse (mean) `1' `controls' `trends_nonparam' `trends_lin' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

if ("`cluster'"!=""&"`cluster'"!="`2'")&("`trends_lin'"==""|"`trends_lin'"=="`2'"){

collapse (mean) `1' `controls' `trends_nonparam' `cluster' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

if ("`cluster'"==""|"`cluster'"=="`2'")&("`trends_lin'"==""|"`trends_lin'"=="`2'"){

collapse (mean) `1' `controls' `trends_nonparam' `recat_treatment' (count) `counter' [pw=`counter'], by(`2' `3')

}

}

}

// If the weight option is specified, set `counter' as `weight'. 

*if "`weight'"!=""{

*replace `counter'=`weight'

*}

*END NEWW

// Creating all the variables needed for estimation of instantaneous effect

*Y, G, T, D variables

gen outcome_XX=`1'
egen group_XX=group(`2')
egen time_XX=group(`3')
gen treatment_XX=`4'

*Creating a discretized treatment even if recat_treatment option not specified

if "`recat_treatment'" !=""{
gen D_cat_XX=`recat_treatment'
}
else{
gen D_cat_XX=treatment_XX
}

*Creating groups of recategorized treatment, to ensure we have an ordered treatment with interval of 1 between consecutive values

egen d_cat_group_XX=group(D_cat_XX)

*Declaring data set as panel

xtset group_XX time_XX

*First diff outcome, treatment, and controls

g diff_y_XX = d.outcome_XX
g diff_d_XX = d.treatment_XX

if "`controls'" !=""{
local count_controls=0
foreach var of varlist `controls'{
local count_controls=`count_controls'+1
gen ZZ_cont`count_controls'=d.`var'
}
}

*Lag D_cat

g lag_d_cat_group_XX = L1.d_cat_group_XX

*NEWW
// Note: Creating new variables necessary for the robust_dynamic option
// Staggered treatment (and its first difference): 
// if robust_dynamic option not specified: actual treatment 
// if robust_dynamic option specified: actual treatment till first change, and treatment at date of first change thereafter: D_{g,min(F_{g,\ne D_{g,1}},t)}
// ever_change_d: 
// if robust_dynamic option not specified: 0 
// if robust_dynamic option specified: indicator for whether group g's treatment has changed at least once at t
// increase_d: 
// if robust_dynamic option not specified: 1\{D_{g,t}-D_{g,t-1}>0\} 
// if robust_dynamic option specified: 1\{\sum_t N_{g,t}beta^tD_{g,t}>\sum_t N_{g,t}beta^tD_{g,1}\}

capture drop stag_d_XX
capture drop ever_change_d_XX
capture drop diff_stag_d_XX
capture drop d_sq_XX
capture drop tot_d_XX
capture drop increase_d_XX

gen stag_d_XX=treatment_XX
// Note: important to ensure that creation of ever_change_d_XX and diff_stag_d_XX correct even with unbalanced panel of groups. 
// Conventions used: 
// a) if a group is missing at a date t, but treatment in t-1 and t+1 are equal, and had never changed treatment before
//t-1, considered as group that has never changed till t+1 at least: ever_change_d_XX=0 in t+1, so can be used as control, 
// and we also set diff_stag_d_XX=0 in t so can be used as control in t
// b) if a group is missing at a date t, treatments in t-1 and t+1 are different, and had never changed treatment before
//t-1, we set diff_stag_d_XX=. and that group is essentially dropped from the estimation after t-1, because we don't know when treatment changed. 
 if "`robust_dynamic'"!=""{
gen d_sq_XX=treatment_XX
sort group_XX time_XX
gen ever_change_d_XX=(abs(treatment_XX-treatment_XX[_n-1])>`threshold_stable_treatment') if treatment_XX!=.&treatment_XX[_n-1]!=.&group_XX==group_XX[_n-1]
replace ever_change_d_XX=1 if ever_change_d_XX[_n-1]==1 & group_XX==group_XX[_n-1]
replace stag_d_XX=stag_d_XX[_n-1] if ever_change_d_XX==1 & ever_change_d_XX[_n-1]==1&group_XX==group_XX[_n-1]
replace d_sq_XX=d_sq_XX[_n-1] if group_XX==group_XX[_n-1]
gen tot_d_XX=(treatment_XX-d_sq_XX)*`counter'*`discount'^time_XX
bys group_XX: egen increase_d_XX=total(tot_d_XX)
replace  increase_d_XX=(increase_d_XX>0)
}
xtset group_XX time_XX
g diff_stag_d_XX = d.stag_d_XX
 if "`robust_dynamic'"!=""{
replace diff_stag_d_XX=0 if ever_change_d_XX==0
}
if "`robust_dynamic'"==""{
gen ever_change_d_XX=0 if diff_d_XX!=.
gen increase_d_XX=(diff_d_XX>0) if diff_d_XX!=.
}
*END NEWW

// If placebos requested, creating all the variables needed for estimation of placebos

*NEWW
*if "`placebo'"!="0"{
if "`placebo'"!="0"&"`longdiff_placebo'"==""{
*END NEWW

forvalue i=1/`=`placebo''{

*Lag First diff outcome, treatment, and controls
capture drop diff_d_lag`i'_XX
capture drop diff_y_lag`i'_XX
g diff_d_lag`i'_XX = L`i'.diff_d_XX
g diff_y_lag`i'_XX = L`i'.diff_y_XX

if "`controls'" !=""{
forvalue j=1/`=`count_controls''{
gen ZZ_cont_lag`i'_`j'=L`i'.ZZ_cont`j'
}

}

}

}

*NEWW
if "`placebo'"!="0"&"`longdiff_placebo'"!=""{

forvalue i=1/`=`placebo''{

*Long diff outcome and controls, and if dynamic effects not requested: forward of first diff treatment

capture drop ldiff_y_`i'_XX
capture drop ldiff_y_for`i'_XX
g ldiff_y_`i'_XX = S`=`i''.outcome_XX
g ldiff_y_`i'_lag_XX =L.ldiff_y_`i'_XX
drop ldiff_y_`i'_XX 

if "`controls'" !=""{

local count_controls=0
foreach var of varlist `controls'{
local count_controls=`count_controls'+1
g ZZ_cont_ldiff`i'_`count_controls'=S`=`i''.`var'
}
forvalue j=1/`=`count_controls''{
g  ZZ_cont_ldiff_`i'_lag_`j'=L.ZZ_cont_ldiff`i'_`j'
drop ZZ_cont_ldiff`i'_`j'
}

}

if "`dynamic'"=="0" {

capture drop diff_stag_d_for`i'_XX
g diff_stag_d_for`i'_XX = F`i'.diff_stag_d_XX
*RECENT NEWW
capture drop counter_F`i'_XX
g counter_F`i'_XX=F`i'.`counter'
*END RECENT NEWW

}

}
}
*END NEWW


// If dynamic effects requested, creating all the variables needed for estimation of dynamic effects

if "`dynamic'"!="0"{

forvalue i=1/`=`dynamic''{

*Long diff outcome, long diff treatment, forward of first diff treatment, and long diff controls

*NEWW
*capture drop diff_d_for`i'_XX
*g diff_d_for`i'_XX = F`i'.diff_d_XX
capture drop diff_stag_d_for`i'_XX
g diff_stag_d_for`i'_XX = F`i'.diff_stag_d_XX
*RECENT NEWW
capture drop counter_F`i'_XX
g counter_F`i'_XX=F`i'.`counter'
*END RECENT NEWW
*END NEWW

capture drop ldiff_y_`i'_XX
capture drop ldiff_y_for`i'_XX
g ldiff_y_`i'_XX = S`=`i'+1'.outcome_XX
g ldiff_y_for`i'_XX =F`i'.ldiff_y_`i'_XX 

*NEWW
capture drop ldiff_d_`i'_XX
capture drop ldiff_d_for`i'_XX
g ldiff_d_`i'_XX = S`=`i'+1'.treatment_XX
g ldiff_d_for`i'_XX =F`i'.ldiff_d_`i'_XX
*END NEWW

if "`controls'" !=""{

local count_controls=0
foreach var of varlist `controls'{
local count_controls=`count_controls'+1
g ZZ_cont_ldiff`i'_`count_controls'=S`=`i'+1'.`var'
}
forvalue j=1/`=`count_controls''{
g  ZZ_cont_ldiff_for`i'_`j'=F`i'.ZZ_cont_ldiff`i'_`j'
}

}

}

}

//Replace controls by their first difference 

if "`controls'" !=""{
local count_controls=1
foreach var of varlist `controls'{
replace `var'=ZZ_cont`count_controls'
local count_controls=`count_controls'+1
}
}

//Creating trends_var if needed

if "`trends_nonparam'" !=""{
egen long trends_var_XX=group(`trends_nonparam' time_XX)
}

*NEWW
if "`if_first_diff'"!=""{
gen if_first_diff_XX=(`if_first_diff')
replace diff_stag_d_XX=. if if_first_diff_XX==0
}
*END NEWW

*END NEWW

// Run did_multiplegt_results.

*NEWW
*if "`if'" !=""{
*did_multiplegt_results `varlist' `if', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster')
*}
*if "`if'" ==""{
*did_multiplegt_results `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster')
did_multiplegt_results `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') switchers(`switchers') `longdiff_placebo' `count_switchers_tot' `count_switchers_contr' `robust_dynamic' discount(`discount') seed(`seed')
*}
*END NEWW

// Compute standard errors of point estimates 

if `breps'>0 {

drop _all

svmat bootstrap
sum bootstrap1
scalar se_effect_0_2=r(sd)
forvalue i=1/`dynamic'{
sum bootstrap`=`i'+1'
scalar se_effect_`i'_2=r(sd)
}
forvalue i=1/`placebo'{
sum bootstrap`=`i'+`dynamic'+1'
scalar se_placebo_`i'_2=r(sd)
}

}

// Clearing ereturn

ereturn clear

// Error message if instantaneous effect could not be estimated

*NEWW (the text of the error message has also changed)
if "`count_switchers_tot'"!=""{
ereturn scalar N_switchers_effect_0_tot=N_switchers_effect_0_tot_2
}
if N_effect_0_2==.{
di as error ""
di as error "The command was not able to estimate the treatment effect at the period when groups' treatment change." 
di as error "If your treatment is continuous or takes a large number of values, you may need to use" 
di as error "the threshold_stable_treatment option to ensure you have groups whose treatment does not change" 
di as error "over time. You may also need to use the recat_treatment option to discretize your treatment variable."
matrix effect0=.,.,.,.,.,.
}
*END NEWW

// If instantaneous effect could be estimated, collect estimate and number of observations 

else {
ereturn scalar effect_0 = effect_0_2
if `breps'>0 {
ereturn scalar se_effect_0 = se_effect_0_2
*NEWW
matrix effect0=effect_0_2,se_effect_0_2,effect_0_2-1.96*se_effect_0_2,effect_0_2+1.96*se_effect_0_2,N_effect_0_2,N_switchers_effect_0_2
*END NEWW
}
ereturn scalar N_effect_0 = N_effect_0_2
ereturn scalar N_switchers_effect_0 = N_switchers_effect_0_2
*NEWW
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
ereturn scalar N_switchers_effect_0_contr=N_switchers_effect_0_contr_2
}
*END NEWW 
}

// If dynamic effects requested, collect estimates and number of observations

if "`dynamic'"!="0"{

*Looping over the number of dynamic effects requested

forvalue i=1/`=`dynamic''{

// Error message if dynamic effect i could not be estimated

*NEWW (the text of the error message has also changed)
if "`count_switchers_tot'"!=""{
ereturn scalar N_switchers_effect_`i'_tot=N_switchers_effect_`i'_tot_2
}
if N_effect_`i'_2==.{
di as error ""
di as error "The command was not able to estimate the treatment effect "`i' 
di as error "periods after groups' treatment changes for the first time." 
di as error "If your treatment is continuous or takes a large number of values, you may need to use" 
di as error "the threshold_stable_treatment option to ensure you have groups whose treatment does not change" 
di as error "over time. You may also need to use the recat_treatment option to discretize your treatment variable."
di as error "You may also be trying to estimate more dynamic effects than it is possible to do in your data."
matrix effect`i'=.,.,.,.,.,.
}
*END NEWW

// If dynamic effect i could be estimated, collect estimate and number of observations 

else {
ereturn scalar effect_`i' = effect_`i'_2
if `breps'>0 {
ereturn scalar se_effect_`i' = se_effect_`i'_2
*NEWW
matrix effect`i'=effect_`i'_2,se_effect_`i'_2,effect_`i'_2-1.96*se_effect_`i'_2,effect_`i'_2+1.96*se_effect_`i'_2,N_effect_`i'_2,N_switchers_effect_`i'_2
*END NEWW
}
ereturn scalar N_effect_`i' = N_effect_`i'_2
ereturn scalar N_switchers_effect_`i' = N_switchers_effect_`i'_2
*NEWW
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
ereturn scalar N_switchers_effect_`i'_contr=N_switchers_effect_`i'_contr_2
}
*END NEWW
}

*End of the loop on the number of dynamic effects
}

*End of the condition assessing if the computation of dynamic effects was requested by the user
}

// If placebos requested, collect estimates and number of observations

if "`placebo'"!="0"{

*Looping over the number of placebos requested

forvalue i=1/`=`placebo''{

// Error message if placebo i could not be estimated

*NEWW (the text of the error message has also changed)
if "`count_switchers_tot'"!=""{
ereturn scalar N_switchers_placebo_`i'_tot=N_switchers_placebo_`i'_tot_2
}
if N_placebo_`i'_2==.{
di as error ""
di as error "The command was not able to estimate the placebo "`i' 
di as error "periods before groups' treatment changes." 
di as error "If your treatment is continuous or takes a large number of values, you may need to use" 
di as error "the threshold_stable_treatment option to ensure you have groups whose treatment does not change" 
di as error "over time. You may also need to use the recat_treatment option to discretize your treatment variable."
di as error "You may also be trying to estimate more placebos than it is possible to do in your data."
matrix placebo`i'=.,.,.,.,.,.

}
*END NEWW

// If placebo i could be estimated, collect estimate and number of observations 

else {
ereturn scalar placebo_`i' = placebo_`i'_2
if `breps'>0 {
ereturn scalar se_placebo_`i' = se_placebo_`i'_2
*NEWW
matrix placebo`i'=placebo_`i'_2,se_placebo_`i'_2,placebo_`i'_2-1.96*se_placebo_`i'_2,placebo_`i'_2+1.96*se_placebo_`i'_2,N_placebo_`i'_2,N_switchers_placebo_`i'_2
*END NEWW
}
ereturn scalar N_placebo_`i' = N_placebo_`i'_2
*NEWW
ereturn scalar N_switchers_placebo_`i' = N_switchers_placebo_`i'_2
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
ereturn scalar N_switchers_placebo_`i'_contr=N_switchers_placebo_`i'_contr_2
}
*END NEWW
}

*End of the loop on the number of placebos
}

*End of the condition assessing if the computation of placebos was requested by the user
}

// If dynamic effects or placebos requested and covariance option specified, compute covariances between all estimated effects

*NEWW
scalar too_many_dynamic_or_placebo=0
scalar too_few_bootstrap_reps=0
*END NEWW

if `breps'>0&"`covariances'"!=""{

if "`dynamic'"!="0"{

forvalue i=0/`dynamic'{
forvalue j=`=`i'+1'/`dynamic'{
*NEWW
*correlate bootstrap`=`i'+1' bootstrap`=`j'+1', covariance
capture correlate bootstrap`=`i'+1' bootstrap`=`j'+1', covariance
if _rc==2000{
scalar too_many_dynamic_or_placebo=1
}
if _rc==2001{
scalar too_few_bootstrap_reps=1
}
if _rc!=2000&_rc!=2001{
*END NEWW
ereturn scalar cov_effects_`i'_`j'=r(cov_12)
scalar cov_effects_`i'_`j'_int=r(cov_12)
scalar cov_effects_`j'`i'_int=r(cov_12)
*NEWW
}
*END NEWW
}
}

}


if `placebo'>1{

forvalue i=1/`placebo'{
forvalue j=`=`i'+1'/`placebo'{
*NEWW
*correlate bootstrap`=`i'+`dynamic'+1' bootstrap`=`j'+`dynamic'+1', covariance
capture correlate bootstrap`=`i'+`dynamic'+1' bootstrap`=`j'+`dynamic'+1', covariance
if _rc==2000{
scalar too_many_dynamic_or_placebo=1
}
if _rc==2001{
scalar too_few_bootstrap_reps=1
}
if _rc!=2000&_rc!=2001{
*ereturn scalar cov_placebo_`i'`j'=r(cov_12)
*scalar cov_placebo_`i'`j'_int=r(cov_12)
ereturn scalar cov_placebo_`i'_`j'=r(cov_12)
scalar cov_placebo_`i'_`j'_int=r(cov_12)
}
*END NEWW
}
}

}

}

*NEWW

/////// Error messages if too_many_dynamic_or_placebo or too_few_bootstrap_reps

if too_many_dynamic_or_placebo==1 {
di as error ""
di as error "The command was not able to run till the end, presumably because it could not" 
di as error "estimate all placebos and dynamic effects requested. Estimates are stored in e()," 
di as error "so you can type ereturn list to see which placebos and dynamic effects the command"
di as error "could estimate. To solve this problem, you will probably have to diminish the number"
di as error "of placebos or dynamic effects requested. See the help file for more information on the"
di as error "maximum number of dynamic effects and placebos the command can compute."
}

if too_few_bootstrap_reps==1 {
di as error ""
di as error "The command was not able to run till the end, presumably because it could not" 
di as error "compute sufficiently many bootstrap replications for some of the placebos and dynamic" 
di as error "effects requested. To solve this problem, you will probably have to increase the number"
di as error "of bootstrap replications."
}

if too_few_bootstrap_reps==0&too_many_dynamic_or_placebo==0{

*END NEWW

/////// Computing average effect, if option requested

if "`average_effect'"!=""{

scalar average_effect_int=0
scalar var_average_effect_int=0
scalar N_average_effect_int=0
*NEWW
scalar N_switch_average_effect_int=0
*END NEWW


//// Computing weights

*NEWW

/*
// Weights for simple average

if "`average_effect'"=="simple"{
scalar check_cov=1
matrix Weight=J(`dynamic'+1,1,1/(`dynamic'+1))
}

// Weights proportionnal to number of switchers for which each effect is estimated

if "`average_effect'"=="prop_number_switchers"{
scalar check_cov=1
scalar total_switchers=0
forvalue i=0/`=`dynamic''{
matrix Weight[`i'+1,1]=N_switchers_effect_`i'_2
scalar total_switchers=total_switchers+N_switchers_effect_`i'_2
}
matrix Weight=Weight*(1/total_switchers)

}
*/

scalar total_weight=0
matrix Weight=J(`dynamic'+1,1,0)
forvalue i=0/`=`dynamic''{
matrix Weight[`i'+1,1]=denom_DID_ell_`i'
scalar total_weight=total_weight+denom_delta_`i'
}
matrix Weight=Weight*(1/total_weight)

*END NEWW

//// Computing average effect, its variance, and returning results 

forvalue i=0/`=`dynamic''{
scalar average_effect_int=average_effect_int+Weight[`i'+1,1]*effect_`i'_2
scalar N_average_effect_int=N_average_effect_int+N_effect_`i'_2
scalar N_switch_average_effect_int=N_switch_average_effect_int+N_switchers_effect_`i'_2
*NEWW
if "`breps'"!="0"&"`covariances'"!=""{
*END NEWW
scalar var_average_effect_int=var_average_effect_int+Weight[`i'+1,1]^2*se_effect_`i'_2^2
if `i'<`dynamic'{
forvalue j=`=`i'+1'/`=`dynamic''{
scalar var_average_effect_int=var_average_effect_int+Weight[`i'+1,1]*Weight[`j'+1,1]*2*cov_effects_`i'_`j'_int
}
}
*NEWW
}
*END NEWW
}

*Returning results

ereturn scalar effect_average=average_effect_int
*NEWW
if "`breps'"!="0"&"`covariances'"!=""{
ereturn scalar se_effect_average=sqrt(var_average_effect_int)
matrix average=average_effect_int,sqrt(var_average_effect_int),average_effect_int-1.96*sqrt(var_average_effect_int),average_effect_int+1.96*sqrt(var_average_effect_int),N_average_effect_int,N_switch_average_effect_int
}
*END NEWW
ereturn scalar N_effect_average=N_average_effect_int
*NEWW
ereturn scalar N_switchers_effect_average=N_switch_average_effect_int
*END NEWW
}

*NEWW
///// Running joint test that placebos all 0, if jointtestplacebo option specified

if "`breps'"!="0"&"`covariances'"!=""&"`jointtestplacebo'"!=""&`placebo'>1{

matrix Placebo=J(`placebo',1,0)
matrix Var_Placebo=J(`placebo',`placebo',0)
forvalue i=1/`placebo'{
matrix Placebo[`i',1]=placebo_`i'_2
scalar cov_placebo_`i'_`i'_int=se_placebo_`i'_2^2
forvalue j=1/`i'{
matrix Var_Placebo[`i',`j']=cov_placebo_`j'_`i'_int
}
if `i'<`placebo'{
forvalue j=`=`i'+1'/`placebo'{
matrix Var_Placebo[`i',`j']=cov_placebo_`i'_`j'_int
}
}
}

matrix Var_Placebo_inv=invsym(Var_Placebo)
matrix Placebo_t=Placebo'
matrix chi2placebo=Placebo_t*Var_Placebo_inv*Placebo
ereturn scalar p_jointplacebo=1-chi2(`placebo',chi2placebo[1,1])
}
*END NEWW

///// Putting estimates and their confidence intervals on a graph, if breps option specified

if "`breps'"!="0"{

local estimates_req=3+`placebo'+`dynamic'

if `breps'<`estimates_req' {
set obs `estimates_req'
}

gen time_to_treatment=.
gen treatment_effect=.
gen se_treatment_effect=.
gen N_treatment_effect=.
gen treatment_effect_upper_95CI=.
gen treatment_effect_lower_95CI=.

if "`placebo'"!="0"{
forvalue i=1/`=`placebo''{
*NEWW
*replace time_to_treatment=-`i' if _n==`placebo'-`i'+1
replace time_to_treatment=-`i'-1 if _n==`placebo'-`i'+1
*END NEWW
replace treatment_effect=placebo_`i'_2 if _n==`placebo'-`i'+1
replace se_treatment_effect=se_placebo_`i'_2 if _n==`placebo'-`i'+1
replace N_treatment_effect=N_placebo_`i'_2 if _n==`placebo'-`i'+1
replace treatment_effect_upper_95CI=placebo_`i'_2+1.96*se_placebo_`i'_2 if _n==`placebo'-`i'+1
replace treatment_effect_lower_95CI=placebo_`i'_2-1.96*se_placebo_`i'_2 if _n==`placebo'-`i'+1
}
}
*NEWW
replace time_to_treatment=-1 if _n==`placebo'+1
replace treatment_effect=0 if _n==`placebo'+1 
replace treatment_effect_upper_95CI=0 if _n==`placebo'+1 
replace treatment_effect_lower_95CI=0 if _n==`placebo'+1 
*END NEWW

*NEWW
*replace treatment_effect=effect_0_2 if _n==`placebo'+1 
*replace se_treatment_effect=se_effect_0_2 if _n==`placebo'+1
*replace N_treatment_effect=N_effect_0_2 if _n==`placebo'+1
*replace treatment_effect_upper_95CI=effect_0_2+1.96*se_effect_0_2 if _n==`placebo'+1 
*replace treatment_effect_lower_95CI=effect_0_2-1.96*se_effect_0_2 if _n==`placebo'+1 
replace time_to_treatment=0 if _n==`placebo'+2
replace treatment_effect=effect_0_2 if _n==`placebo'+2
replace se_treatment_effect=se_effect_0_2 if _n==`placebo'+2
replace N_treatment_effect=N_effect_0_2 if _n==`placebo'+2
replace treatment_effect_upper_95CI=effect_0_2+1.96*se_effect_0_2 if _n==`placebo'+2 
replace treatment_effect_lower_95CI=effect_0_2-1.96*se_effect_0_2 if _n==`placebo'+2 
*END NEWW

if "`dynamic'"!="0"{
forvalue i=1/`=`dynamic''{
*NEWW
*replace time_to_treatment=`i' if _n==`placebo'+`i'+1
*replace treatment_effect=effect_`i'_2 if _n==`placebo'+`i'+1 
*replace se_treatment_effect=se_effect_`i'_2 if _n==`placebo'+`i'+1
*replace N_treatment_effect=N_effect_`i'_2 if _n==`placebo'+`i'+1
*replace treatment_effect_upper_95CI=effect_`i'_2+1.96*se_effect_`i'_2 if _n==`placebo'+`i'+1 
*replace treatment_effect_lower_95CI=effect_`i'_2-1.96*se_effect_`i'_2 if _n==`placebo'+`i'+1 
replace time_to_treatment=`i' if _n==`placebo'+`i'+2
replace treatment_effect=effect_`i'_2 if _n==`placebo'+`i'+2 
replace se_treatment_effect=se_effect_`i'_2 if _n==`placebo'+`i'+2
replace N_treatment_effect=N_effect_`i'_2 if _n==`placebo'+`i'+2
replace treatment_effect_upper_95CI=effect_`i'_2+1.96*se_effect_`i'_2 if _n==`placebo'+`i'+2 
replace treatment_effect_lower_95CI=effect_`i'_2-1.96*se_effect_`i'_2 if _n==`placebo'+`i'+2  
*END NEWW

}
}

*NEWW: the lines till END NEWW below have been moved a few lines up, before the lines where the graphs are created
/////Saving results in a data set, if option requested

if "`save_results'"!=""{

	if "`average_effect'"!=""{
	*tostring time_to_treatment, replace
	*replace time_to_treatment="Average effect" if _n==`placebo'+`dynamic'+3 
	replace treatment_effect=average_effect_int if _n==`placebo'+`dynamic'+3 
	replace se_treatment_effect=sqrt(var_average_effect_int) if _n==`placebo'+`dynamic'+3
	replace N_treatment_effect=N_average_effect_int if _n==`placebo'+`dynamic'+3
	replace treatment_effect_upper_95CI=treatment_effect+1.96*se_treatment_effect if _n==`placebo'+`dynamic'+3 
	replace treatment_effect_lower_95CI=treatment_effect-1.96*se_treatment_effect if _n==`placebo'+`dynamic'+3  
	}
 	
keep time_to_treatment N_treatment_effect treatment_effect se_treatment_effect treatment_effect_upper_95CI treatment_effect_lower_95CI

if "`average_effect'"!=""{
keep if _n<=3+`placebo'+`dynamic'
}
if "`average_effect'"==""{
keep if _n<=2+`placebo'+`dynamic'
}

}
*END NEWW

// Producing the graphs

*NEWW
*twoway (line treatment_effect time_to_treatment, lpattern(solid)) (rcap treatment_effect_upper_95CI treatment_effect_lower_95CI time_to_treatment), xlabel(-`placebo'[1]`dynamic') xtitle("Time to treatment", size(large)) ytitle("Treatment effect", size(large)) graphregion(color(white)) plotregion(color(white)) legend(off)
if "`longdiff_placebo'"==""&"`dynamic'"=="0"{

drop if time_to_treatment==-1
replace time_to_treatment=time_to_treatment+1 if time_to_treatment<0

if "`graphoptions'"==""{
twoway (connected treatment_effect time_to_treatment, lpattern(solid)) (rcap treatment_effect_upper_95CI treatment_effect_lower_95CI time_to_treatment), xlabel(`=-`placebo''[1]`=`dynamic'') xtitle("Relative time to period where treatment changes (t=0)", size(large)) title("DID, from period t-1 to t", size(large)) graphregion(color(white)) plotregion(color(white)) legend(off)
}
if "`graphoptions'"!=""{
global options="`graphoptions'"
twoway (connected treatment_effect time_to_treatment, lpattern(solid)) (rcap treatment_effect_upper_95CI treatment_effect_lower_95CI time_to_treatment), $options
}

}

if "`longdiff_placebo'"!=""{

if "`graphoptions'"==""{
twoway (connected treatment_effect time_to_treatment, lpattern(solid)) (rcap treatment_effect_upper_95CI treatment_effect_lower_95CI time_to_treatment), xlabel(`=-`placebo'-1'[1]`=`dynamic'') xtitle("Relative time to period where treatment first changes (t=0)", size(large)) title("DID, from last period before treatment changes (t=-1) to t", size(large)) graphregion(color(white)) plotregion(color(white)) legend(off)
}
if "`graphoptions'"!=""{
global options="`graphoptions'"
twoway (connected treatment_effect time_to_treatment, lpattern(solid)) (rcap treatment_effect_upper_95CI treatment_effect_lower_95CI time_to_treatment), $options
}

}

if "`save_results'"!=""{
save "`save_results'", replace
}

*END NEWW

// End of the condition assessing if breps requested (so graph has to be produced)
}

*NEWW
// Producing a table

if `breps'>0{
matrix results=effect0
local rownames "Effect_0"
if "`dynamic'"!="0"{
forvalue i=1/`=`dynamic''{
matrix results=results \ effect`i'
local rownames "`rownames' Effect_`i'"
}
}
if "`average_effect'"!=""&"`covariances'"!=""{
matrix results=results \ average
local rownames "`rownames' Average"
}
if "`placebo'"!="0"{
forvalue i=1/`=`placebo''{
matrix results=results \ placebo`i'
local rownames "`rownames' Placebo_`i'"
}
}
matrix colnames results  = "Estimate" "SE" "LB CI" "UB CI" "N" "Switchers"
matrix rownames results= `rownames'
noisily matlist results, title("DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic option is used, and of placebo tests of the parallel trends assumption if the placebo option is used. The estimators are robust to heterogeneous effects, and to dynamic effects if the robust_dynamic option is used.")
*RECENT NEWW
matrix b2=results[1...,1..1]
ereturn matrix estimates=b2
if "`average_effect'"!=""&"`covariances'"!=""{
matrix var2=J(`placebo'+`dynamic'+2,1,0)
forvalue i=1/`=`placebo'+`dynamic'+2'{
matrix var2[`i',1]=results[`i',2]^2
}
}
if "`average_effect'"==""|"`covariances'"==""{
matrix var2=J(`placebo'+`dynamic'+1,1,0)
forvalue i=1/`=`placebo'+`dynamic'+1'{
matrix var2[`i',1]=results[`i',2]^2
}
}
matrix rownames var2= `rownames'
ereturn matrix variances=var2
ereturn local cmd "did_multiplegt"
*END RECENT NEWW
}
*END NEWW

//
}

// End of the condition checking that not too_many_dynamic_or_placebo or too_few_bootstrap_reps
}

restore

// End of the quietly condition
}

// Answers to FAQs

*NEWW
*if N_effect_0_2!=.&did_multiplegt_check==1{
*di as text "This command does not produce a table, but all the estimators you have requested and their standard errors"
*di as text "are stored as eclass objects. Please type ereturn list to see them."
if `breps'==0{
di as text "When the breps option is not used, the command does not produce a table or a graph,"
di as text "but the estimators requested are stored as eclass objects. Type ereturn list to see them."
}
if `breps'>0{
if "`longdiff_placebo'"==""&"`dynamic'"!="0"{
di as text ""
di as text "When dynamic effects and first-difference placebos are requested, the command does"
di as text "not produce a graph, because placebos estimators are DIDs across consecutive time periods,"
di as text "while dynamic effects estimators are long-difference DIDs, so they are not really comparable."
}
}
*END NEWW
end


///////////////////////////////////////////////////////////////////
///// Program #2: does all the sanity checks before estimation ////
///////////////////////////////////////////////////////////////////

capture program drop did_multiplegt_check
program did_multiplegt_check, eclass
	version 12.0
*NEWW
	*syntax varlist(min=4 max=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) weight(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances average_effect(string)]
	syntax varlist(min=4 max=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) weight(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances average_effect longdiff_placebo robust_dynamic if_first_diff(string)]
*END NEWW
preserve	
	
// Names of temporary variables
tempvar counter

// Initializing check

scalar did_multiplegt_check=1

// Selecting sample

	if "`if'" !=""{
	keep `if'
	}
	tokenize `varlist'
	drop if `1'==.|`2'==.|`3'==.|`4'==.
	if "`controls'" !=""{
	foreach var of varlist `controls'{
	drop if `var'==.
	}
	}
	if "`cluster'" !=""{
	drop if `cluster'==.
	}
	if "`recat_treatment'" !=""{
	drop if `recat_treatment'==.
	}
	if "`weight'" !=""{
	drop if `weight'==.
	}

// Creating the Y, G, T, D variables
	
	gen outcome_XX=`1'
	gen group_XX=`2'
	egen time_XX=group(`3')
	gen treatment_XX=`4'

/*	
*NEWW
if "`if_first_diff'"!=""{
keep if `if_first_diff'
}
*END NEWW
*/

*NEWW
/*
// When the weight option is specified, the data has to be at the (g,t) level.

bys group_XX time_XX: egen `counter'=count(outcome_XX)
sum `counter'

if r(max)>1&"`weight'"!=""{
di as error"You have specified the weight option but your data is not aggregated at the group*time level, the command cannot run, aggregate your data at the group*time level before running it."
scalar did_multiplegt_check=0
}

scalar aggregated_data=0
if r(max)==1{
scalar aggregated_data=1
}
*/
*END NEWW

// Counting time periods and checking at least two time periods

sum time_XX, meanonly
if r(max)<2 {
di as error"There are less than two time periods in the data, the command cannot run."
scalar did_multiplegt_check=0
}
local max_time=r(max)

// Creating a discretized treatment even if recat_treatment option not specified

if "`recat_treatment'" !=""{
gen D_cat_XX=`recat_treatment'
}
else{
gen D_cat_XX=treatment_XX
}

// Creating groups of recategorized treatment, to ensure we have an ordered treatment with interval of 1 between consecutive values

egen d_cat_group_XX=group(D_cat_XX)

// Counting treatment values and checking at least two values

sum d_cat_group_XX, meanonly
if r(max)==r(min) {
di as error "Either the treatment variable or the recategorized treatment in the recat_treatment option takes only one value, the command cannot run."
scalar did_multiplegt_check=0
}

// Checking that the number in threshold_stable_treatment is positive

if `threshold_stable_treatment'<0{
di as error "The number in the threshold_stable_treatment option should be greater than or equal to 0."
scalar did_multiplegt_check=0
}

*NEWW
// Checking that the trends_nonparam and trends_lin options have not been jointly specified

*if "`trends_nonparam'" !=""&"`trends_lin'" !=""{
*di as error "The trends_nonparam and trends_lin options cannot be specified at the same time."
*scalar did_multiplegt_check=0
*}
*END NEWW

// Checking that number of placebos requested is admissible

if `placebo'>`max_time'-2{
di as error "The number of placebo estimates you have requested it too large: it should be at most equal to the number"
di as error "of time periods in your data minus 2."
scalar did_multiplegt_check=0
}

// Checking that number of dynamic effects requested is admissible

if `dynamic'>`max_time'-2{
di as error "The number of dynamic effects you have requested it too large: it should be at most equal to the number"
di as error "of time periods in your data minus 2."
scalar did_multiplegt_check=0
}

// Checking that number of bootstrap replications requested greater than 2

if `breps'==1{
di as error "The number of bootstrap replications should be equal to 0, or greater than 2."
scalar did_multiplegt_check=0
}

*NEWW
// Checking that if dynamic effects requested, robust_dynamic also requested
if "`robust_dynamic'"==""&`dynamic'!=0 {
*END NEWW
di as error "If you request the computation of some dynamic effects," 
di as error "you need to request that your estimators be robust to dynamic effects."
scalar did_multiplegt_check=0
}

*END NEWW


// Checking that if average_effect option requested, number of dynamic effects at least one

*NEWW
*if "`average_effect'"!=""&("`covariances'"==""|`dynamic'==0) {
if "`average_effect'"!=""&`dynamic'==0 {
*END NEWW
di as error "If you request the average_effect option," 
di as error "you need to request that at least one dynamic effect be computed."
scalar did_multiplegt_check=0
}

*NEWW
// Checking that if longdiff_placebo option requested, robust_dynamic also requested

if "`longdiff_placebo'"!=""&"`robust_dynamic'"=="" {
di as error "If you request the longdiff_placebo option, you also need to request the robust_dynamic option." 
scalar did_multiplegt_check=0
}

// Checking that if longdiff_placebo and dynamic options requested, number of placebos lower than number of dynamic

if "`longdiff_placebo'"!=""&"`dynamic'"!="0"&`placebo'>`dynamic'{
di as error "When the longdiff_placebo and dynamic options are requested, the number" 
di as error "of placebos requested cannot be larger than the number of dynamic effects." 
scalar did_multiplegt_check=0
}

*END NEWW

restore

end

/////////////////////////////////////////////////////////
///// Program #3: Runs and boostraps did_multiplegt_estim
/////////////////////////////////////////////////////////


capture program drop did_multiplegt_results
program did_multiplegt_results, eclass
	version 12.0
*NEWW	
	*syntax varlist(min=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) counter(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances]
	syntax varlist(min=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) counter(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances switchers(string) longdiff_placebo count_switchers_tot count_switchers_contr robust_dynamic discount(real 1) seed(integer 0)]
*END NEWW
	
// If computation of standard errors requested, bootstrap did_multiplegt_estim

if `breps'>0 {

tempvar group_bsample

// Initializing the too many controls scalar

scalar too_many_controls=0
 
forvalue i=1/`breps'{

preserve
*NEWW
if `seed'!=0{
set seed `=`seed'+`i''
}
*END NEWW
bsample, cluster(`cluster')

//Indicate that program will run bootstrap replications

local bootstrap_rep=1

*NEWW
*if "`if'" !=""{
*did_multiplegt_estim `varlist' `if', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
*}
*if "`if'" ==""{
*did_multiplegt_estim `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
did_multiplegt_estim `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep') switchers(`switchers') `longdiff_placebo' `count_switchers_tot' `count_switchers_contr' `robust_dynamic' discount(`discount')
*}
*END NEWW

// Put results into a matrix 

matrix bootstrap_`i'=effect_0_2
forvalue j=1/`dynamic'{
matrix bootstrap_`i'=bootstrap_`i',effect_`j'_2
}
forvalue j=1/`placebo'{
matrix bootstrap_`i'=bootstrap_`i',placebo_`j'_2
}

restore

// End of the loop on number of bootstrap replications
}

// Putting the matrix with all bootstrap reps together

matrix bootstrap=bootstrap_1
forvalue i=2/`breps'{
matrix bootstrap=bootstrap\ bootstrap_`i'
}

// Error message if too many controls

if too_many_controls==1{
di as error "In some bootstrap replications, the command had to run regressions with strictly more" 
di as error "control variables than the sample size, so the controls could not all be accounted for." 
di as error "If you want to solve this problem, you may reduce the number of control"
di as error "variables. You may also use the recat_treatment option to discretize your treatment."
di as error "Finally, you could reduce the number of placebos and/or dynamic effects requested."
}

// End of if condition assessing if bootstrap reps requested 
}

// Run did_multiplegt_estim to get estimates and number of observations used 

preserve

//Indicate that program will run main estimation

local bootstrap_rep=0

// Initializing the too many controls scalar

scalar too_many_controls=0

*NEWW
*if "`if'" !=""{
*did_multiplegt_estim `varlist' `if', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep') switchers(`switchers') `longdiff_placebo' `count_switchers_tot' `count_switchers_contr' `robust_dynamic' discount(`discount')
*}
*if "`if'" ==""{
*did_multiplegt_estim `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
did_multiplegt_estim `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep') switchers(`switchers') `longdiff_placebo' `count_switchers_tot' `count_switchers_contr' `robust_dynamic' discount(`discount')
*}
*END NEWW

// Error message if too many controls

if too_many_controls==1{
di as error "In the main estimation, the command had to run regressions with strictly more" 
di as error "control variables than the sample size, so the controls could not all be accounted for." 
di as error "If you want to solve this problem, you may reduce the number of control"
di as error "variables. You may also use the recat_treatment option to discretize your treatment."
di as error "Finally, you could reduce the number of placebos and/or dynamic effects requested."
}

restore

end

////////////////////////////////////////////////////////////////////////////////
///// Program #4: performs outcome change residualisation, and requests ////////
///// computation of all point estimates asked by user /////////////////////////
////////////////////////////////////////////////////////////////////////////////

capture program drop did_multiplegt_estim
program did_multiplegt_estim, eclass
	version 12.0
*NEWW
	*syntax varlist(min=4 numeric) [if] [in] [, THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) counter(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) bootstrap_rep(integer 0)]
	syntax varlist(min=4 numeric) [if] [in] [, THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) counter(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) bootstrap_rep(integer 0) switchers(string) longdiff_placebo count_switchers_tot count_switchers_contr robust_dynamic discount(real 1)]
*END NEWW

*NEWW: the residualization wrt to trends_lin and/or controls moves here. + a few changes inside residualization.

tempvar tag_obs group_incl

if `bootstrap_rep'==0{
gen tag_switchers_contr_XX=0
}
	
if "`trends_lin'" !=""|"`controls'" !=""{

sum d_cat_group_XX, meanonly
local D_min=r(min)
local D_max=r(max)

forvalue d=`=`D_min''/`=`D_max'' {

global cond_increase "abs(diff_stag_d_XX)>`threshold_stable_treatment'&increase_d_XX==1&lag_d_cat_group_XX==`d'&diff_stag_d_XX!=."
global cond_stable "abs(diff_stag_d_XX)<=`threshold_stable_treatment'&ever_change_d_XX==0&lag_d_cat_group_XX==`d'"
global cond_decrease "abs(diff_stag_d_XX)>`threshold_stable_treatment'&increase_d_XX==0&lag_d_cat_group_XX==`d'&diff_stag_d_XX!=."

*RECENT NEWW
// Counting number of units in each supergroup
sum diff_y_XX if $cond_increase, meanonly
scalar n_increase=r(N)
sum diff_y_XX if $cond_stable, meanonly
scalar n_stable=r(N)
sum diff_y_XX if $cond_decrease, meanonly
scalar n_decrease=r(N)

// Assessing if the residualization needs to be done for that treatment value
if ("`switchers'"==""&n_stable>0&(n_increase>0|n_decrease>0))|("`switchers'"=="in"&n_stable>0&n_increase>0)|("`switchers'"=="out"&n_stable>0&n_decrease>0) {
*END RECENT NEWW

sum diff_y_XX if $cond_stable, meanonly

// Assessing if too many controls
if r(N)>=1{
scalar too_many_controls_temp=(r(N)<wordcount("`controls'"))
scalar too_many_controls=max(too_many_controls,too_many_controls_temp)
}

///////////////// Regression of diff_y on controls and FEs of trends_lin, and storing coefficients

cap drop FE*

if "`trends_lin'"!=""{

capture $noisily reghdfe diff_y_XX `controls' [aweight=`counter'] if $cond_stable, absorb(FE1=`trends_lin' FE2=time_XX) resid keepsingletons

}

if "`trends_lin'"==""&"`trends_nonparam'"==""&"`controls'"!=""{

capture $noisily reghdfe diff_y_XX `controls' [aweight=`counter'] if $cond_stable, absorb(FE1=time_XX) resid keepsingletons

}

if "`trends_nonparam'"!=""&"`controls'"!=""{

capture $noisily reghdfe diff_y_XX `controls' [aweight=`counter'] if $cond_stable, absorb(FE1=trends_var_XX) resid keepsingletons

}

capture matrix B = e(b)

// Patching if not enough observations in this regression
if _rc!=301{

if "`trends_lin'"!=""{

gen `tag_obs'=e(sample)
bys `trends_lin': egen `group_incl'=max(`tag_obs')
fcollapse (mean) FE_1=FE1, by(`trends_lin') merge
sum FE_1 [aweight=`counter'] if lag_d_cat_group_XX==`d'&`group_incl'==1
replace FE_1=r(mean) if lag_d_cat_group_XX==`d'&`group_incl'==0 
if `bootstrap_rep'==0{
replace tag_switchers_contr_XX=1 if `group_incl'==1&($cond_increase | $cond_decrease) 
}
}

// Creating variables with controls coefficients
local j = 0
foreach var of local controls {
local j = `j' + 1
gen coeff`j' = B[1,`j']
}

///////////////////// Residualizing outcome changes

// Current outcome FD, for instantaneous effect estimation
if "`trends_lin'"!=""{
replace diff_y_XX=diff_y_XX-FE_1 if lag_d_cat_group_XX==`d'
}

local j=0
foreach var of local controls{
local j=`j'+1
replace diff_y_XX=diff_y_XX-coeff`j'*ZZ_cont`j' if lag_d_cat_group_XX==`d'
}

// Lagged outcome FD, for FD placebo estimation
if "`placebo'"!="0"&"`longdiff_placebo'"==""{

forvalue i=1/`=`placebo''{

if "`trends_lin'"!=""{
replace diff_y_lag`i'_XX=diff_y_lag`i'_XX-FE_1 if lag_d_cat_group_XX==`d'
}

local j=0
foreach var of local controls{
local j=`j'+1
replace diff_y_lag`i'_XX=diff_y_lag`i'_XX-coeff`j'*ZZ_cont_lag`i'_`j' if lag_d_cat_group_XX==`d'
}

}

}

// Lagged outcome long diff, for long diff placebo estimation
if "`placebo'"!="0"&"`longdiff_placebo'"!=""{

forvalue i=1/`=`placebo''{

if "`trends_lin'"!=""{
replace ldiff_y_`i'_lag_XX=ldiff_y_`i'_lag_XX-FE_1*`i' if lag_d_cat_group_XX==`d'
}

local j=0
foreach var of local controls{
local j=`j'+1
replace ldiff_y_`i'_lag_XX=ldiff_y_`i'_lag_XX-coeff`j'*ZZ_cont_ldiff_`i'_lag_`j' if lag_d_cat_group_XX==`d'
}

}

}

// Lead outcome long diff, for dynamic effect estimation
if "`dynamic'"!="0"{

forvalue i=1/`=`dynamic''{

if "`trends_lin'"!=""{
replace ldiff_y_for`i'_XX=ldiff_y_for`i'_XX-FE_1*(`i'+1) if lag_d_cat_group_XX==`d'
}

local j=0
foreach var of local controls{
local j=`j'+1
replace ldiff_y_for`i'_XX=ldiff_y_for`i'_XX-coeff`j'*ZZ_cont_ldiff_for`i'_`j' if lag_d_cat_group_XX==`d'
}

}

}

cap drop `group_incl' `tag_obs'
cap drop FE*
cap drop coeff*

/// End of patch if not enough observations in the regression with controls
}

*RECENT NEWW
/// End of condition assessing if residualization needed for that treatment value
}
*END RECENT NEWW

// End of the loop over values of D_cat
}

// End of the if condition assessing if trends_lin or controls requested
}

*END NEWW

// Counting time periods

sum time_XX, meanonly
local max_time=r(max)

// Estimating the instantaneous effect

*Running did_multiplegt_core

*NEWW
*did_multiplegt_core, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(0) counter_dynamic(0) bootstrap_rep(`bootstrap_rep')
did_multiplegt_core, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(0) counter_dynamic(0) bootstrap_rep(`bootstrap_rep') switchers(`switchers') `robust_dynamic' discount(`discount') trends_lin(`trends_lin')
*END NEWW

*Collecting point estimate and number of observations

scalar effect_0_2=effect_XX
scalar N_effect_0_2=N_effect
scalar N_switchers_effect_0_2=N_switchers
if "`count_switchers_tot'"!=""{
scalar N_switchers_effect_0_tot_2=N_switchers_tot2
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_effect_0_contr_2=N_switchers_contr2
} 
scalar denom_DID_ell_0=denom_DID_ell_XX
scalar denom_delta_0=denom_XX
*END NEWW

// If first difference placebos requested, estimate them and number of observations used in that estimation

*NEWW
*if "`placebo'"!="0"{
if "`placebo'"!="0"&"`longdiff_placebo'"==""{
*END NEWW

tempvar cond_placebo  
gen `cond_placebo'=1

*Looping over the number of placebos requested

forvalue i=1/`=`placebo''{

*Replacing FD of outcome by lagged FD of outcome, FD of controls by lagged FD of controls, and excluding from placebo observations whose lagged FD of treatment non 0. 

// Note: the line below is superfluous if the robust_dynamic option is specified, because then 
// only (g,t)s with diff_stag_d_XX>`threshold_stable_treatment', meaning those changing treatment for the first time at t satisfy "cond_increase_t" and "cond_decrease_t" anyways.
// But that line plays a role if the robust_dynamic option is not specified so it is important to keep it. 
replace `cond_placebo'=0 if abs(diff_d_lag`i'_XX)>`threshold_stable_treatment'

preserve

replace diff_y_XX=diff_y_lag`i'_XX

if "`controls'" !=""{
local j=0
foreach var of local controls{
local j=`j'+1
replace `var'=ZZ_cont_lag`i'_`j'
}
}

*If no observation satisfy `cond_placebo'==1, set N_placebo_`i'_2 to 0

sum diff_y_XX if `cond_placebo'==1

if r(N)==0{

scalar N_placebo_`i'_2=.
*NEWW
scalar placebo_`i'_2=.
scalar N_switchers_placebo_`i'_2=.
if "`count_switchers_tot'"!=""{
scalar N_switchers_placebo_`i'_tot_2=.
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_placebo_`i'_contr_2=.
} 
*END NEWW
}

*Otherwise, run did_multiplegt_core

else{

*NEWW
*did_multiplegt_core if `cond_placebo'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(`i') counter_dynamic(0) bootstrap_rep(`bootstrap_rep')
did_multiplegt_core if `cond_placebo'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(`i') counter_dynamic(0) bootstrap_rep(`bootstrap_rep') switchers(`switchers') `robust_dynamic' discount(`discount') trends_lin(`trends_lin')
*END NEWW

*Collecting point estimate and number of observations

scalar placebo_`i'_2=effect_XX
scalar N_placebo_`i'_2=N_effect
*NEWW
scalar N_switchers_placebo_`i'_2=N_switchers
if "`count_switchers_tot'"!=""{
scalar N_switchers_placebo_`i'_tot_2=N_switchers_tot2
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_placebo_`i'_contr_2=N_switchers_contr2
} 
*END NEWW

}

restore

*End of the loop on the number of placebos
}

*End of the condition assessing if the computation of placebos was requested by the user
}

*NEWW

// If long-difference placebos requested, estimate them and number of observations used in that estimation

if "`placebo'"!="0"&"`longdiff_placebo'"!=""{

tempvar cond_placebo
gen `cond_placebo'=1

*Looping over the number of placebos requested

forvalue i=1/`=`placebo''{

*Replacing FD of outcome by long diff of outcome, and creating variable to exclude from placebo observations whose lead FD of treatment non 0. 

if `i'>1{
replace `cond_placebo'=0 if abs(diff_stag_d_for`=`i'-1'_XX)>`threshold_stable_treatment'
}

preserve

replace diff_y_XX=ldiff_y_`i'_lag_XX
*RECENT NEWW
if `i'>1{
replace `counter'=counter_F`=`i'-1'_XX
}
*END RECENT NEWW

if "`controls'" !=""{
local j=0
foreach var of local controls{
local j=`j'+1
replace `var'=ZZ_cont_ldiff_`i'_lag_`j'
}
}

*If no observation satisfy `cond_placebo'==1, set N_placebo_`i'_2 to 0

sum diff_y_XX if `cond_placebo'==1

if r(N)==0{
scalar N_placebo_`i'_2=.
scalar placebo_`i'_2=.
scalar N_switchers_placebo_`i'_2=.
if "`count_switchers_tot'"!=""{
scalar N_switchers_placebo_`i'_tot_2=.
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_placebo_`i'_contr_2=.
} 
}

*Otherwise, run did_multiplegt_core

else{

did_multiplegt_core if `cond_placebo'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(`i') counter_dynamic(0) bootstrap_rep(`bootstrap_rep') switchers(`switchers') `robust_dynamic' discount(`discount') trends_lin(`trends_lin')

*Collecting point estimate and number of observations

scalar placebo_`i'_2=-effect_XX
scalar N_placebo_`i'_2=N_effect
scalar N_switchers_placebo_`i'_2=N_switchers
if "`count_switchers_tot'"!=""{
scalar N_switchers_placebo_`i'_tot_2=N_switchers_tot2
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_placebo_`i'_contr_2=N_switchers_contr2
} 
}

restore

*End of the loop on the number of placebos
}

*End of the condition assessing if the computation of long-diff placebos was requested by the user
}

*END NEWW

// If dynamic effects requested, estimate them and number of observations used in that estimation

if "`dynamic'"!="0"{

tempvar cond_dynamic
gen `cond_dynamic'=1

*Looping over the number of placebos requested

forvalue i=1/`=`dynamic''{

*Replacing FD of outcome by long diff of outcome, and creating variable to exclude from placebo observations whose lead FD of treatment non 0. 

*NEWW
*replace `cond_dynamic'=0 if abs(diff_d_for`i'_XX)>`threshold_stable_treatment'
replace `cond_dynamic'=0 if abs(diff_stag_d_for`i'_XX)>`threshold_stable_treatment'
*END NEWW

preserve

replace diff_y_XX=ldiff_y_for`i'_XX
*RECENT NEWW
replace `counter'=counter_F`i'_XX
*END RECENT NEWW

*NEWW
// Note: this line ensures that in Program #5 below, when we compute the denominators (denom_XX), 
// we have in the denominator D_{g,t+\ell}-d, which is also D_{g,t+\ell}-D_{g,t-1} for a group leaving treatment d for the first time in t
replace diff_d_XX=ldiff_d_for`i'_XX
*END NEWW 

if "`controls'" !=""{
local j=0
foreach var of local controls{
local j=`j'+1
replace `var'=ZZ_cont_ldiff_for`i'_`j'
}
}

*If no observation satisfy `cond_dynamic'==1, set N_effect_`i'_2 to 0

sum diff_y_XX if `cond_dynamic'==1

if r(N)==0{

scalar N_effect_`i'_2=.
scalar N_switchers_effect_`i'_2=.
*NEWW
scalar effect_`i'_2=.
if "`count_switchers_tot'"!=""{
scalar N_switchers_effect_`i'_tot_2=.
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_effect_`i'_contr_2=.
} 
*END NEWW
}

*Otherwise, run did_multiplegt_core

else{

*NEWW
*did_multiplegt_core if `cond_dynamic'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(0) counter_dynamic(`i') bootstrap_rep(`bootstrap_rep')
did_multiplegt_core if `cond_dynamic'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(0) counter_dynamic(`i') bootstrap_rep(`bootstrap_rep') switchers(`switchers') `robust_dynamic' discount(`discount') trends_lin(`trends_lin')
*END NEWW

*Collecting point estimate and number of observations

scalar effect_`i'_2=effect_XX
scalar N_effect_`i'_2=N_effect
scalar N_switchers_effect_`i'_2=N_switchers
*NEWW
if "`count_switchers_tot'"!=""{
scalar N_switchers_effect_`i'_tot_2=N_switchers_tot2
}
if "`count_switchers_contr'"!=""&("`trends_lin'"!=""|"`trends_nonparam'"!=""){
scalar N_switchers_effect_`i'_contr_2=N_switchers_contr2
} 
scalar denom_DID_ell_`i'=denom_DID_ell_XX
scalar denom_delta_`i'=denom_XX
*END NEWW

}

restore

drop diff_stag_d_for`i'_XX 

*End of the loop on the number of dynamic effects
}

*End of the condition assessing if the computation of dynamic effects was requested by the user
}

end

////////////////////////////////////////////////////////////////////////////////
///// Program #5: performs computation of all individual point estimates ///////
////////////////////////////////////////////////////////////////////////////////

capture program drop did_multiplegt_core
program did_multiplegt_core
	version 12.0
*NEWW
	*syntax [if] [in] [, THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) d_cat_group(varlist numeric) lag_d_cat_group(varlist numeric) diff_d(varlist numeric) diff_y(varlist numeric) counter(varlist numeric) time(varlist numeric) group_int(varlist numeric) max_time(integer 0) counter_placebo(integer 0) counter_dynamic(integer 0) bootstrap_rep(integer 0)]
	syntax [if] [in] [, THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) d_cat_group(varlist numeric) lag_d_cat_group(varlist numeric) diff_d(varlist numeric) diff_y(varlist numeric) counter(varlist numeric) time(varlist numeric) group_int(varlist numeric) max_time(integer 0) counter_placebo(integer 0) counter_dynamic(integer 0) bootstrap_rep(integer 0) switchers(string) robust_dynamic discount(real 1) trends_lin(varlist numeric)]
*END NEWW

tempvar diff_y_res1 diff_y_res2 group_incl treatment_dummy tag_obs tag_switchers counter_tot counter_switchers tag_switchers_tot counter_switchers_tot tag_switchers_contr counter_switchers_contr

preserve

// Selecting the sample

	if "`if'" !=""{
	keep `if'
	}
	
// Drop if diff_y_XX missing, to avoid that those observations are used in estimation

drop if diff_y_XX==.
	
// Creating residualized first diff outcome if trends_nonparam specified in estimation

*NEWW
*if "`controls'" !=""|"`trends_nonparam'" !=""|"`trends_lin'" !=""{
if "`trends_nonparam'" !=""{
*END NEWW

sum d_cat_group_XX, meanonly
local D_min=r(min)
local D_max=r(max)

*NEWW
*$noisily di "residualizing outcome"
*END NEWW

forvalue d=`=`D_min''/`=`D_max'' {

*NEWW
*global cond_stable "abs(diff_d_XX)<=`threshold_stable_treatment'&lag_d_cat_group_XX==`d'"
// Note: see note below on the cond_increase_t cond_stable_t etc. conditions to understand the change
global cond_increase "abs(diff_stag_d_XX)>`threshold_stable_treatment'&increase_d_XX==1&lag_d_cat_group_XX==`d'&diff_stag_d_XX!=."
global cond_stable "abs(diff_stag_d_XX)<=`threshold_stable_treatment'&ever_change_d_XX==0&lag_d_cat_group_XX==`d'"
global cond_decrease "abs(diff_stag_d_XX)>`threshold_stable_treatment'&increase_d_XX==0&lag_d_cat_group_XX==`d'&diff_stag_d_XX!=."
*END NEWW

sum diff_y_XX if $cond_stable, meanonly

*NEWW
// Assessing if too many controls
*if r(N)<=wordcount("`controls'"){
*scalar too_many_controls=1
*}
// We do the residualization only if there are groups with a stable treatment equal to d between two dates
*else {
*if "`trends_nonparam'"!=""{
*END NEWW

/////////////// Regression of diff_y on time FEs interacted with trends_nonparam variable, and computation of residuals

cap drop FE*
*NEWW
*capture $noisily reghdfe diff_y_XX `controls' [aweight=`counter'] if $cond_stable, absorb(FE1=trends_var_XX) resid keepsingletons
capture $noisily reghdfe diff_y_XX  [aweight=`counter'] if $cond_stable, absorb(FE1=trends_var_XX) resid keepsingletons
*END NEWW

*NEWW
// Patching if not enough observations in this regression
capture matrix B = e(b)
if _rc!=301{
*END NEWW

// Tagging units with a value of `trends_nonparam' that does not appear in the regression sample
// Example: In a county-level application, we may want to allow for state-year effects.
// But we may have a county going from 2 to 3 units of treatment between two years, but such that no county in that state remains at 2 units between those two years.
// Then, that county-year's state-year effect is dropped from the regression, so we cannot use that regression to compute that county-year's residual.
gen `tag_obs'=e(sample)
bys trends_var_XX: egen `group_incl'=max(`tag_obs')

fcollapse (mean) FE=FE1 , by(trends_var_XX) merge

gen `diff_y_res1'  = diff_y_XX - FE

*NEWW
/*
// 2nd step of residual construction: residual(outcome - FE) - controls*beta
local j = 0
foreach var of local controls {
local j = `j' + 1
gen coeff`j' = B[1,`j']
replace `diff_y_res1' = `diff_y_res1'  - coeff`j'*`var'
}
*/
*END NEWW

gen constant = B[1,1]
replace `diff_y_res1' = `diff_y_res1' - constant

cap drop FE constant

// Regression of diff_y on controls and time FEs, and computation of residuals 
$noisily reg diff_y_XX i.time_XX [aweight=`counter'] if $cond_stable, $no_header_no_table
predict `diff_y_res2', r

// Replacing diff_y_XX by residual from 1st regression, for observations whose group was included in first regression, and by residual from 2nd regression for other observations
replace diff_y_XX=`diff_y_res1' if lag_d_cat_group_XX==`d'&`group_incl'==1
replace diff_y_XX=`diff_y_res2' if lag_d_cat_group_XX==`d'&`group_incl'==0

*NEWW
if `bootstrap_rep'==0{
replace tag_switchers_contr_XX=1 if `group_incl'==1&($cond_increase | $cond_decrease) 
}
*END NEWW

drop `diff_y_res1' `diff_y_res2' `group_incl' `tag_obs'

*NEWW
// End of if condition in which one enters if more than 1 observation
}
*END NEWW

*NEWW
*}
*END NEWW


*NEWW
// End of the if condition assessing if there are groups with a stable value of the treatment equal to d between two dates
*}
*END NEWW

// End of the loop over values of D_cat
}

// End of the if condition assessing if trends_nonparam included in estimation
}
 
// Treatment effect

// Initializing estimate, weight, and variable to count observations used in estimation
scalar effect_XX=0
scalar N_effect =0
scalar N_switchers=0
*NEWW
scalar N_switchers_tot2=0
scalar N_switchers_contr2=0
*END NEWW
scalar denom_XX=0
scalar denom_DID_ell_XX=0
gen `tag_obs'=0
gen `tag_switchers'=0
gen `tag_switchers_tot'=0

$noisily di "Computing DIDM"

// Looping over time periods
forvalue t=`=`counter_placebo'+2'/`=`max_time'-`counter_dynamic''{

// Determining the min and max value of group of treatment at t-1

sum lag_d_cat_group_XX if time_XX==`t', meanonly

local D_min=r(min)
local D_max=r(max)



// Ensuring that there are observations with non missing lagged treatment

if `D_min'!=.&`D_max'!=.{

// Looping over possible values of lag_D at time t
forvalue d=`=`D_min''/`=`D_max'' {

// Defining conditions for groups where treatment increased/remained stable/decreased between t-1 and t

*NEWW

*global cond_increase_t "diff_d_XX>`threshold_stable_treatment'&lag_d_cat_group_XX==`d'&time_XX==`t'&diff_d_XX!=."
*global cond_stable_t "abs(diff_d_XX)<=`threshold_stable_treatment'&lag_d_cat_group_XX==`d'&time_XX==`t'"
*global cond_decrease_t "diff_d_XX<-`threshold_stable_treatment'&lag_d_cat_group_XX==`d'&time_XX==`t'"

// Note: If robust_dynamic option specified, 
// cond_increase_t=those:  
// 1) whose treatment changes for first time at t (t=t-\ell in paper): abs(diff_stag_d_XX)>`threshold_stable_treatment'
// 2) whose treatment cost is higher than if they had kept status quo treatment: increase_d_XX==1
// Same thing for cond_decrease_t
// cond_stable_t= those: 
// 1) whose treatment does not change at t, 
// 2) whose treatment has not changed before t (was implied by 1 in staggered designs, not the case anymore, hence the addition of ever_change_d_XX==0)
// those two conditions are sufficient to select the right control groups when we estimate the instantaneous treatment effect, or first difference placebos,
// but if we are running this to estimate a dynamic effect at time t+\ell we need a third condition: 
// 3) the ``if `cond_dynamic'==1'' condition when we call the command in program #4 above ensures we do not have obs whose treatment changed for the first time somehwere between t+1 and t+\ell. 
// If robust_dynamic option not specified, ever_change_d_XX==0, diff_stag_d_XX=diff_d_XX, and increase_d_XX=(diff_d_XX>0) so the new conditions below are equal to the old ones commented above.
 
global cond_increase_t "abs(diff_stag_d_XX)>`threshold_stable_treatment'&increase_d_XX==1&lag_d_cat_group_XX==`d'&time_XX==`t'&diff_stag_d_XX!=."
global cond_stable_t "abs(diff_stag_d_XX)<=`threshold_stable_treatment'&ever_change_d_XX==0&lag_d_cat_group_XX==`d'&time_XX==`t'"
global cond_decrease_t "abs(diff_stag_d_XX)>`threshold_stable_treatment'&increase_d_XX==0&lag_d_cat_group_XX==`d'&time_XX==`t'&diff_stag_d_XX!=."

*END NEWW

// Counting number of units in each supergroup
sum d_cat_group_XX if $cond_increase_t, meanonly
scalar n_increase=r(N)
sum d_cat_group_XX if $cond_stable_t, meanonly
scalar n_stable=r(N)
sum d_cat_group_XX if $cond_decrease_t, meanonly
scalar n_decrease=r(N)

// If there are units whose treatment increased and units whose treatment remained stable, estimate corresponding DID, 
// increment point estimate and weight, and tag observations used in estimation

*NEWW
if "`switchers'" !="out"{
if `bootstrap_rep'==0{
replace `tag_switchers_tot'=1 if $cond_increase_t
}
*END NEWW
if n_increase*n_stable>0 {
gen `treatment_dummy' =($cond_increase_t)

if `bootstrap_rep'==0{
replace `tag_obs'=1 if (($cond_increase_t)|($cond_stable_t))
replace `tag_switchers'=1 if $cond_increase_t
}

$noisily reg diff_y_XX `treatment_dummy' [aweight=`counter'] if ($cond_increase_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_increase_t, meanonly
*NEWW
*scalar effect_XX=effect_XX+_b[`treatment_dummy']*r(N)*r(mean)
scalar effect_XX=effect_XX+_b[`treatment_dummy']*r(N)*r(mean)*(`discount'^`t')
*END NEWW
$noisily reg diff_d_XX `treatment_dummy' [aweight=`counter'] if ($cond_increase_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_increase_t, meanonly
*NEWW
*scalar denom_XX=denom_XX+_b[`treatment_dummy']*r(N)*r(mean)
scalar denom_XX=denom_XX+_b[`treatment_dummy']*r(N)*r(mean)*(`discount'^`t')
scalar denom_DID_ell_XX=denom_DID_ell_XX+r(N)*r(mean)*(`discount'^`t')
*END NEWW
drop `treatment_dummy' 
}
*NEWW
}
*END NEWW

// If there are units whose treatment decreased and units whose treatment remained stable, estimate corresponding DID, 
// increment point estimate and weight, and tag observations used in estimation

*NEWW
if "`switchers'"!="in"{
if `bootstrap_rep'==0{
replace `tag_switchers_tot'=1 if $cond_decrease_t
}
*END NEWW
if n_decrease*n_stable>0 {
gen `treatment_dummy' =($cond_decrease_t)

if `bootstrap_rep'==0{
replace `tag_obs'=1 if (($cond_decrease_t)|($cond_stable_t))
replace `tag_switchers'=1 if $cond_decrease_t
}

$noisily reg diff_y_XX `treatment_dummy' [aweight=`counter'] if ($cond_decrease_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_decrease_t, meanonly
*NEWW
*scalar effect_XX=effect_XX-_b[`treatment_dummy']*r(N)*r(mean)
scalar effect_XX=effect_XX-_b[`treatment_dummy']*r(N)*r(mean)*(`discount'^`t')
*END NEWW
$noisily reg diff_d_XX `treatment_dummy' [aweight=`counter'] if ($cond_decrease_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_decrease_t, meanonly
*NEWW
*scalar denom_XX=denom_XX-_b[`treatment_dummy']*r(N)*r(mean)
scalar denom_XX=denom_XX-_b[`treatment_dummy']*r(N)*r(mean)*(`discount'^`t')
scalar denom_DID_ell_XX=denom_DID_ell_XX+r(N)*r(mean)*(`discount'^`t')
*END NEWW
drop `treatment_dummy' 
}
*NEWW
}
*END NEWW

// End of loop on recat treatment values at t-1 
}

// End of condition ensuring that there are observations with non missing lagged treatment
}

// End of loop on time
}

*NEWW
if "`robust_dynamic'"==""{
*END NEWW
scalar effect_XX=effect_XX/denom_XX
*NEWW
}
*END NEWW

*NEWW
if "`robust_dynamic'"!=""{
scalar effect_XX=effect_XX/denom_DID_ell_XX
}
*END NEWW

if `bootstrap_rep'==0{
egen `counter_tot'=total(`counter') if `tag_obs'==1
sum `counter_tot', meanonly
scalar N_effect=r(mean)
egen `counter_switchers'=total(`counter') if `tag_switchers'==1
sum `counter_switchers', meanonly
scalar N_switchers=r(mean)
egen `counter_switchers_tot'=total(`counter') if `tag_switchers_tot'==1
sum `counter_switchers_tot', meanonly
scalar N_switchers_tot2=r(mean)
egen `counter_switchers_contr'=total(`counter') if tag_switchers_contr_XX==1&`tag_switchers'==1
sum `counter_switchers_contr', meanonly
scalar N_switchers_contr2=r(mean)
}

restore

end
