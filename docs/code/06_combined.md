---
layout: default
title: All estimators
parent: Stata code
nav_order: 10
mathjax: true
image: "../../../assets/images/DiD.png"
---

# All estimators
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Comparing the estimators

This example follows the [five estimators](https://github.com/borusyak/did_imputation/blob/main/five_estimators_example.png) code that utilizes the `event_plot` command. In this example, we will use the same code structure we have been using in the individual sections above. So let's get started.

## Step 1: Create all the variables for all the DiD packages

```applescript
clear

local units = 30
local start = 1
local end 	= 100

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen time  = seq(), f(`start') t(`end') 	

sort  id t
xtset id t

gen Y 	   		= 0		// outcome variable	
gen D 	   		= 0		// intervention variable
gen cohort      = .  	// treatment cohort
gen effect      = .		// treatment effect size
gen first_treat = .		// when the treatment happens for each cohort
gen rel_time	= .     // time - first_treat


set seed 20211222


// determine the number of cohorts and assign them to IDs
levelsof id, local(lvls)
foreach x of local lvls {
	local chrt = runiformint(0,2)	
	replace cohort = `chrt' if id==`x'
}


// for each cohort determine the timing and treatment effect
levelsof cohort, local(lvls)  
foreach x of local lvls {
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
			
	local timing = runiformint(`start' + 5,`end' + 100)	// 
	replace first_treat = `timing' if cohort==`x'
	replace first_treat = . if first_treat > `end'
		replace D = 1 if cohort==`x' & t>= `timing' 
}


replace rel_time = t - first_treat   // relative time
replace Y = cond(D==1, effect, 0) + (rnormal() / 2)  // treatment effect  // id + t +   * rel_time



// derive the various variables for various estimators

	gen never_treat = first_treat==.  // never treated group

	sum first_treat
	gen last_cohort = first_treat==r(max) // last treated 

	gen gvar = first_treat
	recode gvar (. = 0)   

	
	summ rel_time
	local relmin = abs(r(min))
	local relmax = abs(r(max))

	// leads
	cap drop F_*
	forval x = 1/`relmin' {  // drop the first lead
		gen     F_`x' = rel_time == -`x'
		replace F_`x' = 0 if never_treat==1
	}

	
	//lags
	cap drop L_*
	forval x = 0/`relmax' {
		gen     L_`x' = rel_time ==  `x'
		replace L_`x' = 0 if never_treat==1
	}
	
	ren F_1 ref  // reference year
	

  
```

This gives us the same graph we have been using for all our examples:

```applescript
xtline Y, overlay legend(off)
```

<img src="../../../assets/images/test_data.png" height="300">


## Step 2: Run the packages and store the results



```applescript
************
*** TWFE ***
************

reghdfe Y L_* F_*, absorb(id t) cluster(i)

estimates store twfe 

*************
*** csdid ***
*************

csdid Y, ivar(id) time(t) gvar(gvar) notyet

estat event, window(-10 10) estore(csdd) 

***********************
*** did_imputation  ***
***********************

did_imputation Y i t first_treat, horizons(0/10) pretrend(10) minn(0) 

estimates store didimp	
	
***********************
*** did_multiplegt  ***
***********************

did_multiplegt Y id t D, robust_dynamic dynamic(10) placebo(10) breps(2) cluster(id)

matrix didmgt_b = e(estimates) 
matrix didmgt_v = e(variances)

*****************************
***  eventstudyinteract   ***
*****************************

eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)	

matrix evtstint_b = e(b_iw) 
matrix evtstint_v = e(V_iw)

*****************************		
*** did2s (Gardner 2021)  ***
*****************************

did2s Y, first_stage(id t) second_stage(F_* L_*) treatment(D) cluster(id)

matrix did2s_b = e(b)
matrix did2s_v = e(V)

******************
*** stackedev  ***
******************

	
stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(never_treat) unit_fe(id) clust_unit(id)
	
matrix stackedev_b = e(b)
matrix stackedev_v = e(V)	
```


## Step 3: Put all the estimators together

Here we also make use of the colorpalettes package (`ssc install palettes, replace` and `ssc install colrspace, replace`) to control the color.

```applescript
colorpalette tableau, nograph	

event_plot 	  twfe	csdd 	bjs 	dcdh_b#dcdh_v 	sa_b#sa_v 	stackedev_b#stackedev_v	did2s_b#did2s_v, 	///
	stub_lag( L_# 	Tp# 	tau# 	Effect_#  		L_#			L_#  					L_# 		) 		///
	stub_lead(F_# 	Tm# 	pre# 	Placebo_#   	F_#			F_# 					F_# 		)		///
		together perturb(-0.30(0.10)0.30) trimlead(10) trimlag(10) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  														///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 		lag_ci_opt1(color(black)	 lw(0.1)) 	///
			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) 	lag_ci_opt2(color("`r(p1)'") lw(0.1)) 	///
			lag_opt3(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) 	lag_ci_opt3(color("`r(p2)'") lw(0.1)) 	///
			lag_opt4(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) 	lag_ci_opt4(color("`r(p3)'") lw(0.1)) 	///
			lag_opt5(msymbol(Sh)  msize(1.2) mlwidth(0.3) color("`r(p4)'")) 	lag_ci_opt5(color("`r(p4)'") lw(0.1)) 	///
			lag_opt6(msymbol(Oh)  msize(1.2) mlwidth(0.3) color("`r(p5)'")) 	lag_ci_opt6(color("`r(p5)'") lw(0.1)) 	///	 
			lag_opt7(msymbol(V)   msize(1.2) mlwidth(0.3) color("`r(p6)'")) 	lag_ci_opt7(color("`r(p6)'") lw(0.1)) 	///		
					graph_opt(	                                   ///
							title("DiD estimates")                   ///
							xtitle("")                               ///
							ytitle("Average effect") xlabel(-5(1)10) ///
							legend(order(1 "TWFE" 3 "csdid (CS 2020)" 5 "did_imputation (BJS 2021)" 7 "did_multiplegt (CD 2020)"  9 "eventstudyinteract (SA 2020)" 11 "did2s (G 2021)" 13 "stackedev (CDLZ 2019)" ) pos(6) rows(2) region(style(none))) 	///
							xline(-0.5, lc(gs8) lp(dash)) ///
							yline(   0, lc(gs8) lp(dash)) ///
							) 
```

which gives us this figure:

<img src="../../../assets/images/allestimators2.png" height="300">













