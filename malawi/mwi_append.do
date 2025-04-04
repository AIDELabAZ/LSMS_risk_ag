* Project: lsms risk
* Created on: Aug 2020
* Created by: mcg
* Edited on: 3 Apr 2025
* Edited by: jdm
* Stata v.18

* does
	* reads in merged data sets
	* appends merged data sets
	* outputs appended malawi panel with all four waves


* assumes
	* xfill.ado

* TO DO:
	* complete

	
* **********************************************************************
* 0 - setup
* **********************************************************************
	
* define paths
	global root 	"$data/lsms_risk_ag_data/merged_data/malawi"
	global wth		"$data/lsms_base/weather"
	global export 	"$data/lsms_risk_ag_data/regression_data/malawi"
	global logout 	"$data/lsms_risk_ag_data/merged_data/malawi/logs"

* open log 
	cap log close 
	log using 		"$logout/mwi_append_build", append

	
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
	*** 35,947 observations 
	count if 		wave == 1
	*** wave 1 has 7,760
	count if 		wave ==2
	*** wave 2 has 11,716
	count if 		wave ==3
	*** wave 3 has 6,084
	count if 		wave ==4
	*** wave 4 has 10,387
	
	drop if 		wave  == . | hh_id_obs == . | plot_id_obs == . | crop_name == ""
	* 0 observations dropped
	
	isid			wave hh_id_obs plot_id_obs crop_name
	
* **********************************************************************
* 2- clean harvest value
* **********************************************************************

* generate seed vars
	gen				isp = plot_area_GPS if improved == 1
	replace			isp = 0 if isp == .
			
* collapse to household level
	collapse (sum)	plot_area_GPS fert_kg ///
					isp harvest_value_USD seed_kg harvest_kg ///
			 (max)	inorganic_fertilizer organic_fertilizer /// 
					irrigated used_pesticides extension ///
					crop_shock pests_shock rain_shock flood_shock livestock ///
			 (mean) hh_asset_index hh_electricity_access /// 
					dist_popcenter hh_shock totcons_USD /// 
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
    Not matched                       111,213
        from master                         2  (_merge==1)
        from using                    111,211  (_merge==2)

    Matched                             9,882  (_merge==3)
    -----------------------------------------

*/ 
	keep if 	_merge == 3
	drop 		_merge

* drop missing plot area and households that only appear once
	drop if 	plot_area_GPS == 0
	* 84 obs deleted
	duplicates 	tag hh_id_obs, generate(dup)
	drop if		dup == 0
	drop		dup
	*** dropped 1,447 non-panel households
	

* **********************************************************************
* 4 - end matter
* **********************************************************************

* save file
	qui: compress
	save 				"$export/mwi_complete.dta", replace
	
* close the log
	log	close

/* END */
