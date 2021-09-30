---
layout: default
title: Theory and code
nav_order: 6
permalink: /docs/code
---

# Theory and Stata code

*This page is currently under construction. Don't use it!*

This section aims to cover the papers with some discussion of the theory but mostly a deep dive into the Stata code.

## The classic 2x2 Difference-in-Difference or the The Twoway Fixed Effects Model (TWFE)

Let us start with the classic Twoway Fixed Effects (TWFE) model:

$$ y_{it} = \beta_0 + \beta_1 Treat_i + \beta2_t Post_t + \beta_3 Treat_i Post_t + \epsilon_{it}  $$


where $y_{it}$ is the outcome variable of interest, $\alpha_i$ is the treatment variable, $\alpha_t$ is the post variable, and $\beta$ is the coefficient of interest.

In a very simple form, a two by two (2x2) model can be explained using the following table:



| Post\Treatment | Treatment = 0 | Treatment = 1 | Difference  | 
| ----- | ----- | ----- | -----   |
|          | Treatment = 0 | Treatment = 1 | *Difference*  | 
| -------- | ----- | ----- | -----   |
| Post = 0 |  $\beta_0$   | $\beta_0 + \beta_1$    |  $\beta_1$  |
| Post = 1 |  $\beta_0 + \beta_2$   |  $\beta_0 + \beta_1 + \beta_2 + \beta_3$  |  $\beta_1 + \beta_3$   |
| *Difference* | $\beta_2$   |  $\beta_2 + \beta_3$  | $\beta_3$   |




## The triple difference estimator (DDD)

The triple difference estimator essential takes two DDs, one with the target unit of analysis with a treated and an untreated group. This is compared to another similar group in the pre and post-treatment period. Fo effectively there are two treatments. One where an actual treatment on the desired group is tested, and a placebo camparison group, on which the same intervention is also applied.
The triple difference estimator essential takes two DDs, one with the target unit of analysis with a treated and an untreated group. This is compared to another similar group in the pre and post-treatment period. Fo effectively there are two treatments. One where an actual treatment on the desired group is tested, and a placebo camparison group C, on which the same intervention is also applied.

Y(it) = b0 + b1 P(i) + b2 C(j) + b3 T(t) + b4 (P T)(it) + b5 (C T)(jt) + b6 (P C)(ij) + b7(P C T)(ijt) + error

for simplicity, since markdown doesn't support equation writing, we just write it as:

Y = b0 + b1 P + b2 C + b3 T + b4 (P T) + b5 (C T) + b6 (P C) + b7 (P C T) + error

where we have 3x3 combinations: P = {0,1}, T={0,1}, C={0,1}. As is the case with the 2x2 DD, here the coefficient of interest is b7. This can also be broken down in a table form. But rather than create one big table, the results are usually presented for C = 0, or the main treatment group, and for C = 1, or the main comparison group. The difference between the two boils down to b7. Let's see this here:


Main group (C = 0):


|          | T = 0 | T = 1 | *Diff*  | 
| -------- | ----- | ----- | -----   |
| P = 0 |  b0   | b0 + b3    |  b3  |
| P = 1 |  b0 + b1   |  b0 + b1 + b3 + b4  |  b3 + b4   |
| *Diff* | b3   |  b3 + b4  | b4   |

Comparison group (C = 1):

|          | T = 0 | T = 1 | *Diff*  | 
| -------- | ----- | ----- | -----   |
| P = 0 |  b0 + b2   | b0 + b2 + b3 + b5    | b3 + b5  |
| P = 1 |  b0 + b1 + b2 + b6  |  b0 + b1 + b2 + b3 + b4 + b5 + b6 + b7  |  b3 + b4 + b5 + b7   |
| *Diff* | b1 + b6    |  b1 + b4 + b6 + b7  | b4 + b7   |


Let's take the difference between the two matrices or (C = 1) - (C = 0):


|          | T = 0 | T = 1 | *Diff*  | 
| -------- | ----- | ----- | -----   |
| P = 0 |  b2   | b2 + b5    | b5  |
| P = 1 |  b2 + b6  |  b2 + b5 + b6 + b7  |  b6 + b7   |
| *Diff* | b6    |  b6 + b7  | **b7**   |

where we end up with the main difference of b7. Note that this table logic is also far simpler than having a long list of expectations defined for each combination.








