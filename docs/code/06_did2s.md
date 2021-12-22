---
layout: default
title: did2s
parent: Stata code
nav_order: 8
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did2s (Gardner 2021)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction

The *did2s* command is written by [Kyle Butts](https://kylebutts.com/) based on the Gardner 2021 paper [Two-stage differences in differences](https://jrgcmu.github.io/2sdd_current.pdf). A detailed description is provided in this [blog post](https://kylebutts.com/blog/posts/2021-05-24-two-stage-difference-in-differences/).

## Installation and options

```applescript
ssc install did2s, replace
```

Take a look at the help file:

```applescript
help did2s
```

The core syntax is as follows:

```applescript
did2s Y, first_stage(i t) second_stage(*leads* *lags*) treat_var(*D*) cluster(*var*)
```

where: 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| i | panel id |
| t | time variable  |
| *lags* | manually generated lag variables  |
| *leads* | manually generated lead variables  |
| D | Dummy variable which =1 if treated |
| cluster(*var*)  |  Cluster variable is panel id or higher aggregation unit  |


### The options

| Option | Description |


*INCOMPLETE*


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


For `did2s` we need to generate 10 leads and lags and drop the first lead:

```applescript
	// leads
	cap drop F_*
	forval x = 2/10 {  // drop the first lead
		gen F_`x' = rel_time == -`x'
	}

	
	//lags
	cap drop L_*
	forval x = 0/10 {
		gen L_`x' = rel_time ==  `x'
	}

```




Let's try the basic `did2s` command:

```applescript
did2s Y, first_stage(id t) second_stage(F_* L_*) treatment(D) cluster(id)
```


which will show this output:

```xml
                                     (Std. err. adjusted for clustering on id)
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         F_2 |   .2253244   .2301779     0.98   0.328     -.225816    .6764647
         F_3 |    .128698   .2333503     0.55   0.581    -.3286603    .5860563
         F_4 |  -.1034735   .2210323    -0.47   0.640    -.5366889    .3297418
         F_5 |   .0552204   .1918748     0.29   0.774    -.3208473     .431288
         F_6 |  -.1979187   .2018475    -0.98   0.327    -.5935326    .1976951
         F_7 |  -.1802993   .2217714    -0.81   0.416    -.6149633    .2543646
         F_8 |   .0756883   .1691673     0.45   0.655    -.2558736    .4072502
         F_9 |   .0365711   .2123039     0.17   0.863    -.3795369     .452679
        F_10 |   .0605167   .1902589     0.32   0.750     -.312384    .4334174
         L_0 |   .0791996   .2780198     0.28   0.776    -.4657091    .6241084
         L_1 |   8.619413    .330885    26.05   0.000      7.97089    9.267936
         L_2 |   17.63192   .4278901    41.21   0.000     16.79327    18.47057
         L_3 |   26.00454   .6601769    39.39   0.000     24.71061    27.29846
         L_4 |   34.69155   .9373878    37.01   0.000     32.85431     36.5288
         L_5 |   42.57469   1.320541    32.24   0.000     39.98648    45.16291
         L_6 |    51.8403   1.579579    32.82   0.000     48.74439    54.93622
         L_7 |   59.97723   1.914613    31.33   0.000     56.22466     63.7298
         L_8 |   68.85919   2.106164    32.69   0.000     64.73118    72.98719
         L_9 |   77.24698   2.323762    33.24   0.000     72.69249    81.80147
        L_10 |   85.82518   2.649239    32.40   0.000     80.63277    91.01759
------------------------------------------------------------------------------
```


In order to plot the estimates we can use the `event_plot` (`ssc install event_plot, replace`) command as follows: 


```applescript
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("did2s")) stub_lag(L_#) stub_lead(F_#) together
```

And we get:

<img src="../../../assets/images/did2s_1.png" height="300">



*INCOMPLETE*

