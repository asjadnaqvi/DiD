---
layout: default
title: Bacon decomposition
parent: Code
nav_order: 2
mathjax: true
---


# What is Bacon decomposition?

As stated in the last example of the TWFE section, if we have different treatment timings with different treatment effects, it is not clear what is pre and post, and what is treated and not treated.

Let us state this example again:

```applescript
clear
local units = 3
local start = 1
local end 	= 10

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen t 	   = seq(), f(`start') t(`end') 	

sort  id t
xtset id t

lab var id "Panel variable"
lab var t  "Time  variable"

gen D = 0
replace D = 1 if id==2 & t>=5
replace D = 1 if id==3 & t>=8
lab var D "Treated"

gen Y = 0
replace Y = D * 2 if id==2 & t>=5
replace Y = D * 4 if id==3 & t>=8

lab var Y "Outcome variable"
```


If we plot this:

```applescript
twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))		

```

we get:

<img src="../../../assets/images/twfe5.png" height="300">


and running a simple TWFE specification:

```applescript
xtreg Y D i.t, fe 
reghdfe Y D, absorb(id t)   
```

gives us an ATT of $$ \beta^{TWFE} $$ = 2.91. 

What Bacon decomposition does, is that it unpacks this coefficient into three cohorts. These are: 


1. **treated ($$ T $$)** versus **never treated ($$ U $$)**
2. **early treated ($$ T^e $$)** versus **late treated ($$ T^l $$)**
3. **late treated ($$ T^l $$)** versus **early treated ($$ T^e $$)**


This terminology is still a bit confusing. In our example above, we have two treated groups, id=2 (early treated) and id=3 (late treated). So the first cohort can be further divided into two sub-cohorts: early treated vs never treated ($$ T^e $$ vs $$ U $$) and late treated vs never treated ($$ T^l $$ vs $$ U $$). So in total four components are estimated.

So what do we do we with these components? Each component is essentially a vanilla 2x2 TWFE model, from which we recover two values:

1.  the TWFE parameter ($$ \beta^{TWFE} $$)
2.  the **weight** of this component as determined by its *relative size* in the data

We go back to these later. But first, let's see what the `bacondecomp` command gives us. In the absence of controls, this is the only option we can use:


```applescript
bacondecomp Y D, ddetail
```

which gives us this figure:

<img src="../../../assets/images/bacon1.png" height="300">

The figure shows four points for the three cohorts in our example. The treated versus never treated ($$ T $$ vs $$ U $$) are triangles. Since we have an early treated (id=2) and late treated (id=3) groups, we can see that the y-axis gives us the correct beta values of 2 and 4 respectively. The x-axis gives the weights. The crosses represent the late versus early, and early versus late groups. Since these also have values of 2 and 4, the y-axis is the same while the x-axis gives us the weights.

The figure above is summarized in this table that also pops up in the output window in Stata:

```bpf
Calculating treatment times...
Calculating weights...
Estimating 2x2 diff-in-diff regressions...

Diff-in-diff estimate: 2.909    

DD Comparison              Weight      Avg DD Est
-------------------------------------------------
Earlier T vs. Later C       0.182           2.000
Later T vs. Earlier C       0.136           4.000
T vs. Never treated         0.682           2.933
-------------------------------------------------
T = Treatment; C = Control
```

Here we get our weights and the TWFE $$ \beta $$ components. The table tells us that ($$ T $$ vs $$ U $$), which is the sum of the late and early treated versus never treated, has the largest weight, followed by early vs late treated, and lastly, late vs early treated.

If we do the weighted sum of these components:

```applescript
ereturn list

display e(dd_avg_e)*e(wt_sum_e) + e(dd_avg_l)*e(wt_sum_l) + e(dd_avg_u)*e(wt_sum_u)
```

from which we recover the original TWFE $$ \beta $$ estimate of 2.91.


## The logic of the weights

In this section, we will learn to recover the weights manually for our example.


COMING SOON!








