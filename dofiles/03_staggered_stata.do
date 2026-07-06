clear

set scheme white_tableau

cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"
cap cd "D:\anaqvi\Dropbox\STATA - DID"


**** installation

*install from GitHub: https://github.com/jonathandroth/staggered#stata-implementation

*ssc install staggered, replace

*which staggered


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

*xtline Y, overlay legend(off)
*graph export esi_1.png, replace	wid(2000)	

		

		
*** command options		
		
		

** use never treated as control


gen gvar = first_treat
recode gvar (. = 0)



staggered Y, i(id) t(t)  g(gvar) estimand(eventstudy) eventTime(-10/10)

return list
ereturn list



tempname CI b
mata st_matrix("`CI'", st_matrix("r(table)")[5::6, .])
mata st_matrix("`b'",  st_matrix("e(b)"))
*matrix colnames `CI' = `:rownames e(thetastar)'
*matrix colnames `b'  = `:rownames e(thetastar)'
coefplot matrix(`b'), ci(`CI') vertical yline(0)


	graph export staggered_1.png, replace wid(2000)	




/*
event_plot e(b)#e(V), default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("staggered")) stub_lag(-#) stub_lead(#) together
		graph export esi_2.png, replace	wid(2000)			


