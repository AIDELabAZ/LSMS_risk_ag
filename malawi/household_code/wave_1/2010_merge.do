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
	global root 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_1"
	global root2 	"$data/lsms_base/countries/malawi"
	global export 	"$data/lsms_risk_ag_data/refined_data/malawi/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/wave1_rb_vars", append

	
* ***********************************************************************
**#1 - load lsms_base then merge community vars
* ***********************************************************************

* load data- starting with extension
	use 		"$root2/wave1_clean", clear
	
	
* merge in clean malawi data
	drop _merge
	merge m:1 ea_id_merge using "$root/com_sec"

/*    Result                      Number of obs
    -----------------------------------------
    Not matched                           564
        from master                         0  (_merge==1)
        from using                        564  (_merge==2)

    Matched                             9,428  (_merge==3)
    -----------------------------------------

*/

	save 		"$root2/wave1_cleanrb", replace
