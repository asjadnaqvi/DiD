---
layout: default
title: All estimators
parent: Stata code
nav_order: 20
mathjax: true
image: "../../../assets/images/DiD.png"
---

# All estimators
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


*(Last updated: 29 Nov 2022)*

---


# Comparing the estimators

This example follows the [five estimators](https://github.com/borusyak/did_imputation/blob/main/five_estimators_example.png) code that utilizes the `event_plot` command. In this example, we will use the same code structure we have been using in the individual sections above. So let's get started.


Please note that the estimators are not truely substitutable except in certain circumstances. Please read the assumptions of each estimator carefully before plotting them in one graph. A good starting point to understanding the differences between estimators is [Roth 2024](https://arxiv.org/abs/2401.12309). 


## Step 0: Get all the packages

Packages get updated once in a while. It is also good to check for updates once in a while! 

```stata
// supporting packages
ssc install schemepack, replace
ssc install avar, replace 
ssc install reghdfe, replace
ssc install event_plot, replace
ssc install palettes, replace
ssc install colrspace, replace

// DiD packages
ssc install drdid, replace
ssc install csdid, replace
ssc install did_imputation, replace
ssc install eventstudyinteract, replace
ssc install did_multiplegt, replace
ssc install stackedev, replace
ssc install did2s, replace
```

The `schemepack` package installs Stata graph schemes. You can `set scheme white_tableau` for a clean scheme to replicate the graphs exactly shown below. The `palettes` and `colrspace` package allows users to customize colors.


## Step 1: Create all the variables for all the DiD packages

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 


## Step 2: Run the packages and store the results



```stata
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

did_multiplegt_dyn Y id t D, effects(10) placebo(10) cluster(id)

matrix didmgt_b = e(estimates) 
matrix didmgt_v = e(variances)

*****************************
***  eventstudyinteract   ***
*****************************

eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)	

matrix evtstint_b = e(b_iw) 
matrix evtstint_v = e(V_iw)

***************		
*** did2s   ***
***************

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

```stata
colorpalette tableau, nograph	

event_plot    twfe	csdd    didimp  dcdh_b#dcdh_v   sa_b#sa_v   stackedev_b#stackedev_v did2s_b#did2s_v , 	///
	stub_lag( L_#   Tp#     tau#    Effect_#        L_#         L_#                     L_# 			) 		///
	stub_lead(F_# 	Tm#     pre#    Placebo_#       F_#         F_#                     F_# 			)		///
		together perturb(-0.30(0.10)0.30) trimlead(20) trimlag(20) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) lag_ci_opt2(color("`r(p1)'") lw(0.15)) 	///
			lag_opt3(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) lag_ci_opt3(color("`r(p2)'") lw(0.15)) 	///
			lag_opt4(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt4(color("`r(p3)'") lw(0.15)) 	///
			lag_opt5(msymbol(Sh)  msize(1.2) mlwidth(0.3) color("`r(p4)'")) lag_ci_opt5(color("`r(p4)'") lw(0.15)) 	///
			lag_opt6(msymbol(Oh)  msize(1.2) mlwidth(0.3) color("`r(p5)'")) lag_ci_opt6(color("`r(p5)'") lw(0.15)) 	///	 
			lag_opt7(msymbol(V)   msize(1.2) mlwidth(0.3) color("`r(p6)'")) lag_ci_opt7(color("`r(p6)'") lw(0.15)) 	///		
					graph_opt(												///
								title("DiD event study plot") 						///
								xtitle("") 									///
								ytitle("Average effect") xlabel(-20(2)20)	///
								legend(order(1 "TWFE" 3 "csdid (CS 2020)" 5 "did_imputation (BJS 2021)" 7 "did_multiplegt (CD 2020)"  9 "eventstudyinteract (SA 2020)" 11 "stackedev (CDLZ 2019)" 13 "did2s (G 2021)") pos(6) rows(3) region(style(none))) 	///
								xline(-0.5, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 
```

which gives us this figure:

<img src="../../../assets/images/allestimators2.png" width="100%">













