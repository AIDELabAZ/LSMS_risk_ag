* Project: lsms risk ag
* Created on: January 2025
* Created by: reece
* Edited on: 26 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* merges IVs with lsms_base 
	
* assumes
	* access to all raw data
	* mdesc.ado
	* cleaned hh_seca.dta

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_1"
	global root2 	"$data/lsms_base/countries/nigeria"
	global export 	"$data/lsms_risk_ag_data/merged_data/nigeria/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/wave1_cleanrb", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/nga_allrounds_final_cprb_w", clear
	
	drop		_merge
	
	keep if wave == 1
	
* merge in clean com sec
	merge m:1  ea_id_merge hh_id_merge using "$root/wave1_rb_vars"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            14,661  (_merge==3)
    -----------------------------------------

*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	*** 2,015 obs dropped
	
	drop if			harv_missing == 1
	*** 2,478 obs dropped
	
***********************************************************************
**# 2 - impute value of harvest
***********************************************************************

* replace outliers at top 5 percent
	gen				yield = harvest_value_USD/plot_area_GPS
	sum 			harvest_value_USD
	*** mean 384, sd 2577, max 167,494
	
	sum				yield, detail
	*** mean 46,072, sd 2,533,997, max 2.24e+08
	
	replace			harvest_value_USD = . if yield > `r(p95)' 
	* 860 changes made
	
* impute 
	mi set 			wide 	// declare the data to be wide.
	mi xtset		, clear 	// clear any xtset that may have had in place previously
	
	mi register			imputed harvest_value_USD // identify harv vle variable to be imputed
	sort				hh_id_obs plot_id_obs parcel_id_obs cropid, stable // sort to ensure reproducability of results
	mi impute 			pmm harvest_value_USD i.admin_2 plot_area_GPS i.cropid, add(1) rseed(245780) ///
								noisily dots force knn(5) bootstrap					
**# Bookmark #1
	mi 				unset	
	
* inspect imputation 
	sum 			harvest_value_USD_1_
	*** mean 263, sd 496, max 11,724
	
	drop			yield
	gen				yield = harvest_value_USD/plot_area_GPS
	sum				yield
	*** mean 1,158, sd 2,036, max 12,936
	
* replace the imputated variable
	replace 			harvest_value_USD = harvest_value_USD_1_
	*** 500 changes
	
	drop 				mi_miss harvest_value_USD_1_ yield
	
	
***********************************************************************
**# 3 - end matter
***********************************************************************
	bysort 			wave hh_id_obs ea_id_merge plot_id_obs crop_name: gen dup_check = _N
	tab 			dup_check
	list 			wave hh_id_obs ea_id_merge plot_id_obs crop_name if dup_check > 1
	duplicates drop wave hh_id_obs ea_id_merge plot_id_obs crop_name, force
	* 1 observation deleted
	
	isid			wave hh_id_obs ea_id_merge plot_id_merge crop_name
	
	save 		"$export/wave1_cleanrb", replace
	
* close the log
	log	close

/* END */