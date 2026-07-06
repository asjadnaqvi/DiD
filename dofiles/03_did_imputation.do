clear

set scheme white_tableau
graph set window fontface "Arial Narrow"
cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"



**** installation

ssc install did_imputation, replace
which did_imputation
*help did_imputation



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
*graph export esi_1.png, replace	wid(2000)	

		

		
*** command options		
		
		



*did_imputation Y i t first_treat, horizons(0/10) pretrend(10)

did_imputation Y i t first_treat

did_imputation Y i t first_treat, horizons(0/10) pretrend(10) minn(0)

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("did_imputation") xlabel(-10(1)10)) stub_lag(tau#) stub_lead(pre#) together	 

	graph export did_imputation_1.png, replace wid(2000)			

		
		