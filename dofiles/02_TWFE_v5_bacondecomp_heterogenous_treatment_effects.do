clear

set scheme white_tableau


cap cd "D:\Programs\Dropbox\Dropbox\STATA - DID"

		
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

*cap drop Y
*gen Y = 0
*replace Y = D * 2 if id==2 & t>=5
*replace Y = D * 4 if id==3 & t>=8


cap drop Y
gen Y = 0
replace Y = id/10 + cond(D==1, 0, 0) if id==1
replace Y = id/10 + cond(D==1, 2, 0) if id==2
replace Y = id/10 + cond(D==1, 4, 0) if id==3


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

		
		
reg Y D i.t i.id // panel and time fixed effects

xtreg Y D i.t, fe
reghdfe Y D, absorb(id t)  		


**** increase treatment over time

cap drop Y
gen Y = 0
replace Y = id + t + cond(D==1, 0 * t, 0) if id==1
replace Y = id + t + cond(D==1, 2 * t, 0) if id==2
replace Y = id + t + cond(D==1, 4 * t, 0) if id==3



twoway ///
	(connected Y t if id==1) ///
	(connected Y t if id==2) ///
	(connected Y t if id==3) ///
		,	///
		xline(4.5 7.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "id=1" 2 "id=2" 3 "id=3"))		



reg Y D i.t i.id // panel and time fixed effects
xtreg Y D i.t, fe
reghdfe Y D, absorb(id t)  	

*bacondecomp Y D, ddetail

		
