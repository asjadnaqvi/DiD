---
layout: default
title: R code
nav_order: 7
permalink: /docs/code_r
has_children: true
mathjax: true
image: "../../../assets/images/DiD.png"
---

# R code

This section aims to cover the R estimation commands from various packages. 
Click on the navigation links at the bottom of the page to see detailed 
implementation code for a specific package.

Before we start, you can refer to the following glossary table for symbols:

| Symbol | Description | 
| $$ id $$ | panel id |
| $$ time $$ | time variable |
| $$ y $$ | outcome variable |
| $$ treat $$ | =1 if treated observation |
| $$ \epsilon $$ | error term |

## Data generation

All of the R code in this section will make use of the same fake dataset, which
we generate below. This dataset will closely mimic the equivalent dataset used
in the [Stata examples]({{ "/docs/code" | relative_url }}). But it won't be 
_exactly_ the same because of different random seeds (**important!**). This means 
that you shouldn't expect the same results when comparing the R and Stata examples
on this website. (Unless, of course, you explicitly use the same dataset.)

```r
set.seed(123456L)

# 60 time periods, 30 individuals, and 5 waves of treatment
tmax = 60; imax = 30; nlvls = 5

dat = 
  expand.grid(time = 1:tmax, id = 1:imax) |>
  within({
    
    cohort      = NA
    effect      = NA
    first_treat = NA
    
    for (chrt in 1:imax) {
      cohort = ifelse(id==chrt, sample.int(nlvls, 1), cohort)
    }
    
    for (lvls in 1:nlvls) {
      effect      = ifelse(cohort==lvls, sample(2:10, 1), effect)
      first_treat = ifelse(cohort==lvls, sample(1:(tmax+20), 1), first_treat)
    }
    
    first_treat = ifelse(first_treat>tmax, Inf, first_treat)
    treat       = time>=first_treat
    rel_time    = time - first_treat
    y           = id + time + ifelse(treat, effect*rel_time, 0) + rnorm(imax*tmax)
    
    rm(chrt, lvls, cohort, effect)
  })

head(dat)
#>   time id        y rel_time treat first_treat
#> 1    1  1 2.158289      -11 FALSE          12
#> 2    2  1 2.498052      -10 FALSE          12
#> 3    3  1 3.034077       -9 FALSE          12
#> 4    4  1 4.886266       -8 FALSE          12
#> 5    5  1 7.085950       -7 FALSE          12
#> 6    6  1 5.788352       -6 FALSE          12
```

The dataset is easier to understand visually, so here it is in plot form. I'll
use the **lattice** package instead of **ggplot2**, since the former comes
bundled with the base R installation.

```r
library(lattice)
# Some (optional!) plot theme settings
trellis.par.set(list(
  axis.line      = list(col = NA),
  reference.line = list(col = "gray85", lty = 3),
  superpose.line = list(col = hcl.colors(imax, "SunsetDark")),
  par.xlab.text  = list(fontfamily = "ArialNarrow"),
  par.ylab.text  = list(fontfamily = "ArialNarrow"),
  axis.text      = list(fontfamily = "ArialNarrow")
  ))

xyplot(
  y ~ time,  
  groups = id,
  type = c("l", "g"),
  ylab = "Y", xlab = "Time variable",
  data = dat
  )
```

<img src="../../../assets/images/test_data_R.png" height="300">

With our dataset in hand, please click through to the individual pages
in the **Table of Contents** below. Each of these explores a specific R package 
in more detail, by walking you through an implementation example using our
test dataset. I plan to add more packages as time allows, but please feel 
free to contribute yourself via a PR. 

{: .fs-6 .fw-300 }
