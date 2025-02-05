* Project: lsms risk ag
* Created on: Feb 2025
* Created by: reece
* Edited on: 4 Feb 2025
* Edited by: reece
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
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave1_rb_vars", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave2_clean", clear
	
	
* merge in clean com sec
	merge m:1 manager_id_merge using "$root/wave2_rb_vars"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                         2,291
        from master                     1,559  (_merge==1)
        from using                        732  (_merge==2)

    Matched                            23,708  (_merge==3)
    -----------------------------------------

*/

* keep only merged
	keep if			_merge == 3
	drop			_merge
	
	save 		"$export/wave2_cleanrb", replace

	
* close the log
	log	close

/* END */