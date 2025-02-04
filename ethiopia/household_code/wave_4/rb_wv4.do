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
	* 
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_4"
	global root2 	"$data/lsms_base/countries/ethiopia"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave4_rb_vars", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave4_clean", clear
	
	
* merge in clean com sec
	drop _merge
	merge m:1  manager_id_merge using "$root/wave4_rb_vars"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                         6,399
        from master                     5,491  (_merge==1)
        from using                        908  (_merge==2)

    Matched                            12,973  (_merge==3)
    -----------------------------------------

*/
	*manager id works, is this merge good enough?
	
	save 		"$export/wave4_cleanrb", replace
