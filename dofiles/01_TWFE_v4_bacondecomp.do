clear

set scheme white_tableau


cap cd "D:\Dropbox\STATA - DID"

		
**** adding a third group with differential treatment timing


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

*gen btrue = cond(T==1, 4, 0) 		

cap drop Y
gen Y = 0
replace Y = D * 2 if id==2 & t>=5
replace Y = D * 4 if id==3 & t>=8

lab var Y "Outcome variable"

cap drop P
gen P = 0
replace P = 1 if id==2 & t >= 5
replace P = 1 if id==3 & t >= 8
lab var P "Post"		

		
twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))		

graph export twfe5.png, replace	wid(3000)			
		
display ((2 * 6) + (4 * 3)) / 9



table P id, stat(mean Y)		
		
gen id2 = .
replace id2 = 0 if id==1		
replace id2 = 1 if id>1
		
	


*xtreg Y D t, fe  // this is wrong!
xtreg Y D i.t, fe robust
reghdfe Y D, absorb(id t)   





bacondecomp Y D, ddetail // stub(temp_)  stub option is not working??
graph export bacondecomp1.png, replace wid(2000)

/*


Diff-in-diff estimate: 2.909    

DD Comparison              Weight      Avg DD Est
-------------------------------------------------
Earlier T vs. Later C       0.182           2.000
Later T vs. Earlier C       0.136           4.000
T vs. Never treated         0.682           2.933
-------------------------------------------------
T = Treatment; C = Control


*/

ereturn list

mat li e(sumdd)

*di e(sumdd)[1,1] 



di e(sumdd)[1,1]*e(sumdd)[1,2] + e(sumdd)[2,1]*e(sumdd)[2,2] + e(sumdd)[3,1]*e(sumdd)[3,2]

*display e(dd_avg_e)*e(wt_sum_e) + e(dd_avg_l)*e(wt_sum_l) + e(dd_avg_u)*e(wt_sum_u)



  
*** overall variance VD

xtreg Y D i.t, fe 

 *xtreg Y D time* , fe 
 *mat origb=e(b)
 *mat origv=e(V)
 
 
 *xtreg D time* , fe 
 xtreg D i.t , fe 
 
 cap drop Dtilde
 predict double Dtilde, e
 
 sum Dtilde
 
 display ((r(N) - 1)/r(N)) * r(Var) 
 scalar VD = (( r(N) - 1) / r(N) ) * r(Var) 
 
 
 
**** let's do this manually:

* identify the groups first:

/*
gen t1 = 1 if id==1 // never treated
gen t2 = 1 if id==2 // early treated
gen t3 = 1 if id==3 // late  treated
*/




// late vs early treated

cap drop tle
gen tle = .
replace tle = 0 if t>=5
replace tle = 1 if t>=8 & id==3

colorpalette tableau, nograph

twoway ///
	(connected Y t if id==1, lc(gs12) mc(gs12)) ///
	(connected Y t if id==2, lc(gs12) mc(gs12)) ///
	(connected Y t if id==3, lc(gs12) mc(gs12)) ///
	(connected Y t if id==3 & tle!=., lc("`r(p3)'") mc("`r(p3)'")) ///
	(connected Y t if id==2 & tle!=., lc("`r(p2)'") mc("`r(p2)'")) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late treated" 5 "Early control"))	
graph export bacon2.png, replace	wid(3000)	

xtreg Y D i.tle if (id==2 | id==3), fe robust



scalar De  = 6/10  // share of early treated in all sample
scalar Dl  = 3/10  // share of late treated in all sample
scalar nl = 1/3    // relative group size of late
scalar ne = 1/3    // relative group size of early
scalar nel = 3/6   // share of treatment periods in group sample

display "weight_le = " (((ne + nl) * (De))^2 * nel * (1 - nel) * (Dl / De) * ((De - Dl)/(De)) ) / VD

bacondecomp Y D, ddetail // stub(temp_)  stub option is not working??

****weight for early versus late

cap drop tel
gen tel = .
replace tel = 0 if t<=7 & id==3
replace tel = 1 if t<=7 & id==2


colorpalette tableau, nograph

twoway ///
	(connected Y t if id==1, lc(gs12) mc(gs12)) ///
	(connected Y t if id==2, lc(gs12) mc(gs12)) ///
	(connected Y t if id==3, lc(gs12) mc(gs12)) ///
	(connected Y t if id==3 & tel!=., lc("`r(p3)'") mc("`r(p3)'")) ///
	(connected Y t if id==2 & tel!=., lc("`r(p2)'") mc("`r(p2)'")) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Early treated" 5 "Late control"))

graph export bacon3.png, replace	wid(3000)			

scalar De  = 6/10  // share of late treated in all sample
scalar Dl  = 3/10  // share of early treated in all sample

scalar nl = 1/3    // relative group size of late
scalar ne = 1/3    // relative group size of early		
scalar nle = 3/6   // share of treatment periods in group sample. why is it 3/6 and not 3/7?		
		
		
display "weight_el = " (((ne + nl) * (1 - Dl))^2 * (nle * (1 - nle)) * ((De - Dl)/(1 - Dl)) * ((1 - De)/(1 - Dl))) / VD


xtreg Y D i.tel if (id==2 | id==3), fe robust

*** early versus never treated


cap drop ten
gen ten = .
replace ten = 0 if id==1 
replace ten = 1 if id==2



colorpalette tableau, nograph

twoway ///
	(connected Y t if id==1, lc(gs12) mc(gs12)) ///
	(connected Y t if id==2, lc(gs12) mc(gs12)) ///
	(connected Y t if id==3, lc(gs12) mc(gs12)) ///
	(connected Y t if id==2 & ten!=., lc("`r(p2)'") mc("`r(p2)'")) ///
	(connected Y t if id==1 & ten!=., lc("`r(p1)'") mc("`r(p1)'")) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Early treated" 5 "Never treated"))	

graph export bacon4.png, replace	wid(3000)	



cap drop tln
gen tln = .
replace tln = 0 if id==1 
replace tln = 1 if id==3


colorpalette tableau, nograph

twoway ///
	(connected Y t if id==1, lc(gs12) mc(gs12)) ///
	(connected Y t if id==2, lc(gs12) mc(gs12)) ///
	(connected Y t if id==3, lc(gs12)) ///
	(connected Y t if id==3 & tln!=., lc("`r(p3)'") mc("`r(p3)'")) ///
	(connected Y t if id==1 & tln!=., lc("`r(p1)'") mc("`r(p1)'")) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late treated" 5 "Never treated"))	

graph export bacon5.png, replace	wid(3000)			
		
scalar Dl  = 3/10  // share of late treated in all sample
scalar De  = 6/10  // share of early treated in all sample

scalar ne = 1/3    // relative group size of late
scalar nl = 1/3    // relative group size of late
scalar nU = 1/3    // relative group size of early		

scalar nlU = 3/10   // share of treatment periods in group sample.
scalar neU = 6/10   // share of treatment periods in group sample.

display "weight_eU = " ((ne + nU)^2 * (neU * (1 - neU)) * (De * (1 - De))) / VD
display "weight_lU = " ((nl + nU)^2 * (nlU * (1 - nlU)) * (Dl * (1 - Dl))) / VD


display "weight_sumU = " (((ne + nU)^2 * (neU * (1 - neU)) * (De * (1 - De))) / VD) + (((nl + nU)^2 * (nlU * (1 - nlU)) * (Dl * (1 - Dl))) / VD)



xtreg Y D i.t if (id==1 | id==2), fe robust
xtreg Y D i.t if (id==1 | id==3), fe robust

