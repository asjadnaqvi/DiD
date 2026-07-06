program csdid_table, rclass 
	syntax [, level(int `c(level)') noci cformat(string) sformat(string) *]
*set trace on
	_get_diopts diopts rest, `options'

	local cf %9.0g  
	local pf %5.3f
	local sf %7.2f

	if ("`cformat'"!="") {
			local cf `cformat'
	}
	if ("`sformat'"!="") {
			local sf `sformat'
	}

        tempname mytab z t  ll ul cimat rtab
        .`mytab' = ._tab.new, col(6) lmargin(0)
        .`mytab'.width    13   |12    12     8         12    12
        .`mytab'.titlefmt  .     .     .   %6s       %24s     .
        .`mytab'.pad       .     2     1     0          3     3
        .`mytab'.numfmt    . %9.0g %9.0g %7.2f    %9.0g %9.0g
        /*if "`e(df_r)'" != "" {
                local stat t
                scalar `z' = invttail(e(df_r),(100-`level')/200)
        }
        else {
                local stat z
                scalar `z' = invnormal((100+`level')/200)
        }*/
		
		local stat t 
		
        local namelist : colname e(b)
        local eqlist : coleq e(b)
        local k : word count `namelist'
		local knew = `k'
		matrix `rtab' = J(9, `k', .)
		matrix `cimat'= e(cband)
		* pvalue
		matrix rownames `rtab' = b se t  ll ul df crit eform
		matrix colnames `rtab' = `namelist'
		forvalues i = 1/`k' {
		    local kxc: word `i' of `eqlist'
			if ("`kxc'"=="wgt") {
				local knew = `knew' -1
			}
			matrix `rtab'[1,`i'] = `cimat'[`i',1]
			matrix `rtab'[2,`i'] = `cimat'[`i',2]
			matrix `rtab'[3,`i'] = `cimat'[`i',3]
			matrix `rtab'[5,`i'] = `cimat'[`i',4]
			matrix `rtab'[6,`i'] = `cimat'[`i',5]
			matrix `rtab'[9,`i'] = 0
		}
        .`mytab'.sep, top
        if `:word count `e(depvar)'' == 1 {
                local depvar "`e(depvar)'"
        }
        .`mytab'.titles "`depvar'"                      /// 1
                        " Coefficient"                  /// 2
                        "Std. err."                     /// 3
                        "`stat'"                        /// 4   "P>|`stat'|"                    /// 5
                        "[`level'% conf. interval]" ""  //  6 7
						
        forvalues i = 1/`knew' {
                local name : word `i' of `namelist'
                local eq   : word `i' of `eqlist'
                if ("`eq'" != "_") {
                        if "`eq'" != "`eq0'" {
                                .`mytab'.sep
                                local eq0 `"`eq'"'
                                .`mytab'.strcolor result  .  .  .  .    .
                                .`mytab'.strfmt    %-12s  .  .  .  .    .
                                .`mytab'.row      "`eq'" "" "" "" ""  ""
                                .`mytab'.strcolor   text  .  .  .  .    .
                                .`mytab'.strfmt     %12s  .  .  .  .    .
                        }
                        local beq "[`eq']"
                }
                else if `i' == 1 {
                        local eq
                        .`mytab'.sep
                }
                scalar `t' = `cimat'[`i',3]
                /*if "`e(df_r)'" != "" {
                        scalar `p' = 2*ttail(e(df_r),abs(`t'))
                }*/
                *scalar `p' = 2*normal(-abs(`t'))
				
				scalar `ll'   = `cimat'[`i',4]
				scalar `ul'   = `cimat'[`i',5]
                .`mytab'.row    "`name'"                ///
                                `beq'_b[`name']         ///
                                `beq'_se[`name']        ///
                                `t'                     /// `p'  ///
                                `ll' `ul'
        }
        .`mytab'.sep, bottom
		return matrix table = `rtab'
end
