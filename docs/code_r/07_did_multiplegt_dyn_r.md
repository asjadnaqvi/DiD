---
layout: default
title: did_multiplegt_dyn
parent: R code
nav_order: 7
mathjax: true
image: "../../../assets/images/DiD.png"
---

# did_multiplegt_dyn (Chaisemartin and D'Haultfœuille 2024)
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Introduction

The **DIDmultiplegtDYN** package implements the estimators proposed by 
[de Chaisemartin and D'Haultfœuille (2024)](https://doi.org/10.1162/rest_a_01414) 
(henceforth dCDH24). Like its predecessor **DIDmultiplegt**, the key stength
of dCDH24 lies in the sheer range of treatment designs allowed in the command. 
It can be used with a binary and absorbing (<ins>staggered</ins>) treatment, but 
it can also be used with a <ins>non-binary treatment</ins> (discrete or continuous) 
that can increase or decrease multiple times, even if lagged treatments affect 
the outcome, and if the current and lagged treatments have heterogeneous effects, 
across space and/or over time.

Unlike **DIDmultiplegt**, dCDH24 <ins>does not rely on bootstrap</ins> replications 
for the computation of standard errors. By default, the command computes analytical 
standard errors, which dramatically reduces the running time. Another difference with 
its predecessor lies in the improved integration with the R language. The command now
provides custom methods for `summary` and `print`. Since the output is a nested list
with `did_multiplegt_dyn` class, the command allows for further method dispatch. 
Lastly, the command output always includes the event-study graph as a `ggplot` object, 
which means that users can use in full the vast range of tools offered 
by the `ggplot2` library to customize the display of the event-study plot.

Relative to **DIDmultiplegt**, dCDH24 comes with a plethora of new estimation and 
post-estimation options:
+ **normalized**: estimation of the dynamic effects *per unit of treatment*;
+ **predict_het**: built-in treatment effect heterogeneity analysis;
+ **design** and **date_first_switch**: post-estimation options to analyze 
the design and timing of the treatment;
+ **by** and **by_path**: estimating dynamic effects within levels of a 
group-level variable or within treatment paths;
+ **trends_lin**: built-in group-specific linear trends;
+ **only_never_switchers**: restricting the dCDH24 estimators to only compare switchers and never-switchers.

## Installation and options

The package can be installed from CRAN

```r
install.packages("DIDmultiplegtDYN") # Install (only need to run once or when updating)
library("DIDmultiplegtDYN") # Load the package into memory (required each new session)
```

The main workhorse function of the package is `did_multiplegt_dyn()`, which in its 
simplest form looks like:

```r
did_multiplegt_dyn(df, outcome, group, time, treatment, ...)
```

where 

| Variable | Description |
| ----- | ----- |
| df | dataset |
| outcome | outcome variable |
| group | group variable |
| time | time variable  |
| treatment | treatment variable (any dummy, discrete or continuous numeric variable) |
| ... | Additional arguments |

Again, a key strength of `did_multiplegt_dyn()` is that allows for very flexible
estimation strategies and requirements. There are a variety of additional 
function arguments aimed at supporting or invoking these flexibilities. We have 
covered a few of the most important ones above, but you can take a look at the 
helpfile (`?did_multiplegt_dyn`) for more detailed information.

## Dataset

To demonstrate the package in action, we'll use the fake dataset that we 
[created earlier]({{ "/docs/code_r#data-generation" | relative_url }}). Here's a 
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
library(DIDmultiplegtDYN)
```

Let's try the basic `did_multiplegt_dyn()` command:

```r
did_multiplegt_dyn(df = dat, outcome = "y", group = "id", time = "time", treatment = "treat")

#' ----------------------------------------------------------------------
#'        Estimation of treatment effects: Event-study effects
#' ----------------------------------------------------------------------
#'  Estimate        SE     LB CI     UB CI         N Switchers
#'  -0.45717   0.44252  -1.32450   0.41015        83        26

#' ----------------------------------------------------------------------
#'     Average cumulative (total) effect per treatment unit
#' ----------------------------------------------------------------------
#'  Estimate        SE     LB CI     UB CI         N Switchers
#'  -0.45717   0.44252  -1.32450   0.41015        83        26
#' Average number of time periods over which a treatment effect is accumulated: 1.0000


#' The development of this package was funded by the European Union.
#' ERC REALLYCREDIBLE - GA N. 101043899
```

The one-off run of `did_multiplegt_dyn` computes the dynamic effects for the
first period after the treatment switch. Let's try now the command with more
dynamic effects, placebos and clustering at the group level. 

```r
mod_dCDH24 = did_multiplegt_dyn(
  dat, 'y', 'id', 'time', 'treat', # original regression params
  effects   = 10,                  # no. of post-treatment periods
  placebo   = 10,                  # no. of pre-treatment periods
  cluster   = 'id'                 # variable to cluster SEs on
  )

#' ----------------------------------------------------------------------
#'        Estimation of treatment effects: Event-study effects
#' ----------------------------------------------------------------------
#'              Estimate SE      LB CI    UB CI    N  Switchers
#' Effect_1     -0.45717 0.44252 -1.32450 0.41015  83 26       
#' Effect_2     6.01241  0.41452 5.19997  6.82485  83 26       
#' Effect_3     12.15926 0.37512 11.42404 12.89448 83 26       
#' Effect_4     17.79738 0.38663 17.03960 18.55516 83 26       
#' Effect_5     23.88198 0.31469 23.26520 24.49877 77 26       
#' Effect_6     29.81641 0.42263 28.98808 30.64474 77 26
#' Effect_7     36.41290 0.47205 35.48770 37.33810 77 26
#' Effect_8     42.90801 0.28881 42.34196 43.47407 77 26
#' Effect_9     48.40043 0.50253 47.41549 49.38537 67 26
#' Effect_10    54.32903 0.40159 53.54193 55.11614 67 26

#' ----------------------------------------------------------------------
#'     Average cumulative (total) effect per treatment unit
#' ----------------------------------------------------------------------
#'  Estimate        SE     LB CI     UB CI         N Switchers
#'  27.12607   0.32014  26.49860  27.75353       642       260
#' Average number of time periods over which a treatment effect is accumulated: 5.5000

#' ----------------------------------------------------------------------
#'      Testing the parallel trends and no anticipation assumptions
#' ----------------------------------------------------------------------
#'              Estimate SE      LB CI    UB CI   N  Switchers
#' Placebo_1    -0.20543 0.53571 -1.25541 0.84456 83 26
#' Placebo_2    -0.08358 0.36033 -0.78982 0.62266 83 26
#' Placebo_3    -0.43627 0.38175 -1.18449 0.31195 83 26
#' Placebo_4    -0.23315 0.43870 -1.09300 0.62669 83 26
#' Placebo_5    -0.88144 0.50670 -1.87455 0.11167 77 26
#' Placebo_6    0.07470  0.36160 -0.63401 0.78342 77 26
#' Placebo_7    -0.48019 0.42165 -1.30661 0.34624 77 26
#' Placebo_8    -0.35821 0.44594 -1.23225 0.51582 77 26
#' Placebo_9    0.06761  0.56032 -1.03060 1.16582 67 26
#' Placebo_10   0.06228  0.44232 -0.80465 0.92920 67 26

#' Test of joint nullity of the placebos : p-value = 0.1132

#' The development of this package was funded by the European Union.
#' ERC REALLYCREDIBLE - GA N. 101043899
```
Notice that the standard error on the first effect does not change with respect to the 
previous example. This is due to the fact that the standard errors computed
by the program are already clustered at the group level by default. 
The output displays the point estimates, standard errors, confidence 
intervals and sample sizes for dynamic effects, placebos and the average total effect
(per unit of treatment). By default, the `print` and `summary` display also include
the p-value from a joint significance test of the placebos and the average number
of periods after the first switch that fall into the estimation of dynamic effects. 

Let's inspect the assigned object.

```r
print(class(mod_dCDH24))
# [1] "did_multiplegt_dyn"
print(names(mod_dCDH24))
# [1] "args"    "results" "coef"    "plot"
```

In this basic setting, we can retrieve:
1. the arguments of the command call (_args_)
2. the command results in scalar/matrix form (_results_)
3. the command results in a format that is more compatible with `honestdid` (_coef_)
4. the `ggplot` event-study graph (_plot_)

The plot will be automatically displayed by the command unless the
`graph_off = TRUE` argument is specified. In any case, the plot object will
be stored in the output and it can be retrieved afterwards.
Let's see the graph.

```r
print(mod_dCDH24$plot)
```

<img src="../../../assets/images/did_multiplegt_dyn_R.png" height="300">

Since the graph above is a `ggplot` object, one can use all the tools
from the `ggplot2` library to add layers of customization. For instance,
we can recreate the style of (cs)`did` plots with only a few lines of code:

```r
# A graph example to convince skeptical did users
library(ggplot2) # Load the ggplot2 library
plt <- mod_dCDH24$plot # Assign the plot to new object (to avoid writing its full path every time)

plt$layers[[1]] <- NULL # drop the line
plt$layers[[1]]$aes_params$colour <- c(rep("#00BFC4", 10), rep("#F7736B", 10)) # Change the CI color
plt$layers[[2]]$aes_params$colour <- c(rep("#00BFC4", 11), rep("#F7736B", 10)) # Change the scatter color
plt <- plt + geom_hline(yintercept = 0, linetype = "dashed", color = "black") +  # Add the reference line
    theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank(), # Clean the background
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour = "black")
    ) + scale_x_continuous(breaks=seq(-10,10,1)) +  # Adjust the x axis ticks
    ylab(" ") + ggtitle("DIDmultiplegtDYN") # Add titles
print(plt) 
```

Here's the result:

<img src="../../../assets/images/did_multiplegt_dyn_R_did.png" height="300">
