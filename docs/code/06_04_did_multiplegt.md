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

## Note
{: .no_toc}

To estimate event-study/dynamic effects, we strongly recommend using the <ins>much faster</ins> [did_multiplegt_dyn](https://asjadnaqvi.github.io/DiD/docs/code/06_16_did_multiplegt_dyn/) command. 

In addition to that, did_multiplegt_dyn offers more options than did_multiplegt, among which:
+ **normalized**: estimation of the normalized dynamic effects (de Chaisemartin & D'Haultfoeuille, 2024);
+ **predict_het**: built-in treatment effect heterogeneity analysis;
+ **design** and **date_first_switch**: post-estimation options to analyze the design and timing of the treatment;
+ **by** and **by_path**: estimating dynamic effects within levels of a group-level variable or within treatment paths;
+ **trends_lin**: built-in group-specific linear trends.

Lastly, as of the last release, did_multiplegt_dyn also includes two user-requested features:
+ **only_never_switchers**: restricting the estimators from de Chaisemartin & D'Haultfoeuille (2024) to only compare switchers and never-switchers;
+ integration with **esttab**: here a quick [tutorial](https://github.com/chaisemartinPackages/did_multiplegt_dyn/blob/main/vignettes/vignette_2.md).

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

```
DID estimators of the instantaneous treatment effect, of dynamic treatment effects if the dynamic option is used, and of placebo tests of the parallel trends assumption if the placebo option is used. The estimators are robust to heterogeneous effects, and to dynamic effects if the robust_dynamic option is used.

             |  Estimate         SE      LB CI      UB CI          N  Switchers 
-------------+-----------------------------------------------------------------
    Effect_0 | -.0608394   .3385877  -.7244714   .6027925         78         23 
    Effect_1 |   8.49767   .5275372   7.463697   9.531643         78         23 
    Effect_2 |  17.64773   .5603101   16.54952   18.74594         78         23 
    Effect_3 |   25.9377   .7248335   24.51702   27.35837         78         23 
    Effect_4 |  34.62362   1.156474   32.35693   36.89031         75         23 
    Effect_5 |  42.85682   1.351173   40.20852   45.50512         64         19 
    Effect_6 |  51.93103   1.752829   48.49548   55.36658         64         19 
    Effect_7 |  60.13327   2.030397   56.15369   64.11285         64         19 
    Effect_8 |  68.82446   2.307799   64.30118   73.34775         64         19 
    Effect_9 |  77.30792   2.459029   72.48822   82.12762         64         19 
   Effect_10 |  85.78878   2.787185    80.3259   91.25166         55         19 
     Average |  40.79851   1.296695   38.25699   43.34003        762        229 
   Placebo_1 |  .1308918   .4749145  -.7999405   1.061724         78         23 
   Placebo_2 | -.0635463   .3918012  -.8314767   .7043841         78         23 
   Placebo_3 | -.1275425   .3842444  -.8806616   .6255766         78         23 
   Placebo_4 | -.3848304   .3772655  -1.124271     .35461         78         23 
   Placebo_5 | -.4583827   .3471871  -1.138869   .2221039         75         23 
   Placebo_6 | -.1875761   .3364545  -.8470269   .4718747         64         19 
   Placebo_7 |  .1194069   .4117733  -.6876687   .9264825         64         19 
   Placebo_8 |  .0628537   .4481983  -.8156149   .9413223         64         19 
   Placebo_9 | -.1943704   .4845458   -1.14408   .7553393         64         19 
  Placebo_10 | -.2936845   .5014765  -1.276578   .6892093         64         19 
```

The command also produces by default an event-study graph (unless the **firstdiff_placebo** option is specified):

<img src="../../../assets/images/did_multiplegt_stata.png" height="300">

We can also plot the results using the `event_plot` (`ssc install event_plot, replace`) command as follows: 

```stata
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("did_multiplegt") xlabel(-10(1)10)) stub_lag(Effect_#) stub_lead(Placebo_#) together
```

and we get this figure:

<img src="../../../assets/images/did_multiplegt_stata_ep.png" height="300">


