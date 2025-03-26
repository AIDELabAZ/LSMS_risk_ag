* Project: lsms risk ag
* Created on: January 2025
* Created by: reece
* Edited on: 29 Jan 2025
* Edited by: reece
* Stata v.18

* does
	* merges community vars with lsms_base 
	
* assumes
	* access to all raw data
	* mdesc.ado
	* cleaned hh_seca.dta

* TO DO:
	* 
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_6"
	global root2 	"$data/lsms_base/countries/malawi"
	global export 	"$data/lsms_risk_ag_data/merged_data/malawi/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/wave4_rb_vars", append

	
* ***********************************************************************
**#1 -  load lsms_base then merge community vars
* ***********************************************************************

	use 		"$root2/wave4_clean", clear
	
	
* merge in community variables
	drop _merge
	merge m:1 ea_id_merge using "$root/com_sec"

/* 

    Result                      Number of obs
    -----------------------------------------
    Not matched                            69
        from master                        69  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            12,240  (_merge==3)
    -----------------------------------------

*/ 
* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	*** 751 obs dropped
	
	drop if			harv_missing == 1
	*** 1,102 obs dropped
	
	
***********************************************************************
**# 2 - impute value of harvest
***********************************************************************

* replace outliers at top 5 percent
	gen				yield = harvest_value_USD/plot_area_GPS
	sum 			harvest_value_USD
	*** mean 83, sd 2084, max 147,636
	
	sum				yield, detail
	*** mean 548, sd 19798, max 1,737,222
	
	replace			harvest_value_USD = . if yield > `r(p95)' 
	* 488 changes made
	
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
	*** mean 35, sd 86, max 2450
	
	drop			yield
	gen				yield = harvest_value_USD/plot_area_GPS
	sum				yield
	*** mean 122, sd 155, max 760
	
* replace the imputated variable
	replace 			harvest_value_USD = harvest_value_USD_1_
	*** 1,450 changes
	
	drop 				mi_miss harvest_value_USD_1_ yield
	
***********************************************************************
**# 3 - end matter
***********************************************************************
	isid		wave hh_id_obs plot_id_obs crop_name	
	
	save 		"$export/wave4_cleanrb", replace
	
* close the log
	log	close

/* END */

