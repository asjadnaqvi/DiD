---
layout: default
title: eventstudyinteract
parent: Stata code
nav_order: 7
mathjax: true
image: "../../../assets/images/DiD.png"
---

# eventstudyinteract
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Notes

- Based on: Sun and Abraham (2020). [Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects](https://www.sciencedirect.com/science/article/pii/S030440762030378X).
- Program version (if available): 0.5
- Last checked: Nov 2024
- Additional info in this [blog post](https://kylebutts.com/blog/posts/2021-05-24-two-stage-difference-in-differences/).


## Installation and options


```stata
ssc install eventstudyinteract, replace
```

Take a look at the help file:

```stata
help eventstudyinteract
```


## Test the command

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 



Let's try the basic `eventstudyinteract` command the never_treated as the `control_cohort`:

```stata
eventstudyinteract Y L_* F_*, vce(cluster id) absorb(id t) cohort(first_treat) control_cohort(never_treat)
```


which will show this output:

```stata
IW estimates for dynamic effects                        Number of obs =  1,800
Absorbing 2 HDFE groups                                 F(236, 29)    =      .
                                                        Prob > F      =      .
                                                        R-squared     = 0.9999
                                                        Adj R-squared = 0.9999
                                                        Root MSE      = 1.0114
                                    (Std. err. adjusted for 30 clusters in id)
------------------------------------------------------------------------------
             |               Robust
           Y | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         L_0 |  -.0705566   .4520534    -0.16   0.877    -.9951096    .8539963
         L_1 |   8.477542   .4379319    19.36   0.000     7.581871    9.373214
         L_2 |   17.69445   .6109211    28.96   0.000     16.44497    18.94392
         L_3 |   25.97508   .6262269    41.48   0.000      24.6943    27.25585
         L_4 |   34.74591   .9050206    38.39   0.000     32.89493    36.59688
         L_5 |    42.5053   1.223893    34.73   0.000     40.00216    45.00845
         L_6 |   51.87653   1.498852    34.61   0.000     48.81103    54.94202
         L_7 |   60.49124   1.799291    33.62   0.000     56.81128     64.1712
         L_8 |    69.1176   1.982205    34.87   0.000     65.06353    73.17167
         L_9 |   77.28842   2.229958    34.66   0.000     72.72764     81.8492
        L_10 |   85.61498   2.555366    33.50   0.000     80.38867    90.84129
        L_11 |   93.99587   2.708476    34.70   0.000     88.45642    99.53533
        L_12 |   103.5575   3.047215    33.98   0.000     97.32524    109.7897

                                 <OUTPUT TRUNCATED>

        F_44 |   .4711243   .7455523     0.63   0.532    -1.053701     1.99595
        F_45 |  -1.302809   .9750776    -1.34   0.192    -3.297066    .6914491
        F_46 |  -.1432933   .5311437    -0.27   0.789    -1.229604    .9430176
        F_47 |  -.5297326   1.077463    -0.49   0.627    -2.733392    1.673927
        F_48 |  -.3128089    .743813    -0.42   0.677    -1.834077    1.208459
        F_49 |  -.0590544   .7666954    -0.08   0.939    -1.627123    1.509014
        F_50 |  -1.156447   .3122062    -3.70   0.001     -1.79498   -.5179134
        F_51 |  -.2063065   .7599222    -0.27   0.788    -1.760522    1.347909
        F_52 |   .0657318   .5711765     0.12   0.909    -1.102455    1.233919
        F_53 |  -.5740659   .5549477    -1.03   0.309    -1.709061    .5609296
        F_54 |   .3670635   1.075711     0.34   0.735    -1.833013     2.56714
        F_55 |  -.4353981   .7411865    -0.59   0.561    -1.951295    1.080498
------------------------------------------------------------------------------
```


In order to plot the estimates we can use the `event_plot` (`ssc install event_plot, replace`) command where we restrict the figure to 10 leads and lags: 


```stata
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-10(1)10) ///
		title("eventstudyinteract")) stub_lag(L_#) stub_lead(F_#) trimlag(10) trimlead(10) together
```

And we get:

<img src="../../../assets/images/eventstudyinteract_1.png" width="100%">

