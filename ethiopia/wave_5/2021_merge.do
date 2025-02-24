* Project: lsms risk ag
* Created on: Feb 2025
* Created by: reece
* Edited on: 23 Feb 25
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
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_5"
	global root2 	"$data/lsms_base/countries/ethiopia"
	global export 	"$data/lsms_risk_ag_data/merged_data/ethiopia/wave_5"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave5_rb_vars", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave5_clean", clear
	
	drop		_merge
	
* merge in clean com sec
	merge m:1  manager_id_merge using "$root/wave5_rb_vars"


/*
 
    Result                      Number of obs
    -----------------------------------------
    Not matched                         2,529
        from master                     1,937  (_merge==1)
        from using                        592  (_merge==2)

    Matched                            10,018  (_merge==3)
    -----------------------------------------

*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	drop if			crop_name == ""
	
	isid			wave hh_id_obs plot_id_obs crop_name
	
	save 		"$export/wave5_cleanrb", replace

* close the log
	log	close

/* END */
