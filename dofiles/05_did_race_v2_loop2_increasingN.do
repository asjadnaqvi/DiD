clear all
clear frames

set scheme white_tableau

cap cd "D:\Dropbox\STATA - DID/did_race2"




**** installation

*ssc install csdid, replace
*help csdid

*ssc install did_multiplegt, replace
*help did_multiplegt

*ssc install did_imputation, replace
*help did_imputation

*ssc install eventstudyinteract, replace
*ssc install avar, replace // dependency

*ssc install lpdid, replace

*ssc install sdid, replace

*ssc install xtevent, replace

*ssc install stackedev, replace



**** create the frame

cap frame drop sumstats
frames create sumstats run iter i t obs treatments comparisons str20(estimator) pass time double(mean sd ll ul)
 


*** data generation
local iter 10
local min  100            
local max  400
local diff 50


local z = 1



forval x = `min'(`diff')`max' {
forval y = 1/`iter' {	


di in green "Run `z': N = `x', Iter. = `y'"	




clear


qui {

local units = 10
local start = 1
local end 	= `x'

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

levelsof id, local(lvls)
foreach j of local lvls {
	local chrt = runiformint(0,5)	
	replace cohort = `chrt' if id==`j'
}


levelsof cohort if cohort!=0, local(lvls)  //  if cohort!=0 skip cohort 0 (never treated). necessary for some estimators

foreach j of local lvls {
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`j'
			
	local timing = runiformint(`start',`end' + 20)	// 
	replace first_treat = `timing' if cohort==`j'
	replace first_treat = . if first_treat > `end'
		replace D = 1 if cohort==`j' & t>= `timing' 
}

replace rel_time = t - first_treat
replace Y = id + t + cond(D==1, effect * rel_time, 0) + rnormal()





*** command options		
		
		
gen never_treat = first_treat==.
*tab never_treat

sum first_treat
gen last_cohort = first_treat==r(max) // dummy for the latest- or never-treated cohort

summ rel_time
local relmin = min(abs(r(min)), 40)    // cap endless variable generation
local relmax = min(abs(r(max)), 40)	   // cap endless variable generation

*di "`relmin', `relmax'"

	// leads
	cap drop F_*
	forval j = 2/`relmin' {  // drop the first lead
		gen F_`j' = rel_time == -`j'
	}

	
	//lags
	cap drop L_*
	forval j = 0/`relmax' {
		gen L_`j' = rel_time ==  `j'
	}

**** use never treated as control
gen gvar = first_treat
recode gvar (. = 0)

**** core variables

qui levelsof first_treat
local cohorts = r(r)
local comparisons = `end' * `cohorts' - `cohorts'

compress
save data_`z'.dta, replace
}

xtline Y, overlay legend(off) title("Run `z': N = `x', Iter. = `y'") xtitle("Time") ytitle("Outcome variable")
qui graph export graph_`z'.png, replace wid(2000)	





//**** 00 - TWFE ****//  

