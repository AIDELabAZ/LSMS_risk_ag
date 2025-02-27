* Project: lsms risk ag
* Created on: feb 2025
* Created by: reece
* Edited on: 27 Feb 2025
* Edited by: jdm
* Stata v.18

* does
	* loads multi country data set
	* outputs results file for analysis

* assumes
	* cleaned, merged (weather), and appended (waves) data

* TO DO:
	*

	
********************************************************************************
**#0 - setup
********************************************************************************

* define paths

	global root 	"$data/lsms_risk_ag_data/regression_data/ethiopia"
	global export 	"$data/lsms_risk_ag_data/results"
	global logout 	"$data/lsms_risk_ag_data/regression_data/logs"

* open log 
	cap 	log 	close 
	log 	using 	"$logout/regressions", append

 	
********************************************************************************
**# 1 - load data
********************************************************************************
 
 	use 		"$root/eth_complete", clear
	
* ******************************************************************************
**# 2 - create variables we need for regression
* ******************************************************************************	

* drop missing plot area
	drop if 	plot_area_GPS == 0

* create log of yield, fert rate, seed rate, fert * seed
	egen 		std_y = std(harvest_kg2/plot_area_GPS)
	egen		std_f = std(nitrogen_kg2/plot_area_GPS)
	egen		std_s = std(isp)
	gen			std_f2 = std_f^2
	gen			std_s2 = std_s^2
	gen			std_fs = std_f*std_s
	
	
********************************************************************************
**# 3 - calculating ap and ds parameters
********************************************************************************

* set panel indicator
	xtset hh_id_obs
	
	
********************************************************************************
**## 3.1 - create loop for production regressions
********************************************************************************

