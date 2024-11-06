---
layout: default
title: lpdid
parent: Stata code
nav_order: 11
mathjax: true
image: "../../../assets/images/DiD.png"
---

# lpdid
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Notes

- Based on: Dube et. al. (2023). [A Local Projections Approach to Difference-in-Differences](https://www.nber.org/papers/w31184)
- Program version (if available): -
- Last checked: Nov 2024



## Installation and options

```stata
ssc install lpdid, replace

ssc install reghdfe, replace  // dependency
ssc install boottest, replace  // dependency
ssc install egenmore, replace  // dependency
```

Take a look at the help file:

```stata
help lpdid
```


## Test the command


Let's try the basic command:

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 


```stata
lpdid Y, time(t) unit(id) treat(D) pre(10) post(10)
```

which will show this output:

```stata
LP-DiD Event Study Estimates

      E-time | Coeffic~t         SE          t      P>|t|  [95% co~.  interval]        obs 
-------------+----------------------------------------------------------------------------
       pre10 | -.0201543   .4056344       -.05      .9607  -.8497698   .8094613        932 
        pre9 | -.1347506   .3338661        -.4      .6895  -.8175835   .5480822        962 
        pre8 | -.1211563   .3874075       -.31      .7567  -.9134936   .6711811        992 
        pre7 | -.3739777   .4017302       -.93      .3596  -1.195608   .4476529       1022 
        pre6 | -.4470791   .3015656      -1.48       .149   -1.06385   .1696918       1052 
        pre5 | -.3550108   .3109155      -1.14      .2629  -.9909044   .2808828       1082 
        pre4 | -.0828967    .358771       -.23      .8189  -.8166658   .6508723       1112 
        pre3 | -.0590864   .3355107       -.18      .8614  -.7452829   .6271101       1142 
        pre2 |  .0997862    .448693        .22      .8256  -.8178941   1.017466       1172 
        pre1 |         0          .          .          .          .          .          . 
        tau0 | -.0746047   .3366208       -.22      .8262  -.7630715   .6138621       1202 
        tau1 |  8.573242   .3848829      22.27          0   7.786068   9.360416       1172 
        tau2 |  17.69598   .4460238      39.67          0   16.78376    18.6082       1142 
        tau3 |  26.07077   .5299135       49.2          0   24.98698   27.15457       1112 
        tau4 |  34.90456   .8004812       43.6          0    33.2674   36.54173       1082 
        tau5 |  43.23232   1.073271      40.28          0   41.03724   45.42741       1048 
        tau6 |  52.47728   1.300362      40.36          0   49.81775   55.13682       1018 
        tau7 |  60.62629   1.581023      38.35          0   57.39274   63.85985        988 
        tau8 |  69.49236   1.688231      41.16          0   66.03954   72.94518        958 
        tau9 |  77.99379   1.965505      39.68          0   73.97388    82.0137        928 
       tau10 |  85.78189   2.011471      42.65          0   81.66797   89.89581        898 

LP-DiD Pooled Estimates

             | Coeffic~t         SE          t      P>|t|  [95% co~.  interval]        obs 
-------------+----------------------------------------------------------------------------
         Pre | -.1660366   .2749978        -.6      .5507  -.7284703    .396397        932 
        Post |  43.09124   .9481363      45.45          0   41.15208   45.03039        898 

```


The command's built-in graph option gives us: 



<img src="../../../assets/images/lpdid_1.png" width="100%">



