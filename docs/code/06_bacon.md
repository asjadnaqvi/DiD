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


If we plot this, we get:

<img src="../../../assets/images/twfe5.png" height="300">


and running a simple TWFE specification:

```applescript
xtreg Y D i.t, fe 
reghdfe Y D, absorb(id t)   
```

gives us an ATT of $$ \beta^TWFE $$ = 2.91. 

What Bacon decomposition does, is that it unpacks this coefficient into three components. These are: 


1. **treated ($$ T $$)** versus **never treated ($$ U $$)**
2. **early treated ($$ T^e $$)** versus **late treated ($$ T^l $$)**
3. **late treated ($$ T^l $$)** versus **early treated ($$ T^e $$)**


This terminology is still a bit confusing. In our example above, we have two treated groups, id=2 (early treated) and id=3 (late treated). So the first component can be further divided into two sub-components: early treated vs never treated ($$ T^e $$ vs $$ U $$) and late treated vs never treated ($$ T^l $$ vs $$ U $$). So in total four components are calculated.

So what do we do we with these components? Each component is essentially a vanilla 2x2 TWFE model, from which we recover two values:

1.  the TWFE parameter ($$ \beta^TWFE $$)
2.  the **weight** of this component as determined by its *relative size* in the data
















