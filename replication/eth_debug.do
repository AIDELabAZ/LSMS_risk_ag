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

				
********************************************************************************
**# 2 - regressions using v07 only across rainfall metrics and weather sources
********************************************************************************


********************************************************************************
**## 2.1 - production function
********************************************************************************

            xtivreg std_y hh_size v05_rf2 i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p v05_rf2_t1), ///
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

            xtivreg std_e2 hh_size v05_rf2 i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p v05_rf2_t1), ///
                fe vce(cluster hh_id_obs)
				
            matrix 		a2 = e(b)
            scalar 		b2_f = a2[1,1]
            scalar 		b2_f2 = a2[1,2]
            scalar 		b2_s = a2[1,3]
            scalar 		b2_s2 = a2[1,4]
            scalar 		b2_fs = a2[1,5]
            gen 		mu2_s = b2_s + 2*b2_s2 * std_s + b2_fs * std_f
            gen 		mu2_f = b2_f + 2*b2_f2 * std_f + b2_fs * std_s

            xtivreg std_e3 hh_size v05_rf2 i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access dist_popcenter extension dist_weekly maize_ea_p v05_rf2_t1), ///
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

        * Constraint definitions
            constraint drop 1/20
            constraint 1 		[mu1_s]mu2_s = [mu1_f]mu2_f
            constraint 2 		[mu1_s]mu3_s = [mu1_f]mu3_f

         * Model 1
            eststo clear
            bootstrap, reps(10) seed(2045): ///
            reg3 (mu1_s mu2_s mu3_s) (mu1_f mu2_f mu3_f), ///
            constraint(1 2) nolog

            * Model 2
				gen 		mod_mu2_s = v07_rf2_t1 * mu2_s
				gen 		mod_mu3_s = v07_rf2_t1 * mu3_s
				gen 		mod_mu2_f = v07_rf2_t1 * mu2_f
				gen 		mod_mu3_f = v07_rf2_t1 * mu3_f

            * Constraint definitions
				constraint drop 1/20
				constraint 1 		[mu1_s]mu2_s = [mu1_f]mu2_f
				constraint 2 		[mu1_s]mu3_s = [mu1_f]mu3_f
				constraint 3 		[mu1_s]mod_mu2_s = [mu1_f]mod_mu2_f
				constraint 4 		[mu1_s]mod_mu3_s = [mu1_f]mod_mu3_f
				constraint 5 		[mu1_s]v07_rf2_t1 = [mu1_f]v07_rf2_t1

				bootstrap, reps(10) seed(2045): ///
				reg3 (mu1_s mu2_s mu3_s v07_rf2_t1 mod_mu2_s mod_mu3_s) ///
					(mu1_f mu2_f mu3_f v07_rf2_t1 mod_mu2_f mod_mu3_f), ///
				constraint(1 2 3 4 5) nolog

					* Model 3
					gen 		mod_mu2_s2 = v07_rf2_t2 * mu2_s
					gen 		mod_mu3_s2 = v07_rf2_t2 * mu3_s
					gen 		mod_mu2_f2 = v07_rf2_t2 * mu2_f
					gen 		mod_mu3_f2 = v07_rf2_t2 * mu3_f
			
					gen 		mod_mu2_s3 = v07_rf2_t3 * mu2_s
					gen 		mod_mu3_s3 = v07_rf2_t3 * mu3_s
					gen 		mod_mu2_f3 = v07_rf2_t3 * mu2_f
					gen 		mod_mu3_f3 = v07_rf2_t3 * mu3_f

					* Constraint definitions
					constraint 6 		[mu1_s]mod_mu2_s2 = [mu1_f]mod_mu2_f2
					constraint 7 		[mu1_s]mod_mu3_s2 = [mu1_f]mod_mu3_f2
					constraint 8 		[mu1_s]mod_mu2_s3 = [mu1_f]mod_mu2_f3
					constraint 9 		[mu1_s]mod_mu3_s3 = [mu1_f]mod_mu3_f3
					constraint 10 		[mu1_s]v07_rf2_t2 = [mu1_f]v07_rf2_t2
					constraint 11 		[mu1_s]v07_rf2_t3 = [mu1_f]v07_rf2_t3
			
					bootstrap, reps(10) seed(2045): ///
					reg3 (mu1_s mu2_s mu3_s v07_rf2_t1 mod_mu2_s mod_mu3_s ///
							v07_rf2_t2 mod_mu2_s2 mod_mu3_s2 v07_rf2_t3 mod_mu2_s3 mod_mu3_s3) ///
						(mu1_f mu2_f mu3_f v07_rf2_t1 mod_mu2_f mod_mu3_f ///
							v07_rf2_t2 mod_mu2_f2 mod_mu3_f2 v07_rf2_t3 mod_mu2_f3 mod_mu3_f3), ///
						constraint(1 2 3 4 5 6 7 8 9 10 11) nolog

