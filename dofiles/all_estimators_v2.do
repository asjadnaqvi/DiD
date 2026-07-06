
clear
clear matrix
set scheme white_tableau


local units = 30
local start = 1
local end 	= 100

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


// determine the number of cohorts and assign them to IDs

set seed 2022070
*set seed 20345

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


*************
*** graph ***
*************

xtline Y, overlay legend(off)

************
*** TWFE ***
************

xtreg Y D t, fe           
xtreg Y D i.t, fe      

reg Y D i.t i.id	       

reghdfe Y D, absorb(id t)  


reghdfe Y L_* F_*, absorb(id t) cluster(i)
estimates store twfe 

event_plot twfe, stub_lag(L_#) stub_lead(F_#) default_look together graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("TWFE"))


*************
*** csdid ***
*************


csdid Y, ivar(id) time(t) gvar(gvar) notyet

estat event, window(-10 10) estore(csdd) 


event_plot csdd, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("csdid") xlabel(-10(1)10)) stub_lag(Tp#) stub_lead(Tm#) together	 


***********************
*** did_imputation  ***
***********************


did_imputation Y i t first_treat, horizons(0/10) pretrend(10) minn(0) autosample

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("did_imputation") xlabel(-10(1)10)) stub_lag(tau#) stub_lead(pre#) together	 

estimates store bjs	
	

***********************
*** did_multiplegt  ***
***********************

did_multiplegt Y id t D, robust_dynamic dynamic(10) placebo(10) breps(2) cluster(id)


matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)


event_plot dcdh_b#dcdh_v, default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	



*****************************
***  eventstudyinteract   ***
*****************************


eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)	

// store the estimate
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)

	
event_plot sa_b#sa_v, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("eventstudyinteract")) stub_lag(L_#) stub_lead(F_#) together





******************
*** stackedev  ***
******************

gen no_treat = first_treat==.			

	// leads
	cap drop F_*
	cap drop ref*
	cap drop stack
	
	forval x = 1/10 {  // drop the first lead
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
	
	event_plot stackedev_b#stackedev_v, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("stackedev")) stub_lag(L_#) stub_lead(F_#) together



		

*****************************		
*** did2s (Gardner 2021)  ***
*****************************

	// leads
	cap drop F_*
	forval x = 2/10 {  // drop the first lead
		gen F_`x' = rel_time == -`x'
	}

	
	//lags
	cap drop L_*
	forval x = 0/10 {
		gen L_`x' = rel_time ==  `x'
	}

did2s Y, first_stage(id t) second_stage(F_* L_*) treatment(D) cluster(id)

matrix did2s_b = e(b)
matrix did2s_v = e(V)


	event_plot did2s_b#did2s_v, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("did2s")) stub_lag(L_#) stub_lead(F_#) together





***********************************
**** store the true estimators  ***
***********************************

/*
matrix btrue = J(1,6,.)
matrix colnames btrue = tau0 tau1 tau2 tau3 tau4 tau5
qui forvalues h = 0/5 {
	sum tau if K==`h'
	matrix btrue[1,`h'+1]=r(mean)
}
*/


**************************
**** combine them all  ***
**************************

colorpalette tableau, nograph	

event_plot 	  twfe	csdd 	bjs 	dcdh_b#dcdh_v 	sa_b#sa_v 	stackedev_b#stackedev_v	did2s_b#did2s_v, 	///
	stub_lag( L_# 	Tp# 	tau# 	Effect_#  		L_#			L_#  					L_# ) 		///
	stub_lead(F_# 	Tm# 	pre# 	Placebo_#   	F_#			F_# 					F_# )		///
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
								legend(order(1 "TWFE" 3 "csdid (CS 2020)" 5 "did_imputation (BJS 2021)" 7 "did_multiplegt (CD 2020)"  9 "eventstudyinteract (SA 2020)" 11 "stackedev (CDLZ 2019)" 13 "did2s (G 2021)") pos(6) rows(2) region(style(none))) 	///
								xline(-0.5, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							) 

	graph export allestimators2.png, replace wid(2000)	

*** END OF FILE ****

 
