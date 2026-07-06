clear

set scheme white_tableau


cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"


*** in the absence of controls there is not bias.
		
// generate the panel


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


set seed 13082021


// gen cohorts
cap drop Y
cap drop D
cap drop cohort
cap drop effect
cap drop timing

gen Y 	   = 0					// outcome variable	
gen D 	   = 0					// intervention variable
gen cohort = .  				// total treatment variables
gen effect = .					// treatment effect size
gen timing = .					// when the treatment happens for each cohort


levelsof id, local(lvls)
foreach x of local lvls {
	local chrt = runiformint(0,5)	
	replace cohort = `chrt' if id==`x'
}


levelsof cohort , local(lvls)  //  if cohort!=0 skip cohort 0 (never treated)
foreach x of local lvls {
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
		
		
	local timing = runiformint(`start' + 5,`end' - 5)	
	replace timing = `timing' if cohort==`x'
		replace D = 1 if cohort==`x' & t>= `timing' 
}



// generate the outcome variable

replace Y = id + t + cond(D==1, effect * (t - timing), 0)




// generate the graph

levelsof cohort
local items = `r(r)'

local lines

levelsof id

forval x = 1/`r(r)' {
	
	qui summ cohort if id==`x'
	local color = `r(mean)' + 1
	
	
	colorpalette tableau, nograph
		
	local lines `lines' (line Y t if id==`x', lc("`r(p`color')'") lw(vthin))	||
	
}

twoway ///
	`lines'	///
		,	legend(off)

graph export TWFE_bashing1.png, replace wid(3000)		

xtreg Y i.t D, fe 

reghdfe Y D, absorb(id t)   

*reghdfe Y D, absorb(id t)
*mat btwfe = e(b)[1,1]
*mat li btwfe




scalar btwfe = e(b)[1,1]
display btwfe


*bacondecomp Y D
 
bacondecomp Y D, ddetail
graph export TWFE_bashing2.png, replace wid(3000)		

scalar bbacon = e(b)[1,1]
display bbacon


/*
mat all = `units', `end', btwfe, bbacon, e(dd_avg_u), e(wt_sum_u), e(dd_avg_e), e(wt_sum_e), e(dd_avg_l), e(wt_sum_l)
mat coln all = i t bTWFE bBACON bTvsU wTvsU bEvsL wEvsL bLvsE wLvsE


*mat dir
mat li all




xtreg Y D i.t , fe
coefplot, drop(_cons D) vertical xlabel(, angle(vertical)) yline(0) nolab xsize(2) ysize(1)

*coefplot, drop(*t) vertical

*/

********************************************
*********** cohort 0 is never treated
********************************************

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


set seed 654793


// gen cohorts
cap drop Y
cap drop D
cap drop cohort
cap drop effect
cap drop timing

gen Y 	   = 0					// outcome variable	
gen D 	   = 0					// intervention variable
gen cohort = .  				// total treatment variables
gen effect = .					// treatment effect size
gen timing = .					// when the treatment happens for each cohort


levelsof id, local(lvls)
foreach x of local lvls {
	local chrt = runiformint(0,5)	
	replace cohort = `chrt' if id==`x'
}


levelsof cohort if cohort!=0, local(lvls)  //   skip cohort 0 (never treated)
foreach x of local lvls {
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
		
	local timing = runiformint(`start' + 5,`end' - 5)	
	replace timing = `timing' if cohort==`x'
		replace D = 1 if cohort==`x' & t>= `timing' 
}




// generate the outcome variable

replace Y = id + t + cond(D==1, effect * (t - timing), 0)




// generate the graph

levelsof cohort
local items = `r(r)'
local lines
levelsof id

forval x = 1/`r(r)' {
	
	qui summ cohort if id==`x'
	local color = `r(mean)' + 1
	
	colorpalette tableau, nograph
	local lines `lines' (line Y t if id==`x', lc("`r(p`color')'") lw(vthin))	||	
}

twoway ///
	`lines'	///
	, legend(off)

graph export TWFE_bashing3.png, replace wid(3000)		

*xtreg Y i.t D, fe

reghdfe Y D, absorb(id t)   

*reghdfe Y D, absorb(id t)
*mat btwfe = e(b)[1,1]
*mat li btwfe




scalar btwfe = e(b)[1,1]
display btwfe
 
bacondecomp Y D, ddetail
graph export TWFE_bashing4.png, replace wid(3000)		

scalar bbacon = e(b)[1,1]
display bbacon


/*
mat all = `units', `end', btwfe, bbacon, e(dd_avg_u), e(wt_sum_u), e(dd_avg_e), e(wt_sum_e), e(dd_avg_l), e(wt_sum_l)
mat coln all = i t bTWFE bBACON bTvsU wTvsU bEvsL wEvsL bLvsE wLvsE


*mat dir
mat li all




xtreg Y D i.t , fe
coefplot, drop(_cons D) vertical xlabel(, angle(vertical)) yline(0) nolab xsize(2) ysize(1)

*coefplot, drop(*t) vertical


*/

