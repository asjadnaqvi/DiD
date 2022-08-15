---
layout: default
title: did2s
parent: R code
nav_order: 3
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did2s (Gardner 2021)
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
install.packages("did2s") # Install (only need to run once or when updating)
library("did2s")          # Load the package into memory (required each new session)
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
library(did2s)
```

```r
d2s = did2s(
  data         = dat,
  yname        = "y", 
  treatment    = "treat", 
  cluster_var  = "id",
  first_stage  = ~ 0 | id + time,
  second_stage = ~ i(rel_time, ref = -c(1,Inf))
  )
d2s
#' OLS estimation, Dep. Var.: y
#' Observations: 1,800 
#' Standard-errors: Custom 
#' rel_time::-43  -0.049719   0.272847   -0.182224 0.8554282    
#' rel_time::-42  -0.150764   0.196905   -0.765670 0.4439783    
#' rel_time::-41   0.411294   0.419485    0.980472 0.3269918    
#' rel_time::-40  -0.060809   0.285788   -0.212777 0.8315264    
#' rel_time::-39  -0.104809   0.445865   -0.235069 0.8141833    
#' <truncated>
#' ---
#' Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#' RMSE: 25.7   Adj. R2: 0.939163

```

```r
# fixest::iplot(d2s) # Vanilla option is fine, but we can tweak a bit...
d2s |>
  fixest::iplot(
    main     = "did2s",
    xlab     = "Time to treatment",
    drop     = "[[:digit:]]{2}",    # Drop any leads/lags greater than |9|
    ref.line = 1
  )
```

<img src="../../../assets/images/did2s_R.png" height="300">