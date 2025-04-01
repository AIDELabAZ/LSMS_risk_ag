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
	global root 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_2"
	global root2 	"$data/lsms_base/countries/nigeria"
	global export 	"$data/lsms_risk_ag_data/merged_data/nigeria/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/wave2_cleanrb", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/nga_allrounds_final_cprb_w", clear
	
	drop		_merge
	
	keep if wave == 2
	
* merge in clean com sec
	merge m:1  ea_id_merge hh_id_merge using "$root/wave2_rb_vars"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                           581
        from master                       378  (_merge==1)
        from using                        203  (_merge==2)

    Matched                            13,941  (_merge==3)
    -----------------------------------------

*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	*** 1,649 obs dropped
	
	drop if			harv_missing == 1
	*** 1,881 obs dropped
	
***********************************************************************
**# 2 - impute value of harvest
***********************************************************************

* replace outliers at top 5 percent
	gen				yield = harvest_value_USD/plot_area_GPS
	sum 			harvest_value_USD
	*** mean 432, sd 6458, max 463,300
	
	sum				yield, detail
	*** mean 1717, sd 15,165, max 1,324,236
	
	replace			harvest_value_USD = . if yield > `r(p95)' 
	* 740 changes made
	
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
	*** mean 256, sd 483, max 9108
	
	drop			yield
	gen				yield = harvest_value_USD/plot_area_GPS
	sum				yield
	*** mean 736, sd 961, max 5454
	
* replace the imputated variable
	replace 			harvest_value_USD = harvest_value_USD_1_
	*** 521 changes
	
	drop 				mi_miss harvest_value_USD_1_ yield
	
	
***********************************************************************
**# 3 - end matter
***********************************************************************
	
	isid		wave hh_id_obs ea_id_merge plot_id_merge crop_name
	
	save 		"$export/wave2_cleanrb", replace
	
* close the log
	log	close

/* END */