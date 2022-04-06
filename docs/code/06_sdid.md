---
layout: default
title: sdid
parent: Stata code
nav_order: 9
mathjax: true
image: "../../../assets/images/DiD.png"
---

# sdid (Arkhangelsky et. al. 2021)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction

The *sdid* command is written by [Damian Clarke](https://www.damianclarke.net/) and [Daniel Pailañir](https://daniel-pailanir.github.io/) based on the Arkhangelsky et. al. 2021 paper [Synthetic Difference-in-Differences](https://www.aeaweb.org/articles?id=10.1257/aer.20190159). A detailed description is provided on [GitHub](https://github.com/Daniel-Pailanir/sdid).

## Installation and options

```applescript
ssc install sdid, replace
```

Take a look at the help file:

```applescript
help sdid
```

The minimum core syntax is as follows:

```applescript
sdid Y i t D, vce(method) 
```

where: 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| i | panel id |
| t | time variable  |
| D | Dummy variable which =1 if treated |
| vce(*method*)  |  method = bootstrap, jackknife, placebo |


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



Let's try the basic `sdid` command. The current version returns a bug when the time variable is not "year", so first we rename it `ren t year`, and next we run the basic command:

```applescript
sdid Y id year D, vce(bootstrap) seed(1000) 
```

Since we are using bootstrapped standard errors, we fix the seed for replicability. We get this output:


```xml

Bootstrap replications (50). This may take some time.
----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5
..................................................     50


Synthetic Difference-in-Differences Estimator

-----------------------------------------------------------------------------
           Y |     ATT     Std. Err.     t      P>|t|    [95% Conf. Interval]
-------------+---------------------------------------------------------------
   treatment | 131.07490    8.42889    15.55    0.000   114.55458   147.59522
-----------------------------------------------------------------------------
95% CIs and p-values are based on Large-Sample approximations.
Refer to Arkhangelsky et al., (2020) for theoretical derivations.
```

The command also has a built in graph option:

```applescript
sdid Y id year D, vce(bootstrap) seed(1000) graph
```

which generates a bunch of graphs based on Figure 1 in [Arkhangelsky et. al. 2021](https://www.aeaweb.org/articles?id=10.1257/aer.20190159).


Graphs that start with *g1_* show the id-specific differences between treatment and control and are drawn for the year of the "first_treatment". 

<img src="../../../assets/images/sdid_g1_24.png" height="200"><img src="../../../assets/images/sdid_g1_34.png" height="200"><img src="../../../assets/images/sdid_g1_38.png" height="200"><img src="../../../assets/images/sdid_g1_56.png" height="200">

It does not apply to our example, but the dots sizes can vary based on the weight size, where groups with zero weights are given an x symbol.

The next set of graphs start with *g2_* and represent the synthetic DiD graphs (DiD + synthetic control) also split by the year of the first treatment:

<img src="../../../assets/images/sdid_g2_24.png" height="200"><img src="../../../assets/images/sdid_g2_34.png" height="200"><img src="../../../assets/images/sdid_g2_38.png" height="200"><img src="../../../assets/images/sdid_g2_56.png" height="200">

The weights used to average pre-treatment periods are shown as area fills at the bottom of the figures.



*INCOMPLETE*

