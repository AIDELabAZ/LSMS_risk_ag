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
	global root 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_3"
	global root2 	"$data/lsms_base/countries/ethiopia"
	global export 	"$data/lsms_risk_ag_data/refined_data/ethiopia/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/ethiopia/logs"

* open log 
	cap log close 
	log using "$logout/wave3_rb_vars", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave3_clean", clear
	
	
* merge in clean com sec
	drop _merge
	merge m:1  manager_id_merge using "$root/wave3_rb_vars"

/*


    Result                      Number of obs
    -----------------------------------------
    Not matched                        55,259
        from master                    27,288  (_merge==1)
        from using                     27,971  (_merge==2)

    Matched                                 0  (_merge==3)
    -----------------------------------------


*/

	*save 		"$export/wave3_cleanrb", replace
