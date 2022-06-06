# Taken out from Bacon Decomposition


## When some groups are never treated

In the above example, it is obvious that the TWFE model is wrong. But it gets complicated if we have the never treated group in there as well. Let's rerun the script, but now we set cohort==0 to be never treated:

```applescript
cap drop Y
cap drop D
cap drop effect
cap drop timing

gen Y 	   = 0					// outcome variable	
gen D 	   = 0					// intervention variable
gen effect = .					// treatment effect size
gen timing = .					// when the treatment happens for each cohort

levelsof cohort if cohort!=0, local(lvls)  //   skip cohort 0 (never treated)
foreach x of local lvls {
	
	local eff = runiformint(2,10)
		replace effect = `eff' if cohort==`x'
		
	local timing = runiformint(`start' + 5,`end' - 5)	
	replace timing = `timing' if cohort==`x'
		replace D = 1 if cohort==`x' & t>= `timing' 
}


// generate the outcome variable
replace Y = id + t + cond(D==1, effect * (t - timing), 0)
```

and generate the graph:

```applescript
levelsof cohort
local items = `r(r)'
local lines
levelsof id

forval x = 1/`r(r)' {
	
	qui summ cohort if id==`x'
	local color = `r(mean)' + 1
	
	colorpalette tableau, nograph
	local lines `lines' (line Y t if id==`x', lc("`r(p`color')'") lw(vthin))	||	
}

twoway ///
	`lines'	///
		,	legend(off)
```

which gives us:

<img src="../../../assets/images/TWFE_bashing3.png" height="300">

Here we see the cohort that is not treated in the blue color. The TWFE model:

```applescript
reghdfe Y D, absorb(id t)   
```

give us:

```bpf
HDFE Linear regression                            Number of obs   =      1,800
Absorbing 2 HDFE groups                           F(   1,   1710) =     215.19
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.8204
                                                  Adj R-squared   =     0.8110
                                                  Within R-sq.    =     0.1118
                                                  Root MSE        =    40.6805

------------------------------------------------------------------------------
           Y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
           D |   52.36467   3.569625    14.67   0.000     45.36337    59.36596
       _cons |   72.89326   1.628907    44.75   0.000      69.6984    76.08812
------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
          id |        30           0          30     |
           t |        60           1          59     |
-----------------------------------------------------+
```

Or the average treatement effect of $$D=52$$. A positive value, that would not seem wrong at first glance. Let's see what the Bacon decomposition would look like:

```applescript
bacondecomp Y D, ddetail nograph
```

<img src="../../../assets/images/TWFE_bashing4.png" height="300">

This graph tells us that the treated versus never treated is positive and exerts the highest weights as compared to the other two groups. But look at the Early versus Late and Late versus Early. Only very 2x2 estimates are positive. All the rest are negative.

If we look at the table:

```bpf
Calculating treatment times...
Calculating weights...
Estimating 2x2 diff-in-diff regressions...

Diff-in-diff estimate: 52.365   

DD Comparison              Weight      Avg DD Est
-------------------------------------------------
Earlier T vs. Later C       0.247          60.451
Later T vs. Earlier C       0.246         -78.899
T vs. Never treated         0.506         112.204
-------------------------------------------------
T = Treatment; C = Control
```

We can see the interplay between the three groups. The Treated versus Never Treated group has the heighest weight. Remember from above, that this group tends to have the largest weight since it covers all the observations. But look at the Late versus early group, it is a huge negative average effect and contributes a forth to the overall estimate. And here is where the problem usually lies. TWFE models might look like they are working, since ATT are positive, but the underlying cohort weights distribution and 2x2 DiD estimates are likely diluting the actual estimates. While in this example, the average TWFE $$\hat{\beta}$$ was positive, if you remove the seeding the rerun it, you can see that in some TWFE estimates, the $$\hat{\beta}$$ values are very small and close to zero, and in very rare cases, might even time of the zero line.

So how do we correct the $$\hat{\beta}$$? This is where the packages come in. They will be covered separately in other sections.


*INCOMPLETE*

