# Preamble

This page is sort of a working literature review to follow what is currently going on in the field with regards to Difference-in-Difference (DD), Two-way Fixed Effects (TWFE), dealing with heterogenous treatments over time, and how to correct for biases arising from them.

I am not an expert on this topic but this method has a fairly universal application. I am myself currently working on several different applications of this topic. At this time of writing this document, my own current strategy is to put papers on hold for the time being and see how the literature is developing. Several papers are coming out in the next months or so that will also be discussed here.




## The canonical 2x2 model

In econometrics the core model is the difference-in-difference estimator of the following type:

Y(it) = b0 + b1 P(i) + b2 T(t) + b3 (P T)(it) + error

where T = Treatment, and P = Post treatment. Here the coefficient of interest is b3, which in a perfect world should be significant and in the right direction. The other two coefficients should be zero to full-fill the pre-trend requirements.

We can see this in a table form as well:

|          | Treatment = 0 | Treatment = 1 | *Difference*  | 
| -------- | ----- | ----- | -----   |
| Post = 0 |  b0   | b0 + b1    |  b1  |
| Post = 1 |  b0 + b2   |  b0 + b1 + b2 + b3  |  b1 + b3   |
| *Difference* | b2   |  b2 + b3  | b3   |

One can find more on this in the classic Woolridge (XXX) book.

This core setup has been used a lot. A canonical application of this model is the AER Card and Krueger (2000) [Minimum Wages and Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania](https://davidcard.berkeley.edu/papers/njmin-aer.pdf) that has resulted in quite some debate over the years. Regardless of which side of the minimum wage debate you are on, the DD method persits as the tool of choice for analysis throughout the years.
ADD PAPERS.


This methdology has also evolved over time to include multiple treatments (T1, T2) and triple differences (DDD). The multiple treatments part simply examples the combinations of above 2x2 matrix. For example with two treatments, this would become a 3x3 matrix. The cofficient of interest would be the triple interaction term the some combination of the differences between this and other terms.


## The triple difference estimator (DDD)
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

So where is DDD applied? Well actually quite a lot in high ranked economic journals. See XXX here for a comprehensive list:

XXXX



## The issue with Treatments

The above framework assumes that all units are treated at the same time. While this might be true for some interventions that are roled out, three problems exist:
- Treatments are implemented at different times
- Treatments are implemented at different intensities
- Units can move in an out of treatments

Any combination of the above three has a *high chance* of making the standard DD or DDD analysis wrong as shown in the Goodman-Bacon 2019 paper. The reason, difference in timing of different treatments makes some coefficients negative (also referred to as negative weights), thus canceling out the overall treatment effect.

The solution, assign different weighting schemes to treated and untreated units based on how and when the treatments are rolled out. This means that some groups that are treated *later*, act as a control for the groups that are treated *now*. In other words, for each treatment period, one calculates a 2x2 DD estimator and uses some weighting to combine them.





