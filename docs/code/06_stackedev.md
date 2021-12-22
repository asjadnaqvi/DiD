---
layout: default
title: stackedev
parent: Stata code
nav_order: 7
mathjax: true
image: "../../../assets/images/DiD.png"
---

# stackedev (Cengiz, Dube, Lindner, Zipperer 2019)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction

The *stackedev* command is written by [Joshua Bleiberg](https://github.com/joshbleiberg/stackedev) based on the Cengiz, Dube, Lindner, Zipperer 2019 QJE paper [The effect of minimum wages on low-wage jobs](https://academic.oup.com/qje/article/134/3/1405/5484905).

The command is currently under active development so options might change around.

## Installation and options

The command is not currently on SSC but it is searchable:

```applescript
search stackedev, all
```

and then:

```
net describe stackedev, from(http://fmwww.bc.edu/RePEc/bocode/s)
net install stackedev.pkg
```

Take a look at the help file:

```applescript
help stackedev
```

The core syntax is as follows:

```applescript
stackedev Y F* L* , cohort(first_treat) time(t) never_treat(no_treat) unit_fe(i) clust_unit(i)
```

where: 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| i | panel id |
| t | time variable  |
| *lags* | manually generated lag variables  |
| *leads* | manually generated lead variables  |
| first_treat | Year of first treatment |
| no_treat  |  Dummy = 1 if unit is never treated  |


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


For `stackedev` we need to generate the `no_treat` variable and 10 leads and lags:

```applescript
gen no_treat = first_treat==.			

	// leads
	cap drop F_*
	forval x = 1/10 {  // drop the first lead
		gen     F_`x' = rel_time == -`x'
		replace F_`x' = 0 if no_treat==1
	}

	
	//lags
	cap drop L_*
	forval x = 0/10 {
		gen     L_`x' = rel_time ==  `x'
		replace L_`x' = 0 if no_treat==1
	}
	
	ren F_1 ref  // reference year

```




Let's try the basic `stackedev` command:

```applescript
stackedev Y F_* L_* ref, cohort(first_treat) time(t) never_treat(no_treat) unit_fe(id) clust_unit(id)
```


which will show this output:

```xml
HDFE Linear regression                            Number of obs   =      8,100
Absorbing 2 HDFE groups                           F(  21,     49) =    1869.11
Statistics robust to heteroskedasticity           Prob > F        =     0.0000
                                                  R-squared       =     0.7059
                                                  Adj R-squared   =     0.6941
                                                  Within R-sq.    =     0.1402
Number of clusters (unit_stack) =         50      Root MSE        =    28.0272

                            (Std. err. adjusted for 50 clusters in unit_stack)
------------------------------------------------------------------------------
             |               Robust
           Y | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         F_2 |  -73.65877    10.7275    -6.87   0.000     -95.2165   -52.10104
         F_3 |  -73.77536   10.76667    -6.85   0.000    -95.41179   -52.13892
         F_4 |  -74.01336   10.71399    -6.91   0.000    -95.54393   -52.48279
         F_5 |  -74.24938   10.71468    -6.93   0.000    -95.78134   -52.71741
         F_6 |  -74.33223   10.67582    -6.96   0.000     -95.7861   -52.87836
         F_7 |  -74.22897   10.78169    -6.88   0.000    -95.89558   -52.56236
         F_8 |  -73.98963    10.7601    -6.88   0.000    -95.61287    -52.3664
         F_9 |  -74.01052   10.73407    -6.89   0.000    -95.58143    -52.4396
        F_10 |  -73.78284   10.73911    -6.87   0.000    -95.36388   -52.20179
         L_0 |   -73.9512   10.82253    -6.83   0.000    -95.69989    -52.2025
         L_1 |   -65.4353   10.57871    -6.19   0.000    -86.69401   -44.17658
         L_2 |  -56.23356   10.52066    -5.35   0.000    -77.37562    -35.0915
         L_3 |  -47.94121   10.38544    -4.62   0.000    -68.81153    -27.0709
         L_4 |  -39.19742    10.2582    -3.82   0.000    -59.81204    -18.5828
         L_5 |  -44.38549   8.773992    -5.06   0.000    -62.01749   -26.75349
         L_6 |  -35.01765   8.532471    -4.10   0.000     -52.1643   -17.87101
         L_7 |   -26.4962   8.247857    -3.21   0.002    -43.07089   -9.921512
         L_8 |  -17.81266   8.113653    -2.20   0.033    -34.11766   -1.507664
         L_9 |  -9.696307    7.86312    -1.23   0.223    -25.49784    6.105224
        L_10 |  -1.410515   7.566479    -0.19   0.853    -16.61592    13.79489
         ref |  -73.90698   10.71636    -6.90   0.000    -95.44231   -52.37166
       _cons |   60.97933   .5582457   109.23   0.000      59.8575    62.10117
------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
    id#stack |        51          51           0    *|
     t#stack |       240           0         240     |
-----------------------------------------------------+
* = FE nested within cluster; treated as redundant for DoF computation

```


In order to plot the estimates we can use the `event_plot` (`ssc install event_plot, replace`) command as follows: 


```applescript
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("stackedev")) stub_lag(L_#) stub_lead(F_#) together
```

And we get:

<img src="../../../assets/images/stackedev_1.png" height="300">

The graph produced here has the same issue as with the `eventstudyinteract` command. My suspicion is that the intercept in the regressions is messing up the event study plots. [CHECK!]


*INCOMPLETE*

