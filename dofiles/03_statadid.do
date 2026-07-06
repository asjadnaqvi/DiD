clear

set scheme white_tableau

cap cd "D:\Dropbox\STATA - DID"



**** installation



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
replace Y = id + t + cond(D==1, effect * rel_time, 0) + rnormal()


*** data graph

xtline Y, overlay legend(off)
*graph export data_1.png, replace wid(2000)	

		
*reghdfe Y L_* F_*, absorb(id t) cluster(i)

		
*** command options		

gen no_treat = first_treat==.			

/*
summ rel_time
local relmin = abs(r(min))
local relmax = abs(r(max))

	// leads
	cap drop F_*
	forval x = 1/`relmin' {  // drop the first lead
		gen     F_`x' = rel_time == -`x'
		replace F_`x' = 0 if no_treat==1
	}

	
	//lags
	cap drop L_*
	forval x = 0/`relmax' {
		gen     L_`x' = rel_time ==  `x'
		replace L_`x' = 0 if no_treat==1
	}


ren F_1 ref  //base year
*/	
	

** use never treated as control




didregress (Y) (D), group(id) time(t)
*estat trendplots
*estat ptrends
*estat granger

*estat bdecomp, summaryonly


estat bdecomp
estat bdecomp, graph
graph export stata_bacon_internal.png, replace wid(2000)


bacondecomp Y D

bacondecomp Y D, ddetail
graph export stata_bacondecomp.png, replace wid(3000)		


hdidregress twfe (Y) (D), group(id) time(t)
*estat aggregation, dynamic(-10(1)10) graph

hdidregress aipw (Y) (D), group(id) time(t)
estat ptrends
estat atetplot
estat atetplot, sci
graph export hdid_aipw1.png, replace wid(2000)


*estat aggregation, dynamic graph(xlabel(, angle(90)))

estat aggregation, dynamic(-10(1)10) graph
graph export hdid_aipw2.png, replace wid(2000)


hdidregress ipw (Y) (D), group(id) time(t)
estat aggregation, dynamic(-10(1)10) graph


hdidregress ra (Y) (D), group(id) time(t)
estat aggregation, dynamic(-10(1)10) graph





