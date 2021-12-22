---
layout: default
title: did_imputation
parent: Stata code
nav_order: 5
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_imputation (Borusyak, Jaravel, Spiess 2021)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction

The *did_imputation* command is written by Kirill Borusyak, Xavier Jaravel, and Jann Spiess (henceforth BJS), based on their paper [Revisiting Event Study Designs: Robust and Efficient Estimation](https://arxiv.org/abs/2108.12419).




## Installation and options

```applescript
ssc install did_imputation, replace
```

Take a look at the help file:

```applescript
help did_imputation
```


```applescript
did_imputation Y i t first_treat
```

where: 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| i | panel id |
| t | time variable  |
| first_treat | timing of first treatment (missing for untreated groups) |


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

Let's try the basic `did_imputation` command with 10 leads and lags

```applescript
did_imputation Y i t first_treat, horizons(0/10) pretrend(10)
```


which will show this output:

```xml
WARNING: suppressing the following coefficients from estimation because of insufficient effective sample size: tau0 tau1 tau2 tau3 tau4 tau5 tau6 tau7 tau8 tau9 tau10. To report them nevertheless, set the minn option to a smaller number or 0, but keep in mind that the estimates may be unreliable and their SE may be downward biased.

                                                         Number of obs = 1,438
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
        tau0 |          0  (omitted)
        tau1 |          0  (omitted)
        tau2 |          0  (omitted)
        tau3 |          0  (omitted)
        tau4 |          0  (omitted)
        tau5 |          0  (omitted)
        tau6 |          0  (omitted)
        tau7 |          0  (omitted)
        tau8 |          0  (omitted)
        tau9 |          0  (omitted)
       tau10 |          0  (omitted)
        pre1 |   .1206052   .2867599     0.42   0.674    -.4414338    .6826443
        pre2 |   .2116369   .3322261     0.64   0.524    -.4395143    .8627881
        pre3 |   .0601094     .28101     0.21   0.831      -.49066    .6108789
        pre4 |   .0568874   .2810549     0.20   0.840    -.4939701    .6077449
        pre5 |  -.2050823   .2643479    -0.78   0.438    -.7231945      .31303
        pre6 |  -.3225205   .2344532    -1.38   0.169    -.7820403    .1369993
        pre7 |  -.2239894   .2512797    -0.89   0.373    -.7164885    .2685097
        pre8 |    .052194   .2244509     0.23   0.816    -.3877217    .4921096
        pre9 |   .0285485   .2359939     0.12   0.904     -.433991    .4910879
       pre10 |   .0962904   .2315309     0.42   0.677    -.3575018    .5500827
------------------------------------------------------------------------------
```

Here we can see that estimation does not compute the lags. This is just to illustrate that the command will still throw out a table which can be plotted essentially showing null effects. So be careful if you are looping over a large number of variables.

In order to correctly recover the values, we have to use the `minn(0)` option, which reduces the threshold for calculating the estimates based on to treated groups to zero (default is 30).

```applescript
did_imputation Y i t first_treat, horizons(0/10) pretrend(10) minn(0)
```

which gives us:

```xml

                                                         Number of obs = 1,438
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
        tau0 |   .0787163   .2677837     0.29   0.769    -.4461301    .6035626
        tau1 |   8.637227   .2815466    30.68   0.000     8.085406    9.189048
        tau2 |   17.78728   .2329168    76.37   0.000     17.33078    18.24379
        tau3 |   26.07725   .2293303   113.71   0.000     25.62777    26.52673
        tau4 |   34.76562   .2815757   123.47   0.000     34.21374     35.3175
        tau5 |   42.93274   .2848896   150.70   0.000     42.37437    43.49111
        tau6 |   52.00695   .2787334   186.58   0.000     51.46064    52.55326
        tau7 |   60.20919   .2526518   238.31   0.000       59.714    60.70438
        tau8 |   68.90038   .2317814   297.26   0.000      68.4461    69.35466
        tau9 |   77.38383   .2652313   291.76   0.000     76.86399    77.90368
       tau10 |   85.83142    .309541   277.29   0.000     85.22473    86.43811
        pre1 |   .1206052   .2867599     0.42   0.674    -.4414338    .6826443
        pre2 |   .2116369   .3322261     0.64   0.524    -.4395143    .8627881
        pre3 |   .0601094     .28101     0.21   0.831      -.49066    .6108789
        pre4 |   .0568874   .2810549     0.20   0.840    -.4939701    .6077449
        pre5 |  -.2050823   .2643479    -0.78   0.438    -.7231945      .31303
        pre6 |  -.3225205   .2344532    -1.38   0.169    -.7820403    .1369993
        pre7 |  -.2239894   .2512797    -0.89   0.373    -.7164885    .2685097
        pre8 |    .052194   .2244509     0.23   0.816    -.3877217    .4921096
        pre9 |   .0285485   .2359939     0.12   0.904     -.433991    .4910879
       pre10 |   .0962904   .2315309     0.42   0.677    -.3575018    .5500827
------------------------------------------------------------------------------

```



In order to plot the estimates we can use the `event_plot` (`ssc install event_plot, replace`) command as follows: 


```applescript
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("csdid") xlabel(-10(1)10)) stub_lag(Tp#) stub_lead(Tm#) together	 
```

And we get:

<img src="../../../assets/images/did_imputation_1.png" height="300">


*INCOMPLETE*

