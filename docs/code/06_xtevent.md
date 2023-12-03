---
layout: default
title: xtevent
parent: Stata code
nav_order: 12
mathjax: true
image: "../../../assets/images/DiD.png"
---

# xtevent
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction



## Installation and options

```stata
ssc install xtevent, replace
```

Take a look at the help file:

```stata
help xtevent
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
xtevent Y, pol(D) p(id) t(t) w(20) cohort(gvar) control_cohort(never_treat)
```

which shows this output:

```stata

No proxy or instruments provided. Implementing OLS estimator

You have specified cohort and control_cohort options. Event-time coefficients will be estimated with the Interaction Weighted Estimator of Sun and Abraham (2021).
warning: variance matrix is nonsymmetric or highly singular.

Linear regression, absorbing indicators            Number of obs     =     570
Absorbed variable: id                              No. of categories =      30
                                                   F(55, 485)        = 4887.00
                                                   Prob > F          =  0.0000
                                                   R-squared         =  0.9991
                                                   Adj R-squared     =  0.9990
                                                   Root MSE          =  1.3963
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   _k_eq_m21 |   .1357876          .        .       .            .           .
   _k_eq_m20 |   -.150126          .        .       .            .           .
   _k_eq_m19 |  -.2886362          .        .       .            .           .
   _k_eq_m18 |   1.001511          .        .       .            .           .
   _k_eq_m17 |  -1.524232          .        .       .            .           .
   _k_eq_m16 |   .4040116          .        .       .            .           .
   _k_eq_m15 |   .0406827          .        .       .            .           .
   _k_eq_m14 |   .1196182          .        .       .            .           .
   _k_eq_m13 |   1.180311          .        .       .            .           .
   _k_eq_m12 |   .2643562          .        .       .            .           .
   _k_eq_m11 |  -.1566494          .        .       .            .           .
   _k_eq_m10 |  -.1636734          .        .       .            .           .
    _k_eq_m9 |    .378421          .        .       .            .           .
    _k_eq_m8 |   .7320174          .        .       .            .           .
    _k_eq_m7 |   .2677505          .        .       .            .           .
    _k_eq_m6 |  -.0065124          .        .       .            .           .
    _k_eq_m5 |  -.2562236          .        .       .            .           .
    _k_eq_m4 |   .0455235          .        .       .            .           .
    _k_eq_m3 |    .177183          .        .       .            .           .
    _k_eq_m2 |   .2562286          .        .       .            .           .
    _k_eq_p0 |   .0834288          .        .       .            .           .
    _k_eq_p1 |   8.706174          .        .       .            .           .
    _k_eq_p2 |   17.65776          .        .       .            .           .
    _k_eq_p3 |   26.50699          .        .       .            .           .
    _k_eq_p4 |   35.77882          .        .       .            .           .
    _k_eq_p5 |   43.81289          .        .       .            .           .
    _k_eq_p6 |   53.43996          .        .       .            .           .
    _k_eq_p7 |   69.77442          .        .       .            .           .
    _k_eq_p8 |   79.86261          .        .       .            .           .
    _k_eq_p9 |   89.59572          .        .       .            .           .
   _k_eq_p10 |    99.8721          .        .       .            .           .
   _k_eq_p11 |   109.2024          .        .       .            .           .
   _k_eq_p12 |    119.943          .        .       .            .           .
   _k_eq_p13 |   129.5638          .        .       .            .           .
   _k_eq_p14 |   140.1471          .        .       .            .           .
   _k_eq_p15 |   149.8544          .        .       .            .           .
   _k_eq_p16 |   160.9501          .        .       .            .           .
   _k_eq_p17 |          0  (omitted)
   _k_eq_p18 |          0  (omitted)
   _k_eq_p19 |          0  (omitted)
   _k_eq_p20 |          0  (omitted)
   _k_eq_p21 |          0  (omitted)
             |
           t |
         23  |   1.217965          .        .       .            .           .
         24  |   2.095903          .        .       .            .           .
         25  |   3.252631          .        .       .            .           .
         26  |   4.563759          .        .       .            .           .
         27  |   6.070876          .        .       .            .           .
         28  |   7.544779          .        .       .            .           .
         29  |   8.929311          .        .       .            .           .
         30  |   10.02112          .        .       .            .           .
         31  |   10.26208          .        .       .            .           .
         32  |   11.99903          .        .       .            .           .
         33  |   12.76723          .        .       .            .           .
         34  |     13.821          .        .       .            .           .
         35  |   14.24483          .        .       .            .           .
         36  |   15.16298          .        .       .            .           .
         37  |    15.8125          .        .       .            .           .
         38  |   16.35458          .        .       .            .           .
         39  |   16.49738          .        .       .            .           .
         40  |   16.30867          .        .       .            .           .
             |
       _cons |    36.6592          .        .       .            .           .
------------------------------------------------------------------------------

```


The graph can be generated as follows using `event_plot` command:


```
matrix xt_b = e(b) 
matrix xt_v = e(V)

	event_plot xt_b#xt_v, default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect")  ///
		title("xtevent")) stub_lag(_k_eq_p#) stub_lead(_k_eq_m#) together

```

<img src="../../../assets/images/xtevent_1.png" height="300">



