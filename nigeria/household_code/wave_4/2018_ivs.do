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
	global root 	"$data/raw_lsms_data/nigeria/wave_4/raw"
	global root2 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_4"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_4"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2018_ivs", append

	
* ***********************************************************************
**#1 - prepare nigeria 2018 - household geovariables
* ***********************************************************************

* load data
	use 		"$root/NGA_HouseholdGeovars_Y4", clear
	
	keep  hhid dist_road2 dist_popcenter2 dist_market
	
	rename		dist_road2 dist_road
	rename 		dist_popcenter2 dist_popcenter
	
* generate year
	gen year = 2018
	lab var year "year of survey- wv4 2018"

* merge in extension variable
	merge m:1  hhid using "$root2/2018_secta5a_harvestw4"
	drop		_merge
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,660
        from master                     1,660  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             3,456  (_merge==3)
    -----------------------------------------
*/	
	
* rename hhid for lsms_base merge
	gen 			hh_id_merge = string(hhid)
	
* prepare for export
	isid			hhid
	describe
	summarize 
	save 			"$export/wave4_rb_vars.dta", replace
	

* close the log
	log	close

/* END */
	