* Project: lsms risk ag
* Created on: Feb 2025
* Created by: reece
* Edited on: 28 Feb 25
* Edited by: jdm
* Stata v.18

* does
	* merges community vars with lsms_base 
	
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
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_2"
	global root2 	"$data/lsms_base/countries/ethiopia"
	global export 	"$data/lsms_risk_ag_data/merged_data/ethiopia/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave1_rb_vars", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/eth_allrounds_final_cprb_w", clear
	
	drop		_merge
	
	keep if wave == 2
* merge in clean com sec
	merge m:1 manager_id_merge using "$root/wave2_rb_vars"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         4,417
        from master                     3,685  (_merge==1)
        from using                        732  (_merge==2)

    Matched                            23,723  (_merge==3)
    -----------------------------------------
*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	*** one obs dropped
	
	drop if			harv_missing == 1
	*** 1,746 obs dropped
	
	
***********************************************************************
**# 2 - impute value of harvest
***********************************************************************

* replace outliers at top 5 percent
	gen				yield = harvest_value_USD/plot_area_GPS
	sum 			harvest_value_USD
	*** mean 72, sd 457, max 30,958
	
	sum				yield, detail
	*** mean 6,250, sd 429,935, max 6.11e+07
	
	replace			harvest_value_USD = . if yield > `r(p95)' 
	* 1,539 changes made
	
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
	*** mean 55, sd 155, max 7,144
	
	drop			yield
	gen				yield = harvest_value_USD/plot_area_GPS
	sum				yield
	*** mean 547, sd 724, max 4,586
	
* replace the imputated variable
	replace 			harvest_value_USD = harvest_value_USD_1_
	*** 1,356 changes
	
	drop 				mi_miss harvest_value_USD_1_ yield
	
	
***********************************************************************
**# 3 - end matter
***********************************************************************

	isid			wave hh_id_obs plot_id_obs crop_name
	
	save 		"$export/wave2_cleanrb", replace

	
* close the log
	log	close

/* END */