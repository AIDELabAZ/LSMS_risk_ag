* Project: lsms risk ag
* Created on: 1 Apr 2025
* Created by: reece
* Edited on: 23 Apr 2025
* Edited by: reece
* Stata v.18

* does
	* creates kdensity plots for nigeria

* assumes
	* cleaned, merged (weather), and appended (waves) data

	
********************************************************************************
**# 0 - setup
********************************************************************************

	global root   	"$data/lsms_risk_ag_data/regression_data/nigeria"
	global export 	"$data/lsms_risk_ag_data/results"
	global figures 	"$data/lsms_risk_ag_data/results/figures"
	global tables 	"$data/lsms_risk_ag_data/results/tables"
	global logout 	"$data/lsms_risk_ag_data/regression_data/logs"

	cap 	log 	close
	log 	using 	"$logout/model_comparisons_nga", replace


********************************************************************************
**# 1 - variable creation
********************************************************************************

	use 		"$root/nga_complete", clear
	
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
					
					
		* create squared rainfall variables	
	foreach v in `rain' {
			gen `v'_sq = `v'^2
	}					
					

********************************************************************************
**## 2.1 - kdensity for yield
********************************************************************************

			kdensity std_y
			* i'm wondering if this should be "kdensity mu1_f" instead? if we want mean?
	
            xtivreg std_y hh_size v01_rf2 v01_rf2_sq i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access extension dist_popcenter dist_road dist_market maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)
				
********************************************************************************
**## 2.2 - kdensity for variance
********************************************************************************
			
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

            xtivreg std_e2 hh_size v01_rf2 v01_rf2_sq i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access extension dist_popcenter dist_road dist_market maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)
		
            matrix 		a2 = e(b)
            scalar 		b2_f = a2[1,1]
            scalar 		b2_f2 = a2[1,2]
            scalar 		b2_s = a2[1,3]
            scalar 		b2_s2 = a2[1,4]
            scalar 		b2_fs = a2[1,5]
            gen 		mu2_s = b2_s + 2*b2_s2 * std_s + b2_fs * std_f
            gen 		mu2_f = b2_f + 2*b2_f2 * std_f + b2_fs * std_s
			
* create kdensity for variance
			kdensity 	mu2_f
			* we have two calulations for the moments, one for fert and seed. I just chose fert for now.
				

            xtivreg std_e3 hh_size v01_rf2 v01_rf2_sq i.year ///
                (std_f std_f2 std_s std_s2 std_fs = ///
                hh_electricity_access extension dist_popcenter dist_road dist_market maize_ea_p `t'), ///
                fe vce(cluster hh_id_obs)
				
            matrix 		a3 = e(b)
            scalar 		b3_f = a3[1,1]
            scalar 		b3_f2 = a3[1,2]
            scalar 		b3_s = a3[1,3]
            scalar 		b3_s2 = a3[1,4]
            scalar 		b3_fs = a3[1,5]
            gen 		mu3_s = b3_s + 2*b3_s2 * std_s + b3_fs * std_f
            gen 		mu3_f = b3_f + 2*b3_f2 * std_f + b3_fs * std_s

* create kdensity for skew
			kdensity 	mu3_f
				
	
log close
