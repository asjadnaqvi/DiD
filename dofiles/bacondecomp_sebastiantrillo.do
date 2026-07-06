* First we create data that has staggered timing BUT no heterogenous timing effects. This is taken from 
* https://asjadnaqvi.github.io/DiD/docs/code/06_02_bacon/

clear
local units = 3
local start = 1
local end   = 10

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

* Let's plot it to see how it looks

twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1 Untreated" 2 "id=2 Early Treated" 3 "id=3 Late Treated"))
		
* If we were to estimate DDs for all of these, we would have 4,2,2 and 4  four estimates 
* First we can see the ones comparing Early and Late vs. Untreated 

twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1 Untreated" 2 "id=2 Early Treated" 3 "id=3 Late Treated")) ///
		 text(1 5.4 "{&beta}{subscript:t-e, c-U}=2", placement(east))  text(1.2 5.2  "`=ustrunescape("\u23AB")'"   "`=ustrunescape("\u23AC")'"  "`=ustrunescape("\u23AD")'"  , size(12) color(bluishgray) )  ///
		text(2.2 8.3 "{&beta}{subscript:t-l,c-U}=4", placement(east))  text(2.2 8.2  "`=ustrunescape("\u23AB")'"  "`=ustrunescape("\u23AA")'"   "`=ustrunescape("\u23AC")'" "`=ustrunescape("\u23AA")'"  "`=ustrunescape("\u23AD")'"  , size(15) color(bluishgray) )  	 
		 
* Then we can see Late vs. Early, and Early vs. Late 
twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1 Untreated" 2 "id=2 Early Treated" 3 "id=3 Late Treated")) ///
		 text(1 5.4 "{&beta}{subscript:t-e, c-L}=2", placement(east))  text(1.2 5.2  "`=ustrunescape("\u23AB")'"   "`=ustrunescape("\u23AC")'"  "`=ustrunescape("\u23AD")'"  , size(12) color(bluishgray) )  ///
		text(3.2 8.3 "{&beta}{subscript:t-l, c-E}=4=2-(-2)", placement(east))  text(3.2 8.2  "`=ustrunescape("\u23AB")'"   "`=ustrunescape("\u23AC")'"   "`=ustrunescape("\u23AD")'"  , size(12) color(bluishgray) )  	 
		 
		
rename *, lower 

* So now the TWFE estimate, should be a weighted average of 4,2,2 and 4. 

estimates clear
eststo: reghdfe y d, a(id t)
esttab, se

* Which get us  2.909091


