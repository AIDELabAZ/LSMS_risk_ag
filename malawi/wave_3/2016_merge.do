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
	global root 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_3"
	global root2 	"$data/lsms_base/countries/malawi"
	global export 	"$data/lsms_risk_ag_data/merged_data/malawi/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/wave3_rb_vars", append

	
* ***********************************************************************
**#1 -  load lsms_base then merge community vars
* ***********************************************************************

	use 		"$root2/mwi_allrounds_final_cprb_w", clear
	
	keep if wave == 3
	
	
* merge in community variables
	drop _merge
	merge m:1 ea_id_merge using "$root/com_sec"

/* 
   Result                      Number of obs
    -----------------------------------------
    Not matched                         8,404
        from master                     7,650  (_merge==1)
        from using                        754  (_merge==2)

    Matched                               155  (_merge==3)
    -----------------------------------------

. 

*/
	* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	*** 3 obs dropped
	
	drop if			harv_missing == 1
	*** 15 obs dropped
	
	
***********************************************************************
**# 2 - impute value of harvest
***********************************************************************

* replace outliers at top 5 percent
	gen				yield = harvest_value_USD/plot_area_GPS
	sum 			harvest_value_USD
	*** mean 18, sd 32, max 229
	
	sum				yield, detail
	*** mean 80, sd 143, max 972
	
	replace			harvest_value_USD = . if yield > `r(p95)' 
	* 14 changes made
	
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
	*** mean 15, sd 29, max 229
	
	drop			yield
	gen				yield = harvest_value_USD/plot_area_GPS
	sum				yield
	*** mean 56, sd 85, max 378
	
* replace the imputated variable
	replace 			harvest_value_USD = harvest_value_USD_1_
	*** 6 changes
	
	drop 				mi_miss harvest_value_USD_1_ yield
	
***********************************************************************
**# 3 - end matter
***********************************************************************
	isid		wave hh_id_obs plot_id_obs crop_name	
	
	save 		"$export/wave3_cleanrb", replace
	
* close the log
	log	close

/* END */

	