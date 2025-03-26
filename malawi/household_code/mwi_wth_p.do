* Project: lsms risk
* Created on: Aug 2020
* Created by: mcg
* Edited on: 25 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* adds weather data to mwi_complete_p

* assumes
	* xfill.ado

* TO DO:
	* complete

	
* **********************************************************************
* 0 - setup
* **********************************************************************
	
* define paths
	global root 	"$data/lsms_risk_ag_data/regression_data/malawi"
	global wth		"$data/lsms_base/weather"
	global export 	"$data/lsms_risk_ag_data/regression_data/malawi"
	global logout 	"$data/lsms_risk_ag_data/refined_data/malawi/logs"

* open log 
	cap log close 
	log using 		"$logout/mwi_complete_p", append

	
* **********************************************************************
* 1 - append data
* **********************************************************************

* import wave 1 dataset
	use 		"$root/mwi_complete_p", clear

	drop if 		wave  == . | hh_id_obs == . | plot_id_obs == . | crop_name == ""
	* 3,047 observations dropped
	
	*isid			wave hh_id_obs 
	
* **********************************************************************
* 2- clean harvest value
* **********************************************************************

* generate seed vars
	gen				isp = plot_area_GPS if improved == 1
	replace			isp = 0 if isp == .
			
* collapse to household level
	collapse (sum)	plot_area_GPS total_labor_days2 nitrogen_kg2 ///
					isp harvest_value_USD seed_kg2 harvest_kg ///
			 (max)	inorganic_fertilizer organic_fertilizer /// 
					irrigated used_pesticides extension ///
					crop_shock pests_shock rain_shock flood_shock livestock ///
			 (mean) hh_asset_index hh_electricity_access /// 
					dist_popcenter hh_shock totcons_USD2 /// 
					soil_fertility_index hh_size maize_ea_p, ///
			  by(year hh_id_obs wave country pw ea_id_merge ///
					ea_id_obs strataid urban admin_1 admin_2 ///
					hh_id_merge admin_3 dist_weekly dist_daily out_supply)
							
    isid hh_id_obs wave

* generate improved seed share
	replace			isp = isp/plot_area_GPS
	

	
* merge in weather data
	merge 1:1 		hh_id_obs wave using "$wth/weather"
/* 
 
    Result                      Number of obs
    -----------------------------------------
    Not matched                       112,953
        from master                         1  (_merge==1)
        from using                    112,952  (_merge==2)

    Matched                             8,141  (_merge==3)
    -----------------------------------------


*/ 
	keep if 	_merge == 3
	drop 		_merge

* drop missing plot area and households that only appear once
	drop if 	plot_area_GPS == 0
	
	duplicates 	tag hh_id_obs, generate(dup)
	drop if		dup == 0
	drop		dup
	*** dropped 1,791 non-panel households
	

* **********************************************************************
* 4 - end matter
* **********************************************************************

* save file
	qui: compress
	save 				"$export/mwi_complete_p_wth.dta", replace
	
* close the log
	log	close

/* END */
