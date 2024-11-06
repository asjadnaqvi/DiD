---
layout: default
title: did_multiplegt_dyn
parent: Stata code
nav_order: 4
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt_dyn 
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Notes

- Based on: Chaisemartin and D'Haultfœuille 2024
- Program version (if available): -
- Last checked: Nov 2024

## Installation

```stata
ssc install did_multiplegt_dyn, replace
```

Take a look at the help file:

```stata
help did_multiplegt_dyn
```

## Test the command

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 

Let's try the basic `did_multiplegt_dyn` command:


```stata
did_multiplegt_dyn Y id t D, effects(10) placebo(10) cluster(id)
```

and we get this output:

```stata
--------------------------------------------------------------------------------
             Estimation of treatment effects: Event-study effects
--------------------------------------------------------------------------------

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+-----------------------------------------------------------------
    Effect_1 | -.0608394   .3275515  -.7028286   .5811498         78         23 
    Effect_2 |   8.49767   .3888474   7.735543   9.259797         78         23 
    Effect_3 |  17.64773   .3877416   16.88777   18.40769         78         23 
    Effect_4 |   25.9377   .3203208   25.30988   26.56551         78         23 
    Effect_5 |  34.62362   .3923778   33.85458   35.39267         75         23 
    Effect_6 |  42.85682   .3893014   42.09381   43.61984         64         19 
    Effect_7 |  51.93103   .3963844   51.15413   52.70793         64         19 
    Effect_8 |  60.13327   .3945513   59.35997   60.90658         64         19 
    Effect_9 |  68.82446   .4118019   68.01735   69.63158         64         19 
   Effect_10 |  77.30792   .4396869   76.44615   78.16969         64         19 
--------------------------------------------------------------------------------
Test of joint nullity of the effects : p-value = 0


--------------------------------------------------------------------------------
               Average cumulative (total) effect per treatment unit
--------------------------------------------------------------------------------

             |  Estimate         SE      LB CI      UB CI          N     Switch  x Periods 
-------------+----------------------------------------------------------------------------
  Av_tot_eff |  36.72796   .2689364   36.20085   37.25506        641        210            
--------------------------------------------------------------------------------
Average number of time periods over which a treatment's effect is accumulated = 5.2619048


--------------------------------------------------------------------------------
          Testing the parallel trends and no anticipation assumptions
--------------------------------------------------------------------------------

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+-----------------------------------------------------------------
   Placebo_1 |  .1308918   .4574125  -.7656203   1.027404         78         23 
   Placebo_2 | -.0635463   .3403349  -.7305904   .6034978         78         23 
   Placebo_3 | -.1275425   .3855322  -.8831717   .6280867         78         23 
   Placebo_4 | -.3848303   .3223237  -1.016573   .2469125         78         23 
   Placebo_5 | -.4583828   .3389718  -1.122755   .2059897         75         23 
   Placebo_6 |  -.187576   .4510044  -1.071528   .6963763         64         19 
   Placebo_7 |  .1194068   .4068627  -.6780295   .9168431         64         19 
   Placebo_8 |  .0628537   .4251272  -.7703804   .8960877         64         19 
   Placebo_9 | -.1943702   .4963493  -1.167197   .7784565         64         19 
  Placebo_10 | -.2936846   .5040208  -1.281547    .694178         64         19 
--------------------------------------------------------------------------------
Test of joint nullity of the placebos : p-value = .01289977


The development of this package was funded by the European Union (ERC, REALLYCREDIBLE,GA N°101043899).

```

If the **graph_off** option is not specified, the command always returns by default an event-study graph:

<img src="../../../assets/images/did_multiplegt_dyn1.png" width="100%">

It is also possible to use `event_plot` to produce the event-study graph:

```stata
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt_dyn") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

<img src="../../../assets/images/did_multiplegt_dyn2.png" width="100%">
