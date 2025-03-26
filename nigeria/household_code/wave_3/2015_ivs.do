* Project: lsms risk ag
* Created on: 25 Mar 2025
* Created by: reece
* Edited on: 26 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* merges all IVs
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/nigeria/wave_3/raw"
	global root2 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_3"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_3"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2015_ivs", append

	
* ***********************************************************************
**#1 - prepare nigeria 2015 - household geovariables
* ***********************************************************************

* load data
	use 		"$root/NGA_HouseholdGeovars_Y3", clear
	
	keep zone state lga sector ea hhid dist_road2 dist_popcenter2 dist_market
	
	rename		dist_road2 dist_road
	rename 		dist_popcenter2 dist_popcenter
	
* generate year
	gen year = 2015
	lab var year "year of survey- wv3 2015"

* merge in extension variable
	merge m:1 zone state lga sector ea hhid using "$root2/2015_secta5a_harvestw3"
	drop		_merge
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,707
        from master                     1,707  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             2,906  (_merge==3)
    -----------------------------------------

*/	

* create ea_id_merge for lsms_base merge
	gen 			str_lga = string(lga)
	gen 			str_ea = string(ea)
	gen 			ea_id_merge = str_lga + "-" + str_ea
	
* rename hhid for lsms_base merge
	gen 			hh_id_merge = string(hhid)

* prepare for export
	drop if			zone == .
	* 1 observation deleted
	isid			zone state lga sector ea_id_merge hh_id_merge
	describe
	summarize 
	save 			"$export/wave3_rb_vars.dta", replace
	

* close the log
	log	close

/* END */
	