* Project: lsms risk
* Created on: Aug 2020
* Created by: mcg
* Edited on: 23 Feb 25
* Edited by: jdm
* Stata v.18

* does
	* reads in merged data sets
	* appends merged data sets
	* outputs appended ethiopia panel with all five waves


* assumes
	* xfill.ado

* TO DO:
	* complete

	
* **********************************************************************
* 0 - setup
* **********************************************************************
	
* define paths
	global root 	"$data/lsms_risk_ag_data/merged_data/ethiopia"
	global wth		"$data/lsms_base/weather"
	global export 	"$data/lsms_risk_ag_data/regression_data/ethiopia"
	global logout 	"$data/lsms_risk_ag_data/merged_data/ethiopia/logs"

* open log 
	cap log close 
	log using 		"$logout/eth_append_build", append

	
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
	
* append wave 5 dataset
	append		using "$root/wave_5/wave5_cleanrb", force	
	
* check the number of observations again
	count
	*** 77,552 observations 
	count if 		year == 2011
	*** wave 1 has 6,988
	count if 		year == 2013
	*** wave 2 has 23,708
	count if 		year == 2015
	*** wave 3 has 24,023
	count if 		year == 2018
	*** wave 4 has 12,815
	count if 		year == 2021
	*** wave 5 has 10,018
	
	isid			wave hh_id_obs plot_id_obs crop_name
	
* **********************************************************************
* 2- collapse to hh
* **********************************************************************

* drop all non-maize crops
	keep if 		crop_name == "MAIZE"
	*66,613 dropped
	
* collapse to plot level
	collapse (sum)	plot_area_GPS total_labor_days2 nitrogen_kg2 ///
					seed_kg2 harvest_kg2 ///
			 (max)	inorganic_fertilizer organic_fertilizer /// 
			 irrigated used_pesticides improved extension ///
			 crop_shock pests_shock rain_shock flood_shock livestock, ///
						by(hh_asset_index hh_electricity_access /// 
						dist_popcenter hh_shock totcons_USD2 /// 
						soil_fertility_index hh_size year ///
						country wave crop_name pw ea_id_merge ///
						ea_id_obs strataid urban admin_1 admin_2 ///
						hh_id_obs hh_id_merge admin_3 dist_weekly)
							
    isid hh_id_obs wave

* merge in weather data
	merge 1:1 		hh_id_obs wave using "$wth/weather"
	/* 
    Result                      Number of obs
    -----------------------------------------
    Not matched                       114,853
        from master                         2  (_merge==1)
        from using                    114,851  (_merge==2)

    Matched                             6,242  (_merge==3)
    -----------------------------------------
*/ 
	keep if 	_merge == 3
	drop 		_merge


* **********************************************************************
* 4 - end matter
* **********************************************************************

* save file
	qui: compress
	save 				"$export/eth_complete.dta", replace
	
* close the log
	log	close

/* END */
