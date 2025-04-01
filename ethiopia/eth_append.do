* Project: lsms risk
* Created on: Aug 2020
* Created by: mcg
* Edited on: 28 Feb 25
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
	*** 82,434 observations 
	count if 		year == 2011
	*** wave 1 has 3,994
	count if 		year == 2013
	*** wave 2 has 25,511
	count if 		year == 2015
	*** wave 3 has 26,470
	count if 		year == 2018
	*** wave 4 has 13,831
	count if 		year == 2021
	*** wave 5 has 12,616
	
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
					soil_fertility_index hh_size v01_rf2 v01_rf2_t1 v02_rf2 /// 
					v03_rf2 v04_rf2 v05_rf2 v05_rf2_t1 v06_rf2 v07_rf2 /// 
					v07_rf2_t1 v07_rf2_t2 v07_rf2_t3 v08_rf2 v09_rf2 ///
					v09_rf2_t1 v09_rf2_t2 v09_rf2_t3 v10_rf2 v11_rf2 ///
					v11_rf2_t1 v11_rf2_t2 v11_rf2_t3 v12_rf2 v13_rf2 ///
					v13_rf2_t1 v13_rf2_t2 v13_rf2_t3 v14_rf2 v14_rf2_t1 ///
					v14_rf2_t2 v14_rf2_t3 v01_rf3 v01_rf3_t1 v02_rf3 v03_rf3 ///
					v04_rf3 v05_rf3 v05_rf3_t1 v06_rf3 v07_rf3 v07_rf3_t1 ///
					v07_rf3_t2 v07_rf3_t3 v08_rf3 v09_rf3 v09_rf3_t1 v09_rf3_t2 ///
					v09_rf3_t3 v10_rf3 v11_rf3 v11_rf3_t1 v11_rf3_t2 v11_rf3_t3 ///
					v12_rf3 v13_rf3 v13_rf3_t1 v13_rf3_t2 v13_rf3_t3 v14_rf3 ///
					v14_rf3_t1 v14_rf3_t2 v14_rf3_t3 v01_rf4 v01_rf4_t1 v02_rf4 ///
					v03_rf4 v04_rf4 v05_rf4 v05_rf4_t1 v06_rf4 v07_rf4 v07_rf4_t1 ///
					v07_rf4_t2 v07_rf4_t3 v08_rf4 v09_rf4 v09_rf4_t1 v09_rf4_t2 ///
					v09_rf4_t3 v10_rf4 v11_rf4 v11_rf4_t1 v11_rf4_t2 v11_rf4_t3 ///
					v12_rf4 v13_rf4 v13_rf4_t1 v13_rf4_t2 v13_rf4_t3 v14_rf4 ///
					v14_rf4_t1 v14_rf4_t2 v14_rf4_t3 maize_ea_p, ///
			  by(year hh_id_obs wave country pw ea_id_merge ///
					ea_id_obs strataid urban admin_1 admin_2 ///
					hh_id_merge admin_3 dist_weekly)
							
    isid hh_id_obs wave

* generate improved seed share
	replace			isp = isp/plot_area_GPS

* drop missing plot area and households that only appear once
	drop if 	plot_area_GPS == 0
	* 179 deleted
	duplicates 	tag hh_id_obs, generate(dup)
	drop if		dup == 0
	drop		dup
	*** dropped 1,407 non-panel households
	

* **********************************************************************
* 4 - end matter
* **********************************************************************

* save file
	qui: compress
	save 				"$export/eth_complete.dta", replace
	
* close the log
	log	close

/* END */
