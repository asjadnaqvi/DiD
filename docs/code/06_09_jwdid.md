---
layout: default
title: jwdid
parent: Stata code
nav_order: 9
mathjax: true
image: "../../../assets/images/DiD.png"
---

# jwdid
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---



## Notes

- Based on: [Wooldridge 2021](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3906345), [Wooldridge 2023](https://academic.oup.com/ectj/article/26/3/C31/7250479).
- Program version (if available): v2.00 Paper Out
- Last checked: Nov 2024



## Installation and options

```stata
ssc install jwdid, replace
ssc install hdfe, replace
```

Take a look at the help file:

```stata
help jwdid // dependency
```



## Test the command

Please make sure that you generate the data using the script given [here](https://asjadnaqvi.github.io/DiD/docs/code/06_03_data/) 


Let's try the basic `jwdid` command:

```stata
jwdid Y, ivar(id) time(t) gvar(gvar)  never
```

which will should show this output:

```stata
WARNING: Singleton observations not dropped; statistical significance is biased (link)
(MWFE estimator converged in 2 iterations)
warning: missing F statistic; dropped variables due to collinearity or too few clusters

HDFE Linear regression                            Number of obs   =      1,800
Absorbing 2 HDFE groups                           F( 236,     29) =          .
Statistics robust to heteroskedasticity           Prob > F        =          .
                                                  R-squared       =     0.9999
                                                  Adj R-squared   =     0.9999
                                                  Within R-sq.    =     0.9996
Number of clusters (id)      =         30         Root MSE        =     1.0111

                                       (Std. err. adjusted for 30 clusters in id)
---------------------------------------------------------------------------------
                |               Robust
              Y | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
----------------+----------------------------------------------------------------
gvar#t#c.__tr__ |
         24  1  |  -.3046101   .6300019    -0.48   0.632    -1.593109    .9838884
         24  2  |  -.6957401   .6009789    -1.16   0.256     -1.92488    .5333998
         24  3  |   .1275004   .8770109     0.15   0.885    -1.666188    1.921189
         24  4  |  -.1772073   .8058568    -0.22   0.827    -1.825369    1.470955
         24  5  |  -.8972072   .6524983    -1.38   0.180    -2.231716    .4373016
         24  6  |  -1.275086   .9782155    -1.30   0.203    -3.275761    .7255895
         24  7  |  -.8707661   .7651948    -1.14   0.264    -2.435765    .6942331
         24  8  |  -.3766007   .8382016    -0.45   0.657    -2.090915    1.337714
         24  9  |  -.1285843   1.224015    -0.11   0.917    -2.631975    2.374807
         24 10  |   .0283149   .7864521     0.04   0.972     -1.58016     1.63679
         24 11  |  -.3418546   1.044269    -0.33   0.746    -2.477625    1.793915
         24 12  |  -.7545786   .9622937    -0.78   0.439     -2.72269    1.213533
         24 13  |  -.3072581   .7502999    -0.41   0.685    -1.841794    1.227277


                                 <OUTPUT TRUNCATED>

         56 47  |  -.8615277   .7908704    -1.09   0.285    -2.479039    .7559838
         56 48  |  -1.330157   .9825658    -1.35   0.186     -3.33973    .6794157
         56 49  |  -1.344657   1.225782    -1.10   0.282    -3.851662    1.162348
         56 50  |   -1.55924   .9140308    -1.71   0.099    -3.428643    .3101628
         56 51  |  -.6348989   .7432368    -0.85   0.400    -2.154989    .8851911
         56 52  |  -.4315613     1.2208    -0.35   0.726    -2.928377    2.065255
         56 53  |  -.0581789   .9713858    -0.06   0.953    -2.044886    1.928528
         56 54  |  -.0270778    .872869    -0.03   0.975    -1.812295     1.75814
         56 56  |  -.1821628   1.075073    -0.17   0.867    -2.380934    2.016609
         56 57  |   7.908278   .8946205     8.84   0.000     6.078574    9.737983
         56 58  |   17.82876    .804218    22.17   0.000     16.18395    19.47357
         56 59  |   25.96505   .8421089    30.83   0.000     24.24275    27.68736
         56 60  |   35.58904   1.318965    26.98   0.000     32.89146    38.28663
                |
          _cons |   46.05389   .2379501   193.54   0.000     45.56723    46.54056
---------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
          id |        30          30           0    *|
           t |        60           1          59     |
-----------------------------------------------------+
* = FE nested within cluster; treated as redundant for DoF computation

```


The command's built-in graph option gives us: 


```stata
estat event,  estore(jw) 

jwdid_plot
```


<img src="../../../assets/images/jwdid_1.png" width="100%">



