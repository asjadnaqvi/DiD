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

## Introduction

The *did_multipegt* command by Chaisemartin and D'Haultfoeuille (henceforth CD) is probably one of the most flexible DiD estimators currently available. A key reason is that it allows for treatment switching (units can move in and out of treatment status) and varying and heterogenous treatment effects.

The command is very comprehesive, encompassing different estimation techniques derived from various CD papers. While a basic use is provided here, for more advanced applications, a careful reading of the papers a must. Furthermore, since applications are almost non-existent, little can be said on the practicalities of how and when to apply the advance options. Overall, the command is extremely slow. This has to do with the fact that standard errors require bootstrap replications, and adding additional options multiplies the number of estimations, on top of the timing group combinations, that are done in the background.

## Installation and options

```applescript
ssc install did_multiplegt, replace
```

Take a look at the options:

```applescript
help did_multiplegt
```

The main command is as follows:

```applescript
did_multiplegt Y G T D
```

where 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| G | group variable |
| T | time variable  |
| D | treatment dummy variable (=1 if treated) |


### The core DiD controls

| Option | Description |
| ----- | ----- |
| robust_dynamic  | If this is not specified, the C&D 2020a estimator is calculated, otherwise the C&D 2020b estimator is used |
|   dynamic(*#*) | Number of lags to be estimated |
|    placebo(*#*) | Number of leads to be estimated |
| breps(*#*) | Number of bootstrap replications (required for estimating standard errors) |
| seed(*#*)  | For the replication of breps |
| cluster(*varname*) | cluster variable at the panel ID or higher level |

### Advance controls

For a comprehensive overview of the advanced controls, please see the help file and the related papers.

| Option | Description |
| ----- | ----- |
| average_effect | The average effect of staying treated (robust_dynamic is required) |
| longdiff_placebo | For testing wehether parallel trends hold over a longer set of leads (robust_dynamic is required) |
| controls(*varlist*) | Like most of the recent DiD estimators, the use of the controls is a bit complex. See the help file |
| trends_nonparam(*varlist*) |  |
| trends_lin(*varlist*) |   |
| recat_treatment(*varlist*) |   |
| threshold_stable_treatment(*#*) |   |
| if_first_diff(*string*) |   |
| count_switchers_contr |   |
| switchers(*in* or *out*) |   |
| count_switchers_tot |   |
| discount(*#*) |   |

### Post estimation 

| Option | Description |
| ----- | ----- |
| jointtestplacebo |  |
| graphoptions(*string*) |  |
| save_results(*path*) |  |


For stored results see:

```applescript
ereturn list
```

## Examples

### A simple example

Let's start by generating a simple data set:


```applescript
clear
local units = 3
local start = 1
local end   = 10

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	= seq(), b(`time')  
egen t 	= seq(), f(`start') t(`end') 	

gen D = 0
replace D = 1 if id==2 & t>=5
replace D = 1 if id==3 & t>=8
lab var D "Treated"

cap drop Y
gen Y = 0
replace Y = id + t + cond(D==1, 0 * t, 0) if id==1
replace Y = id + t + cond(D==1, 2 * t, 0) if id==2
replace Y = id + t + cond(D==1, 4 * t, 0) if id==3

sort  id t
xtset id t

lab var id "Panel variable"
lab var t  "Time  variable"
lab var Y "Outcome variable"
```

Plot the data to see what it looks like:

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

<img src="../../../assets/images/cd_1.png" height="300">


Let's do a simple TWFE model		

```applescript
reghdfe Y D, absorb(id t)  
```

which gives us this output:

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

```

And now let's try the standard `did_multiplegt` syntax:

```applescript
did_multiplegt Y id t D, robust_dynamic cluster(id) breps(100)
```
which gives us:

```xml
DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic option 
is used, and of placebo tests of the parallel trends assumption if the placebo option is used. The estimators
 are robust to heterogeneous effects, and to dynamic effects if the robust_dynamic option is used.

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+------------------------------------------------------------------
    Effect_0 |        21   8.709065   3.930232   38.06977          5          2 

```



### A more complicated example

Here we generate an example with continuous interventions:

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

set seed 20211220  // to control the outputs

// gen cohorts
cap drop Y
cap drop D
cap drop cohort
cap drop effect
cap drop timing

gen Y 	   = 0		// outcome variable	
gen D 	   = 0		// intervention variable
gen cohort = .  	// total treatment variables
gen effect = .		// treatment effect size
gen timing = .		// when the treatment happens for each cohort

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

<img src="../../../assets/images/cd_2.png" height="300">

Let's try a standard TWFE model:

```applescript
reghdfe Y D, absorb(id t) 
```

which gives us a negative ATT, which is obviously wrong:

```xml
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =      1,800
Absorbing 2 HDFE groups                           F(   1,   1710) =      78.28
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.8564
                                                  Adj R-squared   =     0.8490
                                                  Within R-sq.    =     0.0438
                                                  Root MSE        =    39.4095

------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |  -31.50433   3.560877    -8.85   0.000    -38.48846   -24.52019
       _cons |   134.8577   2.428059    55.54   0.000     130.0954      139.62
------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
          id |        30           0          30     |
           t |        60           1          59     |
-----------------------------------------------------+
```

Let's try the basic `did_multiplegt` command:

```applescript
did_multiplegt Y id t D, robust_dynamic cluster(id) breps(20)
```

and it returns nothing. Don't know why this is the case. [CHECK]

Let's try an event study option with 10 leads (placebo) and lags:

```applescript
did_multiplegt Y id t D, robust_dynamic dynamic(10) placebo(10) breps(20) cluster(id)
```

and we get this output:

```xml
DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic option 
is used, and of placebo tests of the parallel trends assumption if the placebo option is used. The estimators 
are robust to heterogeneous effects, and to dynamic effects if the robust_dynamic option is used.

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+------------------------------------------------------------------
    Effect_0 |         0          0          0          0        100         25 
    Effect_1 |      5.44   .2812186   4.888812   5.991188         96         25 
    Effect_2 |     10.88   .5624372   9.777623   11.98238         90         25 
    Effect_3 |     16.32   .8436559   14.66643   17.97357         90         25 
    Effect_4 |     21.76   1.124874   19.55525   23.96475         90         25 
    Effect_5 |      27.2   1.406093   24.44406   29.95594         90         25 
    Effect_6 |     32.64   1.687312   29.33287   35.94713         90         25 
    Effect_7 |     38.08    1.96853   34.22168   41.93832         86         25 
    Effect_8 |     43.52   2.249749   39.11049   47.92951         82         25 
    Effect_9 |     48.96   2.530967    43.9993    53.9207         76         25 
   Effect_10 |        53   3.696522   45.75482   60.24518         60         20 
   Placebo_1 |         0          0          0          0        100         25 
   Placebo_2 |         0          0          0          0        100         25 
   Placebo_3 |         0          0          0          0        100         25 
   Placebo_4 |         0          0          0          0        100         25 
   Placebo_5 |         0          0          0          0        100         25 
   Placebo_6 |         0          0          0          0        100         25 
   Placebo_7 |         0          0          0          0        100         25 
   Placebo_8 |         0          0          0          0        100         25 
   Placebo_9 |         0          0          0          0        100         25 
  Placebo_10 |         0          0          0          0         70         19 

When dynamic effects and first-difference placebos are requested, the command does
not produce a graph, because placebos estimators are DIDs across consecutive time periods,
while dynamic effects estimators are long-difference DIDs, so they are not really comparable.
```

Even though we are warned that we should not do an event study, we can still plot these using the `event_plot` command. 

Get the `event_plot` command by typing `ssc install event_plot, replace` and generate the event plot:


```applescript
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

from which we get this figure:

<img src="../../../assets/images/cd_3.png" height="300">


*INCOMPLETE*

