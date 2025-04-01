* Project: lsms risk ag
* Created on: feb 2025
* Created by: reece
* Edited on: 31 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* loads ethiopia data set
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
 
 	use 		"$root/eth_complete_p", clear
	
* ******************************************************************************
**# 2 - create variables we need for regression
* ******************************************************************************	

* create log of yield, fert rate, seed rate, fert * seed
	egen 		std_y = std(harvest_value_USD/plot_area_GPS)
	
* summarize variable
	sum			std_y
	*** 3 wild outliers. drop them then redo std_y calc
	
	drop if		std_y > 20
	drop		std_y
	egen 		std_y = std(harvest_value_USD/plot_area_GPS)
	
	gen			std_y2 = std_y^2
	gen			std_y3 = std_y^3
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
	local			rain	v01_rf2 v05_rf2 v01_rf3 v05_rf3 v01_rf4 v05_rf4
	foreach v in `rain' {
		
	* loop through rainfall in time t-1
		local			lag	v01_rf2_t1 v05_rf2_t1 v01_rf3_t1 v05_rf3_t1 v01_rf4_t1 v05_rf4_t1
		foreach t in `lag' {
			
		* compare two rainfall variables and only use one from same source	
			if substr("`v'", 2, 2) == substr("`t'", 2, 2) & ///
			   substr("`v'", 7, 1) == substr("`t'", 7, 1) {
				
			* production function with IV
				xtivreg 		std_y hh_size `v' i.year ///
									(std_f std_f2 std_s std_s2 std_fs = ///
									hh_electricity_access dist_popcenter ///
									extension dist_weekly maize_ea_p `t'), ///
									fe vce(cluster hh_id_obs) 

****First Moment***************************************************************
	
			* store estimated coefficients from last reg into matrix 'a'
				capture 		matrix drop a
				matrix 			a = e(b)
	
			* extract the fertilizer coefficients from matrix 'a'
			* and store them as 'b1_f' and 'b1_f2'
				scalar 			b1_f = a[1,1]
				scalar 			b1_f2 = a[1,2]
	
			* extract the seed coefficients from matrix 'a'
			* and store them as 'b1_s' and 'b1_s2'
				scalar 			b1_s = a[1,3]
				scalar 			b1_s2 = a[1,4]
	
			* extract the interaction coefficients from matrix 'a'
			* and store it as 'b1_fs'
				scalar 			b1_fs = a[1,5]
	
			* computing marginal effect of seed and fertilizer
				capture 		drop mu1_s mu1_f
				gen 			mu1_s = b1_s + 2*b1_s2 * std_s + b1_fs * std_f
				gen 			mu1_f = b1_f + 2*b1_f2 * std_f + b1_fs * std_s
	
	
****Second Moment **************************************************************
	
			* regress on squared yield					
				xtivreg 		std_y2 hh_size `v' i.year ///
									(std_f std_f2 std_s std_s2 std_fs = ///
									hh_electricity_access dist_popcenter ///
									extension dist_weekly `t'), ///
									fe vce(cluster hh_id_obs) 
	
			* store estimated coefficients from last reg into matrix 'a2'
				capture 		matrix drop a2
				matrix 			a2 = e(b)
	
			* extract the fertilizer coefficients from matrix 'a2'
			* (variance effect of fertilizer use)
				scalar 			b2_f = a2[1,1]
				scalar 			b2_f2 = a2[1,2]
	
			* extract the seed coefficients from matrix 'a2'
			* (variance effect of seed use)
				scalar 			b2_s = a2[1,3]
				scalar 			b2_s2 = a2[1,4]
	
			* extract the interaction coefficients from matrix 'a2'
			* (variance effect of the seed and fertilizer interaction)
				scalar 			b2_fs = a2[1,5]
	
			* computing variance effect of seed and fertilizer
				capture 		drop mu2_s mu2_f
				gen 			mu2_s = b2_s + 2*b2_s2 * std_s + b2_fs * std_f
				gen 			mu2_f = b2_f + 2*b2_f2 * std_f + b2_fs * std_s


****Third Moment ***************************************************************

			* regress on cubed yield
				xtivreg 		std_y3 hh_size `v' i.year ///
									(std_f std_f2 std_s std_s2 std_fs = ///
									hh_electricity_access dist_popcenter ///
									extension dist_weekly `t'), ///
									fe vce(cluster hh_id_obs) 
			
	
			* store estimated coefficients from last reg into matrix 'a3'
				capture 		matrix drop a3
				matrix 			a3 = e(b)
	
			* extract the fertilizer coefficients from matrix 'a2'
			* (skew effect of fertilizer use)
				scalar 			b3_f = a3[1,1]
				scalar 			b3_f2 = a3[1,2]
	
			* extract the seed coefficients from matrix 'a2'
			* (skew effect of seed use)
				scalar 			b3_s = a3[1,3]
				scalar 			b3_s2 = a3[1,4]
	
			* extract the interaction coefficients from matrix 'a2'
			* (skew effect of the seed and fertilizer interaction)
				scalar 			b3_fs = a3[1,5]
	
			* computing skew effect of seed and fertilizer
				capture 		drop mu3_s mu3_f
				gen 			mu3_s = b3_s + 2*b3_s2 * std_s + b3_fs * std_f
				gen 			mu3_f = b3_f + 2*b3_f2 * std_f + b3_fs * std_s

				
********************************************************************************
**## 3.2 - create loop for risk aversion regressions
********************************************************************************	
			
			* generate loop for shock variables
				local shock v07_rf2_t1 v09_rf2_t1 v11_rf2_t1 v13_rf2_t1 v14_rf2_t1 ///
							v07_rf3_t1 v09_rf3_t1 v11_rf3_t1 v13_rf3_t1 v14_rf3_t1 ///
							v07_rf4_t1 v09_rf4_t1 v11_rf4_t1 v13_rf4_t1 v14_rf4_t1
					foreach s in `shock' {
						
				* compare two rainfall variables and only use one from same source	
					if substr("`v'", 7, 1) == substr("`s'", 7, 1) {
						
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
			}	
			* drop variables generated in production regressions
				drop			mu1_s mu1_f mu2_s mu2_f mu3_s mu3_f
		}
	}
}

