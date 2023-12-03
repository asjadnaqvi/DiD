---
layout: default
title: fect
parent: Stata code
nav_order: 12
mathjax: true
image: "../../../assets/images/DiD.png"
---

# wooldid
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction



## Installation and options

```stata
net install fect, from("https://raw.githubusercontent.com/xuyiqing/fect_stata/master/") replace
ssc install _gwtmean, replace  // depdendency
```

Take a look at the help file:

```stata
help fect
```



## Generate sample data


Here we generate a test dataset with heterogeneous treatments:

```stata
clear

local units = 30
local start = 1
local end   = 60

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


** use never treated as control

gen gvar = first_treat
recode gvar (. = 0)

gen never_treat = first_treat==.  // never treated group
```

Generate the graph:


```stata
xtline Y, overlay legend(off)
```

<img src="../../../assets/images/test_data.png" height="300">

## Test the command


Let's try the basic command:

```stata
fect Y, treat(D) unit(id) time(t) 
```

which currently does not show an output but displays a graph:



<img src="../../../assets/images/fect_1.png" height="300">



