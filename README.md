# Preamble

This is sort of a working literature review document to follow what is currently going on in the field with regards to Difference-in-Difference (DinD), Two-way Fixed Effects (TWFE), dealing with heterogenous treatments, and how to correct for biases arising from them.

I am not an expert on this topic but this method has a fairly universal application. I am myself currently working on several different applications of this topic. At this time of writing this document, my own current strategy is to put papers on hold for the time being and see how the literature is developing. Several papers are coming out in the next months or so that will also be discussed here.




# Background

In econometrics the core model is the difference-in-difference estimator of the following type:

Y(it) = b0 + b1 x Treatment(i) + b2 x Post(t) + b3 x (Treatment(i) * Post(t)) + error

Here the coefficient of interest is b3, which in a perfect world should be significant and in the right direction. The other two coefficients should be zero to full-fill the pre-trend requirements.

We can see this in a table form as well:

| Post\Treatment | Treatment = 0 | Treatment = 1 | Difference  | 
| ----- | ----- | ----- | -----   |
| Post = 0 |  b0   | b0 + b1    |  b1  |
| Post = 1 |  b0 + b2   |  b0 + b1 + b2 + b3  |  b1 + b3   |
| *Difference* | b2   |  b2 + b3  | b3   |

A classic application of this model is the AER Card and Krueger (2000) paper titled Minimum Wages and Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania (https://davidcard.berkeley.edu/papers/njmin-aer.pdf)

