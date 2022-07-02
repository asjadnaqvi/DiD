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
clear matrix
set scheme white_tableau


local units = 30
local start = 1
local end 	= 60

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen t 	   = seq(), f(`start') t(`end') 	

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
	local chrt = runiformint(0,5)	
	replace cohort = `chrt' if id==`x'
}


// for each cohort determine the timing and treatment effect
levelsof cohort, local(lvls)  
foreach x of local lvls {
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
			
	local timing = runiformint(`start',`end' + 20)	// 
	replace first_treat = `timing' if cohort==`x'
	replace first_treat = . if first_treat > `end'
		replace D = 1 if cohort==`x' & t>= `timing' 
}



replace rel_time = t - first_treat   // relative time
replace Y = id + t + cond(D==1, effect * rel_time, 0) + rnormal()  // treatment effect


// derive the various variables for various estimators
	*** leads
	cap drop F_*
	forval x = 2/10 {  
		gen F_`x' = rel_time == -`x'
	}

	
	*** lags
	cap drop L_*
	forval x = 0/10 {
		gen L_`x' = rel_time ==  `x'
	}
	

	
gen never_treat = first_treat==.  // never treated group

sum first_treat
gen last_cohort = first_treat==r(max) // last treated 


gen gvar = first_treat
recode gvar (. = 0)     
  
```

This gives us the same graph we have been using for all our examples:

```applescript
xtline Y, overlay legend(off)
```

<img src="../../../assets/images/test_data.png" height="300">


## Step 2: Run the package and store the packages



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

gen no_treat = first_treat==.			

	// leads
	cap drop F_*
	forval x = 1/10 {  
		gen     F_`x' = rel_time == -`x'
		replace F_`x' = 0 if no_treat==1
	}

	
	//lags
	cap drop L_*
	forval x = 0/10 {
		gen     L_`x' = rel_time ==  `x'
		replace L_`x' = 0 if no_treat==1
	}
	
	ren F_1 ref  // reference year
	
stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(no_treat) unit_fe(id) clust_unit(id)
	
	
matrix stackedev_b = e(b)
matrix stackedev_v = e(V)	
```


## Step 3: Put all the estimators together

Here we also make use of the colorpalettes package (`ssc install palettes, replace` and `ssc install colrspace, replace`) to control the color.

```applescript
colorpalette tableau, nograph	

event_plot 	  twfe	csdd 	didimp 	didmgt_b#didmgt_v 	evtstint_b#evtstint_v 	did2s_b#did2s_v		stackedev_b#stackedev_v	, 	///
	stub_lag( L_# 	Tp# 	tau# 	Effect_#  			L_#						L_#  				L_# ) 		///
	stub_lead(F_# 	Tm# 	pre# 	Placebo_#   		F_#						F_# 				F_# )		///
		together perturb(-0.30(0.10)0.30) trimlead(5) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  														///
			lag_opt1(msymbol(+)    mlwidth(0.3) color(black)) 		lag_ci_opt1(color(black)	 lw(0.1)) 	///
			lag_opt2(msymbol(lgx)  mlwidth(0.3) color("`r(p1)'")) 	lag_ci_opt2(color("`r(p1)'") lw(0.1)) 	///
			lag_opt3(msymbol(Dh)   mlwidth(0.3) color("`r(p2)'")) 	lag_ci_opt3(color("`r(p2)'") lw(0.1)) 	///
			lag_opt4(msymbol(Th)   mlwidth(0.3) color("`r(p3)'")) 	lag_ci_opt4(color("`r(p3)'") lw(0.1)) 	///
			lag_opt5(msymbol(Sh)   mlwidth(0.3) color("`r(p4)'")) 	lag_ci_opt5(color("`r(p4)'") lw(0.1)) 	///
			lag_opt6(msymbol(Oh)   mlwidth(0.3) color("`r(p5)'")) 	lag_ci_opt6(color("`r(p5)'") lw(0.1)) 	///	 
			lag_opt7(msymbol(V)    mlwidth(0.3) color("`r(p6)'")) 	lag_ci_opt7(color("`r(p6)'") lw(0.1)) 	///		
					graph_opt(												///
								title("DiD estimates") 						///
								xtitle("") 									///
								ytitle("Average effect") xlabel(-5(1)10)	///
								legend(order(1 "TWFE" 3 "csdid (CS 2020)" 5 "did_imputation (BJS 2021)" 7 "did_multiplegt (CD 2020)"  9 "eventstudyinteract (SA 2020)" 11 "did2s (G 2021)" 13 "stackedev (CDLZ 2019)" ) pos(6) rows(2) region(style(none))) 	///
								xline(-0.5, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							) 
```


<img src="../../../assets/images/allestimators.png" height="300">



The graph above has some interesting elements. First the TWFE model is clearly wrong. But so are `eventstudyinteract` and `stackedev`. All the other estimators give us estimates that are roughly close to the true values (*to be added*). So why do the two packages end up like this? I have no idea! I tested for a bunch of different options but the results stay roughly the same. Two reasons could be that (a) the estimation itself is not fully correcting for heterogenous treatments, and (b) the coding of the command is not correctly capuring heterogenous treatments. 

But if there is an error in the code, then please report it together with the corrections if possible. You can also try different seeds, different cohorts, and different treatment timings and magnitudes and check how the graphs vary. If we throw out the wrong estimators, we can see the results of the remaining packages as follows:

<img src="../../../assets/images/allestimators2.png" height="300">











