*! did_imputation: Treatment effect estimation and pre-trend testing in staggered adoption diff-in-diff designs with an imputation approach of Borusyak, Jaravel, and Spiess (2021)
*! Version: March 1, 2022
*! Author: Kirill Borusyak
*! Recent updates: added leave-out standard errors, fixed a problem with minn when wtr have negative values, report coefs on controls
*! Please check the latest version at: https://github.com/borusyak/did_imputation/
*! Citation: Borusyak, Jaravel, and Spiess, "Revisiting Event Study Designs: Robust and Efficient Estimation" (2021)
program define did_imputation, eclass sortpreserve
version 13.0
syntax varlist(min=4 max=4) [if] [in] [aw iw] [, wtr(varlist) sum Horizons(numlist >=0) ALLHorizons HBALance minn(integer 30) shift(integer 0) ///
	AUTOSample SAVEestimates(name) SAVEWeights LOADWeights(varlist) ///
	AVGEFFectsby(varlist) fe(string) Controls(varlist) UNITControls(varlist) TIMEControls(varlist) ///
	CLUSter(varname) leaveout tol(real 0.000001) maxit(integer 100) verbose nose PREtrends(integer 0) delta(integer 0) alpha(real 0.05)]
qui {
	if ("`verbose'"!="") noi di "Starting"
	ms_get_version reghdfe, min_version("5.7.3")
	ms_get_version ftools, min_version("2.37.0")
	// Part 1: Initialize
	marksample touse, novarlist
	if ("`controls'"!="") markout `touse' `controls'
	if ("`unitcontrols'"!="") markout `touse' `unitcontrols'
	if ("`timecontrols'"!="") markout `touse' `timecontrols'
//	if ("`timeinteractions'"!="") markout `touse' `timeinteractions'
	if ("`cluster'"!="") markout `touse' `cluster', strok
	if ("`saveestimates'"!="") confirm new variable `saveestimates'
	if ("`saveweights'"!="") confirm new variable `saveweights'
	if ("`verbose'"!="") noi di "#00"
	tempvar wei
	if ("`weight'"=="") {
	    gen `wei' = 1
		local weiexp ""
	}
	else {
		gen `wei' `exp'
		replace `wei' = . if `wei'==0
		markout `touse' `wei'
		
		if ("`sum'"=="") { // unless want a weighted sum, normalize the weights to have reasonable scale, just in case for better numerical convergence
			sum `wei' if `touse'
			replace `wei' = `wei' * r(N)/r(sum)
		}
		local weiexp "[`weight'=`wei']"
	}
	local debugging = ("`verbose'"=="verbose")
	
	tokenize `varlist'
	local Y `1'
	local i `2'
	local t `3'
	local ei `4'
	markout `touse' `Y' `t' // missing `ei' is fine, indicates the never-treated group
	markout `touse' `i', strok
	
	tempvar D K
	
	// Process FE
	if ("`fe'"=="") local fe `i' `t'
	if ("`fe'"==".") {
	    tempvar constant
		gen `constant' = 1
	    local fe `constant'
	}
	local fecount = 0
	foreach fecurrent of local fe {
	    if (("`fecurrent'"!="`i'" | "`unitcontrols'"=="") & ("`fecurrent'"!="`t'" | "`timecontrols'"=="")) { // skip i and t if there are corresponding interacted controls 
			local ++fecount
			local fecopy `fecopy' `fecurrent'
			local fe`fecount' = subinstr("`fecurrent'","#"," ",.)
			markout `touse' `fe`fecount'', strok
		}
	}
	local fe `fecopy'
	
	// Figure out the delta
	if (`delta'==0) {
		cap tsset, noquery
		if (_rc==0) {
			if (r(timevar)=="`t'") {
				local delta = r(tdelta)
				if (`delta'!=1) noi di "Note: setting delta = `delta'"
			}
		}
		else local delta = 1
	}
	if (`delta'<=0 | mi(`delta')) {
		di as error "A problem has occured with determining delta. Please specify it explicitly."
		error 198
	}
	
	if (`debugging') noi di "#1"
	gen `K' = (`t'-`ei'+`shift')/`delta' if `touse'
	cap assert mi(`K') | mod(`K',1)==0
	if (_rc!=0) {
		di as error "There are non-integer values of the number of periods since treatment. Please check the time dimension of your data."
		error 198
	}
	
	gen `D' = (`K'>=0 & !mi(`K')) if `touse'

	if ("`avgeffectsby'"=="") local avgeffectsby = "`ei' `t'"
	if ("`cluster'"=="") local cluster = "`i'"
	
	if ("`autosample'"!="" & "`sum'"!="") {
		di as error "Autosample cannot be combined with sum. Please specify the sample explicitly"
		error 184
	}
	if ("`autosample'"!="" & "`hbalance'"!="") {
		di as error "Autosample cannot be combined with hbalance. Please specify the sample explicitly"
		error 184
	}
	if (`debugging') noi di "#2 `fe'"
	
	// Part 2: Prepare the variables with weights on the treated units (e.g. by horizon)
	local wtr_count : word count `wtr'
	if (`wtr_count'==0) { // if no wtr, use the simple average
		tempvar wtr
		gen `wtr' = 1 if (`touse') & (`D'==1)
		local wtrnames tau
		local wtr_count = 1
	}
	else { // create copies of the specified variables so that I can modify them later (adjust for weights, normalize)
		if (`wtr_count'==1) local wtrnames tau
			else local wtrnames "" // will fill it in the loop
		
	    local wtr_new_list 
		foreach v of local wtr {
		    tempvar `v'_new
			gen ``v'_new' = `v' if `touse'
			local wtr_new_list `wtr_new_list' ``v'_new'
			if (`wtr_count'>1) local wtrnames `wtrnames' tau_`v'
		}
		local wtr `wtr_new_list'
	}

	* Horizons
	if (("`horizons'"!="" | "`allhorizons'"!="") & `wtr_count'>1) {
		di as error "Options horizons and allhorizons cannot be combined with multiple wtr variables"
		error 184
	}
	
	if ("`allhorizons'"!="") {
		if ("`horizons'"!="") {
			di as error "Options horizons and allhorizons cannot be combined"
			error 184
		}
		if ("`hbalance'"!="") di as error "Warning: combining hbalance with allhorizons may lead to very restricted samples. Consider specifying a smaller subset of horizons."
		
		levelsof `K' if `touse' & `D'==1 & `wtr'!=0 & !mi(`wtr'), local(horizons) 
	}
	
	if ("`horizons'"!="") { // Create a weights var for each horizon
		if ("`hbalance'"=="hbalance") {
		    // Put zero weight on units for which we don't have all horizons
			tempvar in_horizons num_horizons_by_i min_weight_by_i max_weight_by_i
			local n_horizons = 0
			gen `in_horizons'=0 if `touse'
			foreach h of numlist `horizons' {
				replace `in_horizons'=1 if (`K'==`h') & `touse'
				local ++n_horizons
			}
			egen `num_horizons_by_i' = sum(`in_horizons') if `in_horizons'==1, by(`i')
			replace `wtr' = 0 if `touse' & (`in_horizons'==0 | (`num_horizons_by_i'<`n_horizons'))
			
			// Now check whether wtr and wei weights are identical across periods
			egen `min_weight_by_i' = min(`wtr'*`wei') if `touse' & `in_horizons'==1 & (`num_horizons_by_i'==`n_horizons'), by(`i')
			egen `max_weight_by_i' = max(`wtr'*`wei') if `touse' & `in_horizons'==1 & (`num_horizons_by_i'==`n_horizons'), by(`i')
			cap assert `max_weight_by_i'<=1.000001*`min_weight_by_i' if `touse' & `in_horizons'==1 & (`num_horizons_by_i'==`n_horizons')
			if (_rc>0) {
			    di as error "Weights must be identical across periods for units in the balanced sample"
				error 498
			}
			drop `in_horizons' `num_horizons_by_i' `min_weight_by_i' `max_weight_by_i'
		}
		foreach h of numlist `horizons' {
		    tempvar wtr`h'
			gen `wtr`h'' = `wtr' * (`K'==`h')
			local horlist `horlist' `wtr`h''
			local hornameslist `hornameslist' tau`h'
		}
		local wtr `horlist'
		local wtrnames `hornameslist'
	}
	if (`debugging') noi di "List: `wtr'"
	if (`debugging') noi di "Namelist: `wtrnames'"
	
	if ("`sum'"=="") { // If computing the mean, normalize each wtr variable such that sum(wei*wtr*(D==1))==1
		foreach v of local wtr {
			cap assert `v'>=0 if (`touse') & (`D'==1)
			if (_rc!=0) {
				di as error "Negative wtr weights are only allowed if the sum option is specified"
				error 9
			}
			sum `v' `weiexp' if (`touse') & (`D'==1)
			replace `v' = `v'/r(sum) // r(sum)=sum(`v'*`weiexp')
		}
	}
	
	// Part 2A: initialize the matrices [used to be just before Part 5]
	local tau_num : word count `wtr'
	local ctrl_num : word count `controls'
	if (`debugging') noi di `tau_num' 
	if (`debugging') noi di `"`wtr' | `wtrnames' | `controls'"'
	tempname b Nt
	matrix `b' = J(1,`tau_num'+`pretrends'+`ctrl_num',.)
	matrix `Nt' = J(1,`tau_num',.)
	if (`debugging') noi di "#4.0"
	
	// Part 3: Run the imputation regression and impute the controls for treated obs
	if ("`unitcontrols'"!="") local fe_i `i'##c.(`unitcontrols')
	if ("`timecontrols'"!="") local fe_t `t'##c.(`timecontrols')
	
	count if (`D'==0) & (`touse')
	if (r(N)==0) {
	    if (`shift'==0) noi di as error "There are no untreated observations, i.e. those with `t'<`ei' or mi(`ei')."
			else noi di as error "There are no untreated observations, i.e. those with `t'<`ei'-`shift' or mi(`ei')."
		noi di as error "Please double-check the period & event time variables."
		noi di
		error 459
	}
	
	tempvar imput_resid
	if (`debugging') noi di "#4: reghdfe `Y' `controls' if (`D'==0) & (`touse') `weiexp', a(`fe_i' `fe_t' `fe', savefe) nocon keepsing resid(`imput_resid') cluster(`cluster')"
	if (`debugging') noi reghdfe `Y' `controls' if (`D'==0) & (`touse') `weiexp', a(`fe_i' `fe_t' `fe', savefe) nocon keepsing resid(`imput_resid') cluster(`cluster')
		else reghdfe `Y' `controls' if (`D'==0) & (`touse') `weiexp', a(`fe_i' `fe_t' `fe', savefe) nocon keepsing resid(`imput_resid') cluster(`cluster')verbose(-1)
		// nocon makes the constant recorded in the first FE
		// keepsing is important for when there are units available in only one period (e.g. treated in period 2) which are fine
		// verbose(-1) suppresses singleton warnings
	local dof_adj = (e(N)-1)/(e(N)-e(df_m)-e(df_a)) * (e(N_clust)/(e(N_clust)-1)) // that's how regdfhe does dof adjustment with clusters, see reghdfe_common.mata line 634
		
	* Extrapolate the controls to the treatment group and construct Y0 (do it right away before the next reghdfe kills __hdfe*)
	if (`debugging') noi di "#5"
	tempvar Y0
	gen `Y0' = 0 if `touse'
	
	local feset = 1 // indexing as in reghdfe
	if ("`unitcontrols'"!="") {
	    recover __hdfe`feset'__*, from(`i')
		replace `Y0' = `Y0' + __hdfe`feset'__ if `touse'
		local j=1
		foreach v of local unitcontrols {
			replace `Y0' = `Y0'+__hdfe`feset'__Slope`j'*`v' if `touse'
			local ++j
		}
		local ++feset
	}
	if ("`timecontrols'"!="") {
	    recover __hdfe`feset'__*, from(`t')
		replace `Y0' = `Y0' + __hdfe`feset'__ if `touse'
		local j=1
		foreach v of local timecontrols {
			replace `Y0' = `Y0'+__hdfe`feset'__Slope`j'*`v' if `touse'
			local ++j
		}
		local ++feset
	}
	forvalues feindex = 1/`fecount' { // indexing as in the fe option
	    recover __hdfe`feset'__, from(`fe`feindex'')
		replace `Y0' = `Y0' + __hdfe`feset'__ if `touse'
	    local ++feset
	}
	foreach v of local controls {
		replace `Y0' = `Y0'+_b[`v']*`v' if `touse'
	}
	if (`debugging') noi di "#7"
	
	if ("`saveestimates'"=="") tempvar effect
	else {
		local effect `saveestimates'
		cap confirm var `effect', exact
		if (_rc==0) drop `effect'
	}
	gen `effect' = `Y' - `Y0' if (`D'==1) & (`touse')

	drop __hdfe*
	if (`debugging') noi di "#8"

	* Save control coefs and prepare weights corresponding to the controls to report them later
	if (`ctrl_num'>0) {
		forvalues h = 1/`ctrl_num' {
			local ctrl_current : word `h' of `controls'
			matrix `b'[1,`tau_num'+`pretrends'+`h'] = _b[`ctrl_current']
			local ctrlb`h' = _b[`ctrl_current']
			local ctrlse`h' = _se[`ctrl_current']
		}
		local ctrl_df = e(df_r)
		if (`debugging') noi di "#4B"
		local list_ctrl_weps
		if ("`se'"!="nose") { // Construct weights behind control estimaters. [Could speed up by residualizing all relevant vars on FE first?]
			if (`debugging') noi di "#4C3"
			local ctrlvars "" // drop omitted vars from controls (so that residualization works correctly when computing SE?)
			forvalues h = 1/`ctrl_num' {
				local ctrl_current : word `h' of `controls'
				if (`ctrlb`h''!=0 | `ctrlse`h''!=0) local ctrlvars `ctrlvars' `ctrl_current'
			}
			if (`debugging') noi di "#4C4 `ctrlvars'"
			
			tempvar ctrlweight ctrlweight_product // ctrlweight_product=ctrlweight * ctrl_current
			forvalues h = 1/`ctrl_num' {
				if (`debugging') noi di "#4D `h'"
				tempvar ctrleps_w`h'
				if (`ctrlb`h''==0 & `ctrlse`h''==0) gen `ctrleps_w`h'' = 0 // omitted
				else {
					local ctrl_current : word `h' of `controls'
					local rhsvars = subinstr(" `ctrlvars' "," `ctrl_current' "," ",.) 
					reghdfe `ctrl_current' `rhsvars' `weiexp' if `touse' & `D'==0,  a(`fe_i' `fe_t' `fe') cluster(`cluster') resid(`ctrlweight')
					replace `ctrlweight' = `ctrlweight' * `wei'
					gen `ctrlweight_product' = `ctrlweight' * `ctrl_current'
					sum `ctrlweight_product' if `touse' & `D'==0 
					replace `ctrlweight' = `ctrlweight'/r(sum)
					egen `ctrleps_w`h'' = total(`ctrlweight' * `imput_resid') if `touse', by(`cluster')
					replace `ctrleps_w`h'' = `ctrleps_w`h'' * sqrt(`dof_adj')
					drop `ctrlweight' `ctrlweight_product'
				}
				local list_ctrl_weps `list_ctrl_weps' `ctrleps_w`h''
			}		
		}
		if (`debugging') noi di "#4.75 `list_ctrl_weps'"	
	}
		
	// Check if imputation was successful, and apply autosample
	* For FE can just check they have been imputed everywhere
	tempvar need_imputation
	gen byte `need_imputation' = 0
	foreach v of local wtr {
	    replace `need_imputation'=1 if `touse' & `D'==1 & `v'!=0 & !mi(`v')
	}
	replace `touse' = (`touse') & (`D'==0 | `need_imputation') // View as e(sample) all controls + relevant treatments only
	
	count if mi(`effect') & `need_imputation'
	if r(N)>0 {
		if (`debugging') noi di "#8b `wtr'"
		cap drop cannot_impute
		gen byte cannot_impute = mi(`effect') & `need_imputation'
		count if cannot_impute==1
		if ("`autosample'"=="") {
			noi di as error "Could not impute FE for " r(N) " observations. Those are saved in the cannot_impute variable. Use the autosample option if you would like those observations to be dropped from the sample automatically."
			error 198
		}
		else { // drop the subsample where it didn't work and renormalize all wtr variables
			assert "`sum'"==""
			local j = 1
			qui foreach v of local wtr {
				if (`debugging') noi di "#8d sum `v' `weiexp' if `touse' & `D'==1"
				local outputname : word `j' of `wtrnames'
				sum `v' `weiexp' if `touse' & `D'==1 // just a test that it added up to one first
				if (`debugging') noi di "#8dd " r(sum)
				assert abs(r(sum)-1)<10^-5 | abs(r(sum))<10^-5 // if this variable is always zero/missing, then the sum would be zero
				
				count if `touse' & `D'==1 & cannot_impute==1 & `v'!=0 & !mi(`v') 
				local n_cannot_impute = r(N) // count the dropped units
				if (`n_cannot_impute'>0) {
					sum `v' `weiexp' if `touse' & `D'==1 & cannot_impute!=1 & `v'!=0 & !mi(`v') // those still remaining
					if (r(N)==0) {
						replace `v' = 0 if `touse' & `D'==1 // totally drop the wtr
						local autosample_drop `autosample_drop' `outputname'
					}
					else {
						replace `v' = `v'/r(sum) if `touse' & `D'==1 & cannot_impute!=1
						replace `v' = 0 if cannot_impute==1
						local autosample_trim `autosample_trim' `outputname'
					}
				}
				local ++j
			}
			if (`debugging') noi di "#8e"
			replace `touse' = `touse' & cannot_impute!=1
			if ("`autosample_drop'"!="") noi di "Warning: suppressing the following coefficients because FE could not be imputed for any units: `autosample_drop'." 
			if ("`autosample_trim'"!="") noi di "Warning: part of the sample was dropped for the following coefficients because FE could not be imputed: `autosample_trim'." 
		}		
	}
	* Compare model degrees of freedom [does not work correctly for timecontrols and unitcontrols, need to recompute]
	if (`debugging') noi di "#8c"
	tempvar tnorm
	gen `tnorm' = rnormal() if (`touse') & (`D'==0 | `need_imputation')
	reghdfe `tnorm' `controls' if (`D'==0) & (`touse'), a(`fe_i' `fe_t' `fe') nocon keepsing verbose(-1)
	local df_m_control = e(df_m) // model DoF corresponding to explicitly specified controls
	local df_a_control = e(df_a) // DoF for FE
	reghdfe `tnorm' `controls' , a(`fe_i' `fe_t' `fe') nocon keepsing verbose(-1)
	local df_m_full = e(df_m) 
	local df_a_full = e(df_a) 
	if (`debugging') noi di "#9 `df_m_control' `df_m_full' `df_a_control' `df_a_full'"
	if (`df_m_control'<`df_m_full') {
		di as error "Could not run imputation for some observations because some controls are collinear in the D==0 subsample but not in the full sample"
		if ("`autosample'"!="") di as error "Please note that autosample does not know how to deal with this. Please correct the sample manually"
		error 481
	}
	if (`df_a_control'<`df_a_full') {
		di as error "Could not run imputation for some observations because some absorbed variables/FEs are collinear in the D==0 subsample but not in the full sample"
		if ("`autosample'"!="") di as error "Please note that autosample does not know how to deal with this. Please correct the sample manually"
		error 481
	}
	
	
	// Part 4: Suppress wtr which have an effective sample size (for absolute weights of treated obs) that is too small
	local droplist 
	tempvar abswei
	gen `abswei' = .
	local j = 1
	foreach v of local wtr {
		local outputname : word `j' of `wtrnames'
		replace `abswei' = abs(`v') if (`touse') & (`D'==1)
		sum `abswei' `weiexp' 
		if (r(sum)!=0) { // o/w dropped earlier
			replace `abswei' = (`v'*`wei'/r(sum))^2  if (`touse') & (`D'==1) // !! Probably doesn't work with fw, not sure about pw; probably ok for aw
			sum `abswei'
			if (r(sum)>1/`minn') { // HHI is large => effective sample size is too small
				local droplist `droplist' `outputname'
				replace `v' = 0 if `touse'
			}
		}
		else local droplist `droplist' `outputname' // not ideal: should report those with no data at all separately (maybe together with autosample_drop?)
		local ++j
	}
	if ("`droplist'"!="") noi di "WARNING: suppressing the following coefficients from estimation because of insufficient effective sample size: `droplist'. To report them nevertheless, set the minn option to a smaller number or 0, but keep in mind that the estimates may be unreliable and their SE may be downward biased." 
	
	if (`debugging') noi di "#9.5"
	
	// Part 5: pre-tests
	if (`pretrends'>0) {
		tempname pretrendvar
		tempvar preresid
		forvalues h = 1/`pretrends' {
			gen `pretrendvar'`h' = (`K'==-`h') if `touse'
			local pretrendvars `pretrendvars' `pretrendvar'`h'
			local prenames `prenames' pre`h'
		}
		if (`debugging') noi di "#9A reghdfe `Y' `controls' `pretrendvars' `weiexp' if `touse' & `D'==0,  a(`fe_i' `fe_t' `fe') cluster(`cluster') resid(`preresid')"
		reghdfe `Y' `controls' `pretrendvars' `weiexp' if `touse' & `D'==0,  a(`fe_i' `fe_t' `fe') cluster(`cluster') resid(`preresid')
		forvalues h = 1/`pretrends' {
			matrix `b'[1,`tau_num'+`h'] = _b[`pretrendvar'`h']
			local preb`h' = _b[`pretrendvar'`h']
			local prese`h' = _se[`pretrendvar'`h']
		}
		local pre_df = e(df_r)
		if (`debugging') noi di "#9B"
		local list_pre_weps
		if ("`se'"!="nose") { // Construct weights behind pre-trend estimaters. Could speed up by residualizing all relevant vars on FE first
			matrix pre_b = e(b)
			if (`debugging') noi di "#9C1"
			matrix pre_V = e(V)
			if (`debugging') noi di "#9C2"
			local dof_adj = (e(N)-1)/(e(N)-e(df_m)-e(df_a)) * (e(N_clust)/(e(N_clust)-1)) // that's how regdfhe does dof adjustment with clusters, see reghdfe_common.mata line 634
			if (`debugging') noi di "#9C3"
			local pretrendvars "" // drop omitted vars from pretrendvars (so that residualization works correctly when computing SE)
			forvalues h = 1/`pretrends' {
				if (`preb`h''!=0 | `prese`h''!=0) local pretrendvars `pretrendvars' `pretrendvar'`h'
			}
			if (`debugging') noi di "#9C4 `pretrendvars'"
			
			tempvar preweight
			forvalues h = 1/`pretrends' {
				if (`debugging') noi di "#9D `h'"
				tempvar preeps_w`h'
				if (`preb`h''==0 & `prese`h''==0) gen `preeps_w`h'' = 0 // omitted
				else {
					local rhsvars = subinstr(" `pretrendvars' "," `pretrendvar'`h' "," ",.) 
					reghdfe `pretrendvar'`h' `controls' `rhsvars' `weiexp' if `touse' & `D'==0,  a(`fe_i' `fe_t' `fe') cluster(`cluster') resid(`preweight')
					replace `preweight' = `preweight' * `wei'
					sum `preweight' if `touse' & `D'==0 & `pretrendvar'`h'==1
					replace `preweight' = `preweight'/r(sum)
					egen `preeps_w`h'' = total(`preweight' * `preresid') if `touse', by(`cluster')
					replace `preeps_w`h'' = `preeps_w`h'' * sqrt(`dof_adj')
					drop `preweight'
				}
				local list_pre_weps `list_pre_weps' `preeps_w`h''
			}		
		}
		if (`debugging') noi di "#9.75"	
	}

	// Part 6: Compute the effects 
	count if `D'==0 & `touse'
	local Nc = r(N)	
	
	count if `touse'
	local Nall = r(N)

	tempvar effectsum
	gen `effectsum' = .
	local j = 1
	foreach v of local wtr {
		local outputname : word `j' of `wtrnames'
		if (`debugging') noi di "Reporting `j' `v' `outputname'"

		replace `effectsum' = `effect'*`v'*`wei' if (`D'==1) & (`touse')
		sum `effectsum'
		//ereturn scalar `outputname' = r(sum)
		matrix `b'[1,`j'] = r(sum)
	    
		count if `D'==1 & `touse' & `v'!=0 & !mi(`v')
		matrix `Nt'[1,`j'] = r(N)

		local ++j
	}
	
	if (`debugging') noi di "#10"
	
	// Part 7: Report SE [can add a check that there are no conflicts in the residuals]
	if ("`se'"!="nose") { 
		cap drop __w_*
		tempvar tag_clus resid 
		egen `tag_clus' = tag(`cluster') if `touse'
		gen `resid' = `Y' - `Y0' if (`touse') & (`D'==0)
		if ("`loadweights'"=="") {
			local weightvars = ""
			foreach vn of local wtrnames {
				local weightvars `weightvars' __w_`vn'
			}
			if (`debugging') noi di "#11a imputation_weights `i' `t' `D' , touse(`touse') wtr(`wtr') saveweights(`weightvars') wei(`wei') fe(`fe') controls(`controls') unitcontrols(`unitcontrols') timecontrols(`timecontrols') tol(`tol') maxit(`maxit')"
			noi imputation_weights `i' `t' `D', touse(`touse') wtr(`wtr') saveweights(`weightvars') wei(`wei') ///
				fe(`fe') controls(`controls') unitcontrols(`unitcontrols') timecontrols(`timecontrols') ///
				tol(`tol') maxit(`maxit') `verbose'
			local Niter = r(iter)
		}
		else {
		    local weightvars `loadweights'
			// Here can verify the supplied weights
		}
		
		local list_weps = ""
		local j = 1
		foreach v of local wtr { // to do: speed up by sorting for all wtr together
			if (`debugging') noi di "#11b `v'"
			local weightvar : word `j' of `weightvars'
			tempvar clusterweight smartweight smartdenom avgtau eps_w`j' // Need to regenerate every time in case the weights on treated are in conflict
			egen `clusterweight' = total(`wei'*`v') if `touse' & (`D'==1), by(`cluster' `avgeffectsby')
			egen `smartdenom' = total(`clusterweight' * `wei' * `v') if `touse' & (`D'==1), by(`avgeffectsby')
			gen `smartweight' = `clusterweight' * `wei' * `v' / `smartdenom' if `touse' & (`D'==1)
			replace `smartweight' = 0 if mi(`smartweight') & `touse' & (`D'==1) // if the denominator is zero, this avgtau won't matter
			egen `avgtau' = sum(`effect'*`smartweight') if (`touse') & (`D'==1), by(`avgeffectsby')
			replace `resid' = `effect'-`avgtau' if (`touse') & (`D'==1)
			if ("`leaveout'"!="") {
				if (`debugging') noi di "#11LO"
				count if `smartdenom'>0 & ((`clusterweight'^2)/`smartdenom'>0.99999) & (`touse') & (`D'==1)
				if (r(N)>0) {
					local outputname : word `j' of `wtrnames' // is this the correct variable name when some coefs have been dropped?
					di as error `"Cannot compute leave-out standard errors because of "' r(N) `" observations for coefficient "`outputname'""'
					di as error "This most likely happened because there are cohorts with only one unit or cluster (and the default value for avgeffectsby  is used)."
					di as error "Consider using the avgeffectsby option with broader observation groups. Do not address this problem by using non-leave-out standard errors, as they may be downward biased for the same reason."
					error 498
				}
				replace `resid' = `resid' * `smartdenom' / (`smartdenom'-(`clusterweight'^2)) if (`touse') & (`D'==1)
			}
			egen `eps_w`j'' = sum(`wei'*`weightvar'*`resid') if `touse', by(`cluster')
			
			local list_weps `list_weps' `eps_w`j''
			drop `clusterweight' `smartweight' `smartdenom' `avgtau'
			local ++j
		}
		if (`debugging') noi di "11c"
		tempname V
		if (`debugging') noi di "11d `list_weps' | `list_pre_weps' | `list_ctrl_weps'"
		matrix accum `V' = `list_weps' `list_pre_weps' `list_ctrl_weps' if `tag_clus', nocon
		if (`debugging') noi di "11e `wtrnames' | `prenames' | `controls'"
		matrix rownames `V' = `wtrnames' `prenames' `controls'
		matrix colnames `V' = `wtrnames' `prenames' `controls'
		if ("`saveweights'"=="" & "`loadweights'"=="") drop __w_*
	}
	
	// Part 8: report everything 
	if (`debugging') noi di "#12"
	matrix colnames `b' = `wtrnames' `prenames' `controls'
	matrix colnames `Nt' = `wtrnames'
	ereturn post `b' `V', esample(`touse') depname(`Y') obs(`Nall')
	ereturn matrix Nt = `Nt'
	ereturn scalar Nc = `Nc'
	ereturn local depvar `Y'
	ereturn local cmd did_imputation
	ereturn local droplist `droplist'
	ereturn local autosample_drop `autosample_drop'
	ereturn local autosample_trim `autosample_trim'
	if ("`Niter'"!="") ereturn scalar Niter = `Niter'
	if (`pretrends'>0 & "`se'"!="nose") {
		test `prenames', df(`pre_df')
		ereturn scalar pre_F = r(F)
		ereturn scalar pre_p = r(p)
		ereturn scalar pre_df = `pre_df'
	}
}

local level = 100*(1-`alpha')
_coef_table_header
ereturn display, level(`level')

end

// Additional program that computes the weights corresponding to the imputation estimator and saves them in a variable
cap program drop imputation_weights
program define imputation_weights, rclass sortpreserve
syntax varlist(min=3 max=3), touse(varname) wtr(varlist) SAVEWeights(namelist) wei(varname) ///
	[tol(real 0.000001) maxit(integer 1000) fe(string) Controls(varlist) UNITControls(varlist) TIMEControls(varlist) verbose]
	// Weights of the imputation procedure given wtr for controls = - X0 * (X0'X0)^-1 * X1' * wtr but we get them via iterative procedure
	// k<0 | k==. is control
	// Observation weights are in wei; wtr should be specified BEFORE applying the wei, and the output is before applying them too, i.e. estimator = sum(wei*saveweights*Y)
qui {	
	// Part 1: Initialize
	local debugging = ("`verbose'"=="verbose")
	if (`debugging') noi di "#IW1"
	tokenize `varlist'
	local i `1'
	local t `2'
	local D `3'
	
	local wcount : word count `wtr'
	local savecount : word count `saveweights'
	assert `wcount'==`savecount'
	forvalues j = 1/`wcount' {
		local wtr_j : word `j' of `wtr'
		local saveweights_j : word `j' of `saveweights'
		gen `saveweights_j' = `wtr_j'
		replace `saveweights_j' = 0 if mi(`saveweights_j') & `touse'
		tempvar copy`saveweights_j'
		gen `copy`saveweights_j'' = `saveweights_j'
	}
	
	local fecount = 0
	foreach fecurrent of local fe {
		local ++fecount
		local fe`fecount' = subinstr("`fecurrent'","#"," ",.)
	}
	
	if (`debugging') noi di "#IW2"
	
	// Part 2: Demean & construct denom for weight updating
	if ("`unitcontrols'"!="") {
	    tempvar N0i
		egen `N0i' = sum(`wei') if (`touse') & `D'==0, by(`i')
	}
	if ("`timecontrols'"!="") {
		tempvar N0t
		egen `N0t' = sum(`wei') if (`touse') & `D'==0, by(`t')
	}
	forvalues feindex = 1/`fecount' {
	    tempvar N0fe`feindex'
		egen `N0fe`feindex'' = sum(`wei') if (`touse') & `D'==0, by(`fe`feindex'')
	}

	foreach v of local controls {
		tempvar dm_`v' c`v'
		sum `v' [aw=`wei'] if `D'==0 & `touse' // demean such that the mean is zero in the control sample
		gen `dm_`v'' = `v'-r(mean) if `touse'
		egen `c`v'' = sum(`wei' * `dm_`v''^2) if `D'==0 & `touse' 
	}
	
	foreach v of local unitcontrols {
		tempvar u`v' dm_u`v' s_u`v'
		egen `s_u`v'' = pc(`wei') if `D'==0 & `touse', by(`i') prop
		egen `dm_u`v'' = sum(`s_u`v'' * `v') if `touse', by(`i') // this automatically includes it in `D'==1 as well
		replace `dm_u`v'' = `v' - `dm_u`v'' if `touse'
		egen `u`v'' = sum(`wei' * `dm_u`v''^2) if `D'==0 & `touse', by(`i')
		drop `s_u`v''
	}
	foreach v of local timecontrols { 
		tempvar t`v' dm_t`v' s_t`v'
		egen `s_t`v'' = pc(`wei') if `D'==0 & `touse', by(`t') prop
		egen `dm_t`v'' = sum(`s_t`v'' * `v') if `touse', by(`t') // this automatically includes it in `D'==1 as well
		replace `dm_t`v'' = `v' - `dm_t`v'' if `touse'
		egen `t`v'' = sum(`wei' * `dm_t`v''^2) if `D'==0 & `touse', by(`t')
		drop `s_t`v''
	}
	if (`debugging') noi di "#IW3"

	// Part 3: Iterate
	local it = 0
	local keepiterating `saveweights'
	tempvar delta
	gen `delta' = 0
	while (`it'<`maxit' & "`keepiterating'"!="") {
		if (`debugging') noi di "#IW it `it': `keepiterating'"
		// Simple controls 
		foreach v of local controls {
			update_weights `dm_`v'' , w(`keepiterating') wei(`wei') d(`D') touse(`touse') denom(`c`v'') 
		}
		
		// Unit-interacted continuous controls 
		foreach v of local unitcontrols {
			update_weights `dm_u`v'' , w(`keepiterating') wei(`wei') d(`D') touse(`touse') denom(`u`v'') by(`i')
		}
		if ("`unitcontrols'"!="") update_weights , w(`keepiterating') wei(`wei') d(`D') touse(`touse') denom(`N0i') by(`i') // could speed up a bit by skipping this if we have i#something later
		
		// Time-interacted continuous controls
		foreach v of local timecontrols {
			update_weights `dm_t`v'' , w(`keepiterating') wei(`wei') d(`D') touse(`touse') denom(`t`v'') by(`t')
		}
		if ("`timecontrols'"!="") update_weights , w(`keepiterating') wei(`wei') d(`D') touse(`touse') denom(`N0t') by(`t') // could speed up a bit by skipping this if we have t#something later

		// FEs
		forvalues feindex = 1/`fecount' {
		    update_weights , w(`keepiterating') wei(`wei') d(`D') touse(`touse') denom(`N0fe`feindex'') by(`fe`feindex'')
		}
		
		// Check for which coefs the weights have changed, keep iterating for them
		local newkeepit
		foreach w of local keepiterating {
			replace `delta' = abs(`w'-`copy`w'')
			sum `delta' if `D'==0 & `touse'
			if (`debugging') noi di "#IW it `it' `w' " r(sum)
			if (r(sum)>`tol') local newkeepit `newkeepit' `w'
			replace `copy`w'' = `w'
		}
		local keepiterating `newkeepit'
		local ++it
	}
	if ("`keepiterating'"!="") {
	    noi di as error "Convergence of standard errors is not achieved for coefs: `keepiterating'."
		noi di as error "Try increasing the tolerance, the number of iterations, or use the nose option for the point estimates without SE."
	    error 430
	}
	return scalar iter = `it'
}
end

cap program drop update_weights // warning: intentionally destroys sorting
program define update_weights, rclass
	syntax [varname(default=none)] , w(varlist) wei(varname) d(varname) touse(varname) denom(varname) [by(varlist)]
	// varlist = variable on which to residualize (if empty, a constant is assumed, as for any FE) [for now only one is max!]
	// w = variable storing the weights to be updated
	// wei = observation weights
	// touse = variable defining sample
	// denom = variable storing sum(`wei'*`varlist'^2) if `d'==0, by(`by')
qui {	
	tempvar sumw
	tokenize `varlist'
	if ("`1'"=="") local 1 = "1"
	if ("`by'"!="") sort `by'
	foreach w_j of local w {
		noi di "#UW 5 `w_j': `1' by(`by') "
		egen `sumw' = total(`wei' * `w_j' * `1') if `touse', by(`by')
		replace `w_j' = `w_j'-`sumw'*`1'/`denom' if `d'==0 & `denom'!=0 & `touse'
		assert !mi(`w_j') if `touse'
		drop `sumw'
	}
}
end

// When there is a variable that only varies by `from' but is missing for some observations, fill in its missing values wherever possible
cap program drop recover 
program define recover, sortpreserve
	syntax varlist, from(varlist)
	foreach var of local varlist {
		gsort `from' -`var'
		by `from' : replace `var' = `var'[1] if mi(`var')
	}
end

