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
	global root 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_3"
	global root2 	"$data/lsms_base/countries/nigeria"
	global export 	"$data/lsms_risk_ag_data/merged_data/nigeria/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/wave3_cleanrb", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave3_clean", clear
	
	drop		_merge
	
* merge in clean com sec
	merge m:1  ea_id_merge hh_id_merge using "$root/wave3_rb_vars"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           998
        from master                       659  (_merge==1)
        from using                        339  (_merge==2)

    Matched                            13,133  (_merge==3)
    -----------------------------------------
*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	*** 1,569 obs dropped
	
	drop if			harv_missing == 1
	*** 2,545 obs dropped
	
***********************************************************************
**# 2 - impute value of harvest
***********************************************************************

* replace outliers at top 5 percent
	gen				yield = harvest_value_USD/plot_area_GPS
	sum 			harvest_value_USD
	*** mean 369, sd 1507, max 113,127
	
	sum				yield, detail
	*** mean 2991, sd 22,173, max 901,617
	
	replace			harvest_value_USD = . if yield > `r(p95)' 
	* 511 changes made
	
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
	*** mean 275, sd 485, max 8908
	
	drop			yield
	gen				yield = harvest_value_USD/plot_area_GPS
	sum				yield
	*** mean 968, sd 1392, max 8064
	
* replace the imputated variable
	replace 			harvest_value_USD = harvest_value_USD_1_
	*** 543 changes
	
	drop 				mi_miss harvest_value_USD_1_ yield
	
	
***********************************************************************
**# 3 - end matter
***********************************************************************
	bysort 			wave hh_id_obs ea_id_merge plot_id_obs crop_name: gen dup_check = _N
	tab 			dup_check
	list 			wave hh_id_obs ea_id_merge plot_id_obs crop_name if dup_check > 1
	duplicates drop wave hh_id_obs ea_id_merge plot_id_obs crop_name, force
	* 75 observations dropped
	
	isid		wave hh_id_obs ea_id_merge plot_id_merge crop_name
	
	save 		"$export/wave3_cleanrb", replace
	
* close the log
	log	close

/* END */