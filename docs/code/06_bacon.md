---
layout: default
title: Bacon decomposition
parent: Code
nav_order: 2
mathjax: true
image: "../../../assets/images/DiD.jpg"
---


# What is Bacon decomposition?

As stated in the last example of the TWFE section, if we have different treatment timings with different treatment effects, it is not so obvious what pre and post are. Let us state this example again:

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

In the figure we can see that there are two treatments at different points in time. The treatment to id=2 happens at $$ t $$=5, while the treatment to id=3 happens at $$ t $$=8. When the second treatment takes place, id=2 is already treated and is basically constant. So for id=3, id=2 is also part of the pre-group especially if we just consider the time range $$ 5 \leq t \leq 10 $$. It is also not clear what the ATT in this case should be from just looking at the figure. We can also run a simple TWFE specification to estimate this:

```applescript
xtreg Y D i.t, fe 
reghdfe Y D, absorb(id t)   // alternative specification
```

which gives us an ATT of $$ \hat{\beta} $$ = 2.91. 


This type of relative grouping of treated and not treated, and early and late treated, is part of the new DiD papers, and Bacon decomposition tells us why this is the case. What Bacon decomposition does, is that it unpacks the $$ \hat{\beta} $$ coefficient as a weighted average $$ \beta $$s estimated from three distinct 2x2 groups: 


1. **treated ($$ T $$)** versus **never treated ($$ U $$)**
2. **early treated ($$ T^e $$)** versus **late control ($$ C^l $$)**
3. **late treated ($$ T^l $$)** versus **early control ($$ C^e $$)**

In other words, the panel ids are split into different timing cohorts based on when the first treatment takes place and where it lies in relation to the treatment of other panel ids. The more the panel ids and differential treatment timings, the more the combinations of the above groups.

In our simple example, we have two treated panel ids: id=2 (early treated $$ T^e $$) and id=3 (late treated $$ T^l $$). The treated versus never treated can be further divided into early treated vs never treated ($$ T^e $$ vs $$ U $$) and late treated vs never treated ($$ T^l $$ vs $$ U $$). In total, four sets of values are estimated if there are three groups. Goodman-Bacon also uses a similar example in the paper.

Each set of values is essentially a basic 2x2 TWFE model, from which we recover two thing:

*  A 2x2 ($$ \hat{\beta} $$) parameter using classic TWFE.
*  The **weight** of this parameter on the overall ($$ \hat{\beta}^{DD} $$) as determined by its *relative size* in the data

We go back to these later. But first, let's see what the `bacondecomp` command gives us: 


```applescript
bacondecomp Y D, ddetail
```

In the absence of controls, this is the only option we can use for running `bacondecomp`. At the end of the command, we get this figure:

<img src="../../../assets/images/bacon1.png" height="300">

The figure shows four points for the three groups in our example. The treated versus never treated ($$ T $$ vs $$ U $$) are triangles. Since we have an early treated (id=2) and a late treated (id=3) panel variable, the y-axis gives us beta values of 2 and 4 respectively. These values are also obvious from the simple plot of the panel variables where id=2 increases by 2 and id=3 increases by 4 over the not treated id=1. The crosses represent the late teatment versus early control ($$ T^l $$ vs $$ C^e $$), and early treatment versus late control  ($$ T^e $$ vs $$ C^l $$) groups. Since these also have values of 2 and 4, their $\hat{\beta}$ values on the y-axis are the same. The x-axis gives us the weights of each parameter which we will come to later. 

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

Here we get our weights and the 2x2 $$ \beta $$ for each group. The table tells us that ($$ T $$ vs $$ U $$), which is the sum of the late and early treated versus never treated, has the largest weight, followed by early vs late treated, and lastly, late vs early treated.

If we do the weighted sum of these components:

```applescript
ereturn list

display e(dd_avg_e)*e(wt_sum_e) + e(dd_avg_l)*e(wt_sum_l) + e(dd_avg_u)*e(wt_sum_u)
```

