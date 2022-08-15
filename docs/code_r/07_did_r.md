---
layout: default
title: did
parent: R code
nav_order: 2
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did (Callaway and Sant'Anna 2021)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

_TO-DO: Add text._

## Introduction

_INCOMPLETE_

## Installation and options

The package can be installed from CRAN.

```r
install.packages("did") # Install (only need to run once or when updating)
library("did")          # Load the package into memory (required each new session)
```

_INCOMPLETE_

## Dataset

To demonstrate the package in action, we'll use the fake dataset that we 
[created earlier]({{ "/07_code_r#data-generation" | relative_url }}). Here's a 
reminder of what the data look like.

```r
head(dat)
#>   time id        y rel_time treat first_treat
#> 1    1  1 2.158289      -11 FALSE          12
#> 2    2  1 2.498052      -10 FALSE          12
#> 3    3  1 3.034077       -9 FALSE          12
#> 4    4  1 4.886266       -8 FALSE          12
#> 5    5  1 7.085950       -7 FALSE          12
#> 6    6  1 5.788352       -6 FALSE          12
```

Or, in graph form.

<img src="../../../assets/images/test_data_R.png" height="300">


## Test the package

Remember to load the package (if you haven't already).

```r
library(did)
```

```r
cs = att_gt(
    yname         = "y",
    tname         = "time",
    idname        = "id",
    gname         = "first_treat",
    control_group = "notyettreated",#  Too few groups for "nevertreated" default
    clustervars   = "id", 
    data          = dat
    )
```

```r
cs_es = aggte(cs, type = "dynamic", min_e = -10, max_e = 10)
cs_es
#' Call:
#' aggte(MP = cs, type = "dynamic", min_e = -10, max_e = 10)
#' 
#' Reference: Callaway, Brantly and Pedro H.C. Sant'Anna.  "Difference-in-Differences with Multiple Time Periods." Journal of Econometrics, Vol. 225, No. 2, pp. 200-230, 2021. <https://doi.org/10.1016/j.jeconom.2020.12.001>, <https://arxiv.org/abs/1803.09015> 
#' 
#' 
#' Overall summary of ATT's based on event-study/dynamic aggregation:  
#'     ATT    Std. Error     [ 95%  Conf. Int.]  
#'  30.183        2.2437    25.7853     34.5807 *
#' 
#' 
#' Dynamic Effects:
#'  Event time Estimate Std. Error [95% Simult.  Conf. Band]  
#'         -10   0.1890     0.3215       -0.6810      1.0589  
#'          -9  -0.4952     0.5115       -1.8792      0.8889  
#'          -8  -0.0711     0.4076       -1.1740      1.0318  
#'          -7   0.4991     0.2262       -0.1129      1.1112  
#'          -6  -0.9216     0.3219       -1.7925     -0.0508 *
#'          -5   0.5933     0.4658       -0.6671      1.8538  
#'          -4  -0.2031     0.2951       -1.0017      0.5954  
#'          -3   0.3527     0.4170       -0.7757      1.4810  
#'          -2  -0.1218     0.4732       -1.4022      1.1586  
#'          -1   0.2054     0.4968       -1.1388      1.5496  
#'           0  -0.4572     0.4672       -1.7212      0.8069  
#'           1   6.0124     0.5745        4.4578      7.5670 *
#'           2  12.1593     0.9938        9.4702     14.8483 *
#'           3  17.7974     1.2370       14.4504     21.1444 *
#'           4  23.8820     1.7787       19.0693     28.6946 *
#'           5  29.8164     2.2644       23.6894     35.9434 *
#'           6  36.4129     2.5552       29.4991     43.3267 *
#'           7  42.9080     2.8311       35.2477     50.5683 *
#'           8  48.4004     3.8096       38.0925     58.7083 *
#'           9  54.3290     3.6510       44.4502     64.2079 *
#'          10  60.7524     4.2551       49.2392     72.2657 *
#' ---
#' Signif. codes: `*' confidence band does not cover 0
#' 
#' Control Group:  Not Yet Treated,  Anticipation Periods:  0
#' Estimation Method:  Doubly Robust

```r
ggdid(cs_es, title = "(cs)did")
```

<img src="../../../assets/images/csdid_R.png" height="300">