/* Code to reproduce the application (section 4) in the paper "Two-Way Fixed 
Effects and Differences-in-Differences with Heterogeneous Treatment Effects: A 
Survey " by C. de Chaisemartin and X. D'Haultfoeuille. */

/* The dataset of Wolfers (2006) can be obtained at OpenICPSR, Replication data
for: Did Unilateral Divorce Laws Raise Divorce Rates? A Reconciliation and New 
Results. URL (May 2022): https://www.openicpsr.org/openicpsr/project/116250/
version/V1/view?path=/openicpsr/116250/fcr:versions/V1&type=project */

/* Make sure to have installed, in addition to the commands described in the 
paper,  the commands reghdfe, ftools and avar. */

/* The only part of the code to modify is below: you have to indicate the folder 
where the .dta is saved */ 
cd ""
use "Divorce-Wolfers-AER.dta", clear 
set matsize 1000


/* Matrix saving the average effects from 0 to 7 years after the law, from the 
different methods */
matrix res_avg = J(5,2,0)

* Part 1 Wolfers' results in table 2, w/o linear time trends
xi i.years_unilateral i.st i.year 
quietly: reg div_rate _I* if year>1955 & year<1989 [w=stpop]

matrix temp = e(V)
matrix V_b = temp[1..4,1..4]
matrix e2 = J(4,1,1/4)

matrix temp=r(table)'
matrix res = ((0\1\2\3), temp[1..4,1], temp[1..4,5], temp[1..4,6])
matrix list res

matrix res_avg[1,1] = res[1..4,2]'*e2

matrix temp = e2'*(V_b*e2)
matrix res_avg[1,2] = sqrt(temp[1,1])

/* Part 2: TWFE reg., without gathering by groups of two years (as opposed to
 Wolfers) and with leads of the treatment */
gen Dur=year-lfdivlaw  if lfdivlaw<2000
replace Dur=min(15,max(Dur,-10)) if lfdivlaw<2000
replace Dur=-10 if lfdivlaw==2000

forvalues x = 0/15 {
	g Dt`x'=(Dur==`x')
}
* For placebo estimates
forvalues x = 2/10 {
	g Dt_`x'=(Dur==-`x')
}

drop _I*
xi i.st i.year 
quiet: reg div_rate Dt* _I* if year>1955 & year<1989 [w=stpop], vce(cluster st)

/* We produce the E-S graph by creating a matrix (res) gathering the time to the 
event, the point estimates and the CI */