we recover the original TWFE $$ \beta $$ estimate of 2.91. While the aim of Bacon decomposition is to show how TWFE effects can be wrong (a case we will come to later), in this case, the values are exactly the same. Even so, it is still interesting to find out which group is actually pulling the most weight in the overall value.


## The logic of the weights

In this section, we will learn to recover the weights manually for our example. In order to do this we need to go through the equations defined in this paper:

[Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing](https://www.sciencedirect.com/science/article/pii/S0304407621001445). Journal of Econometrics.


If you cannot access it, there are working paper versions floating around the internet (e.g. [one here on NBER](https://www.nber.org/papers/w25018)) plus there are also videos available on YouTube, for example, [one here](https://www.youtube.com/watch?v=m1xSMNTKoMs).

Let us start with equation 3 in the paper which states the key equation of the $$ \hat{\beta}^{DD} $$ parameter: 

$$ \hat{\beta}^{DD} = \frac{\hat{C}(y_{it},\tilde{D}_{it})}{\hat{V}^D} = \frac{ \frac{1}{NT} \sum_i{\sum_t{y_{it}\tilde{D}_{it}}}}{ \frac{1}{NT} \sum_i{\sum_t{\tilde{D}^2_{it}}}}  $$ 

This is basically a standard panel regression with fixed effects (see Greene or Wooldridge textbooks on panel estimations). Under the hood, a lot is going on in terms of symbols which we need to define. Let's start with the basic ones:

*  $$ N $$ = total panels because $$ i = 1\dots N $$
*  $$ T $$ = total time periods because $$ t = 1\dots T $$

The symbol $$ \tilde{D}_{it} $$ is the demeaned value of $$ D_{it} $$ which is basically a dummy variable which equals one for the treatment observation. The ~ symbol is basically telling us to demean by time and panel means. In order words:

$$ \tilde{D}_{it} = (D_{it} - D_i) - (D_{t} - \bar{\bar{D}})  $$ 

where 

$$ \bar{\bar{D}} = \frac{\sum_i{\sum_t{D_{it}}}}{NT}  $$

which is just the mean of all the observations. This specification is used to demean variables (to incorporate fixed effects). If we do demean or center the data, we can also recover the panel estimates using the standard `reg` command in Stata. In other words, `xtreg y i.t, fe` is equivalent to `reg tildey` [check assertion]. There is also discussion on this in Greene's book.

So if we go to the $$ \hat{\beta}^{DD} $$ equation, we can see that $$ \hat{V}^D $$ is bascially defined as the variance of $$ D_{it} $$. For our basic example, we can calculate it manually:

| $$ i $$ | $$ t $$ | $$ y $$ | $$ D $$ | $$ \bar{D}_i $$ | $$ \bar{D}_t $$ | $$ \bar{\bar{D}} $$ | $$ \tilde{D}_{it} $$ | $$ \tilde{D}^2_{it} $$ |
| - | - | - | - | -| - | - | - | - |
| 1 | 1  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 2  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 3  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 4  | 0 | 0     | 0       | 0       | 0.3     | 0.3        | 0.09        |
| 1 | 5  | 0 | 0     | 0       | 0.33    | 0.3     | \-0.03     | 0.0009      |
| 1 | 6  | 0 | 0     | 0       | 0.33    | 0.3     | \-0.03     | 0.0009      |
| 1 | 7  | 0 | 0     | 0       | 0.33    | 0.3     | \-0.03     | 0.0009      |
| 1 | 8  | 0 | 0     | 0       | 0.67    | 0.3     | \-0.37     | 0.1369      |
| 1 | 9  | 0 | 0     | 0       | 0.67    | 0.3     | \-0.37     | 0.1369      |
| 1 | 10 | 0 | 0     | 0       | 0.67    | 0.3     | \-0.37     | 0.1369      |
| 2 | 1  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 2  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 3  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 4  | 0 | 0     | 0.6     | 0       | 0.3     | \-0.3      | 0.09        |
| 2 | 5  | 2 | 1     | 0.6     | 0.33    | 0.3     | 0.37       | 0.1369      |
| 2 | 6  | 2 | 1     | 0.6     | 0.33    | 0.3     | 0.37       | 0.1369      |
| 2 | 7  | 2 | 1     | 0.6     | 0.33    | 0.3     | 0.37       | 0.1369      |
| 2 | 8  | 2 | 1     | 0.6     | 0.67    | 0.3     | 0.03       | 0.0009      |
| 2 | 9  | 2 | 1     | 0.6     | 0.67    | 0.3     | 0.03       | 0.0009      |
| 2 | 10 | 2 | 1     | 0.6     | 0.67    | 0.3     | 0.03       | 0.0009      |
| 3 | 1  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 2  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 3  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 4  | 0 | 0     | 0.3     | 0       | 0.3     | 0          | 0           |
| 3 | 5  | 0 | 0     | 0.3     | 0.33    | 0.3     | \-0.33     | 0.1089      |
| 3 | 6  | 0 | 0     | 0.3     | 0.33    | 0.3     | \-0.33     | 0.1089      |
| 3 | 7  | 0 | 0     | 0.3     | 0.33    | 0.3     | \-0.33     | 0.1089      |
| 3 | 8  | 4 | 1     | 0.3     | 0.67    | 0.3     | 0.33       | 0.1089      |
| 3 | 9  | 4 | 1     | 0.3     | 0.67    | 0.3     | 0.33       | 0.1089      |
| 3 | 10 | 4 | 1     | 0.3     | 0.67    | 0.3     | 0.33       | 0.1089      |


where $$ D $$ = 1 if treated, $$ \bar{D}_i $$ is the average of $$ D $$ for each panel id $$ i $$, $$ \bar{D}_t $$ is the average of $$ D $$ for each $$ t $$, and $$ \bar{\bar{D}} $$ is the mean of the $$ D $$ column. $$ \tilde{D}_{it} $$ is calculated using the formula stated above and $$ \tilde{D}^2_{it} $$ is just its square term. Here the sum of the $$ \tilde{D}^2_{it} $$ column equals 2.20 which divided by $$ NT $$, or 3 x 10, equals 0.0733, which is the variance $$ \hat{V}^D $$.


We can also recover $$ \hat{V}^D $$ as follows in Stata:


```applescript
 xtreg D i.t , fe 
 
 cap drop Dtilde
 predict double Dtilde, e
 
 sum Dtilde
 scalar VD = (( r(N) - 1) / r(N) ) * r(Var) 
```

where we can view the value by typing `display VD`. Here we should also get 0.0733.

Now that we have spent some time on $$ \hat{V}^D $$, which is not discussed in detail in the paper, we can now move on the next parts. In the paper, three formulas are provided for dealing with the three groups in our example. These are defined as follows in the set of equation 10 in the paper:


*   Early treatment versus late control ($$ T^e $$ vs $$ C^l $$)

$$  s_{el} = \frac{ ((n_e + n_l)(1 - \bar{D}_l))^2  n_{el} (1 - n_{el}) \frac{\bar{D}_e - \bar{D}_l}{1 - \bar{D}_l} \frac{1 - \bar{D}_e}{1 - \bar{D}_l}  }{\hat{V}^D}  $$


*   Late treatment versus early control ($$ T^l $$ vs $$ C^e $$)

$$  s_{le} = \frac{ ((n_e + n_l)\bar{D}_e))^2  n_{el} (1 - n_{el}) \frac{\bar{D}_l}{\bar{D}_e} \frac{\bar{D}_e - \bar{D}_l}{1 - \bar{D}_e}  }{\hat{V}^D}  $$


*   Treated versus untreated ($$ T $$ vs $$ U $$): 

$$  s_{jU} = \frac{ (n_j + n_U)^2 n_{jU} (1 - n_{jU}) \bar{D}_k (1 - \bar{D}_k)}{\hat{V}^D}  $$

where $$ j = \{e,l\} $$ or early and late treatment groups. 


The $$ s $$ are basically the weights that the command `bacondecomp` recovers, that are also displayed in the table. And since there is also a 2x2 $$ \hat{\beta} $$ coefficient associated with each 2x2 group, the weights have two properties:

*    They add up to one or:

$$ \sum_j{s_{jU}} + \sum_{e \neq U}{\sum_{l>e}{s_{el} + s_{le}}} = 1  $$


*    The overall $$ \hat{\beta}^{DD} $$ is a weighted sum of the 2x2 $$ \hat{\beta} $$ parameters: 

$$  \hat{\beta^{DD}} = \sum_j{s_{jU} \hat{\beta}_{jU}} + \sum_{e \neq U}{\sum_{l>e}{ ( s_{el} \hat{\beta}_{el} + s_{le} \hat{\beta}_{le}} ) } $$


Next step, we need to define all the new symbols. But before we do that, we need to get the logic straight. And for this, we start with the original visual:


<img src="../../../assets/images/twfe5.png" height="300">


Here we can see that the never treat group, $$ U $$, which is basically id=1, runs for 10 periods and gets treatment in zero periods. The early treated group (id=2), $$ T^e $$, runs for six periods starting at 5 and ending at 10, while the late treated group (id=3),  $$ T^l $$ runs for 3 periods from 8 till 10. These numbers tell us how many time periods a group stays treated. The share of these values out of the total observations $$ T $$ gives us $$ D^e = 6/10 $$ and $$ De = 3/10 $$ values. This basically tells how much weight each panel group exerts in the total sample. A group that stays treated for longer will (or should) have a larger influence on the ATT.

The next set of values are $$ n_e $$, $$ n_l $$, and  $$ n_U $$, which are the sample size of the groups in the total time periods. Since our panel is fully balanced, and there are three groups, these values basically equal $$ n_e = n_l = n_U = 1/3 $$ (check this claim). Each 2x2 contains a pair of the $$ \{e,l,U\} $$ group, the sum of $$ n $$ shares essentially weigh the relative size of the two panel ids in the group sample in the total observations.

The last unknown value is of the form $$ n_{ab} $$ which is the share of the time of treatment units in a group time, or 

$$ n_{ab} = \frac{n_a}{n_a + n_b} $$ 

The aim of this value is to weight the relative share of treatment within each group. If a treatment takes place in a small fraction of the time, or a very large fraction of the time, then its weight in the overall $$ \hat{\beta}^{DD} $$ will be reduced. In other words, more evenly spaced treatments in each group are given more preference.

From the share formulas above, we can see that it is all about accouting for all sorts of weights that are then applied to the recovered 2x2 $\hat{beta}$ of each group.



## Manual recovery of weights [this needs double checking]

Let's start with the manual recovery process. 

**Late treatment vs early control**

In order to visualize late treated versus early control, we generate the following control and draw the graph:

```applescript
cap drop tle
gen tle = .
replace tle = 0 if t>=5
replace tle = 1 if t>=8 & id==3

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==3 & tle!=.) ///
	(line Y t if id==2 & tle!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late treated" 5 "Early control"))	
```

and we get this figure:

<img src="../../../assets/images/bacon2.png" height="300">

So what is happening in this figure? We see that the id=2 variable which was treated earlier is flat, while the id=3 variable gets a treatment. Here we are saying that rather than calculate the TWFE estimator over the whole sample, we generate it for just id=3 and use id=2 as the control since it is stable in the $$ t $$ = 5 to 10 interval.

 Since we know from above, that the formula for this setting is:
 
 $$  s_{le} = \frac{ ((n_e + n_l)\bar{D}_e))^2  n_{el} (1 - n_{el}) \frac{\bar{D}_l}{\bar{D}_e} \frac{\bar{D}_e - \bar{D}_l}{1 - \bar{D}_e}  }{\hat{V}^D}  $$

we can define the values manually as follows:

```applescript
scalar De  = 6/10  // share of early treated in all sample
scalar Dl  = 3/10  // share of late treated in all sample
scalar nl = 1/3    // relative group size of late
scalar ne = 1/3    // relative group size of early
scalar nel = 3/6   // share of treatment periods in group sample
```

where the last scalar `nel` is the share of treatment which is 3 periods in the total group time horizon of 6 time periods. Here we can recover the weights as follows:

```applescript
display "weight_le = " (((ne + nl) * (De))^2 * nel * (1 - nel) * (Dl / De) * ((De - Dl)/(De)) ) / VD
```

which gives us a value of 0.136. 

Since we already have the sample defined, we can also recover the 2x2 TWFE parameter:

```applescript
xtreg Y D i.tle if (id==2 | id==3), fe robust
```

which gives us a value of $$ D $$ = 4. Since we don't have time or panel fixed effects or gaussian errors, we can also see from the figure that the change in id=3 is 4 units, while id=2 stays constant so the change is 0.

Compare these values to the `bacondecomp` table shown above and you will that these values exactly match the table values. 


**Early treatment vs late control**

Now let's flip this situation. Where we take the late treated variable as the control for the early treated group. 

```applescript
twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==3 & tel!=.) ///
	(line Y t if id==2 & tel!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Early treated" 5 "Late control"))
```


From the figure, we can see that this falls in this range:

<img src="../../../assets/images/bacon3.png" height="300">

and we recover the weights for the share:

```applescript
scalar De  = 6/10  // share of late treated in all sample
scalar Dl  = 3/10  // share of early treated in all sample

scalar nl = 1/3    // relative group size of late
scalar ne = 1/3    // relative group size of early		
scalar nle = 3/6   // share of treatment periods in group sample. why is it 3/6 and not 3/7?		
		
display "weight_el = " (((ne + nl) * (1 - Dl))^2 * (nle * (1 - nle)) * ((De - Dl)/(1 - Dl)) * ((1 - De)/(1 - Dl))) / VD

xtreg Y D i.tel if (id==2 | id==3), fe robust
```

which gives us a value of 0.182 and a $$ \beta $$coefficient of 2. Again this values can be compared with the `bacondecomp` table above.


** Treated versus not treated **  

(fix this section. There is an error in the weights calculation.)


Next we compare the two treated groups (early and late) with the not treated group:


```applescript
cap drop ten
gen ten = .
replace ten = 0 if id==1 
replace ten = 1 if id==2

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==2 & ten!=.) ///
	(line Y t if id==1 & ten!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Early treated" 5 "Never treated"))
		
cap drop tln
gen tln = .
replace tln = 0 if id==1 
replace tln = 1 if id==3

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if id==3 & tln!=.) ///
	(line Y t if id==1 & tln!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late treated" 5 "Never treated"))
```


<img src="../../../assets/images/bacon4.png" height="100"><img src="../../../assets/images/bacon5.png" height="100">




We can recover the coefficients as follows:

```applescript
xtreg Y D i.t if (id==1 | id==2), fe robust		// early
xtreg Y D i.t if (id==1 | id==3), fe robust		// late
```

which gives us 2 and 4 for early and late respectively. And we get the shares as follows:

```applescript
scalar Dl  = 3/10  // share of late treated in all sample
scalar De  = 6/10  // share of early treated in all sample

scalar ne = 1/3    // relative group size of late
scalar nl = 1/3    // relative group size of late
scalar nU = 1/3    // relative group size of early		

scalar nlU = 3/10   // share of treatment periods in group sample.
scalar neU = 6/10   // share of treatment periods in group sample.

display "weight_eU = " ((ne + nU)^2 * (neU * (1 - neU)) * (De * (1 - De))) / VD
display "weight_lU = " ((nl + nU)^2 * (nlU * (1 - nlU)) * (Dl * (1 - Dl))) / VD
```

where the shares equal 0.349 and 0.267 respectively. If we add these up, they come out to 0.616. This number is not exactly the same as the one shown in the `bacondecomp` table (this needs double checking in the formulas), but here we can see that this group has the highest weight as expected.


## Some more testing with more serious examples

COMING SOON!






