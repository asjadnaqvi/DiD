---
layout: default
title: did_multiplegt
parent: Stata code
nav_order: 3
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt (Chaisemartin and D'Haultfœuille 2020, 2021)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction

The *did_multiplegt* command by Chaisemartin and D'Haultfœuille (henceforth CD) is probably one of the most flexible DiD estimators currently available. A key reason is that it allows for treatment switching (units can move in and out of treatment status) in addition to time-varying, heterogeneous treatment effects.

The command is very comprehensive, encompassing different estimation techniques derived from various CD papers. While a basic use is provided here, for more advanced applications, a careful reading of the help file and the relevant papers is highly recommended. Furthermore, since applications are almost non-existent, little can be said on the practicalities of how and when to apply the advance options.

Overall, the command is extremely slow. This has to do with the fact that calculating standard errors require bootstrap replications, and adding additional options multiplies the number of estimation calculations in the background. There is no display or progress bar while the command is running so it is hard to track estimation times.

## Installation and options

```applescript
ssc install did_multiplegt, replace
```

Take a look at the help file:

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


### The standard options

| Option | Description |
| ----- | ----- |
| robust_dynamic  | If this is not specified, the CD 2020a estimator is calculated, otherwise the CD 2020b estimator is used |
|   dynamic(*#*) | Number of lags to be estimated |
|    placebo(*#*) | Number of leads to be estimated |
| breps(*#*) | Number of bootstrap replications (required for estimating standard errors) |
| seed(*#*)  | For the replication of breps |
| cluster(*varname*) | cluster variable at the panel ID or higher level |

### The advance options

For a comprehensive overview of the advanced controls, please see the help file and the related papers.

| Option | Description |
| ----- | ----- |
| average_effect | The average effect of staying treated (robust_dynamic is required) |
| longdiff_placebo | For testing whether parallel trends hold over a longer set of leads (robust_dynamic is required) |
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


The stored results can be viewed by typing `ereturn list`.


## Generate sample data


Here we generate a test dataset with heterogeneous treatments:

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


levelsof cohort , local(lvls) 
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
```

Generate the graph:


```applescript
xtline Y, overlay legend(off)
```

<img src="../../../assets/images/test_data.png" height="300">


## Test the command

Let's try the basic `did_multiplegt` command:

```applescript
did_multiplegt Y id t D, robust_dynamic cluster(id) breps(20)
```

and it returns nothing... [WHY?, CHECK]

Let's try an event study option with 10 leads (refereed to as placebos in the model) and 10 lags:

```applescript
did_multiplegt Y id t D, robust_dynamic dynamic(10) placebo(10) breps(20) cluster(id)
```

and we get this output:

```xml
DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic 
option is used, and of placebo tests of the parallel trends assumption if the placebo option 
is used. The estimators are robust to heterogeneous effects, and to dynamic effects if the 
robust_dynamic option is used.

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+------------------------------------------------------------------
    Effect_0 | -.0608394   .3699999  -.7860393   .6643604         78         23 
    Effect_1 |   8.49767   .3811963   7.750525   9.244815         78         23 
    Effect_2 |  17.64773   .4201394   16.82425    18.4712         78         23 
    Effect_3 |   25.9377   .5058977   24.94614   26.92925         78         23 
    Effect_4 |  34.62362   .8107131   33.03462   36.21262         75         23 
    Effect_5 |  42.85682   1.155268    40.5925   45.12115         64         19 
    Effect_6 |  51.93103   1.416187    49.1553   54.70676         64         19 
    Effect_7 |  60.13327   1.799572   56.60611   63.66043         64         19 
    Effect_8 |  68.82446   1.901396   65.09773    72.5512         64         19 
    Effect_9 |  77.30792   2.222771   72.95129   81.66455         64         19 
   Effect_10 |  85.78878   2.535131   80.81992   90.75764         55         19 
   Placebo_1 | -.1308918   .5886522   -1.28465   1.022866         78         23 
   Placebo_2 |  .1944381   .4274514  -.6433666   1.032243         78         23 
   Placebo_3 |  .0639963   .4441797   -.806596   .9345885         78         23 
   Placebo_4 |  .2572878   .4284934  -.5825592   1.097135         78         23 
   Placebo_5 |  .0679468   .3048067  -.5294744    .665368         78         23 
   Placebo_6 |  -.082143   .2507972  -.5737055   .4094195         78         23 
   Placebo_7 |  -.271289   .3715318  -.9994913   .4569133         78         23 
   Placebo_8 |  .0338621   .2511709  -.4584328    .526157         78         23 
   Placebo_9 | -.1010115   .2640631  -.6185751   .4165522         78         23 
  Placebo_10 |  .3842823   .3026827  -.2089757   .9775403         78         23 

When dynamic effects and first-difference placebos are requested, the command does
not produce a graph, because placebos estimators are DIDs across consecutive time periods,
while dynamic effects estimators are long-difference DIDs, so they are not really comparable.
```

Even though we are warned in the output above that we should not compare the event study estimates, we can still plot these using the `event_plot` (`ssc install event_plot, replace`) command as follows: 


```applescript
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

and we get this figure:

<img src="../../../assets/images/cd_3.png" height="300">


*INCOMPLETE*

