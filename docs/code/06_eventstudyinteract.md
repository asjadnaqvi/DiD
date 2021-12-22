---
layout: default
title: eventstudyinteract
parent: Stata code
nav_order: 6
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

The *eventstudyinteract* command is written by Liyang Sun based on the Sun and Abraham 2020 paper [Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects](https://www.sciencedirect.com/science/article/pii/S030440762030378X).

The command potentially has some issues. See the code and the graphs below. Some more testing is required. If you have some insights on how to fix this, then please email, or post in the [issues](https://github.com/asjadnaqvi/DiD/issues) section on GitHub.

## Installation and options

```applescript
ssc install eventstudyinteract, replace
```

Take a look at the help file:

```applescript
help eventstudyinteract
```

The core syntax is as follows:

```applescript
eventstudyinteract Y *lags* *leads*, vce(cluster *var*) absorb(*i* *t*) cohort(first_treat) control_cohort(*variable*)
```

where: 

| Variable | Description |
| ----- | ----- |
| Y | outcome variable |
| i | panel id |
| t | time variable  |
| *lags* | manually generated lag variables  |
| *leads* | manually generated lead variables  |
| first_treat | timing of first treatment (missing for untreated groups) |
| control_cohort(*var*) | The variable here is either never treated observations, or last treated cohorts  |


### The options

| Option | Description |


*INCOMPLETE*


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


For `eventstudyinteract` we need to generate 10 leads and lags and drop the first lead:

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

and we need to generate the `control_cohort` variables. Here we generate the `never_treated` and `last_cohort` variables as suggested in the help file:

```
gen never_treat = first_treat==.

sum first_treat
gen last_cohort = first_treat==r(max) // dummy for the latest- or never-treated cohort
```



Let's try the basic `eventstudyinteract` command the never_treated as the `control_cohort`:

```applescript
eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)
```


which will show this output:

```xml
IW estimates for dynamic effects                       Number of obs =   1,800
Absorbing 2 HDFE groups                                F(74, 29)     =       .
                                                       Prob > F      =       .
                                                       R-squared     =  0.8289
                                                       Adj R-squared =  0.8118
                                                       Root MSE      = 40.6783
                                    (Std. err. adjusted for 30 clusters in id)
------------------------------------------------------------------------------
             |               Robust
           Y | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         L_0 |  -82.83641   9.395219    -8.82   0.000    -102.0518   -63.62103
         L_1 |  -72.09706   9.606305    -7.51   0.000    -91.74416   -52.44996
         L_2 |  -66.28563   9.387735    -7.06   0.000     -85.4857   -47.08555
         L_3 |  -59.53088   9.654911    -6.17   0.000    -79.27739   -39.78437
         L_4 |  -57.36642   9.575378    -5.99   0.000    -76.95027   -37.78257
         L_5 |  -39.75675   9.060562    -4.39   0.000    -58.28768   -21.22581
         L_6 |  -33.14397   8.537269    -3.88   0.001    -50.60465    -15.6833
         L_7 |  -27.89437    7.86436    -3.55   0.001     -43.9788   -11.80995
         L_8 |  -23.26935   7.097292    -3.28   0.003    -37.78494   -8.753756
         L_9 |  -9.696573   5.205239    -1.86   0.073    -20.34248    .9493362
        L_10 |  -11.75181   7.008037    -1.68   0.104    -26.08486    2.581231
         F_2 |  -74.56978   7.895172    -9.44   0.000    -90.71722   -58.42234
         F_3 |  -73.05913   7.860883    -9.29   0.000    -89.13645   -56.98182
         F_4 |  -73.13007   7.492343    -9.76   0.000    -88.45363    -57.8065
         F_5 |  -69.47478   8.197212    -8.48   0.000    -86.23996    -52.7096
         F_6 |  -71.25639   7.298475    -9.76   0.000    -86.18344   -56.32933
         F_7 |  -67.85099   7.697344    -8.81   0.000    -83.59383   -52.10815
         F_8 |  -66.67338   7.647583    -8.72   0.000    -82.31445   -51.03232
         F_9 |    -65.677   7.560869    -8.69   0.000    -81.14071   -50.21328
        F_10 |   -64.7154   7.532503    -8.59   0.000     -80.1211    -49.3097
------------------------------------------------------------------------------

```


In order to plot the estimates we can use the `event_plot` (`ssc install event_plot, replace`) command as follows: 


```applescript
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("eventstudyinteract")) stub_lag(L_#) stub_lead(F_#) together
```

And we get:

<img src="../../../assets/images/eventstudyinteract_1.png" height="300">


We can see in the figure that the leads are not centered on the y = 0 axis. [Dont't know why. CHECK!]


If we use the last treated cohort, we can change the specification as follows:

```applescript
sum first_treat if last_cohort==1
eventstudyinteract Y L_* F_* if t<`r(max)' & first_treat!=., vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(last_cohort)
```

Note that we also control here for the `first_treat` and time variables as specified in the help file. The output looks like this:

```xml

IW estimates for dynamic effects                       Number of obs =   1,265
Absorbing 2 HDFE groups                                F(60, 22)     =       .
                                                       Prob > F      =       .
                                                       R-squared     =  0.8613
                                                       Adj R-squared =  0.8444
                                                       Root MSE      = 34.3817
                                    (Std. err. adjusted for 23 clusters in id)
------------------------------------------------------------------------------
             |               Robust
           Y | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         L_0 |  -66.26598   6.837144    -9.69   0.000    -80.44535   -52.08661
         L_1 |  -57.05853   6.487161    -8.80   0.000    -70.51208   -43.60498
         L_2 |  -52.46636    5.77124    -9.09   0.000    -64.43518   -40.49754
         L_3 |  -43.84229   7.212854    -6.08   0.000    -58.80083   -28.88375
         L_4 |  -48.74179   6.611497    -7.37   0.000    -62.45319   -35.03038
         L_5 |  -44.35501   7.036249    -6.30   0.000     -58.9473   -29.76272
         L_6 |    -39.481   7.351562    -5.37   0.000    -54.72721   -24.23479
         L_7 |  -34.37319   6.779934    -5.07   0.000    -48.43391   -20.31247
         L_8 |  -29.52601   7.405083    -3.99   0.001    -44.88321   -14.16881
         L_9 |  -13.22114   7.475413    -1.77   0.091     -28.7242    2.281915
        L_10 |  -20.05019   9.161253    -2.19   0.040    -39.04947   -1.050914
         F_2 |  -58.01175   4.941714   -11.74   0.000    -68.26023   -47.76326
         F_3 |  -57.14052   5.272664   -10.84   0.000    -68.07535   -46.20568
         F_4 |  -57.23198   5.211914   -10.98   0.000    -68.04082   -46.42313
         F_5 |  -52.71426   7.287313    -7.23   0.000    -67.82722    -37.6013
         F_6 |  -57.57459   5.194812   -11.08   0.000    -68.34797   -46.80121
         F_7 |  -51.03113   7.869797    -6.48   0.000    -67.35209   -34.71018
         F_8 |   -50.6043   7.934163    -6.38   0.000    -67.05875   -34.14985
         F_9 |  -50.75468   7.803604    -6.50   0.000    -66.93837     -34.571
        F_10 |  -50.96601   7.846942    -6.50   0.000    -67.23957   -34.69245
------------------------------------------------------------------------------
```

We can plot this as follows:


```applescript
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("eventstudyinteract")) stub_lag(L_#) stub_lead(F_#) together
```
and we get this figure:

<img src="../../../assets/images/eventstudyinteract_2.png" height="300">


It has the same issue as above. The leads are not centered around zero. [CHECK!]


*INCOMPLETE*

