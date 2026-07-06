clear

set scheme white_tableau


cap cd "D:\Dropbox\STATA - DID\dofiles"


**** core 2x2

clear
local units = 2
local start = 1
local end 	= 2

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen t 	   = seq(), f(`start') t(`end') 	

sort id t
xtset id t


lab var id "Panel variable"
lab var t  "Time  variable"


gen D = id==2 & t==2

gen btrue = cond(D==1, 2, 0) 		
	
*gen Y = id + btrue*D // no slope
gen Y = id + 3*t + btrue*D // slope

lab de prepost 1 "Pre" 2 "Post"
lab val t prepost

*twoway (scatter Y t)

twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
		,	///
		legend(order(1 "id=1" 2 "id=2")) ///
		xlabel(1 2, valuelabel) ylabel(4(1)10)
		
graph export twfe1.png, replace	wid(3000)
	
bysort id: tabstat Y, by(t) nototal

table t id, stat(mean Y)

xtset id t

reg Y i.id i.t D

xtreg Y D i.t, fe
reghdfe Y D, absorb(id t)


**** multiple time periods

clear
local units = 2
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


gen D = id==2 & t>=5
lab var D "Treated"

gen btrue = cond(D==1, 3, 0) 		

gen Y = id + t +  btrue*D // slope
lab var Y "Outcome variable"

		
		
twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)10) ///
		ylabel(0(1)15) ///
		legend(order(1 "id=1" 2 "id=2"))		

graph export twfe2.png, replace	wid(3000)		
		
		
*table t id, c(mean Y)	 // for versions earlier than Stata 17

table t id, stat(mean Y)	

gen P = t >= 5
lab var P "Post"		

table P id, stat(mean Y)	// (21 - 16) - (7 - 6) = 5 - 1 = 4 

reg Y D id t		
xtreg Y D i.t, fe

xtreg Y D t, fe
reghdfe Y D, absorb(id t)   

// note: rename T. T is actually post x treat dummy.


**** adding a third group with same treatment timing but no panel effects


clear
local units = 3
local start = 1
local end 	= 10

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen id	   = seq(), b(`time')  
egen t 	   = seq(), f(`start') t(`end') 	

lab var id "Panel variable"
lab var t  "Time  variable"

sort  id t
xtset id t


gen D = 0
replace D = 1 if id>=2 & t>=5
lab var D "Treated"

cap drop Y
gen Y = 0
replace Y = cond(D==1, 2, 0) if id==2
replace Y = cond(D==1, 4, 0) if id==3

lab var Y "Outcome variable"		



twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))	
graph export twfe3.png, replace	wid(3000)	
		
xtreg Y D t, fe 
reghdfe Y D, absorb(id  t)   		


**** adding a third group with same treatment timing but panel effects


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
replace D = 1 if id>=2 & t>=5
lab var D "Treated"

cap drop Y
gen Y = 0
replace Y = id + t + cond(D==1, 0, 0) if id==1
replace Y = id + t + cond(D==1, 2, 0) if id==2
replace Y = id + t + cond(D==1, 4, 0) if id==3

lab var Y "Outcome variable"		



twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))	
graph export twfe4.png, replace	wid(3000)	
		
xtreg Y D i.t, fe 
reghdfe Y D, absorb(id  t)   		

reg Y D  // not controlling for any effects
reg Y D i.t // only time fixed effects
reg Y D i.id // only panel fixed effects
reg Y D i.t i.id // panel and time fixed effects

		
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
		
	
table P id2, stat(mean Y)		


tabstat Y, by(D)
tabstat Y [fw = id], by(D)
tabstat Y [fw = t], by(D)

sort id t

reg Y D, robust
reg Y D i.t, robust
reg Y D i.id, robust
reg Y D i.t i.id, robust

*xtreg Y D t, fe  // this is wrong!
xtreg Y D i.t, fe robust
reghdfe Y D, absorb(id t)   





bacondecomp Y D, ddetail stub(temp_)  // stub option is not working??


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
display e(dd_avg_e)*e(wt_sum_e) + e(dd_avg_l)*e(wt_sum_l) + e(dd_avg_u)*e(wt_sum_u)


**** let's do this manually:

* identify the groups first:

gen t1 = 1 if id==1 // never treated
gen t2 = 1 if id==2 // early treated
gen t3 = 1 if id==3 // late  treated


// late vs early treated