********************************************************************************
**## 4 - create model 3 for repeated shocks 
********************************************************************************

	local rain v01_rf2 v05_rf2 v01_rf3 v05_rf3 v01_rf4 v05_rf4
	local lag  v01_rf2_t1 v05_rf2_t1 v01_rf3_t1 v05_rf3_t1 v01_rf4_t1 v05_rf4_t1

	foreach v in `rain' {
		foreach t in `lag' {
			if substr("`v'", 2, 2) == substr("`t'", 2, 2) & substr("`v'", 7, 1) == substr("`t'", 7, 1) {

            * Generate moment variables (mu1, mu2, mu3)
				xtivreg std_y hh_size `v' i.year ///
					(std_f std_f2 std_s std_s2 std_fs = ///
					hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p `t'), ///
					fe vce(cluster hh_id_obs)
				matrix 		b1 = e(b)
				scalar 		b1_f  = b1[1,1]
				scalar 		b1_f2 = b1[1,2]
				scalar		b1_s  = b1[1,3]
				scalar		b1_s2 = b1[1,4]
				scalar 		b1_fs = b1[1,5]
				gen 		mu1_s = b1_s + 2*b1_s2*std_s + b1_fs*std_f
				gen 		mu1_f = b1_f + 2*b1_f2*std_f + b1_fs*std_s

				xtivreg std_y2 hh_size `v' i.year ///
					(std_f std_f2 std_s std_s2 std_fs = ///
					hh_electricity_access dist_popcenter extension dist_weekly `t'), ///
					fe vce(cluster hh_id_obs)
				matrix 		b2 = e(b)
				scalar 		b2_f  = b2[1,1]
				scalar 		b2_f2 = b2[1,2]
				scalar 		b2_s  = b2[1,3]
				scalar 		b2_s2 = b2[1,4]
				scalar 		b2_fs = b2[1,5]
				gen 		mu2_s = b2_s + 2*b2_s2*std_s + b2_fs*std_f
				gen 		mu2_f = b2_f + 2*b2_f2*std_f + b2_fs*std_s

				xtivreg std_y3 hh_size `v' i.year ///
					(std_f std_f2 std_s std_s2 std_fs = ///
					hh_electricity_access dist_popcenter extension dist_weekly `t'), ///
					fe vce(cluster hh_id_obs)
				matrix 		b3 = e(b)
				scalar 		b3_f  = b3[1,1]
				scalar 		b3_f2 = b3[1,2]
				scalar 		b3_s  = b3[1,3]
				scalar 		b3_s2 = b3[1,4]
				scalar 		b3_fs = b3[1,5]
				gen 		mu3_s = b3_s + 2*b3_s2*std_s + b3_fs*std_f
				gen 		mu3_f = b3_f + 2*b3_f2*std_f + b3_fs*std_s

            * Define lagged shocks for v09 from same source
				local suffix = substr("`v'", 7, 1)
				local 		s1 = v09_rf`suffix'_t1
				local 		s2 = v09_rf`suffix'_t2
				local 		s3 = v09_rf`suffix'_t3

            * Define repeated deviation shocks
				gen 		tot_shockd2 = (`s1' < 0 & `s2' < 0)
				gen 		tot_shockd3 = (`s1' < 0 & `s2' < 0 & `s3' < 0)

            * Interactions with moments
				gen 		shock1_mu2_s = tot_shockd2 * mu2_s
				gen 		shock2_mu2_s = tot_shockd3 * mu2_s
				gen 		shock1_mu3_s = tot_shockd2 * mu3_s
				gen 		shock2_mu3_s = tot_shockd3 * mu3_s
				gen 		shock1_mu2_f = tot_shockd2 * mu2_f
				gen 		shock2_mu2_f = tot_shockd3 * mu2_f
				gen 		shock1_mu3_f = tot_shockd2 * mu3_f
				gen 		shock2_mu3_f = tot_shockd3 * mu3_f

            * Define constraints
				constraint drop 1/20
				constraint 1  		[mu1_s]mu2_s = [mu1_f]mu2_f
				constraint 2  		[mu1_s]mu3_s = [mu1_f]mu3_f
				constraint 3  		[mu1_s]shock1_mu2_s = [mu1_f]shock1_mu2_f
				constraint 4  		[mu1_s]shock2_mu2_s = [mu1_f]shock2_mu2_f
				constraint 5  		[mu1_s]shock1_mu3_s = [mu1_f]shock1_mu3_f
				constraint 6  		[mu1_s]shock2_mu3_s = [mu1_f]shock2_mu3_f
				constraint 7  		[mu1_s]tot_shockd2 = [mu1_f]tot_shockd2
				constraint 8  		[mu1_s]tot_shockd3 = [mu1_f]tot_shockd3

            * Run Model 3
				bootstrap, reps(100) seed(2045): ///
				reg3 (mu1_s mu2_s mu3_s tot_shockd2 tot_shockd3 ///
					shock1_mu2_s shock2_mu2_s shock1_mu3_s shock2_mu3_s) ///
					(mu1_f mu2_f mu3_f tot_shockd2 tot_shockd3 ///
					shock1_mu2_f shock2_mu2_f shock1_mu3_f shock2_mu3_f), ///
					constraint(1 2 3 4 5 6 7 8) nolog

            * Drop temp vars
            drop mu1_s mu1_f mu2_s mu2_f mu3_s mu3_f
            drop tot_shockd2 tot_shockd3
            drop shock*_mu*
        }
    }
}
