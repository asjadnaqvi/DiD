clear

set scheme white_tableau

cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"



**** installation

*net d stackdev, from("https://raw.githubusercontent.com/joshbleiberg/stackedev")
*help did2s

*net install stackdev, from("https://raw.githubusercontent.com/joshbleiberg/stackedev/main/") replace
*github install joshbleiberg/stackedev


ssc install stackedev, replace

help stackedev


*** data generation

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


set seed 20211222

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
			
	local timing = runiformint(`start',`end' + 20)	// 
	replace first_treat = `timing' if cohort==`x'
	replace first_treat = . if first_treat > `end'
		replace D = 1 if cohort==`x' & t>= `timing' 
}

replace rel_time = t - first_treat
replace Y =   cond(D==1, effect , 0) + rnormal()  //  id  + t + * rel_time


*** data graph

xtline Y, overlay legend(off)
*graph export data_1.png, replace wid(2000)	

		

		
*** command options		

gen no_treat = first_treat==.			

	// leads
	cap drop F_*
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


ren F_1 ref  //base year
	
	

** use never treated as control


	stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(no_treat) unit_fe(id) clust_unit(id)

	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("stackedev")) stub_lag(L_#) stub_lead(F_#) together 
		
		graph export stackedev_1.png, replace wid(2000)
		
		
		
*****

		/*
use https://github.com/joshbleiberg/stacked_event/raw/main/state_policy_effect.dta, clear
		
		
stackedev outcome pre8 pre7 pre6 pre5 pre4 pre3 pre2 post1 post2 post3 post4 ref, cohort(treat_year) time(year) never_treat(no_treat) unit_fe(state) clust_unit(state) covariates(cov)
		

    gen treat_year=.
    replace treat_year=2006 if inrange(state,13,20)
    replace treat_year=2007 if inrange(state,21,25)
    replace treat_year=2008 if inrange(state,26,40)
    replace treat_year=2009 if inrange(state,40,50)
    label variable treat_year "Cohort"
		
		
		
