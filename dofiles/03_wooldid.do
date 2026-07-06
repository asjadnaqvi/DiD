clear

set scheme white_tableau

cap cd "D:\Dropbox\STATA - DID"
cap cd "D:\anaqvi\Dropbox\STATA - DID"


**** installation

*ssc install ftools, replace


*net install wooldid, from("https://raw.githubusercontent.com/thegland/wooldid/main/wooldidinstall/") replace

ssc install wooldid, replace
which wooldid  // missing information


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

gen never_treat = first_treat==.  // never treated group


wooldid Y id t first_treat, cluster(id) 

wooldid Y id t first_treat, cluster(id) makeplots espre(10) espost(10)


		graph export wooldid_1.png, replace wid(2000)

/*

wooldid Y id t first_treat, cluster(id) timetrends

wooldid Y id t first_treat, cluster(id) att att_it

wooldid Y id t first_treat, cluster(id) histogramcohorteffects




ereturn list


mat li e(wdidmainresults)



wooldid Y id t first_treat, cluster(id) espre(10) espost(10)

ereturn list
return list

mat li e(wdidmainresults)





