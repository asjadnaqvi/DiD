clear all
clear frames

set scheme white_tableau

cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"



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

*** data generation

local units = 20
local start = 1
local end 	= 100

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen t 	   = seq(), f(`start') t(`end') 	

sort  id t
xtset id t


*set seed 20211222

local state = c(rngstate)
di "`state'"


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


*** command options		
		
		
gen never_treat = first_treat==.
tab never_treat

sum first_treat
gen last_cohort = first_treat==r(max) // dummy for the latest- or never-treated cohort

summ rel_time
local relmin = abs(r(min))
local relmax = abs(r(max))

	// leads
	cap drop F_*
	forval x = 2/`relmin' {  // drop the first lead
		gen F_`x' = rel_time == -`x'
	}

	
	//lags
	cap drop L_*
	forval x = 0/`relmax' {
		gen L_`x' = rel_time ==  `x'
	}

**** use never treated as control
gen gvar = first_treat
recode gvar (. = 0)

**** core variables

qui levelsof first_treat
local cohorts = r(r)
local comparisons = `end' * `cohorts' - `cohorts'


**** create the frame

cap frame drop sumstats
frames create sumstats i t obs treatments comparisons str20(estimator) time double(mean sd ll ul)
 

//**** 00 - TWFE ****//  

timer clear
	timer on 100
 
		reghdfe Y D, absorb(id t)   
		lincom (D + _cons)
  		
		local beta =	r(estimate)
		local sd	=	r(se)
		local ll	=	r(lb)
		local ul	=	r(ub)
				
	timer off 100
timer list  
 
frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("twfe")  (`r(t100)') (`beta') (`sd') (`ll') (`ul')

 
 
//**** 01 - csdid ****// 
 
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

frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("csdid")  (`r(t1)') (`beta') (`sd') (`ll') (`ul')



//**** 07 - eventstudyinteract ****//


timer clear
	timer on 7
		eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)

        matrix b = e(b_iw)
        matrix V = e(V_iw)
        ereturn post b V
		
		qui ds L_*
		local vars r(varlist)
		 
		local items: word count `r(varlist)'
		*di "`items'"
		 
		local vars = subinstr(`vars', " ", "+", .)
		*di "`vars'"
		
        lincom (`vars') / `items'

		local beta =	r(estimate)
		di "`beta'"
		
		local sd	=	r(se)
		local ll	=	r(lb)
		local ul	=	r(ub)
				
	timer off 7
timer list
	
frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("eventstudyinteract")  (`r(t7)') (`beta') (`sd') (`ll') (`ul')



//**** 10 - fect ****//


timer clear
	timer on 10

	fect Y, treat(D) unit(id) time(t) 

		local beta	=	e(ATT)[1,1]
		local sd	=	.
		local ll	=	.
		local ul	=	.	

	timer off 10
timer list	

frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("fect")  (`r(t10)') (`beta') (`sd') (`ll') (`ul')

 

//**** 02 - did_imputations ****// 
 
timer clear
	timer on 2
		did_imputation Y i t first_treat
		
		local beta	=	r(table)[1,1]
		local sd	=	r(table)[2,1]
		local ll	=	r(table)[5,1]
		local ul	=	r(table)[6,1]
	timer off 2
timer list

frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("did_imputation")  (`r(t2)') (`beta') (`sd') (`ll') (`ul')



//**** 03 - lpdid ****// 

timer clear
	timer on 3
		lpdid Y, time(t) unit(id) treat(D) pre(30) post(30) nograph

		local beta	=	e(pooled_results)[2,1]
		local sd	=	e(pooled_results)[2,2]
		local ll	=	e(pooled_results)[2,5]
		local ul	=	e(pooled_results)[2,6]		
	timer off 3
timer list

frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("lpdid")  (`r(t3)') (`beta') (`sd') (`ll') (`ul')


//**** 04 - sdid ****// 

timer clear
	timer on 4

		sdid Y id t D, vce(bootstrap) seed(1000)
		
		local beta	=	e(b)[1,1]
		local sd	=	e(V)[1,1]
		local ll	= .
		local ul	= .
		
	timer off 4
timer list

frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("sdid")  (`r(t4)') (`beta') (`sd')  (`ll') (`ul')


//**** 05 - stata hdidregress ****// 

timer clear
	timer on 5

	hdidregress aipw (Y) (D), group(id) time(t)
	estat aggregation

		local beta	=	r(table)[1,1]
		local sd	=	r(table)[2,1]
		local ll	=	r(table)[5,1]
		local ul	=	r(table)[6,1]	
	
	timer off 5
timer list


frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("hdidregress")  (`r(t5)') (`beta') (`sd') (`ll') (`ul')



//**** 06 - wooldid ****// 


timer clear
	timer on 6

		wooldid Y id t first_treat, cluster(id) 

		local beta	=	e(wdidmainresults)[1,1]
		local sd	=	e(wdidmainresults)[1,2]
		local ll	=	e(wdidmainresults)[1,5]
		local ul	=	e(wdidmainresults)[1,6]		
	timer off 6
timer list

frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("wooldid")  (`r(t6)') (`beta') (`sd') (`ll') (`ul')


//**** 08 - jwdid ****//

timer clear
	timer on 8

	jwdid Y, ivar(id) time(t) gvar(gvar)  never
	estat simple

		local beta	=	r(table)[1,1]
		local sd	=	r(table)[2,1]
		local ll	=	r(table)[5,1]
		local ul	=	r(table)[6,1]	
	
	timer off 8
timer list	
	
frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("jwdid")  (`r(t8)') (`beta') (`sd') (`ll') (`ul')
	
	
//**** 06 - xtevent ****//


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

*frame post sumstats (`units') (`end') (`obsv') (`cohorts') (`comparisons') ("xtevent")  (`r(t8)') (`beta') (`sd') (`ll') (`ul')
	

//**** 09 - stackedev ****//

	gen     ref = rel_time == - 1  //base year
	gen no_treat = first_treat==.

	stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(no_treat) unit_fe(id) clust_unit(id)




//// check frames

frame change sumstats





