clear
clear frames

set scheme white_tableau

cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"



**** installation

*ssc install csdid, replace
*help csdid



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



**** core variables

di "i = `units'"
di "t = `end'"
di "obs = `obsv'"

qui levelsof first_treat
local cohorts = r(r)


di "treatments = `cohorts'"

local comparisons = `end' * `cohorts' - `cohorts'

di "2x2 cohorts = `comparisons' "





*frames change sumstats
*frames change default

**** estimator

/*
csdid Y, ivar(id) time(t) gvar(gvar) notyet
ereturn list
return list

estat simple
return list
// mean
mat li r(b)
mat li r(V)
mat li r(table)
local xxx =  rowsof(e(gtt))
di "2x2 groups = `xxx'"

local beta=r(b)[1,1]
local sd=r(V)[1,1]
 */


timer clear
	timer on 1
		csdid Y, ivar(id) time(t) gvar(gvar) notyet
		estat simple
		local beta	=	r(b)[1,1]
		local sd	=	r(V)[1,1]
		local ll	=	r(table)[5,1]
		local ul	=	r(table)[6,1]
	timer off 1
timer list


di "timer = `r(t1)' seconds"


cap frame drop sumstats
frames create sumstats i t obs treatments comparisons str15(estimator) time mean sd ll ul


frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("csdid")  (`r(t1)') (`beta') (`sd') (`ll') (`ul')


frames change sumstats

