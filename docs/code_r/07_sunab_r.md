---
layout: default
title: sunab
parent: R code
nav_order: 6
mathjax: true
image: "../../../assets/images/DiD.png"
---

# fixest::sunab (Sun and Abraham 2020)
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
install.packages("fixest") # Install (only need to run once or when updating)
library("fixest")          # Load the package into memory (required each new session)
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
library(fixest)
```

```r
sa = feols(
    y ~ sunab(first_treat, rel_time) | id + time, 
    data = dat
    )
sa
#' OLS estimation, Dep. Var.: y
#' Observations: 1,800 
#' Fixed-effects: id: 30,  time: 60
#' Standard-errors: Clustered (id) 
#'                Estimate Std. Error   t value Pr(>|t|)    
#' rel_time::-43 -0.992231   0.833177 -1.190901 0.243349    
#' rel_time::-42 -0.682967   0.725131 -0.941854 0.354048    
#' rel_time::-41  0.055083   0.902155  0.061057 0.951733    
#' rel_time::-40 -0.350181   0.549271 -0.637537 0.528777    
#' rel_time::-39 -0.433172   1.175733 -0.368427 0.715231    
#' rel_time::-38 -1.877821   0.949817 -1.977035 0.057614 .  
#' rel_time::-37 -1.994746   0.898465 -2.220171 0.034382 *  
#' rel_time::-36 -0.734659   0.840305 -0.874276 0.389151    
#' ... 83 coefficients remaining (display them with summary() or use argument n)
#' ---
#' Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#' RMSE: 0.913773     Adj. R2: 0.999927
#'                  Within R2: 0.999686
```

```r
# iplot(sa) # Vanilla option is fine, but we can tweak a bit...
sa |>
  iplot(
    main     = "fixest::sunab",
    xlab     = "Time to treatment",
    drop     = "[[:digit:]]{2}",    # Drop leads/lags greater than |9|
    ref.line = 1
    )
```

<img src="../../../assets/images/sunab_R.png" height="300">