qui {
	
noi di in yellow "TWFE"
	
timer clear
	timer on 100
 
		cap reghdfe Y D, absorb(id t)   
	
		if _rc == 0 {
			local pass 	= 	1
			lincom (D + _cons)
			local beta  =	r(estimate)
			local sd	=	r(se)
			local ll	=	r(lb)
			local ul	=	r(ub)
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}
		
		
	timer off 100
timer list  
 
frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("twfe") (`pass') (`r(t100)') (`beta') (`sd') (`ll') (`ul')

 
 
//**** 01 - csdid ****// 
 
noi di in yellow "csdid" 
 
timer clear
	timer on 1
		cap csdid Y, ivar(id) time(t) gvar(gvar) agg(simple) notyet
		
		if _rc == 0 {
			local pass 	= 	1
			estat simple
			local beta	=	r(b)[1,1]
			local sd	=	r(V)[1,1]
			local ll	=	r(table)[5,1]
			local ul	=	r(table)[6,1]
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}		
		

	timer off 1
timer list

frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("csdid") (`pass') (`r(t1)') (`beta') (`sd') (`ll') (`ul')



//**** 07 - eventstudyinteract ****//


noi di in yellow "eventstudyinteract" 

timer clear
	timer on 7
		cap eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)

		if _rc == 0 {
			local pass 	= 	1
			matrix b = e(b_iw)
			matrix V = e(V_iw)
			ereturn post b V
			
			 ds L_*
			local vars r(varlist)
			 
			local items: word count `r(varlist)'
			local vars = subinstr(`vars', " ", "+", .)
			lincom (`vars') / `items'

			local beta =	r(estimate)
			local sd	=	r(se)
			local ll	=	r(lb)
			local ul	=	r(ub)
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}			
		

				
	timer off 7
timer list
	
cap frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("eventstudyinteract") (`pass') (`r(t7)') (`beta') (`sd') (`ll') (`ul')



//**** 10 - fect ****//


noi di in yellow "fect" 

timer clear
	timer on 10

	cap fect Y, treat(D) unit(id) time(t) 

		if _rc == 0 {
			local pass 	= 	1
			local beta	=	e(ATT)[1,1]
			local sd	=	.
			local ll	=	.
			local ul	=	.	
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}		


	timer off 10
timer list	

frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("fect") (`pass') (`r(t10)') (`beta') (`sd') (`ll') (`ul')

 

//**** 02 - did_imputations ****// 
 
noi di in yellow "did_imputation"  
 
timer clear
	timer on 2
		cap did_imputation Y i t first_treat, autosample

		if _rc == 0 {
			local pass 	= 	1
			local beta	=	r(table)[1,1]
			local sd	=	r(table)[2,1]
			local ll	=	r(table)[5,1]
			local ul	=	r(table)[6,1]
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}			

	timer off 2
timer list

frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("did_imputation") (`pass') (`r(t2)') (`beta') (`sd') (`ll') (`ul')



//**** 03 - lpdid ****// 

noi di in yellow "lpdid"  

timer clear
	timer on 3
		cap lpdid Y, time(t) unit(id) treat(D) pre(50) post(50) nograph

		if _rc == 0 {
			local pass 	= 	1
			local beta	=	e(pooled_results)[2,1]
			local sd	=	e(pooled_results)[2,2]
			local ll	=	e(pooled_results)[2,5]
			local ul	=	e(pooled_results)[2,6]	
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}	
	
	timer off 3
timer list

cap frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("lpdid") (`pass') (`r(t3)') (`beta') (`sd') (`ll') (`ul')



//**** 04 - sdid ****// 


noi di in yellow "sdid"  

timer clear
	timer on 4

		cap sdid Y id t D, vce(bootstrap) seed(1000)

		if _rc == 0 {
			local pass 	= 	1
			local beta	=	e(b)[1,1]
			local sd	=	e(V)[1,1]
			local ll	= .
			local ul	= .
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}			
		
	timer off 4
timer list

frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("sdid") (`pass') (`r(t4)') (`beta') (`sd')  (`ll') (`ul')


//**** 05 - stata hdidregress ****// 

noi di in yellow "hdidregress" 

timer clear
	timer on 5

	cap hdidregress aipw (Y) (D), group(id) time(t)

		if _rc == 0 {
			local pass 	= 	1
			estat aggregation

			local beta	=	r(table)[1,1]
			local sd	=	r(table)[2,1]
			local ll	=	r(table)[5,1]
			local ul	=	r(table)[6,1]	
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}		
	

	
	timer off 5
timer list

frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("hdidregress") (`pass') (`r(t5)') (`beta') (`sd') (`ll') (`ul')



//**** 06 - wooldid ****// 

noi di in yellow "wooldid" 

timer clear
	timer on 6

		cap wooldid Y id t first_treat, cluster(id)

		if _rc == 0 {
			local pass 	= 	1
			local beta	=	e(wdidmainresults)[1,1]
			local sd	=	e(wdidmainresults)[1,2]
			local ll	=	e(wdidmainresults)[1,5]
			local ul	=	e(wdidmainresults)[1,6]	
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}	
		
		
	
	timer off 6
timer list

frame post sumstats (`z') (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("wooldid") (`pass') (`r(t6)') (`beta') (`sd') (`ll') (`ul')


//**** 08 - jwdid ****//

noi di in yellow "jwdid" 

timer clear
	timer on 8
	
	cap jwdid Y, ivar(id) time(t) gvar(gvar)  never

		if _rc == 0 {
			local pass 	= 	1
			estat simple
			local beta	=	r(table)[1,1]
			local sd	=	r(table)[2,1]
			local ll	=	r(table)[5,1]
			local ul	=	r(table)[6,1]	
		}
		else {
			local pass 	= 	0
			local beta  =	.
			local sd	=	.
			local ll	=	.
			local ul	=	.
		}		
	

	
	timer off 8
timer list	
	
frame post sumstats (`z')  (`iter') (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("jwdid") (`pass') (`r(t8)') (`beta') (`sd') (`ll') (`ul')
	
	
//**** 06 - xtevent ****//

/*
timer clear
	timer on 6

		xtevent Y, pol(D) p(id) t(t) cohort(gvar) control_cohort(never_treat) static 
	
		lincom (D + _cons)
  		
		local beta =	r(estimate)
		local sd	=	r(se)
		local ll	=	r(lb)
		local ul	=	r(ub)	
	
	timer off 6
timer list	
*/

*frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("xtevent")  (`r(t6)') (`beta') (`sd') (`ll') (`ul')
	

//**** 09 - stackedev ****//

/*
	gen     ref = rel_time == - 1  //base year
	gen no_treat = first_treat==.

	stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(no_treat) unit_fe(id) clust_unit(id)
*/


local z = `z' + 1

		}
	}
}

	
//// check frames

frame change sumstats

compress
save did_race_loop2_increaseN.dta, replace



use did_race_loop2_increaseN, clear
drop if inlist(estimator, "eventstudyinteract")


gen est2 = .
replace est2 = 1  if estimator=="twfe"
replace est2 = 2  if estimator=="hdidregress"
replace est2 = 3  if estimator=="did_imputation"
replace est2 = 4  if estimator=="csdid"
replace est2 = 5  if estimator=="sdid"
replace est2 = 6  if estimator=="wooldid"
replace est2 = 7  if estimator=="jwdid"
replace est2 = 8  if estimator=="lpdid"
replace est2 = 9  if estimator=="fect"
replace est2 = 10 if estimator=="eventstudyinteract"

labmask est2, val(estimator)


bysort run (est2): gen double meandiff = mean - mean[1]
bysort run (est2): gen double meanper  = ((mean - mean[1]) / mean[1]) * 100

local clr %80
local ms  3
local mlw vthin

twoway ///
	(scatter meandiff time  if est2==2, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meandiff time  if est2==3, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meandiff time  if est2==4, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meandiff time  if est2==5, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meandiff time  if est2==6, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meandiff time  if est2==7, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	, ///
	xtitle("Estimation time in seconds") ///
	ytitle("Difference from TWFE mean") ///
	legend(order(1 "hdidregress" 2 "did_imputation" 3 "csdid" 4 "sdid" 5 "wooldid" 6 "jwdid"))

	
local clr %50
local ms  2
local mlw vthin

twoway ///
	(scatter meanper time  if est2==2, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meanper time  if est2==3, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meanper time  if est2==4, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meanper time  if est2==5, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meanper time  if est2==6, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter meanper time  if est2==7, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	(scatter meanper time  if est2==8, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	(scatter meanper time  if est2==9, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	(scatter meanper time  if est2==10, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	, ///
	xtitle("Estimation time in seconds") ///
	ytitle("Percentage difference from TWFE mean") ///
	legend(order(1 "hdidregress" 2 "did_imputation" 3 "csdid" 4 "sdid" 5 "wooldid" 6 "jwdid" 7 "wooldid" 8 "lpdid" 9 "fect" 10 "eventstudyinteract"))	
	
	
local clr %80
local ms  3
local mlw vvthin

twoway ///
	(scatter mean time  if est2==1, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==2, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==3, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==4, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==5, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==6, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==7, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==8, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==9, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter mean time  if est2==10, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	, ///
	xtitle("Estimation time in seconds") ///
	ytitle("Difference from TWFE mean") ///
	legend(order(1 "TWFE" 2 "hdidregress" 3 "did_imputation" 4 "csdid" 5 "sdid" 6 "wooldid" 7 "jwdid" 8 "wooldid" 9 "lpdid" 10 "fect" 11 "eventstudyinteract"))	

local clr %30
local ms  2.2
local mlw vthin	
	
twoway ///
	(scatter time obs  if est2==1, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==2, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==3, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==4, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==5, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==6, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==7, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==8, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==9, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter time obs  if est2==10, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	, ///
	xtitle("Observations") ///
	ytitle("Execution time (secs)") ///
	legend(order(1 "TWFE" 2 "hdidregress" 3 "did_imputation" 4 "csdid" 5 "sdid" 6 "wooldid" 7 "jwdid" 8 "wooldid" 9 "lpdid" 10 "fect" 11 "eventstudyinteract"))	
		
gen double logtime = log(time)		
	
local clr %30
local ms  2.2
local mlw vthin	
	
twoway ///
	(scatter logtime obs  if est2==1, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==2, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==3, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==4, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==5, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==6, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==7, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==8, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==9, msize(`ms') mc(`clr') mlwidth(`mlw')) ///
	(scatter logtime obs  if est2==10, msize(`ms') mc(`clr') mlwidth(`mlw')) ///	
	, ///
	xtitle("Observations") ///
	ytitle("Execution time (secs)") ///
	legend(order(1 "TWFE" 2 "hdidregress" 3 "did_imputation" 4 "csdid" 5 "sdid" 6 "wooldid" 7 "jwdid" 8 "wooldid" 9 "lpdid" 10 "fect" 11 "eventstudyinteract"))	
			
	
	
	
heatplot time i.est2 run if est2!=1
	
	
joyplot time run, by(est2)	 
	
	
	
	
	
