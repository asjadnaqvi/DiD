---
layout: default
title: did_multiplegt_old
parent: Stata code
nav_order: 4
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt_old 
{: .no_toc }



## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Notes
{: .no_toc}

This is now a legacy command and should be replaced by the much faster [did_multiplegt_dyn](https://asjadnaqvi.github.io/DiD/docs/code/06_16_did_multiplegt_dyn/).

- Based on: Chaisemartin and D'Haultfœuille 2020, 2021
- Program version (if available): -
- Last checked: Nov 2024

## Installation

The following installation now adds a collection of various `did_multiplegt` commands:

```stata
ssc install did_multiplegt, replace
```

Take a look at the help file:

```stata
help did_multiplegt_old
```

## Test the command

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 

Let's try the basic `did_multiplegt_old` command:


```stata
did_multiplegt_old  Y id t D, robust_dynamic dynamic(10) placebo(10) breps(20) cluster(id) seed(0)
```

and we get this output:

```stata
DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic option is used, and of placebo tests of the parallel trends assumption if the placebo option is
used. The estimators are robust to heterogeneous effects, and to dynamic effects if the robust_dynamic option is used.

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+-----------------------------------------------------------------
    Effect_0 | -.0608394   .2767628  -.6032945   .4816157         78         23 
    Effect_1 |   8.49767   .3463686   7.818787   9.176552         78         23 
    Effect_2 |  17.64773   .4428714    16.7797   18.51576         78         23 
    Effect_3 |   25.9377   .5286248   24.90159    26.9738         78         23 
    Effect_4 |  34.62362   .7949031   33.06561   36.18163         75         23 
    Effect_5 |  42.85682   .9838843   40.92841   44.78524         64         19 
    Effect_6 |  51.93103   1.263135   49.45529   54.40677         64         19 
    Effect_7 |  60.13327   1.582643   57.03129   63.23525         64         19 
    Effect_8 |  68.82446    1.71335    65.4663   72.18263         64         19 
    Effect_9 |  77.30792   1.879409   73.62428   80.99156         64         19 
   Effect_10 |  85.78878   2.259642   81.35988   90.21768         55         19 
     Average |  40.79851   .9506058   38.93532    42.6617        762        229 
   Placebo_1 |  .1308918   .5697715  -.9858602   1.247644         78         23 
   Placebo_2 | -.0635463   .2533317  -.5600764   .4329839         78         23 
   Placebo_3 | -.1275425   .4031795  -.9177744   .6626893         78         23 
   Placebo_4 | -.3848304    .371244  -1.112469   .3428078         78         23 
   Placebo_5 | -.4583827   .2356492  -.9202551   .0034897         75         23 
   Placebo_6 | -.1875761   .3825025  -.9372809   .5621287         64         19 
   Placebo_7 |  .1194069    .335752  -.5386669   .7774807         64         19 
   Placebo_8 |  .0628537   .3785411  -.6790868   .8047943         64         19 
   Placebo_9 | -.1943704   .3368038   -.854506   .4657651         64         19 
  Placebo_10 | -.2936845   .4187626  -1.114459   .5270903         64         19 
```

The command also produces by default an event-study graph, unless the **firstdiff_placebo** option is specified: in that case, we do not recommend putting together first-difference placebos and long-difference event-study estimates on the same event-study graph.

<img src="../../../assets/images/did_multiplegt_stata.png" width="100%">

We can also plot the results using the `event_plot` (`ssc install event_plot, replace`) command as follows: 

```stata
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

and we get this figure:

<img src="../../../assets/images/did_multiplegt_old.png" width="100%">


