clear

set scheme white_tableau

cap cd "D:\Dropbox\STATA - DID"

ssc install did_multiplegt, replace
which did_multiplegt_dyn




//// more dynamic example

clear
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


lab var id "Panel variable"
lab var t  "Time  variable"


// generate the intervention time


set seed 20211222


// gen cohorts


gen Y 	   		= 0		// outcome variable	
gen D 	   		= 0		// intervention variable
gen cohort      = .  	// treatment cohort
gen effect      = .		// treatment effect size
gen first_treat = .		// when the treatment happens for each cohort
gen rel_time	= .     // time - first_treat


levelsof id, local(lvls)
foreach x of local lvls {
	local chrt = runiformint(0,5)	
	replace cohort = `chrt' if id==`x'
}


levelsof cohort , local(lvls)  //  if cohort!=0 skip cohort 0 (never treated)
foreach x of local lvls {
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
		
		
	local timing = runiformint(`start',`end' + 20)	// first treatment
	replace first_treat = `timing' if cohort==`x'
	replace first_treat = . if first_treat > `end'
		replace D = 1 if cohort==`x' & t>= `timing' 
}

replace rel_time = t - first_treat
replace Y = id + t + cond(D==1, effect * rel_time, 0) + rnormal()


// generate the graph

*xtline Y, overlay legend(off)
*graph export test_data.png, replace	wid(2000)	

		
		

*reghdfe Y D, absorb(id t)  			

*did_multiplegt Y id t D, robust_dynamic cluster(id) breps(20)
*did_multiplegt Y id t D, robust_dynamic dynamic(5) placebo(5) breps(20) cluster(id) 

*event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
*	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)5)) stub_lag(Effect_#) stub_lead(Placebo_#) together

	
did_multiplegt_dyn Y id t D, effects(10) placebo(10) cluster(id)
graph export did_multiplegt_dyn1.png, replace	wid(2000)		
	

ereturn list
return list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("did_multiplegt_dyn") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export did_multiplegt_dyn2.png, replace	wid(2000)			
	