* ===== A parenthesis: How does one obtain this estimate through the traditional covariance/variance way? ========== *
			egen d_barbar=mean(d)

			* this creates mean of D_{it}, which is 0.3
			* now mean D_i

			bys id: egen d_meani=mean(d)

			* now mean D_t
			bys t: egen d_meant=mean(d)

			*so now we have everything to create d tilde:

			gen d_tilde=(d-d_meani)-(d_meant-d_barbar)

			*Now gen the square because we will need it for the variance
			gen d_tilde_square=d_tilde^2

			gen numerator_1=y*d_tilde
			egen numerator=mean(numerator_1)
			egen denominator=mean(d_tilde_square)

			* ++++++ Side track, we could also obtain the variance of D in this way
					xtreg d i.t , fe 
					cap drop Dtilde
					predict double Dtilde, e
 
					sum Dtilde
					scalar VD = (( r(N) - 1)  / r(N) ) * r(Var)
					* Now let's comapre both ways of getting the numerator
					display VD
					sum denominator 
			* ++++++  

			* Ok back, to what we wanted which is getting the main beta from TWFE

			gen beta_dd=numerator/denominator
			sum beta_dd
			
			estimates clear
			eststo: reghdfe y d, a(id t)
			sum beta_dd
			scalar beta=`r(mean)'
			estadd scalar beta:est1 
			esttab, se stats(N r2 beta ,label("N" "R-Squared" "Wooldridge textbook method") fmt (%9.0gc %7.2f %7.3f))
			
* ===== Close parenthesis  ========== *



* Ok so we now the 4 2x2 DD gives us 4,2,2 and 4. So if the TWFE was a "weighted combination" of these comparisons, what are the weights?

*  Well This is what bacon-decomp is good for:
bacondecomp y d, ddetail
   
 * Early_v_Late So it is 2   and it's weight .1818181841 
 * Late_v_Early  So it is 4   and it's weight .1363636317 
 * Untreated vs Early and vs Late: 2.933333323   .6818181841 
 
 * Notice that the graph was able to give us specific weights for the 4 and 2 of the untreated vs late and untreated vs early, and we actually know they are these: 
* Untreated vs. Late 4 .31818182 
* Untreated vs. Early  2 .36363636
* We know this from below, but I don't know how one can tell from the bacon decomposition command other than looking at the graph. 

* So that's great, but then, how does one calculate the weights by hand? 

* Well each comparison (2x2) will have a different weight, there are formulas for each comparison that Bacon writes out, so let's work it out in this setting
 
 * We have 4 betas, so we need 4 weights, and they should all add to 1. To recall, the 4 betas come from the following comparisons
 * 1) Late group as Treatment vs. Early group as control  (4) 
 * 2) Early group as treatment, vs. late group as control  (2) 
 * 3) Early group as treatment vs. never treated (2)
 * 4) Late group as treatment vs. never treated (4) 
 
 * ==============================================================
 * Figuring out the weight of 1. Late Group as Treatment vs. Early group as control  (4)
 * ==============================================================
	scalar De  = 6/10  // share of early treated in all sample
	scalar Dl  = 3/10  // share of late treated in all sample
	scalar nl = 1/3    // relative group size of late
	scalar ne = 1/3    // relative group size of early
	scalar nel = 3/6   // share of treatment periods in group sample

	display "weight_le = " (((ne + nl) * (De))^2 * nel * (1 - nel) * (Dl / De) * ((De - Dl)/(De)) ) / VD

	* Let's obtain the beta from the 2x2 
	cap drop tle
	gen tle = .
	replace tle = 0 if t>=5
	replace tle = 1 if t>=8 & id==3

	xtreg y d i.tle if (id==2 | id==3), fe robust

 * ==============================================================
 * Figuring out the weight of 2. Early group as Treatment vs. Late group as control  (2)
 * ==============================================================
	
	scalar De  = 6/10  // share of late treated in all sample
	scalar Dl  = 3/10  // share of early treated in all sample

	scalar nl = 1/3    // relative group size of late
	scalar ne = 1/3    // relative group size of early		
	scalar nle = 3/6   // share of treatment periods in group sample. why is it 3/6 and not 3/7?		
		
	display "weight_el = " (((ne + nl) * (1 - Dl))^2 * (nle * (1 - nle)) * ((De - Dl)/(1 - Dl)) * ((1 - De)/(1 - Dl))) / VD

	* Let's obtain the beta from the 2x2 
	xtreg y D i.t if (id==2 | id==3) & t<=7, fe robust

 * ==============================================================
 * Figuring out the weight of 3. Early group as Treatment vs. Never treated group as control  (2)  AND 
 * Figuring out the weight of 4. Late group as Treatment vs. Never treated group as control  (4) 
 * ==============================================================
	scalar Dl  = 3/10  // share of late treated in all sample
	scalar De  = 6/10  // share of early treated in all sample

	scalar ne = 1/3    // relative group size of late
	scalar nl = 1/3    // relative group size of late
	scalar nU = 1/3    // relative group size of never treated 		

	scalar nlU = 3/6   // share of treatment periods in group sample.
	scalar neU = 3/6   // share of treatment periods in group sample.

	* Notice that nlU is 3/6 because: it's n_e / (n_e +n_u) so 1/3 /(1/3 + 1/3), which is 1/3/(2/3) which is 3/6 
	* Same for neU

	display "weight_eU = " ((ne + nU)^2 * (neU * (1 - neU)) * (De * (1 - De))) / VD
	display "weight_lU = " ((nl + nU)^2 * (nlU * (1 - nlU)) * (Dl * (1 - Dl))) / VD
	display  .36363636 +.31818182
	* Just checking that this give us  .68181818 which is the weight according to bacon decomposition 

	* Now the respective betas 

	* Early vs. never 
	cap drop ten
	gen ten = .
	replace ten = 0 if id==1 
	replace ten = 1 if id==2

	* Late vs. never 
	cap drop tln
	gen tln = .
	replace tln = 0 if id==1 
	replace tln = 1 if id==3

	* We can recover the coefficients as follows:

	xtreg y d i.t if (id==1 | id==2), fe robust		// early
	xtreg y d i.t if (id==1 | id==3), fe robust		// late


*==========================================================================
* Now that we've figured out the weights, let's do the weighted average and see if we get the same thing!
*==========================================================================
	* So now we add things to get the main beta:
	display 4*.31818182 + 2*.36363636 + 2*.18181818 + 4*.13636364
	scalar beta_weighted = 4*.31818182 + 2*.36363636 + 2*.18181818 + 4*.13636364
 
 
			estimates clear
			eststo: reghdfe y d, a(id t)
			sum beta_dd
			scalar beta=`r(mean)'
			estadd scalar beta:est1 
			estadd scalar beta_weighted:est1
			esttab, se stats(N r2 beta beta_weighted ,label("N" "R-Squared" "Wooldridge textbook method" "Weighted") fmt (%9.0gc %7.2f %7.3f))
			
	* Yay they are all the same! 
			
	