matrix temp = e(V)
matrix V_b = temp[1..8,1..8]
matrix e = J(8,1,1/8)
matrix temp=r(table)'
matrix res=J(26,4,0)
matrix res[10,1]=-1
forvalues x = 2/10 {
matrix res[11-`x',1]=-`x'
matrix res[11-`x',2]=temp[`x'+15,1]
matrix res[11-`x',3]=temp[`x'+15,5]
matrix res[11-`x',4]=temp[`x'+15,6]
}
forvalues x = 0/15 {
matrix res[`x'+11,1]=`x'
matrix res[`x'+11,2]=temp[`x'+1,1]
matrix res[`x'+11,3]=temp[`x'+1,5]
matrix res[`x'+11,4]=temp[`x'+1,6]
}

matrix res_avg[2,1] = res[11..18,2]'*e

matrix temp = e'*(V_b*e)
matrix res_avg[2,2] = sqrt(temp[1,1])

preserve
drop _all
svmat res
twoway (scatter res2 res1, msize(medlarge) msymbol(o) mcolor(navy) legend(off)) ///
	(line res2 res1, lcolor(navy)) (rcap res4 res3 res1, lcolor(maroon)), ///
	 title("TWFE estimates") xtitle("Relative time to change in law") ///
	 ytitle("Effect") ylabel(-1(.5)0.5) yscale(range(-1.1 0.8)) name(g1)
restore

* Joint nullity of all placebos
testparm Dt_*

* Part 3: compute the weights corresponding to the last E-S regression
encode st, generate(state)

twowayfeweights div_rate state year Dt0 if year>1955 & year<1989, type(feTR) ///
test_random_weights(year) weight(stpop) other_treatments(Dt1-Dt15 Dt_2-Dt_10)
	
* Part 4: Sun and Abraham

gen unilateral_year=unilateral*year
replace unilateral_year=3000 if unilateral_year==0
bys state: egen cohort=min(unilateral_year)
replace cohort=. if cohort==3000
gen controlgroup=(cohort==.)

eventstudyinteract div_rate Dt* if year>1955 & year<1989 [aweight=stpop], ///
	absorb(i.state i.year) cohort(cohort) control_cohort(controlgroup) ///
	vce(cluster st)

/* As above, to produce a graph */ 
matrix temp=r(table)'
matrix res=J(26,4,0)
matrix res[10,1]=-1
forvalues x = 2/10 {
matrix res[11-`x',1]=-`x'
matrix res[11-`x',2]=temp[`x'+15,1]
matrix res[11-`x',3]=temp[`x'+15,5]
matrix res[11-`x',4]=temp[`x'+15,6]
}
forvalues x = 0/15 {
matrix res[`x'+11,1]=`x'
matrix res[`x'+11,2]=temp[`x'+1,1]
matrix res[`x'+11,3]=temp[`x'+1,5]
matrix res[`x'+11,4]=temp[`x'+1,6]
}

preserve
drop _all
svmat res
twoway (scatter res2 res1, msize(medlarge) msymbol(o) mcolor(navy) legend(off)) ///
	(line res2 res1, lcolor(navy)) (rcap res4 res3 res1, lcolor(maroon)), ///
	 title("Sun & Abraham") xtitle("Relative time to change in law") ///
	 ytitle("Effect") ylabel(-1(.5)0.5) yscale(range(-1.1 0.8)) name(g2)
restore

* Part 5: Callaway-Sant'Anna

replace cohort=0 if cohort==.

csdid div_rate if year>1955 & year<1989 [weight=stpop], ivar(state) time(year) ///
	gvar(cohort) notyet agg(event)
estat event, window(-9 15)

/* As above, to produce a graph and compute average effects */ 
matrix temp=r(table)'
matrix res=J(26,4,0)
matrix res[10,1]=-1
forvalues x = 3/11 {
matrix res[`x'-2,1]=`x'-13
matrix res[`x'-2,2]=temp[`x',1]
matrix res[`x'-2,3]=temp[`x',5]
matrix res[`x'-2,4]=temp[`x',6]
}
forvalues x = 0/15 {
matrix res[`x'+11,1]=`x'
matrix res[`x'+11,2]=temp[`x'+12,1]
matrix res[`x'+11,3]=temp[`x'+12,5]
matrix res[`x'+11,4]=temp[`x'+12,6]
}

preserve
drop _all
svmat res
twoway (scatter res2 res1, msize(medlarge) msymbol(o) mcolor(navy) legend(off)) ///
	(line res2 res1, lcolor(navy)) (rcap res4 res3 res1, lcolor(maroon)), ///
	 title("Callaway & Sant'Anna") xtitle("Relative time to change in law") ///
	 ytitle("Effect") ylabel(-1(.5)0.5) yscale(range(-1.1 0.8)) name(g3)
restore


* Part 6: BJS, without state-specific trends

did_imputation div_rate state year cohort if year>1955 & year<1989 ///
	[aweight=stpop], horizons(0/15) autosample minn(0) pre(9)

* Joint nullity of all placebos
display e(pre_p)

/* As above, to produce a graph and compute average effects */ 
matrix temp=r(table)'
matrix cov = e(V)
matrix res=J(26,4,0)
matrix res[1,1]=-10
forvalues x = 1/9 {
matrix res[11-`x',1]=-`x'
matrix res[11-`x',2]=temp[`x'+16,1]
matrix res[11-`x',3]=temp[`x'+16,5]
matrix res[11-`x',4]=temp[`x'+16,6]
}
forvalues x = 0/15 {
matrix res[`x'+11,1]=`x'
matrix res[`x'+11,2]=temp[`x'+1,1]
matrix res[`x'+11,3]=temp[`x'+1,5]
matrix res[`x'+11,4]=temp[`x'+1,6]
}

* Average effects from 0 to 7 years after the law (+ its s.e.)
matrix res_av=J(1,2,0)
matrix res_avg[3,1] = res[11..18,2]'*e

matrix temp = e'*(cov[1..8,1..8]*e)
matrix res_avg[3,2] = sqrt(temp[1,1])

preserve
drop _all
svmat res
twoway (scatter res2 res1, msize(medlarge) msymbol(o) mcolor(navy) legend(off)) ///
	(line res2 res1, lcolor(navy)) (rcap res4 res3 res1, lcolor(maroon)), ///
	 title("Borusyak, Jaravel & Spiess") xtitle("Relative time to change in law") ///
	 ytitle("Effect") ylabel(-1(.5)0.5) yscale(range(-1.1 0.8)) name(g4)
restore


* Part 7: dC-DH estimator, without state-specific trends

did_multiplegt div_rate state year unilateral if year>1955 & year<1989, av ///
	robust_dynamic dynamic(15) placebo(9) long covariances joint ///
	cluster(state) breps(200) weight(stpop) seed(1) ///
	graphoptions(ylabel(-1(.5)0.5) yscale(range(-1.1 0.8)) legend(off) ///
	xtitle(Relative time to change in law) title(dC&DH w/o lin. trends) /// 
	ytitle(Effect) name(g5))
		
* Joint nullity of all placebos
display e(p_jointplacebo)

* Average effect
forvalues x=0/7{
	matrix res_avg[4,1]=res_avg[4,1]+e(effect_`x')
	matrix res_avg[4,2]=res_avg[4,2]+ e(se_effect_`x')^2
	if `x'<7{
		local x1 = `x'+1
		forvalues y=`x1'/7{
			matrix res_avg[4,2]=res_avg[4,2]+2*e(cov_effects_`x'_`y')
		}
	}
}
matrix res_avg[4,1]=res_avg[4,1]/8
matrix res_avg[4,2]=sqrt(res_avg[4,2])/8

* Part 8: dC-DH estimator, with linear time trends

did_multiplegt div_rate state year unilateral if year>1955 & year<1989, av ///
	robust_dynamic dynamic(15) placebo(9) long covariances joint ///
	trends_lin(state) cluster(state) breps(200) weight(stpop) seed(1) ///
	graphoptions(ylabel(-1(.5)1.5) yscale(range(-1.1 0.8)) legend(off) ///
	xtitle(Relative time to change in law) title(dC&DH with lin. trends) /// 
	ytitle(Effect) name(g6))
	
* Joint nullity of all placebos
display e(p_jointplacebo)

forvalues x=0/7{
	matrix res_avg[5,1]=res_avg[5,1]+e(effect_`x')
	matrix res_avg[5,2]=res_avg[5,2]+ e(se_effect_`x')^2
	if `x'<7{
		local x1 = `x'+1
		forvalues y=`x1'/7{
			matrix res_avg[5,2]=res_avg[5,2]+2*e(cov_effects_`x'_`y')
		}
	}
}

matrix res_avg[5,1]=res_avg[5,1]/8
matrix res_avg[5,2]=sqrt(res_avg[5,2])/8


matrix rownames res_avg = "Wolfers" "TWFE" "BJS" "dC&DH no lin" "dC&DH, lin"
matrix colnames res_avg = Coeff se

* This produces Table 1 of the paper 
matrix list res_avg

* Gather all graphs together, to produce Figure 3 in the paper
graph combine g1 g2 g3 g4 g5 g6
graph export graphs.pdf, replace

graph drop g*

** Appendix **
* You have to uncomment the lines below to check points 1), 2) and 3)


* 1) the commands csdid and did_multiplegt return the same results w/o weights

/* 
csdid div_rate if year>1955 & year<1989, ivar(state) time(year) ///
	gvar(cohort) notyet agg(event) 

did_multiplegt div_rate state year unilateral if year>1955 & year<1989,  ///
	robust_dynamic dynamic(15) breps(2)
*/	

* 2) csdid returns an error when trying to compute "long" placebos

/* 
csdid div_rate if year>1955 & year<1989 [weight=stpop], ivar(state) time(year) ///
	gvar(cohort) notyet agg(event) long
*/

* 3) did_imputation returns an error when trying to include state linear trends
/*
drop _I*
xi i.st*time

did_imputation div_rate state year cohort if year>1955 & year<1989 ///
[aweight=stpop], fe(state year) h(0/15) autosample pretrends(9) minn(0) ///
controls(_IstXtime_1-_IstXtime_21 _IstXtime_23-_IstXtime_51)
*/