* loop through rainfall in time t
	local			rain	v01_rf1 v05_rf1
	foreach v in `rain' {
		
	* loop through rainfall in time t-1
		local			lag	v01_rf1_t1 v05_rf1_t1
		foreach t in `lag' {
			
		* compare two rainfall variables and only use one from same source	
			if substr("`v'", 2, 2) == substr("`t'", 2, 2) {
				
			* production function with IV
				xtivreg 		std_y hh_size `v' i.year ///
									(std_f std_f2 std_s std_s2 std_fs = ///
									hh_electricity_access dist_popcenter ///
									extension dist_weekly `t'), ///
									fe vce(cluster hh_id_obs) 

****First Moment****************************************************************

			* generate fitted values (u1)			
				capture 		drop u1							
				predict 		u1, xb
	
			* store estimated coefficients from last reg into matrix 'a'
				capture 		matrix drop a
				matrix 			a = e(b)
	
			* extract the fertilizer coefficients from matrix 'a'
			* and store them as 'u1_f' and 'u1_f2'
				scalar 			u1_f = a[1,1]
				scalar 			u1_f2 = a[1,2]
	
			* extract the seed coefficients from matrix 'a'
			* and store them as 'u1_s' and 'u1_s2'
				scalar 			u1_s = a[1,3]
				scalar 			u1_s2 = a[1,4]
	
			* extract the interaction coefficients from matrix 'a'
			* and store it as 'u1_fs'
				scalar 			u1_fs = a[1,5]
	
			* computing marginal effect of seed and fertilizer
				capture 		drop mu1_s mu1_f
				gen 			mu1_s = u1_s + 2*u1_s2 * std_s + u1_fs * std_f
				gen 			mu1_f = u1_f + 2*u1_f2 * std_f + u1_fs * std_s
	
	
****Second Moment **************************************************************

			* generate residuals from the last regression
				capture 		drop resid1
				predict 		resid1, e 
	
			* generate squared residuals
				capture 		drop resid2
				gen 			resid2 = asinh(resid1^2)
	
			* regress on squared residuals
				xtreg 			resid2 std_f std_f2 std_s std_s2 std_fs /// 
									hh_size `v' i.year, fe ///
									vce(cluster hh_id_obs)
					
			* generate fitted values (u2)	
				capture 		drop u2 
				predict 		u2
	
			* store estimated coefficients from last reg into matrix 'a2'
				capture 		matrix drop a2
				matrix 			a2 = e(b)
	
			* extract the fertilizer coefficients from matrix 'a2'
			* (variance effect of fertilizer use)
				scalar 			u2_f = a2[1,1]
				scalar 			u2_f2 = a2[1,2]
	
			* extract the seed coefficients from matrix 'a2'
			* (variance effect of seed use)
				scalar 			u2_s = a2[1,3]
				scalar 			u2_s2 = a2[1,4]
	
			* extract the interaction coefficients from matrix 'a2'
			* (variance effect of the seed and fertilizer interaction)
				scalar 			u2_fs = a2[1,5]
	
			* computing variance effect of seed and fertilizer
				capture 		drop mu2_s mu2_f
				gen 			mu2_s = u2_s + 2*u2_s2 * std_s + u2_fs * std_f
				gen 			mu2_f = u2_f + 2*u2_f2 * std_f + u2_fs * std_s


****Third Moment ***************************************************************

			* generate cubed residuals
				capture 		drop resid3
				gen 			resid3 = asinh(resid1^3)
	
			* regress on cubed residuals
				xtreg 			resid3 std_f std_f2 std_s std_s2 std_fs /// 
									hh_size `v' i.year, fe ///
									vce(cluster hh_id_obs)

			* generate fitted values (u3)	
				capture 		drop u3
				predict 		u3
	
			* store estimated coefficients from last reg into matrix 'a3'
				capture 		matrix drop a3
				matrix 			a3 = e(b)
	
			* extract the fertilizer coefficients from matrix 'a2'
			* (skew effect of fertilizer use)
				scalar 			u3_f = a3[1,1]
				scalar 			u3_f2 = a3[1,2]
	
			* extract the seed coefficients from matrix 'a2'
			* (skew effect of seed use)
				scalar 			u3_s = a3[1,3]
				scalar 			u3_s2 = a3[1,4]
	
			* extract the interaction coefficients from matrix 'a2'
			* (skew effect of the seed and fertilizer interaction)
				scalar 			u3_fs = a3[1,5]
	
			* computing skew effect of seed and fertilizer
				capture 		drop mu3_s mu3_f
				gen 			mu3_s = u3_s + 2*u3_s2 * std_s + u3_fs * std_f
				gen 			mu3_f = u3_f + 2*u3_f2 * std_f + u3_fs * std_s

				
********************************************************************************
**## 3.2 - create loop for risk aversion regressions
********************************************************************************	
			
			* generate loop for shock variables
				local shock v07_rf1_t1 v09_rf1_t1 v11_rf1_t1 v13_rf1_t1 v14_rf1_t1
					foreach s in `shock' {
						
				* create interaction of moment and shock
					gen 			mod_mu2_s = `s' * mu2_s
					gen 			mod_mu3_s = `s' * mu3_s
					gen 			mod_mu2_f = `s' * mu2_f
					gen 			mod_mu3_f = `s' * mu3_f
				
 
				* constraint coefficients of the seed and fert moment to be equal
					constraint 		drop 1 2 3 4 5
					constraint 1 	[mu1_s]mu2_s = [mu1_f]mu2_f
					constraint 2 	[mu1_s]mu3_s = [mu1_f]mu3_f
					constraint 3 	[mu1_s]mod_mu2_s = [mu1_f]mod_mu2_f
					constraint 4 	[mu1_s]mod_mu3_s = [mu1_f]mod_mu3_f
					constraint 5 	[mu1_s]`s' = [mu1_f]`s'

				* Model 1: AP regression with no shock
					bootstrap, 		reps(100) seed(2045): ///
					reg3 			(mu1_s mu2_s mu3_s) ///
									(mu1_f mu2_f mu3_f), ///
									constraint(1 2) nolog

				* Model 2: AP regression with shock
					bootstrap, 		reps(100) seed(2045): ///
					reg3 			(mu1_s mu2_s mu3_s `s' mod_mu2_s mod_mu3_s) ///
									(mu1_f mu2_f mu3_f `s' mod_mu2_f mod_mu3_f), ///
									constraint(1 2 3 4 5) nolog

				* drop variables generated for AP regressions
					drop 			mod_mu2_s mod_mu3_s mod_mu2_f mod_mu3_f
			}	
			* drop variables generated in production regressions
				drop			mu1_s mu1_f mu2_s mu2_f mu3_s mu3_f ///
									u1 u2 u3 resid1 resid2 resid3	
		}
	}
}
