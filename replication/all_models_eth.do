* Project: lsms risk ag
* Created on: 2 Apr 2025
* Created by: jdm
* Edited on: 3 Apr 2025
* Edited by: jdm
* Stata v.18

* does
	* creates coef plots for all Ethiopia results
		* models 1-3
		* two rainfall variables in production
		* three rainfall shock variables
		* all six weather products

* assumes
	* cleaned, merged (weather), and appended (waves) data

	
********************************************************************************
**# 0 - setup
********************************************************************************

	global root   	"$data/lsms_risk_ag_data/regression_data/ethiopia"
	global export 	"$data/lsms_risk_ag_data/results"
	global figures 	"$data/lsms_risk_ag_data/results/figures"
	global tables 	"$data/lsms_risk_ag_data/results/tables"
	global logout 	"$data/lsms_risk_ag_data/regression_data/logs"

	cap 	log 	close
	log 	using 	"$logout/model_comparisons_eth", replace


********************************************************************************
**# 1 - variable creation
********************************************************************************

	use 		"$root/eth_complete", clear
	
	xtset 		hh_id_obs
	
	egen 		std_y = std(harvest_value_USD / plot_area_GPS)
	drop if 	std_y > 20
	drop 		std_y
	egen 		std_y = std(harvest_value_USD / plot_area_GPS)

	egen 		std_f = std(fert_kg / plot_area_GPS)
	egen 		std_s = std(isp)
	gen 		std_f2 = std_f^2
	gen 		std_s2 = std_s^2
	gen 		std_fs = std_f * std_s

	local rain 	v01_rf1 v05_rf1 v01_rf2 v05_rf2 v01_rf3 v05_rf3 v01_rf4 v05_rf4 ///
					v01_rf5 v05_rf5 v01_rf6 v05_rf6

	local lag  	v01_rf1_t1 v05_rf1_t1 v01_rf2_t1 v05_rf2_t1 v01_rf3_t1 v05_rf3_t1 ///
					v01_rf4_t1 v05_rf4_t1 v01_rf5_t1 v05_rf5_t1 v01_rf6_t1 v05_rf6_t1

	local shck1 v07_rf1_t1 v09_rf1_t1 v14_rf1_t1 v07_rf2_t1 v09_rf2_t1 v14_rf2_t1 ///
					v07_rf3_t1 v09_rf3_t1 v14_rf3_t1 v07_rf4_t1 v09_rf4_t1 v14_rf4_t1 ///
					v07_rf5_t1 v09_rf5_t1 v14_rf5_t1 v07_rf6_t1 v09_rf6_t1 v14_rf6_t1 
	
	local shck2 v07_rf1_t2 v09_rf1_t2 v14_rf1_t2 v07_rf2_t2 v09_rf2_t2 v14_rf2_t2 ///
					v07_rf3_t2 v09_rf3_t2 v14_rf3_t2 v07_rf4_t2 v09_rf4_t2 v14_rf4_t2 ///
					v07_rf5_t2 v09_rf5_t2 v14_rf5_t2 v07_rf6_t2 v09_rf6_t2 v14_rf6_t2 
	
	local shck3 v07_rf1_t3 v09_rf1_t3 v14_rf1_t3 v07_rf2_t3 v09_rf2_t3 v14_rf2_t3 ///
					v07_rf3_t3 v09_rf3_t3 v14_rf3_t3 v07_rf4_t3 v09_rf4_t3 v14_rf4_t3 ///
					v07_rf5_t3 v09_rf5_t3 v14_rf5_t3 v07_rf6_t3 v09_rf6_t3 v14_rf6_t3 
					
					
********************************************************************************
**# 2 - regressions using v09 only across rainfall metrics and weather sources
********************************************************************************

