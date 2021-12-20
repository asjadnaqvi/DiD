---
layout: default
title: did_multiplegt
parent: Notes and Stata code
nav_order: 3
mathjax: true
image: "../../../assets/images/DiD.png"
---

# Bacon decomposition
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## did_multiplegt (Chaisemartin and D'Haultfoeuille (C&D))

The *did_multipegt* command is probably one of the most flexible DiD estimators currently available. This is because it allows (a) unbalanced panels, and (b) treatment switching, on top of heterogenous treatments.

The command also encompasses multiple different estimator types defined in different papers by C&D. In brief, this command does a lot and requires a careful reading of the many papers behind it.

Install the command:

```applescript
ssc install did_multiplegt, replace
```

Take a look at the options:

```applescript
help did_multiplegt
```

###The main command is as follows:

```applescript
did_multiplegt Y G T D
```

where 

Y = is the outcome variable
G = is the group variable
T = time variable 
D = treatment dummy variable (=1 if treated)


### The core DiD controls:

robust_dynamic: If this is not specified, the C&D 2020a estimator is calculated, otherwise the C&D 2020b estimator is used.
   |_ dynamic(*#*): Number of lags to be estimated
   |_ placebo(*#*): Number of leads to be estimated


breps(#): Number of bootstrap replications (required for estimating standard errors)
   |_ seed(*#*): To control the replication of breps.

cluster(*varname*): cluster variable at the panel ID or higher level.

### The advance controls

For a comprehensive overview of the advanced controls, please see the help file and the related papers.

average_effect: The average effect of staying treated (robust_dynamic is required).

longdiff_placebo: For testing wehether parallel trends hold over a longer set of leads (robust_dynamic is required)

controls(*varlist*): Like most of the recent DiD estimators, the use of the controls is a bit complex. See the help file.

trends_nonparam(*varlist*):

trends_lin(*varlist*):

recat_treatment(*varlist*):

threshold_stable_treatment(*#*):

if_first_diff(*string*):

count_switchers_contr:
 
switchers(*in*|*out*):

count_switchers_tot:

discount(*#*):

### Post estimation 

jointtestplacebo:

graphoptions(*string*)

save_results(*path*)


For other stored results see:

```applescript
ereturn list
```


## A simple example


```applescript
clear
local units = 3
local start = 1
local end 	= 10

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen t 	   = seq(), f(`start') t(`end') 	

sort  id t
xtset id t


lab var id "Panel variable"
lab var t  "Time  variable"


gen D = 0
replace D = 1 if id==2 & t>=5
replace D = 1 if id==3 & t>=8
lab var D "Treated"

cap drop Y
gen Y = 0
replace Y = id + t + cond(D==1, 0 * t, 0) if id==1
replace Y = id + t + cond(D==1, 2 * t, 0) if id==2
replace Y = id + t + cond(D==1, 4 * t, 0) if id==3

lab var Y "Outcome variable"
```

```applescript
twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))
```		
		

```applescript
reghdfe Y D, absorb(id t)  
```

```xml
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =         30
Absorbing 2 HDFE groups                           F(   1,     17) =      50.06
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.9298
                                                  Adj R-squared   =     0.8802
                                                  Within R-sq.    =     0.7465
                                                  Root MSE        =     4.8596

------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |   23.18182   3.276315     7.08   0.000      16.2694    30.09424
       _cons |   7.145455   1.324107     5.40   0.000     4.351833    9.939076
------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
          id |         3           0           3     |
           t |        10           1           9     |
-----------------------------------------------------+

. 
end of do-file

```

And we can use the standard `did_multiplegt` syntax:

```applescript
did_multiplegt Y id t D, robust_dynamic cluster(id) breps(100)
```


```xml
DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic option is used, and of placebo tests of the parallel trends assumption if the placebo option is used. The estimators are robust to heterogeneous effects, and to dynamic effects if the robust_dynamic option is used.



             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+------------------------------------------------------------------
    Effect_0 |        21   8.709065   3.930232   38.06977          5          2 

```



## A more complicated example

```applescript
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

replace Y = id + t + cond(D==1, effect * (t - timing), 0)
```

Generate the graph:


```applescript
xtline Y, overlay legend(off)
```


```applescript
reghdfe Y D, absorb(id t) 
```

```applescript
did_multiplegt Y id t D, robust_dynamic cluster(id) breps(20)
```

```applescript
did_multiplegt Y id t D, robust_dynamic dynamic(10) placebo(10) breps(20) cluster(id)
```


Get the `event_plot` command (`ssc install event_plot, replace`)

```applescript
event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```





