# Preamble

This page is sort of a working literature review to follow what is currently going on in the field with regards to Difference-in-Difference (DD), Two-way Fixed Effects (TWFE), dealing with heterogenous treatments over time, and how to correct for biases arising from them.

I am not an expert on this topic but this method has a fairly universal application. I am myself currently working on several different applications of this topic. At this time of writing this document, my own current strategy is to put papers on hold for the time being and see how the literature is developing. Several papers are coming out in the next months or so that will also be discussed here.




## The canonical 2x2 model

In econometrics the core model is the difference-in-difference estimator of the following type:

Y(it) = b0 + b1 P(i) + b2 T(t) + b3 (P(i) T(t)) + error

where T = Treatment, and P = Post treatment. Here the coefficient of interest is b3, which in a perfect world should be significant and in the right direction. The other two coefficients should be zero to full-fill the pre-trend requirements.

We can see this in a table form as well:

| Post\Treatment | Treatment = 0 | Treatment = 1 | Difference  | 
| ----- | ----- | ----- | -----   |
| Post = 0 |  b0   | b0 + b1    |  b1  |
| Post = 1 |  b0 + b2   |  b0 + b1 + b2 + b3  |  b1 + b3   |
| *Difference* | b2   |  b2 + b3  | b3   |

One can find more on this in the classic Woolridge (XXX) book.

This core setup has been used a lot. A canonical application of this model is the AER Card and Krueger (2000) [Minimum Wages and Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania](https://davidcard.berkeley.edu/papers/njmin-aer.pdf) that has resulted in quite some debate over the years. Regardless of which side of the minimum wage debate you are on, the DD method persits as the tool of choice for analysis throughout the years.
ADD PAPERS.


This methdology has also evolved over time to include multiple treatments (T1, T2) and triple differences (DDD). The multiple treatments part simply examples the combinations of above 2x2 matrix. For example with two treatments, this would become a 3x3 matrix. The cofficient of interest would be the triple interaction term the some combination of the differences between this and other terms.


## The triple difference estimator (DDD)
The triple difference estimator essential takes two DDs, one with the target unit of analysis with a treated and an untreated group. This is compared to another similar group in the pre and post-treatment period. Fo effectively there are two treatments. One where an actual treatment on the desired group is tested, and a placebo camparison group, on which the same intervention is also applied.

Y(it) = b0 + b1 P(i) + b2 C(j) + b3 T(t) + b4 (P T)(it) + b5 (C T)(jt) + b6 (P C)(ij) + b7(P C T)(ijt) + error