cap drop tle
gen tle = .
replace tle = 0 if t>=5
replace tle = 1 if t>=8 & id==3



twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t3==1 & tle!=.) ///
	(line Y t if t2==1 & tle!=.) ///
		,	///
		xline(5 8) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late" 5 "Early"))	


xtreg Y T i.tle if (t2==1 | t3==1), fe robust


// early vs late treated

cap drop tel
gen tel = .
replace tel = 0 if t<=7 & id==3
replace tel = 1 if t<=7 & id==2



twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t3==1 & tel!=.) ///
	(line Y t if t2==1 & tel!=.) ///
		,	///
		xline(5 8) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late" 5 "Early"))	


xtreg Y T i.tel if (t2==1 | t3==1), fe robust



//  early vs never treated

cap drop ten
gen ten = .
replace ten = 0 if id==1 
replace ten = 1 if id==2

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t2==1 & ten!=.) ///
	(line Y t if t1==1 & ten!=.) ///
		,	///
		xline(5 8) ///
		xlabel(1(1)10) ///
		legend(order(4 "Early" 5 "Never"))	

		
xtreg Y T i.ten if (t1==1 | t2==1), fe robust
		

		
//  late vs never treated

cap drop tln
gen tln = .
replace tln = 0 if id==1 
replace tln = 1 if id==3

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t3==1 & tln!=.) ///
	(line Y t if t1==1 & tln!=.) ///
		,	///
		xline(5 8) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late" 5 "Never"))	

		
xtreg Y T i.ten if (t1==1 | t3==1), fe robust		


*** variance (V) for late or early versus untreated groups

// V_{j}N = n_jN * (1 - n_jN) * Dbar_j * (1 - Dbar_j) where
// n_xy = is the relative size of the timing group = (n_x / n_y + n_x)
// Dbar = is how long a unit stays treated in its timing window


// lets calculate it for late versus untreated:

display "n_lN = " 3 / 10
display "Dbar_l = " 3 / 10
display "V_lN = " 3 / 10 * (1 -  (3 / 10)) * 3 / 10 * (1 -  (3 / 10))


*** time dummies

qui levelsof t, loc(ts)
 qui foreach i of loc ts {
  
  g byte time`i'=(t==`i') 
  la var time`i' "`t'==`i'" 

  }

*** overall variance VD

xtreg Y T i.t, fe 

xtreg Y T time* , fe 
 
 mat origb=e(b)
 mat origv=e(V)
 
 cap drop Dtilde
 xtreg T time* , fe 
 predict double Dtilde, e
 sum Dtilde
 display (( r(N) - 1) / r(N) ) * r(Var) 
 scalar VD = (( r(N) - 1) / r(N) ) * r(Var) 
 
 
 

*** weight for late versus early


twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t3==1 & tle!=.) ///
	(line Y t if t2==1 & tle!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late" 5 "Early"))	


xtreg Y T i.tle if (t2==1 | t3==1), fe robust



scalar De  = 6/10  // share of late treated in all sample
scalar Dl  = 3/10  // share of early treated in all sample
scalar nl = 1/3    // relative group size of late
scalar ne = 1/3    // relative group size of early
scalar nel = 3/6   // share of treatment periods in group sample

display "weight_le = " (((ne + nl) * (De))^2 * nel * (1 - nel) * (Dl / De) * ((De - Dl)/(De)) ) / VD

bacondecomp Y T, ddetail // stub(temp_)  stub option is not working??

****weight for early versus late



twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t3==1 & tel!=.) ///
	(line Y t if t2==1 & tel!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Late" 5 "Early"))


scalar De  = 6/10  // share of late treated in all sample
scalar Dl  = 3/10  // share of early treated in all sample

scalar nl = 1/3    // relative group size of late
scalar ne = 1/3    // relative group size of early		
scalar nle = 3/6   // share of treatment periods in group sample. why is it 3/6 and not 3/7?		
		
		
display "weight_el = " (((ne + nl) * (1 - Dl))^2 * (nle * (1 - nle)) * ((De - Dl)/(1 - Dl)) * ((1 - De)/(1 - Dl))) / VD


*** early versus never treated

twoway ///
	(line Y t if id==1, lc(gs12)) ///
	(line Y t if id==2, lc(gs12)) ///
	(line Y t if id==3, lc(gs12)) ///
	(line Y t if t2==1 & ten!=.) ///
	(line Y t if t1==1 & ten!=.) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(4 "Early" 5 "Never"))	


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