* save results in temp file
	tempname 	eth_results
	postfile 	`eth_results' str3 country str3 sat str3 rain str3 shock str4 model ///
					beta_ap se_ap beta_ds se_ds adjustedr loglike dfr ///
					using "$export/eth_results.dta", replace

	

* start rain loop
	foreach v in `rain' {
		
	* start rain IV loop
		foreach t in `lag' {
			if substr("`v'", 2, 2) == substr("`t'", 2, 2) & substr("`v'", 7, 1) == substr("`t'", 7, 1) {


********************************************************************************
**## 2.1 - production function
********************************************************************************

            xtivreg std_y hh_size `v' i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)
			
			predict std_e1 if e(sample), e
			
			gen			std_e2 = std_e1^2
			gen			std_e3 = std_e1^3
			
			sum			std_e1 std_e2 std_e3
			
            matrix 		a = e(b)
            scalar 		b1_f = a[1,1]
            scalar 		b1_f2 = a[1,2]
            scalar 		b1_s = a[1,3]
            scalar 		b1_s2 = a[1,4]
            scalar 		b1_fs = a[1,5]
            gen 		mu1_s = b1_s + 2*b1_s2 * std_s + b1_fs * std_f
            gen 		mu1_f = b1_f + 2*b1_f2 * std_f + b1_fs * std_s

            xtivreg std_e2 hh_size `v' i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)
				
            matrix 		a2 = e(b)
            scalar 		b2_f = a2[1,1]
            scalar 		b2_f2 = a2[1,2]
            scalar 		b2_s = a2[1,3]
            scalar 		b2_s2 = a2[1,4]
            scalar 		b2_fs = a2[1,5]
            gen 		mu2_s = b2_s + 2*b2_s2 * std_s + b2_fs * std_f
            gen 		mu2_f = b2_f + 2*b2_f2 * std_f + b2_fs * std_s

            xtivreg std_e3 hh_size `v' i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)
				
            matrix 		a3 = e(b)
            scalar 		b3_f = a3[1,1]
            scalar 		b3_f2 = a3[1,2]
            scalar 		b3_s = a3[1,3]
            scalar 		b3_s2 = a3[1,4]
            scalar 		b3_fs = a3[1,5]
            gen 		mu3_s = b3_s + 2*b3_s2 * std_s + b3_fs * std_f
            gen 		mu3_f = b3_f + 2*b3_f2 * std_f + b3_fs * std_s

********************************************************************************
**## 2.2 - arrow-pratt and downside risk estimates
********************************************************************************

		* define some locals to save satellite and variable info
			local sat = substr("`v'", 5, 3)
			local varn = substr("`v'", 1, 3)
	
        * Constraint definitions
            constraint drop 1/20
            constraint 1 		[mu1_s]mu2_s = [mu1_f]mu2_f
            constraint 2 		[mu1_s]mu3_s = [mu1_f]mu3_f

         * Model 1
            eststo clear
            bootstrap, reps(10) seed(2045): ///
            reg3 (mu1_s mu2_s mu3_s) (mu1_f mu2_f mu3_f), ///
            constraint(1 2) nolog
				post		`eth_results' ("eth") ("`sat'") ("`varn'") ("") ///
								("mod1") (`=[mu1_s]_b[mu2_s]') (`=[mu1_s]_se[mu2_s]') ///
								(`=[mu1_s]_b[mu3_s]') (`=[mu1_s]_se[mu3_s]') ///
								(`=e(r2_1)') (`=e(ll)') (`=e(dfk2_adj)')

		* start loop for t1 shock variables
			foreach s1 in `shck1' {
				if substr("`v'", 7, 1) == substr("`s1'", 7, 1) {
			
				local shck = substr("`s1'", 1, 3)
				
            * Model 2
				gen 		mod_mu2_s = `s1' * mu2_s
				gen 		mod_mu3_s = `s1' * mu3_s
				gen 		mod_mu2_f = `s1' * mu2_f
				gen 		mod_mu3_f = `s1' * mu3_f

            * Constraint definitions
				constraint drop 1/20
				constraint 1 		[mu1_s]mu2_s = [mu1_f]mu2_f
				constraint 2 		[mu1_s]mu3_s = [mu1_f]mu3_f
				constraint 3 		[mu1_s]mod_mu2_s = [mu1_f]mod_mu2_f
				constraint 4 		[mu1_s]mod_mu3_s = [mu1_f]mod_mu3_f
				constraint 5 		[mu1_s]`s1' = [mu1_f]`s1'

				bootstrap, reps(10) seed(2045): ///
				reg3 (mu1_s mu2_s mu3_s `s1' mod_mu2_s mod_mu3_s) ///
					(mu1_f mu2_f mu3_f `s1' mod_mu2_f mod_mu3_f), ///
				constraint(1 2 3 4 5) nolog
					post		`eth_results' ("eth") ("`sat'") ("`varn'") ("`shck'") ///
									("mod2") (`=[mu1_s]_b[mu2_s]') (`=[mu1_s]_se[mu2_s]') ///
									(`=[mu1_s]_b[mu3_s]') (`=[mu1_s]_se[mu3_s]') ///
									(`=e(r2_1)') (`=e(ll)') (`=e(dfk2_adj)')
			
			*start loop for t2 shock variable
				foreach s2 in `shck2' {
		
				* start loop for t3 shock variable
					foreach s3 in `shck3' {
						if substr("`s1'", 2, 2) == substr("`s2'", 2, 2) & substr("`s1'", 7, 1) == substr("`s2'", 7, 1) ///
						& substr("`s1'", 2, 2) == substr("`s3'", 2, 2) & substr("`s1'", 7, 1) == substr("`s3'", 7, 1) {
			
					* Model 3
					gen 		mod_mu2_s2 = `s2' * mu2_s
					gen 		mod_mu3_s2 = `s2' * mu3_s
					gen 		mod_mu2_f2 = `s2' * mu2_f
					gen 		mod_mu3_f2 = `s2' * mu3_f
			
					gen 		mod_mu2_s3 = `s3' * mu2_s
					gen 		mod_mu3_s3 = `s3' * mu3_s
					gen 		mod_mu2_f3 = `s3' * mu2_f
					gen 		mod_mu3_f3 = `s3' * mu3_f

					* Constraint definitions
					constraint 6 		[mu1_s]mod_mu2_s2 = [mu1_f]mod_mu2_f2
					constraint 7 		[mu1_s]mod_mu3_s2 = [mu1_f]mod_mu3_f2
					constraint 8 		[mu1_s]mod_mu2_s3 = [mu1_f]mod_mu2_f3
					constraint 9 		[mu1_s]mod_mu3_s3 = [mu1_f]mod_mu3_f3
					constraint 10 		[mu1_s]`s2' = [mu1_f]`s2'
					constraint 11 		[mu1_s]`s3' = [mu1_f]`s3'
			
					bootstrap, reps(10) seed(2045): ///
					reg3 (mu1_s mu2_s mu3_s `s1' mod_mu2_s mod_mu3_s ///
							`s2' mod_mu2_s2 mod_mu3_s2 `s3' mod_mu2_s3 mod_mu3_s3) ///
						(mu1_f mu2_f mu3_f `s1' mod_mu2_f mod_mu3_f ///
							`s2' mod_mu2_f2 mod_mu3_f2 `s3' mod_mu2_f3 mod_mu3_f3), ///
						constraint(1 2 3 4 5 6 7 8 9 10 11) nolog
						post		`eth_results' ("eth") ("`sat'") ("`varn'") ("`shck'") ///
										("mod3") (`=[mu1_s]_b[mu2_s]') (`=[mu1_s]_se[mu2_s]') ///
										(`=[mu1_s]_b[mu3_s]') (`=[mu1_s]_se[mu3_s]') ///
										(`=e(r2_1)') (`=e(ll)') (`=e(dfk2_adj)')
			
					drop mod_mu*
						}
					}
				}
			}
		}
			
        drop mu1_s mu1_f mu2_s mu2_f mu3_s mu3_f std_e*
        }
    }
}



