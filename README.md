This is sort of a working literature review document


#What is the hell is going on?

In econometrics a canonical model is the difference-in-difference estimator of the following type:

Y(it) = b0 + b1 x Treatment(i) + b2 x Post(t) + b3 x (Treatment(i) * Post(t)) + error

Here the coefficient of interest is b3, which in a perfect world should be significant and in the right direction. The other two coefficients should be zero to full-fill the pre-trend requirements.

We can see this in a table form as well:

| Post\Treatment | Treatment = 0 | Treatment = 1 | Difference  | 
| ----- | ----- | ----- | -----   |
| Year = 0 |     |    |    |
| Year = 1 |     |    |    |
| Difference |    |    |    |
