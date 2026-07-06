---
layout: default
title: hdidregress
parent: Stata code
nav_order: 15
mathjax: true
image: "../../../assets/images/DiD.png"
---

# hdidregress
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Notes

- The *hdidregress* is a native Stata implementation of [Callaway and Sant'Anna 2021](https://www.sciencedirect.com/science/article/abs/pii/S0304407620303948).


## Installation

Requires Stata v17 or higher. Take a look at the help file:

```stata
help hdidregress
```

## Test the command

Please make sure that you generate the shared setup data using the setup block given [here](https://asjadnaqvi.github.io/DiD/docs/code_stata/).



```stata
hdidregress aipw (Y) (D), group(id) time(t)
```

The paired dofile also demonstrates additional estimators and decomposition checks:

```stata
bacondecomp Y D
bacondecomp Y D, ddetail

hdidregress twfe (Y) (D), group(id) time(t)
hdidregress aipw (Y) (D), group(id) time(t)
hdidregress ipw (Y) (D), group(id) time(t)
hdidregress ra (Y) (D), group(id) time(t)
```

If you want to mirror the dofile workflow exactly, run the command block above before plotting so the comparison across estimators is reproducible from a single script.

Which gives us this output (truncated for visibility):


```stata
Computing decomposition across 5 timing groups
including a never-treated group
------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |   77.59101   3.731448    20.79   0.000     70.27751    84.90452
------------------------------------------------------------------------------

Bacon Decomposition

+---------------------------------------------------+
|                      |         Beta   TotalWeight |
|----------------------+----------------------------|
|        Timing_groups |  31.77318774   .4830876526 |
|       Never_v_timing |  120.4106995   .5169123474 |
+---------------------------------------------------+
```

The command also has a built in graph option:

```stata
estat atetplot, sci
```


<img src="../../../assets/images/hdid_aipw1.png" width="100%">


The command's built-in graph option gives us: 


```stata
estat aggregation, dynamic(-10(1)10) graph
```

<img src="../../../assets/images/hdid_aipw2.png" width="100%">
