---
layout: default
title: did_multiplegt
parent: Stata code
nav_order: 4
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



## Installation and options

```stata
ssc install did_multiplegt, replace
```

Take a look at the help file:

```stata
help did_multiplegt
```




## Test the command

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 

Let's try the basic `did_multiplegt` command:


```stata
did_multiplegt Y id t D, robust_dynamic dynamic(10) placebo(10) breps(20) cluster(id)
```

and we get this output:

```stata
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


```stata
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

and we get this figure:

<img src="../../../assets/images/cd_3.png" height="300">


