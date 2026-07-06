*! version 0.0  31mar2021  Liyang Sun, lsun20@mit.edu
capture program drop eventstudyinteract
program define eventstudyinteract, eclass sortpreserve
	version 13 
	syntax varlist(min=1 numeric) [if] [in] [aw fw iw pw], absorb(varlist numeric ts fv) cohort(varname) ///
		control_cohort(varname) ///
		[COVARIATEs(varlist numeric ts fv)  vce(string)   ///
		]
	set more off
	
	* Mark sample (reflects the if/in conditions, and includes only nonmissing observations)
	marksample touse
	markout `touse' `by' `xq' `covariates' `absorb', strok
	* Parse the dependent variable
	local lhs: word 1 of `varlist'
	local rel_time_list: list varlist - lhs
	* Convert the varlist of relative time indicators to nvarlist 
	local nvarlist "" // copies of relative time indicators with control cohort set to zero
	local dvarlist "" // for display
	foreach l of varlist `rel_time_list' {
		local dvarlist "`dvarlist' `l'"
		tempname n`l'
		qui gen `n`l'' = `l'
		qui replace `n`l'' = 0 if  `control_cohort' == 1
		local nvarlist "`nvarlist' `n`l''"
	}	

	* Get cohort count  and count of relative time
	qui levelsof `cohort' if  `control_cohort' == 0, local(cohort_list) 
 	local nrel_times: word count `nvarlist' 
	local ncohort: word count `cohort_list'  
	
	* Initiate empty matrix for weights 
	* ff_w stores the cohort shares (rows) for relative time (cols)
	tempname bb ff_w
	
	* Loop over cohort and get cohort shares for relative times
	local nresidlist ""
	foreach yy of local cohort_list {
		tempvar cohort_ind resid`yy'
		qui gen `cohort_ind'  = (`cohort' == `yy') 
		qui regress `cohort_ind' `nvarlist'  if `touse' & `control_cohort' == 0 [`weight'`exp']  , nocons
		mat `bb' = e(b)
		matrix `ff_w'  = nullmat(`ff_w') \ `bb'
		qui predict double `resid`yy'', resid
		local nresidlist "`nresidlist' `resid`yy''"
	}
 
	
	* Get VCV estimate for the cohort shares using avar
	* In case users have not set relative time indicators to zero for control cohort
	* Manually restrict the sample to non-control cohort
	tempname XX Sxx Sxxi S KSxxi Sigma_ff
	mat accum `XX' = `nvarlist' if  `touse' & `control_cohort' == 0 [`weight'`exp'], nocons
	mat `Sxx' = `XX'*1/r(N)
    mat `Sxxi' = syminv(`Sxx')
	qui avar (`nresidlist') (`nvarlist')  if `touse' & `control_cohort' == 0 [`weight'`exp'], nocons robust
	mat `S' = r(S)
    mat `KSxxi' = I(`ncohort')#`Sxxi'
    mat `Sigma_ff' = `KSxxi'*`S'*`KSxxi'*1/r(N)
	// Note that the normalization is slightly different from the paper
	// The scaling factor is 1/N for N the obs of cross-sectional units
	// But here estimates are on the panel, which is why it is 1/NT instead
	// Should cancel out for balanced panel, but unbalanced panel is a TODO
	
	* Prepare interaction terms for the interacted regression
	local cohort_rel_varlist "" // hold the temp varnames	
	foreach l of varlist `nvarlist' {
		foreach yy of local cohort_list {
			tempvar n`l'_`yy'
			qui gen `n`l'_`yy''  = (`cohort' == `yy') * `l' 
			// TODO: might be more efficient to use the c. operator if format w/o missing
			local cohort_rel_varlist "`cohort_rel_varlist' `n`l'_`yy''"
		}
	}
	local bcohort_rel_varlist "" // hold the interaction varnames
	foreach l of varlist `rel_time_list'  {
		foreach yy of local cohort_list {
				local bcohort_rel_varlist "`bcohort_rel_varlist' `l'_x_`yy'"
		}
	}
	* Estimate the interacted regression
	tempname evt_bb b evt_VV V
	qui reghdfe `lhs'  `cohort_rel_varlist'  `covariates'  if `touse' [`weight'`exp'], absorb(`absorb') vce(`vce')
	local bcohort_rel_varlist "`bcohort_rel_varlist' `covariates'" // TODO: does not catch the constant term if reghdfe includes a constant.
	mat `b' = e(b)
	mata st_matrix("`V'",diagonal(st_matrix("e(V)"))')
	* Convert the delta estimate vector to a matrix where each column is a relative time
	local end = 0
	forval i = 1/`nrel_times' {
		local start = `end'+1
		local end = `start'+`ncohort'-1
		mat `b'`i' = `b'[.,`start'..`end']
		mat `evt_bb'  = nullmat(`evt_bb') \ `b'`i'
		mat `V'`i' = `V'[.,`start'..`end']
		mat `evt_VV'  = nullmat(`evt_VV') \ `V'`i'

	}
	mat `evt_bb' = `evt_bb''
	mat `evt_VV' = `evt_VV''

	* Take weighted average for IW estimators
	tempname w delta b_iw nc nr
	mata: `w' = st_matrix("`ff_w'")
	mata: `delta' = st_matrix("`evt_bb'")
	mata: `b_iw' = colsum(`w':* `delta')
	mata: st_matrix("`b_iw'", `b_iw')
	mata: `nc' = rows(`w')
	mata: `nr' = cols(`w')

	* Ptwise variance from cohort share estimation and interacted regression
	tempname VV  wlong V_iw V_iw_diag 
	
	* VCV from the interacted regression
	mata: `VV' = st_matrix("e(V)")
	mata: `VV' = `VV'[1..`nr'*`nc',1..`nr'*`nc'] // in case reghdfe reports _cons
	mata: `wlong' = `w'':*J(1,`nc',e(1,`nr')') // create a "Toeplitz" matrix convolution
	forval i=2/`nrel_times' {
		mata: `wlong' = (`wlong', `w'':*J(1,`nc',e(`i',`nr')'))
	}
	mata: `V_iw' = diagonal(`wlong'*`VV'*`wlong'')
	
	* VCV from cohort share estimation
	tempname Vshare Vshare_evt share_idx Sigma_l
	mata: `Vshare' = st_matrix("`Sigma_ff'")
	mata: `Sigma_l' = J(0,0,.)
	mata: `share_idx' = range(0,(`nc'-1)*`nr',`nr')
	forval i=1/`nrel_times' {
		mata: `Vshare_evt' = `Vshare'[`share_idx':+`i', `share_idx':+`i']
		mata: `V_iw'[`i'] = `V_iw'[`i'] + (`delta'[,`i'])'*`Vshare_evt'*(`delta'[,`i'])
		mata: `Sigma_l' = blockdiag(`Sigma_l',`Vshare_evt')
	}
	mata: `V_iw' = `V_iw''
	mata: st_matrix("`Sigma_l'", `Sigma_l')
	mata: st_matrix("`V_iw'", `V_iw')
	
	mata: `V_iw_diag' = diag(`V_iw')
	mata: st_matrix("`V_iw_diag'", `V_iw_diag')
	mata: mata drop `b_iw' `VV' `nc' `nr' `w' `wlong' `Vshare' `share_idx' `delta' `Vshare_evt' `Sigma_l' `V_iw' `V_iw_diag' 
	
	matrix colnames `b_iw' =  `dvarlist'
	matrix colnames `V_iw' =  `dvarlist'
	matrix rownames `ff_w' =  `cohort_list'
	matrix colnames `ff_w' =  `dvarlist'
	matrix colnames `evt_bb' =  `dvarlist'
	matrix rownames `evt_bb' =  `cohort_list'
	matrix colnames `evt_VV' =  `dvarlist'
	matrix rownames `evt_VV' =  `cohort_list'
	
	ereturn matrix b_interact `evt_bb'
	ereturn matrix V_interact `evt_VV'
	ereturn matrix b_iw  `b_iw' 
	ereturn matrix V_iw `V_iw'
	ereturn matrix ff_w `ff_w'
	ereturn matrix Sigma_l `Sigma_l'
	
	ereturn local title "IW estimates for dynamic effects"
	* Display results	
	_coef_table_header
	_coef_table , bmatrix(e(b_iw)) vmatrix(`V_iw_diag')

end	

