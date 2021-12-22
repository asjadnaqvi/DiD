---
layout: default
title: csdid
parent: Notes and Stata code
nav_order: 4
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

The *csdid* command by Callaway and Sant'Anna (henceforth CS), originally released an [R package](https://bcallaway11.github.io/did/index.html), was coded in Stata by Fernando Rios-Avila who also has a really helpful [page here](https://friosavila.github.io/playingwithstata/index.html). A key reason is that it allows for treatment switching (units can move in and out of treatment status) in addition to time-varying, heterogeneous treatment effects.

Even though the code has been optimized for Stata, the estimation can be slow. This is because in the background all possible 2x2 combinations are being calculated in what are basically non-linear estimations. Therefore if you have a lot of differential treatment timings, and a lot of different panel ids, then the combinations explode. The R code was recently (Dec 2021) optimized with [significant speed gains](https://twitter.com/pedrohcgs/status/1470526912447528960) and it might be helpful to check if the same optimizations can also be implemented in the Stata program.


## Installation and options

```applescript
ssc install csdid, replace
```

Take a look at the help file:

```applescript
help csdid
```


```applescript
csdid Y [ind vars], [ivar(varname)] time(varname) gvar(varname) [options]
```

where: 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| ivar | panel id |
| time | time variable  |
| gvar | timing of first treatment (0 for untreated groups) |


### The options

| Option | Description |
| ----- | ----- |
| notyet  | Use the not-treated groups as control |
| long |  |


### The method options
The estimator has several methods built-in to estimate the standard errors. These can be specified using the **method(***method name***)** option.

| Option | Description |
| ----- | ----- |
| drimp | Inverse probability tilting plus weighted least squares. The default option based on Sant’Anna and Zhao (2020)  |
| dripw  | Doubly robust inverse probability weighting (IPW). Based on Sant’Anna and Zhao (2020)    |
| reg  |  OLS  |
| stdipw  | IPW with stabilized weights    |
| ipw  | IPW based on Abadie (2005)   |
| rc1  | Repeated cross section estimators   |



### The standard error options

| Option | Description |
| ----- | ----- |
|  wboot  | wild boostrap options (see help file for details)    |
|  rseed(#)  | control the seeding for the bootstraps    |
|  cluster(*var*)  |  cluster standard errors   |
|  level(#)  |  If confidence intervals other than 95% are required   |
|  pointwise  |  Pointwise confidence intervals as opposed to uniform C.I.s   |


### Aggregation options

| Option | Description |
| ----- | ----- |
| simple | overall ATT	 |
| group |  ATT by groups	|
| calendar | ATT by time periods	 |
| event | event study specification	  |
| agg(*agg type*) | Different aggregation types (see help file)	 |

### Post estimation 

The following options are available within the command line:

| Option | Description |
| ----- | ----- |
| saverif() | Save the RIFs in a file	 |
| simple | overall ATT	 |

The stored results can be viewed by typing `ereturn list`.

Several post-estimation options are also available: `csdid_estat`, `csdid_stats`, and `csdid_plot`.


## Generate sample data


Here we generate a test dataset with heterogeneous interventions:

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
```

Generate the graph:


```applescript
xtline Y, overlay legend(off)
```

<img src="../../../assets/images/test_data.png" height="300">

## Test the command


For `csdid` we need the *gvar* variable which has the value of the time value when the first treatment happened for each id, and 0 if the id is not treated at all:

```
gen gvar = first_treat
recode gvar (. = 0)
```

Let's try the basic `csdid` command:

```applescript
csdid Y, ivar(id) time(t) gvar(gvar) notyet
```

And a very very long output will show up on the screen! We can now do an event study option with 10 leads and 10 lags:

```applescript
estat event, window(-10 10) estore(cs) 
```

which will show this output:

```xml
ATT by Periods Before and After treatment
Event Study:Dynamic effects
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
        Tm10 |   .3917418   .3493034     1.12   0.262    -.2928803    1.076364
         Tm9 |  -.0720548   .2991634    -0.24   0.810    -.6584043    .5142947
         Tm8 |   .0197712   .3119967     0.06   0.949    -.5917311    .6312735
         Tm7 |  -.2900224    .346774    -0.84   0.403    -.9696869    .3896422
         Tm6 |  -.1089479   .3190294    -0.34   0.733     -.734234    .5163383
         Tm5 |    .092667   .3352292     0.28   0.782    -.5643702    .7497042
         Tm4 |   .2572878   .3222909     0.80   0.425    -.3743907    .8889663
         Tm3 |   .0639963   .4214074     0.15   0.879    -.7619471    .8899396
         Tm2 |   .1944381   .3707239     0.52   0.600    -.5321673    .9210435
         Tm1 |  -.1308918   .4307277    -0.30   0.761    -.9751027     .713319
         Tp0 |  -.0608394   .3220462    -0.19   0.850    -.6920383    .5703595
         Tp1 |    8.49767   .3964781    21.43   0.000     7.720587    9.274753
         Tp2 |   17.64773   .4650298    37.95   0.000     16.73629    18.55917
         Tp3 |    25.9377   .5978201    43.39   0.000     24.76599     27.1094
         Tp4 |   34.62362   .9250424    37.43   0.000     32.81057    36.43667
         Tp5 |   42.85682   1.223002    35.04   0.000     40.45978    45.25386
         Tp6 |   51.93103   1.529193    33.96   0.000     48.93387    54.92819
         Tp7 |   60.13327   1.804358    33.33   0.000     56.59679    63.66975
         Tp8 |   68.82446   1.982765    34.71   0.000     64.93831    72.71061
         Tp9 |   77.30792   2.264938    34.13   0.000     72.86872    81.74712
        Tp10 |   85.78878    2.61102    32.86   0.000     80.67128    90.90629
------------------------------------------------------------------------------
```

In order to plot the estimates we can use the `event_plot` (`ssc install event_plot, replace`) command as follows: 


```applescript
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") ///
	title("csdid") xlabel(-10(1)10)) stub_lag(Tp#) stub_lead(Tm#) together	 
```

And we get this figure:

<img src="../../../assets/images/csdid_1.png" height="300">


*INCOMPLETE*

