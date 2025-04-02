* Project: lsms risk
* Created on: Aug 2020
* Created by: mcg
* Edited on: 26 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* reads in merged data sets
	* appends merged data sets
	* outputs appended nigeria panel with all five waves

* assumes
	* xfill.ado

* TO DO:
	* complete

	
* **********************************************************************
* 0 - setup
* **********************************************************************
	
* define paths
	global root 	"$data/lsms_risk_ag_data/merged_data/nigeria"
	global wth		"$data/lsms_base/weather"
	global export 	"$data/lsms_risk_ag_data/regression_data/nigeria"
	global logout 	"$data/lsms_risk_ag_data/merged_data/nigeria/logs"

* open log 
	cap log close 
	log using 		"$logout/nga_append_build", append

	
* **********************************************************************
* 1 - append data
* **********************************************************************

* import wave 1 dataset
	use 		"$root/wave_1/wave1_cleanrb.dta", clear

* append wave 2 dataset
	append		using "$root/wave_2/wave2_cleanrb.dta", force
	
* append wave 3 dataset
	append		using "$root/wave_3/wave3_cleanrb", force	
	
* append wave 4 dataset
	append		using "$root/wave_4/wave4_cleanrb", force	
	
* check the number of observations again
	count
	*** 44,158 observations 
	count if 		year == 2010
	*** wave 1 has 10,148
	count if 		year == 2012
	*** wave 2 has 10,399
	count if 		year == 2015
	*** wave 3 has 8,933
	count if 		year == 2018
	*** wave 4 has 14,678
	
	isid			wave hh_id_obs plot_id_obs crop_name
	
* **********************************************************************
* 2- clean harvest value
* **********************************************************************
	

* generate seed vars
	gen				isp = plot_area_GPS if improved == 1
	replace			isp = 0 if isp == .
			
* collapse to household level
	collapse (sum)	plot_area_GPS total_labor_days fert_kg ///
					isp harvest_value_USD seed_kg harvest_kg ///
			 (max)	inorganic_fertilizer organic_fertilizer /// 
					irrigated used_pesticides extension ///
					crop_shock pests_shock rain_shock flood_shock livestock ///
			 (mean) hh_asset_index hh_electricity_access /// 
					dist_popcenter dist_road dist_market hh_shock totcons_USD /// 
					soil_fertility_index hh_size maize_ea_p, ///
			  by(year hh_id_obs wave country pw ea_id_merge ///
					ea_id_obs strataid urban admin_1 admin_2 ///
					hh_id_merge admin_3)
							
    isid hh_id_obs wave

* generate improved seed share
	replace			isp = isp/plot_area_GPS
	
* merge in weather data
	merge 1:1 		hh_id_obs wave using "$wth/weather"
/* 
    Result                      Number of obs
    -----------------------------------------
    Not matched                       109,274
        from master                         0  (_merge==1)
        from using                    109,274  (_merge==2)

    Matched                            11,819  (_merge==3)
    -----------------------------------------

*/ 
	keep if 	_merge == 3
	drop 		_merge

* drop missing plot area and households that only appear once
	drop if 	plot_area_GPS == 0
	
	duplicates 	tag hh_id_obs, generate(dup)
	drop if		dup == 0
	drop		dup
	*** dropped 2,915 non-panel households
	

* **********************************************************************
* 4 - end matter
* **********************************************************************

* save file
	qui: compress
	save 				"$export/nga_complete.dta", replace
	
* close the log
	log	close

/* END */
