* Project: lsms risk ag
* Created on: 25 Mar 2025
* Created by: reece
* Edited on: 26 Mar 2025
* Edited by: reece
* Stata v.18

* does
	* cleans community data- daily and weekly market
	* outputs ea level data for merging with extension data
	
* assumes
	* access to all raw data

* TO DO:
	* done
	
	
* **********************************************************************
**#0 - setup
* **********************************************************************

* define paths
	global root 	"$data/raw_lsms_data/nigeria/wave_2/raw"
	global root2 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_2"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_2"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2012_ivs", append

	
* ***********************************************************************
**#1 - prepare nigeria 2012 - household geovariables
* ***********************************************************************

* load data
	use 		"$root/NGA_HouseholdGeovars_Y2", clear
	
	keep zone state lga sector ea hhid qa_type dist_road2 dist_popcenter2 dist_market
	
	rename		dist_road2 dist_road
	rename 		dist_popcenter2 dist_popcenter
	
* generate year
	gen year = 2012
	lab var year "year of survey- wv2 2012"

* merge in extension variable
	merge m:1 zone state lga sector ea hhid using "$root2/2012_secta5a_harvestw2"
	drop		_merge
	
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,174  (_merge==3)
    -----------------------------------------
*/	

* create ea_id_merge for lsms_base merge
	gen 			str_lga = string(lga)
	gen 			str_ea = string(ea)
	gen 			ea_id_merge = str_lga + "-" + str_ea
	
* rename hhid for lsms_base merge
	gen 			hh_id_merge = string(hhid)

* prepare for export
	isid			zone state lga sector ea_id_merge hh_id_merge
	describe
	summarize 
	save 			"$export/wave2_rb_vars.dta", replace
	

* close the log
	log	close

/* END */
	