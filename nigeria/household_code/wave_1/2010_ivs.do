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
	global root 	"$data/raw_lsms_data/nigeria/wave_1/raw"
	global root2 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_1"
	global export 	"$data/lsms_risk_ag_data/refined_data/nigeria/wave_1"
	global logout 	"$data/lsms_risk_ag_data/refined_data/nigeria/logs"

* open log 
	cap log close 
	log using "$logout/2010_ivs", append

	
* ***********************************************************************
**#1 - prepare nigeria 2010 - household geovariables
* ***********************************************************************

* load data
	use 		"$root/NGA_HouseholdGeovariables_Y1", clear
	
	keep zone state lga sector ea hhid lat_dd_mod lon_dd_mod qa_type dist_road dist_popcenter dist_market

* generate year
	gen year = 2011
	lab var year "year of survey- wv1 2011"

* merge in extension variable
	merge m:1 zone state lga sector ea hhid using "$root2/2010_secta5a_harvestw1"
	drop			_merge
	
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                         4,725
        from master                     4,725  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               275  (_merge==3)
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
	save 			"$export/wave1_rb_vars.dta", replace
	

* close the log
	log	close

/* END */
	