********************************************************************************
**# 3 - process results
********************************************************************************

* close the post file and open the data file
	postclose	`eth_results' 
	use 		 "$export/eth_results.dta", clear
	
* create country type variable
	drop		country
	gen			country = 5
	lab def		country 1 "Ethiopia" 2 "Malawi" 3 "Mali" ///
					4 "Niger" 5 "Nigeria" 6 "Tanzania" ///
					7 "Uganda"
	lab val		country country
	lab var		country "Country"
	
* create variables for statistical testing
	gen 		tstat_ap = beta_ap/se_ap
	lab var		tstat_ap "AP t-statistic"
	gen 		pval_ap = 2*ttail(dfr,abs(tstat_ap))
	lab var		pval_ap "AP p-value"	
	gen 		ci_lo_ap =  beta_ap - invttail(dfr,0.025)*se_ap
	lab var		ci_lo_ap "AP Lower confidence interval"
	gen 		ci_up_ap =  beta_ap + invttail(dfr,0.025)*se_ap
	lab var		ci_up_ap "AP Upper confidence interval"
	
	gen 		tstat_ds = beta_ds/se_ds
	lab var		tstat_ds "DS t-statistic"
	gen 		pval_ds = 2*ttail(dfr,abs(tstat_ds))
	lab var		pval_ds "DS p-value"
	gen 		ci_lo_ds =  beta_ds - invttail(dfr,0.025)*se_ds
	lab var		ci_lo_ds "DS Lower confidence interval"
	gen 		ci_up_ds =  beta_ds + invttail(dfr,0.025)*se_ds
	lab var		ci_up_ds "DS Upper confidence interval"

* label variables
	lab var		beta_ap "AP Coefficient"
	lab var		se_ap "AP Standard error"
	lab var		beta_ds "DS Coefficient"
	lab var		se_ds "DS Standard error"
	lab var		adjustedr "Adjusted R^2"
	lab var		loglike "Log likelihood"
	lab var		dfr "Degrees of freedom"

* create unique id variable
	gen 		reg_id = _n
	lab var 	reg_id "unique regression id"
	
	order		reg_id country
	
* create variable to record the name of the rainfall variable
	sort		rain
	gen 		aux_var = 1 if rain == "v01"
	replace 	aux_var = 2 if rain == "v05"

* order and label the varaiable
	order 		aux_var, after(rain)
	lab def		rain 	1 "Mean Daily Rainfall" ///
						2 "Total Rainfall"
							
	lab val		aux_var rain
	lab var		aux_var "Main rainfall variable"
	drop 		rain
	rename 		aux_var rain

* create variable to record the name of the shock variable
	sort		shock
	gen 		aux_var = 1 if shock == ""
	replace 		aux_var = 2 if shock == "v07"
	replace 	aux_var = 3 if shock == "v09"
	replace 	aux_var = 4 if shock == "v14"

* order and label the varaiable
	order 		aux_var, after(shock)
	lab def		shock 	1 "None" ///
						2 "Z-Score of Total Rainfall" ///
						3 "Deviation in Rainy Days" ///
						4 "Longest Dry Spell"
						
	lab val		aux_var shock
	lab var		aux_var "Rainfall shock variable"
	drop 		shock
	rename 		aux_var shock
	
* create variable to record the name of the satellite
	sort 		sat
	gen 		aux_sat = 1 if sat == "rf1"
	replace		aux_sat = 2 if sat == "rf2"
	replace		aux_sat = 3 if sat == "rf3"
	replace		aux_sat = 4 if sat == "rf4"
	replace		aux_sat = 5 if sat == "rf5"
	replace		aux_sat = 6 if sat == "rf6"

* order and label the varaiable
	order 		aux_sat, after(sat)
	lab def		sat 	1 "ARC2" ///
						2 "CHIRPS" ///
						3 "CPC" ///
						4 "ERA5" ///
						5 "MERRA-2" ///
						6 "TAMSAT"
						
	lab val		aux_sat sat	
	lab var		aux_sat "Satellite source"
	drop 		sat
	rename 		aux_sat sat

* create variable to record the regressions specification
	sort 		model
	gen 		aux_reg = 1 if model == "mod1"
	replace 	aux_reg = 2 if model == "mod2"
	replace 	aux_reg = 3 if model == "mod3"

* order and label the varaiable
	order 		aux_reg, after(model)
	lab def		regname 	1 "Model 1" ///
							2 "Model 2" ///
							3 "Model 3" 
							
	lab val		aux_reg regname
	lab var		aux_reg "Model"
	drop 		model
	rename 		aux_reg model

*generate different betas based on signficance
	gen 			sig_ap = beta_ap
	replace 		sig_ap = . if pval_ap > .05
	lab var 		sig_ap "p < 0.05"
	
	gen 			ns_ap = beta_ap
	replace 		ns_ap = . if pval_ap <= .05
	replace 		ns_ap = . if pval_ap == .
	lab var 		ns_ap "n.s."
	
	gen 			sig_ds = beta_ds
	replace 		sig_ds = . if pval_ds > .05
	lab var 		sig_ds "p < 0.05"
	
	gen 			ns_ds = beta_ds
	replace 		ns_ds = . if pval_ds <= .05
	replace 		ns_ds = . if pval_ds == .
	lab var 		ns_ds "n.s."
	
********************************************************************************
**# 4 - results visualization
********************************************************************************

********************************************************************************
**# 4.1 - AP visualization
********************************************************************************

preserve

* stack values of the specification indicators
	sort 			beta_ap
	gen 			obs = _n
	
	gen 			k1 		= 	model
	gen 			k2 		= 	rain + 5
	gen 			k3 		= 	shock + 9
	gen 			k4 		= 	sat + 15
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab				var k1 "Model"
	lab 			var k2 "Rainfall (Production)"
	lab 			var k3 "Rainfall (Shock)"
	lab 			var k4 "Remote Sensing Product"

	qui sum			ci_up_ap
	global			bmax = r(max)
	
	qui sum			ci_lo_ap
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 4*$brange
	global			gheight	=	30


	twoway 			scatter k1 k2 k3 k4 obs, xlab(0(8)84) xsize(10) ysize(6) ///
						xtitle("Specification # - sorted by effect size") ///
						ytitle("Arrow-Pratt (AP)", axis(2) yoffset(24)) ///
						ylab(0(1)$gheight ) msize(small small small small) mcolor(gs10 gs10 gs10 gs10)	///
						ylabel( 1 "Model 1" 2 "Model 2" 3 "Model 3" 4 "*{bf:Model}*" ///					
						6 "Mean Daily" 7 "Total Seasonal" 8 "*{bf:Rainfall (Production)}*" ///
						10 "None" 11 "Z-Score of Total Seasonal" 12 "Deviation in Rainy Days" ///
						13 " Longest Dry Spell" 14 "*{bf:Rainfall (Shock)}*" 16 "ARC2" ///
						17 "CHIRPS" 18 "CPC" 19 "ERA5" 20 "MERRA-2" 21 "TAMSAT" /// 
						22 "*{bf:Weather Product}*" 30 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) || ///
						(scatter ns_ap obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						msize (tiny) ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter sig_ap obs if beta_ap > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						msize (tiny) ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter sig_ap obs if beta_ap < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						msize (tiny) ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo_ap ci_up_ap obs if sig_ap == ., ///
						msize(tiny) barwidth(.2) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo_ap ci_up_ap obs if sig_ap != . & beta_ap < 0, ///
						msize(tiny) barwidth(.2) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo_ap ci_up_ap obs if sig_ap != . & beta_ap > 0, ///
						msize(tiny) barwidth(.2) color(edkblue%50) yaxis(2)  ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid) ) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(12) ring(1))
	
* graph save
	graph export 	"$figures/eth_ap_coef.png", replace as(png)	
	graph export 	"$figures/eth_ap_coef.eps", replace as(eps)		
	
restore	

********************************************************************************
**# 4.1 - DS visualization
********************************************************************************

preserve

* stack values of the specification indicators
	sort 			beta_ds
	gen 			obs = _n
	
	gen 			k1 		= 	model
	gen 			k2 		= 	rain + 5
	gen 			k3 		= 	shock + 9
	gen 			k4 		= 	sat + 15
	
* label new variables	
	lab				var obs "Specification # - sorted by effect size"

	lab				var k1 "Model"
	lab 			var k2 "Rainfall (Production)"
	lab 			var k3 "Rainfall (Shock)"
	lab 			var k4 "Remote Sensing Product"

	qui sum			ci_up_ds
	global			bmax = r(max)
	
	qui sum			ci_lo_ds
	global			bmin = r(min)
	
	global			brange	=	$bmax - $bmin
	global			from_y	=	$bmin - 4*$brange
	global			gheight	=	30


	twoway 			scatter k1 k2 k3 k4 obs, xlab(0(8)84) xsize(10) ysize(6) ///
						xtitle("Specification # - sorted by effect size") ///
						ytitle("Downside Risk (DS)", axis(2) yoffset(24)) ///
						ylab(0(1)$gheight ) msize(small small small small) mcolor(gs10 gs10 gs10 gs10)	///
						ylabel( 1 "Model 1" 2 "Model 2" 3 "Model 3" 4 "*{bf:Model}*" ///					
						6 "Mean Daily" 7 "Total Seasonal" 8 "*{bf:Rainfall (Production)}*" ///
						10 "None" 11 "Z-Score of Total Seasonal" 12 "Deviation in Rainy Days" ///
						13 " Longest Dry Spell" 14 "*{bf:Rainfall (Shock)}*" 16 "ARC2" ///
						17 "CHIRPS" 18 "CPC" 19 "ERA5" 20 "MERRA-2" 21 "TAMSAT" /// 
						22 "*{bf:Weather Product}*" 30 " ", ///
						angle(0) labsize(vsmall) tstyle(notick)) || ///
						(scatter ns_ds obs, yaxis(2) mcolor(black%75) msymbol(Th) ///
						msize (tiny) ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter sig_ds obs if beta_ds > 0, yaxis(2) mcolor(edkblue%75) msymbol(+) ///
						msize (tiny) ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(scatter sig_ds obs if beta_ds < 0, yaxis(2) mcolor(maroon%75) msymbol(+) ///
						msize (tiny) ylab(,axis(2) labsize(vsmall) angle(0) ) yscale( ///
						range($from_y $bmax ) axis(2)) ) || ///
						(rbar ci_lo_ds ci_up_ds obs if sig_ds == ., ///
						msize(tiny) barwidth(.2) color(black%50) yaxis(2) ) || ///
						(rbar ci_lo_ds ci_up_ds obs if sig_ds != . & beta_ds < 0, ///
						msize(tiny) barwidth(.2) color(maroon%50) yaxis(2) ) || ///
						(rbar ci_lo_ds ci_up_ds obs if sig_ds != . & beta_ds > 0, ///
						msize(tiny) barwidth(.2) color(edkblue%50) yaxis(2)  ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid) ) ), ///
						legend(order(7 5 6) cols(3) size(small) rowgap(.5) pos(12) ring(1))
	
* grdsh save
	graph export 	"$figures/eth_ds_coef.png", replace as(png)	
	graph export 	"$figures/eth_ds_coef.eps", replace as(eps)		
	
restore		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
log close
